//
//  ChatroomViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/10.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

class ChatroomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uid: String?
    var chatroomUid: String?
    public var destinationUid: String?
    
    var destinationUserModel: UserModel?
    var comments: [ChatModel.Comment] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        
//        debugPrint("debugPrint 29")
        DidCreateChatroom()
//        debugPrint("debugPrint 31")
        self.tabBarController?.tabBar.isHidden = true // 탭바 사라짐
        
        // MARK: 바깥을 누르면 키보드가 사라짐
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        // NotificationCenter가 동작하는 방식
        // 1. 특정 객체가 NotificationCenter에 등록된 Event를 발생 (=Post)
        // 2. 해당 Event 처리가 등록된 Observer들이 등록된 행동을 취함
        self.tabBarController?.tabBar.isHidden = false
    }
  
    @objc func keyboardWillAppear(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeightConstraint.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            // MARK: 키보드 올라올 때 채팅방 내용을 맨 아래로 보여주기
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification)  {
        self.keyboardHeightConstraint.constant = 0
        self.view.layoutIfNeeded() // view의 변화를 동기적으로, 즉시 반영 요청
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.comments[indexPath.row].uid == uid {
             let view = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as! MyMessageCell
            view.messageLabel.text = self.comments[indexPath.row].message
            view.messageLabel.numberOfLines = 0 // MARK: 이렇게 해야 여러 줄 나올 수 있다?
            return view
        } else {
            let view = tableView.dequeueReusableCell(withIdentifier: "destinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.messageLabel.text = self.comments[indexPath.row].message
            view.messageLabel.numberOfLines = 0
            
            let url = URL(string: (self.destinationUserModel?.profileImageURL)!)!
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                DispatchQueue.main.async {
                    view.profileImageView.image = UIImage(data: data!)
                    view.profileImageView.layer.cornerRadius = view.profileImageView.frame.width/2
                    view.profileImageView.clipsToBounds = true
                }
            }.resume()
            return view
        }
    
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true) // 키보드 내리기
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func createChatroom(_ sender: Any) {
//        debugPrint("debugPrint 46")
        let chatroomInfo: Dictionary<String,Any> = [
            "users": [
                uid!: true,
                destinationUid!: true
            ]
        ]
//        debugPrint("debugPrint 53")
        // MARK: 방 생성
        // FIXME: else일 때만 comment 넘겨짐. nil일 때도 넘겨줘야.
        if chatroomUid == nil {
//            debugPrint("debugPrint 56")
            self.sendButton.isEnabled = false
//            debugPrint("debugPrint 58")
            Database.database().reference().child("chatrooms").childByAutoId().setValue(chatroomInfo, withCompletionBlock: { err,ref in
                if err == nil {
//                    debugPrint("debugPrint 61")
                    self.DidCreateChatroom()
//                    debugPrint("debugPrint 63")
                }
                self.sendButton.isEnabled = true
//                debugPrint("debugPrint 66")
            })
        } else {
//            debugPrint("debugPrint 69")
            let value: Dictionary<String,Any> = [
                "uid": uid!,
                "message": messageTextField.text!
            ]
//            debugPrint("debugPrint 74")
            Database.database().reference().child("chatrooms").child(chatroomUid!).child("comments").childByAutoId().setValue(value) { (err, ref) in
                // MARK: 메세지 보내고 나서 입력창 초기화
                self.messageTextField.text = ""
            }
//            debugPrint("debugPrint 76")
        }
    }
    
    func DidCreateChatroom() {
//        debugPrint("debugPrint 82")
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
//            debugPrint("debugPrint 84")
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
//                debugPrint("debugPrint 86")
                if let chatroomDic = item.value as? [String:AnyObject] {
//                    debugPrint("debugPrint 88")
                    let chatModel = ChatModel(JSON: chatroomDic);
//                    debugPrint("debugPrint 89 \(String(describing: chatModel?.users))")
                    if chatModel?.users[self.destinationUid!] == true {
//                        debugPrint("debugPrint 91\(item.key)")
                        self.chatroomUid = item.key
                        self.getDestinationInfo()
//                        debugPrint("debugPrint 94")
                    }
                }
            }
        }
    }
    
    func getMessageList() {
//        debugPrint("debugPrint 102")
        Database.database().reference().child("chatrooms").child(self.chatroomUid!).child("comments").observe(DataEventType.value){ (datasnapshot) in
            self.comments.removeAll() // 누적 방지
//            debugPrint("debugPrint 105")
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
//                debugPrint("debugPrint 107")
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                self.comments.append(comment!)
            }
            
            self.tableView.reloadData()
            
            // MARK: 메세지 내용 가져올 때 채팅방 내용을 맨 아래로 보여주기
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
//            debugPrint("debugPrint 113")
        }
    }
    

    
    func getDestinationInfo() {
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value) { datasnapshot in
            self.destinationUserModel = UserModel()
            self.destinationUserModel?.setValuesForKeys(datasnapshot.value as! [String:Any])
            self.getMessageList()
        }
    }
    
//    FIXME: 테이블 내의 셀을 NIB으로 Destination 데이터(profile image, uid) 받을 때도 extension이나 protocol 등 고려해보기
//    TODO: 메소드나 클래스, 프로퍼티 등 순서 정리
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
}

class DestinationMessageCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
}

// MARK: 채팅방에서 상대 이름: 강의의 말풍선 만들기1
