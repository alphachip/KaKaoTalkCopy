//
//  ChatsViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/18.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var uid: String!
    var chats: [ChatModel]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uid = Auth.auth().currentUser?.uid
        self.getChatsList()
    }
    
    func getChatsList() {
        Database.database().reference().child("chats").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            self.chats.removeAll() //viewDidAppear() 때문에 갱신 됐을 때 데이터 쌓이지 않으려면 해줘야함
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                if let chatsdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatsdic)
                    self.chats.append(chatModel!)
                }
            }
            // MARK: 채팅 목록 테이블 뷰 업데이트
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rowCell", for: indexPath) as! CustomCell
        
        var destinationUid: String?
        
        // MARK: 상대방 가져오기
        for item in chats[indexPath.row].users {
            if (item.key != self.uid) { // key에 나와 상대의 uid가 있음
                destinationUid = item.key
            }
        }
        
        Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            // destinationUid로 DB의 users 안에 있는 userName을 가져옴
            let userModel = UserModel()
            userModel.setValuesForKeys(datasnapshot.value as! [String:AnyObject]) //1차는 쉽게 담을 수 있지만 2차, 3차원은 wrapper 사용해야.
            
            cell.nameLabel.text = userModel.name
            let url = URL(string: userModel.profileImageURL!)
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                // 스레드로 로딩. 지연되지 않도록함
                DispatchQueue.main.async {
                    cell.profileImageView.image = UIImage(data: data!)
                    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width/2
                    cell.profileImageView.layer.masksToBounds = true //원형으로
                }
            }.resume()
            
            let messageKey = self.chats[indexPath.row].comments.keys.sorted() { $0>$1 } // 오름차순. 내림차순은 부등호 반대로
            cell.messageLabel.text = self.chats[indexPath.row].comments[messageKey[0]]?.message
        }
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 이미지 갱신을 위해
        viewDidLoad()
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

class CustomCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
}
