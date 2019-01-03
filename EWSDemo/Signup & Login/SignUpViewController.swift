//
//  SignUpViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/20/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
import CoreLocation

class SignUpViewController: UIViewController {
    var ref : DatabaseReference?
    var locationManager = CLLocationManager()
    var lastLoc : CLLocation?

    @IBOutlet weak var emailText: UITextField! {
        didSet {
            emailText.setIcon(UIImage(named: "EmailIcon")!)
        }
    }
    @IBOutlet weak var userNameText: UITextField! {
        didSet {
            userNameText.setIcon(UIImage(named: "UsernameIcon")!)
        }
    }
    @IBOutlet weak var phoneText: UITextField! {
        didSet {
            phoneText.setIcon(UIImage(named: "PhoneIcon")!)
        }
    }
    @IBOutlet weak var pwdText: UITextField! {
        didSet {
            pwdText.setIcon(UIImage(named: "PasswordIcon")!)
        }
    }
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setupLocation()
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
        userNameText.resignFirstResponder()
        phoneText.resignFirstResponder()
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
        userNameText.layer.borderWidth = 1
        userNameText.layer.masksToBounds = true
        userNameText.layer.borderColor = UIColor.white.cgColor
        userNameText.layer.cornerRadius = 24
        phoneText.layer.borderWidth = 1
        phoneText.layer.masksToBounds = true
        phoneText.layer.borderColor = UIColor.white.cgColor
        phoneText.layer.cornerRadius = 24
        signUpBtn.layer.masksToBounds = true
        signUpBtn.layer.cornerRadius = 24
    }
    
    func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        self.dismissKeyboard()
        if checkInput() {
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: emailText.text!, password: pwdText.text!) { (result, error) in
                if error == nil {
                    guard let user = result?.user else {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.signUpFailureAlert()
                        }
                        return
                    }
                    let userName = self.userNameText.text!
                    let phone = self.phoneText.text!
                    let pwd = self.pwdText.text!
                    var lat = ""
                    if let latitude = self.lastLoc?.coordinate.latitude {
                        lat = String(latitude)
                    }
                    var log = ""
                    if let longitude = self.lastLoc?.coordinate.longitude {
                        log = String(longitude)
                    }
                    let userDict = ["UserId" : user.uid, "UserName" : userName, "FirstName" : "", "LastName" : "", "Email" : user.email, "Address" : "", "PhoneNumber" : phone, "Password" : pwd, "Latitude" : lat, "Longitude" : log]
                    userInfo.userId = user.uid
                    userInfo.userName = userName
                    userInfo.emailId = user.email
                    userInfo.phoneNumber = phone
                    userInfo.password = pwd
                    userInfo.latitude = lat
                    userInfo.longitude = log
                    self.ref!.child("User").child(user.uid).setValue(userDict, withCompletionBlock: { (dbError, ref) in
                        if dbError == nil {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                            }
                            self.goToHomeScreen()
                        } else {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                self.signUpFailureAlert()
                            }
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.signUpFailureAlert()
                    }
                }
            }
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        self.dismissKeyboard()
        self.performSegue(withIdentifier: "GoToLogin", sender: nil)
    }
    
    func checkInput() -> Bool {
        let email = emailText.text
        guard !((email?.isEmpty)!) else {
            emptyAlert(msg : "Email")
            return false
        }
        let userName = userNameText.text
        guard !((userName?.isEmpty)!) else {
            emptyAlert(msg : "User name")
            return false
        }
        let phone = phoneText.text
        guard !((phone?.isEmpty)!) else {
            emptyAlert(msg : "Phone number")
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
    
    func signUpFailureAlert() {
        showAlert(title: "Failed", msg: "Sign up is failed, please try later again.")
    }
    
    func goToHomeScreen() {
        NotificationCenter.default.post(name: NSNotification.Name("UserInfoIsReady"), object: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeScreen = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! UITabBarController
        
        UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.6, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: {
            UIApplication.shared.keyWindow?.rootViewController = homeScreen
        }) { (isDone) in
            NotificationCenter.default.post(name: NSNotification.Name("UserInfoIsReady"), object: nil)
        }
    }
}

extension SignUpViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            locationManager.stopUpdatingLocation()
            lastLoc = loc
        }
    }
}
