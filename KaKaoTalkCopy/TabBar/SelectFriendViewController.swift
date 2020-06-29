//
//  SelectFriendViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/28.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox

class SelectFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BEMCheckBoxDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    
    var array: [UserModel] = []
    var users = Dictionary<String,Bool>()

    override func viewDidLoad() {
        super.viewDidLoad()

        Database.database().reference().child("users").observe(DataEventType.value) { (snapshot) in
            
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            //MARK: Read user info
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                
                if let dicItem = fchild.value as? [String : Any]{
                    userModel.setValuesForKeys(dicItem)
                    if userModel.uid != myUid {
                        self.array.append(userModel)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData();
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        view.nameLabel.text = array[indexPath.row].name
        view.profileImageView.kf.setImage(with: URL(string: array[indexPath.row].profileImageURL!))
        view.checkBox.delegate = self
        view.checkBox.tag = indexPath.row
        
        return view
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        if checkBox.on {
            users[self.array[checkBox.tag].uid!] = true
        } else {
            users.removeValue(forKey: self.array[checkBox.tag].uid!)
        }
    }
    
    @IBAction func createRoom(_ sender: Any) {
        let myUid = Auth.auth().currentUser?.uid
        users[myUid!] = true
        let nsDic = users as NSDictionary
        
        Database.database().reference().child("chats").childByAutoId().child("users").setValue(nsDic)
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

class SelectFriendCell: UITableViewCell {
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
}
