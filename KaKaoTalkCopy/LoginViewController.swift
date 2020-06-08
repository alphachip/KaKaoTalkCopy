//
//  LoginViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/06.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var signIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.right.top.left.equalTo(self.view)
        }
        // Do any additional setup after loading the view.
        
        signIn.addTarget(self, action: #selector(presentSignUp), for: .touchUpInside)
    }
    
    @objc func presentSignUp() {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        self.present(view, animated: true, completion: nil)
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
