//
//  ProfileViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/30.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    public var destinationUid: String?
    
    @objc func printTestItem() {
        print("clickckckckckck")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Custom navigation-bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: nil, action: #selector(btnButtonClicked(_:)))
        
        let giftButton = UIBarButtonItem(image: UIImage(systemName: "gift"), style: .plain, target: self, action: #selector(printTestItem))
        
        
        if destinationUid == Auth.auth().currentUser?.uid {
            let qrcodeButton = UIBarButtonItem(image: UIImage(systemName: "qrcode"), style: .plain, target: self, action: #selector(printTestItem))
            let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(printTestItem))
            
            navigationItem.rightBarButtonItems = [settingButton, qrcodeButton,  giftButton]
        }
        else {
            let wonButton = UIBarButtonItem(image: UIImage(systemName: "wonsign.circle"), style: .plain, target: self, action: #selector(printTestItem))
            let starButton = UIBarButtonItem(image: UIImage(systemName: "star.circle"), style: .plain, target: self, action: #selector(printTestItem))
            
            navigationItem.rightBarButtonItems = [wonButton, starButton, giftButton]
        }
        
    }
    
    @objc func btnButtonClicked(_ gesture : UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
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
