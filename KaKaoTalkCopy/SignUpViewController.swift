//
//  SignUpViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/07.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

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
        profileImageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(ImagePicker)))
        
        cancelTextField.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func ImagePicker() {
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
        guard let email = emailTextField.text, !email.isEmpty else { print("Email is empty"); return }
        guard let password = passwordTextField.text, !password.isEmpty else { print("Password is empty"); return }
        guard let name = nameTextField.text, !name.isEmpty else { print("Name is empty"); return }
        
        if email != "" && password != "" && name != "" {
            Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
                if err == nil {
                    
                    if let profile = self.profileImageView.image, let selectedProfile = profile.jpegData(compressionQuality: 0.1) {
                        
                        let storageRef = Storage.storage().reference().child("userImages").child((user?.user.uid)!)
                        storageRef.putData(selectedProfile, metadata: nil, completion: { (data,err) in
                            
                            let imageURL = storageRef.downloadURL
                        })
                        
                    }
                    Database.database().reference().child("users").child((user?.user.uid)!).setValue(["name":name])
                    
                    let alert = UIAlertController(title: "Welcome!", message: "sign-up completed", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                        self.cancelEvent()
                    }))
                    
                    self.present(alert, animated: true)
                    
                } else {
                    print(err!)
                    let errMsg = err?.localizedDescription
                    let alert = UIAlertController(title: nil, message: errMsg, preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
                    
                    self.present(alert, animated: true, completion: nil)
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
