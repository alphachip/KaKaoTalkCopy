//
//  MoreViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/30.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    @objc func printTestItem() {
        print("clickckckckckck")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "More"
        label.textAlignment = .left
        navigationItem.titleView = label
        //        view.addSubview(label)
        if let navigationBar = navigationController?.navigationBar {
            
            label.leadingAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
            label.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor, constant: 0).isActive = true
            //            label.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 0).isActive = true
            //            label.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0).isActive = true
            
            let searchFriendButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(printTestItem))
            let addFriendButton = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(printTestItem))
            let playMusicButton = UIBarButtonItem(image: UIImage(systemName: "music.note"), style: .plain, target: self, action: #selector(printTestItem))
            let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(printTestItem))
            
            navigationItem.rightBarButtonItems = [settingButton, playMusicButton, addFriendButton, searchFriendButton]
            
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
