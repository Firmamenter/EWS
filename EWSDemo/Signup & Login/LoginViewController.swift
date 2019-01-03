//
//  LoginViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/20/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class LoginViewController: UIViewController {
    var ref : DatabaseReference?

    @IBOutlet weak var emailText: UITextField! {
        didSet {
            emailText.setIcon(UIImage(named: "EmailIcon")!)
        }
    }
    @IBOutlet weak var pwdText: UITextField! {
        didSet {
            pwdText.setIcon(UIImage(named: "PasswordIcon")!)
        }
    }
    @IBOutlet weak var logInBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        
        ref = Database.database().reference()
        hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        emailText.resignFirstResponder()
        pwdText.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func uiSetup() {
        emailText.layer.borderWidth = 1
        emailText.layer.masksToBounds = true
        emailText.layer.borderColor = UIColor.white.cgColor
        emailText.layer.cornerRadius = 24
        pwdText.layer.borderWidth = 1
        pwdText.layer.masksToBounds = true
        pwdText.layer.borderColor = UIColor.white.cgColor
        pwdText.layer.cornerRadius = 24
        logInBtn.layer.masksToBounds = true
        logInBtn.layer.cornerRadius = 24
    }

    @IBAction func login(_ sender: UIButton) {
        self.dismissKeyboard()
        if checkInput() {
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: emailText.text!, password: pwdText.text!) { (result, error) in
                if error == nil {
                    guard let user = result?.user else {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.failureAlert(msg : "Log in")
                        }
                        return
                    }
                    self.fetchUserInfo(usr : user)
                } else {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.failureAlert(msg: "Log in")
                    }
                }
            }
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forgetPwd(_ sender: UIButton) {
        self.dismissKeyboard()
        let email = emailText.text
        guard !((email?.isEmpty)!) else {
            emptyAlert(msg : "Email")
            return
        }
        SVProgressHUD.show()
        Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.failureAlert(msg: "Reset password")
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func checkInput() -> Bool {
        let email = emailText.text
        guard !((email?.isEmpty)!) else {
            emptyAlert(msg : "Email")
            return false
        }
        let pwd = pwdText.text
        guard !((pwd?.isEmpty)!) else {
            emptyAlert(msg : "Password")
            return false
        }
        return true
    }
    
    func emptyAlert(msg : String) {
        showAlert(title: "Missing Input", msg: "\(msg) is empty, please provide it.")
    }
    
    func failureAlert(msg : String) {
        showAlert(title: "Failed", msg: "\(msg) is failed, please try later again.")
    }
    
    func fetchUserInfo(usr : User) {
        self.ref!.child("User").child(usr.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String : Any] else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.failureAlert(msg: "Reset password")
                }
                return
            }
            userInfo.userId = value["UserId"] as? String
            userInfo.userName = value["UserName"] as? String
            userInfo.firstName = value["FirstName"] as? String
            userInfo.lastName = value["LastName"] as? String
            userInfo.emailId = value["Email"] as? String
            userInfo.address = value["Address"] as? String
            userInfo.phoneNumber = value["PhoneNumber"] as? String
            userInfo.password = value["Password"] as? String
            userInfo.latitude = value["Latitude"] as? String
            userInfo.longitude = value["Longitude"] as? String
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            self.goToHomeScreen()
        })
    }
    
    func goToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeScreen = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! UITabBarController
        
        UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.6, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: {
            UIApplication.shared.keyWindow?.rootViewController = homeScreen
        }) { (isDone) in
            NotificationCenter.default.post(name: NSNotification.Name("UserInfoIsReady"), object: nil)
        }
    }
}
