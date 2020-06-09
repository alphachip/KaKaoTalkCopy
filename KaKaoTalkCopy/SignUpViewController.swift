//
//  SignUpViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/07.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

//extension String: LocalizedError {
//    public var errorDescription: String? { return self }
//}

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupTextField: UIButton!
    @IBOutlet weak var cancelTextField: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        cancelTextField.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    enum SignUpAlertMsg : String {
        case emptyEmail = "Email is empty"
        case emptyPassword = "Password is empty"
        case emptyName = "Name is empty"
        case completedSignUp = "sign-up completed"
        case loadUid = "User cannot be loaded"
    }
    
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        profileImageView.image = info[.originalImage] as? UIImage
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpEvent(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else { self.displayOKAlert(err: nil, title: nil, msg: SignUpAlertMsg.emptyEmail.rawValue); return }
        guard let password = passwordTextField.text, !password.isEmpty else { self.displayOKAlert(err: nil, title: nil, msg: SignUpAlertMsg.emptyPassword.rawValue); return }
        guard let name = nameTextField.text, !name.isEmpty else { self.displayOKAlert(err: nil, title: nil, msg: SignUpAlertMsg.emptyName.rawValue); return }
        
        if email != "" && password != "" && name != "" {
            Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
                if let err = err {
                    self.displayOKAlert(err: err, title: nil, msg: err.localizedDescription)
                }
                else {
                    if let uid = user?.user.uid {
                    if let profile = self.profileImageView.image, let selectedProfile = profile.jpegData(compressionQuality: 0.1) {
                        
                        let storageRef = Storage.storage().reference().child("userImages").child(uid)
                        storageRef.putData(selectedProfile, metadata: nil, completion: { (data,err) in
                            
                            storageRef.downloadURL { url, err in
                                if err == nil, url == nil {
                                    Database.database().reference().child("users").child(uid).setValue(["name":name])
                                } else {
                                    Database.database().reference().child("users").child(uid).setValue(["name":name,"profileImageURL": url?.absoluteString])
                                }
                            }
                            
                            let alert = UIAlertController(title: "Welcome!", message: SignUpAlertMsg.completedSignUp.rawValue, preferredStyle: UIAlertController.Style.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                                self.cancelEvent()
                            }))
                            
                            self.present(alert, animated: true)
                            
                        })
                        
                    }
                    } else {
                        self.displayOKAlert(err: nil, title: nil, msg: SignUpAlertMsg.loadUid.rawValue)
                    }
                    
                }
            }
        }
    }
    
    @objc func cancelEvent() {
        self.dismiss(animated: true, completion: nil)
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
