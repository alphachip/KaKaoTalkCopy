//
//  ChatroomViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/10.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

class ChatroomViewController: UIViewController {
    
    var uid: String?
    var chatroomUid: String?
    public var destinationUid: String?
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uid = Auth.auth().currentUser?.uid
        
        DidCreateChatroom()
    }
    
    @IBAction func createChatroom(_ sender: Any) {
        let chatroomInfo: Dictionary<String,Any> = [
            "users": [
                uid!: true,
                destinationUid!: true
            ]
        ]
        
        //MARK: 방 생성
        if chatroomUid == nil {
            self.sendButton.isEnabled = false
            Database.database().reference().child("chatrooms").childByAutoId().setValue(chatroomInfo, withCompletionBlock: { err,ref in
                if err == nil {
                    self.DidCreateChatroom()
                }
                self.sendButton.isEnabled = true
            })
        } else {
            let value: Dictionary<String,Any> = [
                "comments":[
                    "uid": uid!,
                    "message": messageTextField.text!
                ]
            ]
            Database.database().reference().child("chatrooms").child(chatroomUid!).child("comments").childByAutoId().setValue(value)
        }
        
    }
    
    func DidCreateChatroom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                if let chatroomDic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatroomDic)
                    if chatModel?.users[self.destinationUid!] == true {
                         self.chatroomUid = item.key
                    }
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
