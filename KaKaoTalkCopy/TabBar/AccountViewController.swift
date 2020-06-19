//
//  AccountViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/19.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    @IBOutlet weak var statusMessageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func showAlert(_ sender: Any) {
        let alertController = UIAlertController(title: "Status Message", message: nil, preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Enter a status message."
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let textfield = alertController.textFields?.first {
                let dic = ["message":textfield.text!]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
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
