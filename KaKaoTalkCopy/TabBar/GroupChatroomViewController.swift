//
//  GroupChatroomViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/28.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class GroupChatroomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var destinationRoom: String?
    var uid: String?
    
    var databaseRef: DatabaseReference?
    var observe: UInt?
    var comments: [ChatModel.Comment] = []
    var users: [String:AnyObject]?
    var peopleCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            self.users = datasnapshot.value as! [String:AnyObject]
        }
        
        getMessageList()
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let value: Dictionary<String,Any> = [
            "uid": uid!,
            "message": messageTextField.text!,
            "timestamp": ServerValue.timestamp()
        ]
        Database.database().reference().child("chats").child(destinationRoom!).child("comments").childByAutoId().setValue(value) {
            (err, ref) in
            
            Database.database().reference().child("chats").child(self.destinationRoom!).child("users").observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
                let dic = datasnapshot.value as! [String:Any] // chats>방토큰>user들 정보
                
                for item in dic.keys {
                    if item == self.uid {
                        continue
                    }
                    let user = self.users![item]
                    self.sendGCM(pushToken: user!["pushToken"] as! String)
                }
                self.messageTextField.text = ""
            }
        }
    }
    
    // 안 읽은 사람 인원 수
    func setReadCount(label: UILabel?, position: Int?) {
        let readCount = self.comments[position!].readUsers.count // 읽은 사람 수
        
        // 서버에 무리를 줄이기 위함
        if peopleCount == nil {
            Database.database().reference().child("chats").child(destinationRoom!).child("users").observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
                let dic = datasnapshot.value as! [String:Any]
                self.peopleCount = dic.count
                let noReadCount = self.peopleCount! - readCount
                
                if noReadCount > 0 {
                    label?.isHidden = false
                    label?.text = String(noReadCount)
                } else {
                    label?.isHidden = true
                }
            }
        } else {
            let noReadCount = self.peopleCount! - readCount
            
            if noReadCount > 0 {
                label?.isHidden = false
                label?.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
        }
    }
    
    func sendGCM(pushToken: String?) {
        // docs: https://firebase.google.com/docs/cloud-messaging/http-server-ref
        let url = "https://fcm.googleapis.com/fcm/send"
        let header: HTTPHeaders = [
            "Content-Type":"application/json",
            "Authorization":"key=AAAAzxCVcf8:APA91bHZA95ywGesIJbRTsG6l4yaxuZc8c4Kv3y3VEyLyE3zahdfMPPiVlhKi3SXb8yMkfCnUrADRE6rNJE8wOulnTvVMFxs0jLxDyomkJBz_9wE_IhyIlJfEFp3E0vWcuBZg3PWCPgf"
        ]
        
        let notificationModel = NotificationModel()
        notificationModel.to = pushToken!
        notificationModel.notification.title = "보낸 이 아이디"
        notificationModel.notification.text = messageTextField.text
        
        let params = notificationModel.toJSON()
        
        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: header).responseJSON { (response) in
                    do {
                        try print(response.result.get())
                    } catch {
                        print(error)
                    }
        }
    }
    
    func getMessageList() {
        //        debugPrint("debugPrint 102")
        databaseRef = Database.database().reference().child("chats").child(self.destinationRoom!).child("comments")
        observe = databaseRef?.observe(DataEventType.value){ (datasnapshot) in
            self.comments.removeAll() // 누적 방지
            //            debugPrint("debugPrint 105")
            var readUserDic: Dictionary<String,AnyObject> = [:]
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                //                debugPrint("debugPrint 107")
                let key = item.key as String
                // 마지막 메세지 읽었는지 보고.  comment 분기 처리. 1: comments. 2: readuserdic
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                let comment_motify = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                comment_motify?.readUsers[self.uid!] = true
                readUserDic[key] = (comment_motify?.toJSON())! as NSDictionary // firebase는 NSDictionary를 지원
                self.comments.append(comment!)
            }
            let nsDic = readUserDic as NSDictionary
            
            if self.comments.last?.readUsers.keys == nil {
                return
            }
            
            if !(self.comments.last?.readUsers.keys.contains(self.uid!))! { // 읽는 것 체크인데 채팅방을 방금 만들어서 코멘트 없을 때 에러날 수 있으므로 바로 위 if문에서 nil 체크.
                // 업데이트
                datasnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any]) { (err, ref) in
                    // 업데이트 성공하면 데이터 리로드
                    self.tableView.reloadData()
                    
                    // MARK: 메세지 내용 가져올 때 채팅방 내용을 맨 아래로 보여주기
                    if self.comments.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                    }
                    //            debugPrint("debugPrint 113")
                }
            } else {
                // 업데이트 된 거 표현만 해줌
                self.tableView.reloadData()
                
                // MARK: 메세지 내용 가져올 때 채팅방 내용을 맨 아래로 보여주기
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.comments[indexPath.row].uid == uid {
            let view = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as! MyMessageCell
            view.messageLabel.text = self.comments[indexPath.row].message
            view.messageLabel.numberOfLines = 0 // MARK: 이렇게 해야 여러 줄 나올 수 있다?
            
            if let time = self.comments[indexPath.row].timestamp {
                view.timestampLabel.text = time.toDayTime
            }
            
            setReadCount(label: view.readCounterLabel, position: indexPath.row)
            
            return view
        } else {
            let destinationUser = users![self.comments[indexPath.row].uid!]
            let view = tableView.dequeueReusableCell(withIdentifier: "destinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.nameLabel.text = destinationUser!["name"] as! String
            view.messageLabel.text = self.comments[indexPath.row].message
            view.messageLabel.numberOfLines = 0
            let imageURL = destinationUser!["profileImageURL"] as! String
            let url = URL(string: imageURL )
            view.profileImageView.layer.cornerRadius = view.profileImageView.frame.width/2
            view.profileImageView.clipsToBounds = true
            view.profileImageView.kf.setImage(with: url)
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                DispatchQueue.main.async {
                    view.profileImageView.image = UIImage(data: data!)
                }
            }.resume()
            
            if let time = self.comments[indexPath.row].timestamp {
                view.timestampLabel.text = time.toDayTime
            }
            
            setReadCount(label: view.readCounterLabel, position: indexPath.row)
            
            return view
        }
    }
}
