//
//  MainViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/09.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var array: [UserModel] = []
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (m) in
            m.top.equalTo(view)
            m.bottom.left.right.equalTo(view)
        }
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let imageView = UIImageView()
        
        cell.addSubview(imageView)
        
        imageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell).offset(10)
            m.height.width.equalTo(50)
        }
        
        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageURL!)!) { (data, response, err) in
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!)
                imageView.layer.cornerRadius = imageView.frame.size.width/2
                imageView.clipsToBounds = true
            }
            
        }.resume()
        
        let label = UILabel()
        cell.addSubview(label)
        label.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(imageView.snp.right).offset(20)
        }
        
        label.text = array[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let view = self.storyboard?.instantiateViewController(identifier: "ChatroomViewController") as? ChatroomViewController {
            view.destinationUid = self.array[indexPath.row].uid
            
            self.navigationController?.pushViewController(view, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
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
