//
//  ProfileTabBarController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/30.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

class ProfileTabBarController: UITabBarController {
    
    public var destinationUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = UIColor.clear // TabBar 의 배경 색
        //        tabBar.tintColor = UIColor.purple // TabBar Item 이 선택되었을때의 색
        tabBar.unselectedItemTintColor = UIColor.black // TabBar Item 의 기본 색
        
        if destinationUid == Auth.auth().currentUser?.uid {
            
            let myChatroomViewController = UINavigationController(rootViewController: ChatroomViewController(destinationUid: destinationUid))
            myChatroomViewController.tabBarItem.image = UIImage(systemName: "message.fill")
            myChatroomViewController.tabBarItem.title = "My Chatroom"
            let editProfileViewController = UINavigationController(rootViewController: ChatroomViewController(destinationUid: destinationUid))
            editProfileViewController.tabBarItem.image = UIImage(systemName: "pencil")
            editProfileViewController.tabBarItem.title = "Edit Profile"
            
            viewControllers = [myChatroomViewController, editProfileViewController]
        } else {
            let freeChatViewController = UINavigationController(rootViewController: ChatroomViewController(destinationUid: destinationUid))
            freeChatViewController.tabBarItem.image = UIImage(named: "Fourth")
            freeChatViewController.tabBarItem.title = "Free Chat"
            
            let callViewController = UINavigationController(rootViewController: ChatroomViewController(destinationUid: destinationUid))
            callViewController.tabBarItem.image = UIImage(named: "message.fill")
            callViewController.tabBarItem.title = "Chat"
            
            viewControllers = [freeChatViewController, callViewController]
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


