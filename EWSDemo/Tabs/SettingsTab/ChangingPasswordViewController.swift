//
//  ChangingPasswordViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/22/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class ChangingPasswordViewController: UIViewController {
    var ref : DatabaseReference?

    @IBOutlet weak var currentPwdText: UITextField!
    @IBOutlet weak var newPwdText: UITextField!
    @IBOutlet weak var confirmPwdText: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        uiSetup()
        hideKeyboard()
    }
    
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        currentPwdText.resignFirstResponder()
        newPwdText.resignFirstResponder()
        confirmPwdText.resignFirstResponder()
    }
    
    func uiSetup() {
        self.title = "Change Password"
        setBottomBorder(textField: currentPwdText)
        setBottomBorder(textField: newPwdText)
        setBottomBorder(textField: confirmPwdText)
        submitBtn.layer.masksToBounds = true
        submitBtn.layer.cornerRadius = 24
    }
    
    func setBottomBorder(textField : UITextField) {
        textField.borderStyle = .none
        textField.layer.backgroundColor = UIColor.white.cgColor
        textField.layer.masksToBounds = false
        textField.layer.shadowColor = UIColor.gray.cgColor
        textField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        textField.layer.shadowOpacity = 1.0
        textField.layer.shadowRadius = 0.0
    }
    
    @IBAction func submitPwd(_ sender: UIButton) {
        self.dismissKeyboard()
        if checkInput() {
            SVProgressHUD.show()
            let newPwd = newPwdText.text!
            Auth.auth().currentUser?.updatePassword(to: newPwd, completion: { (error) in
                if error == nil {
                    self.updatePwdInDB()
                } else {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.resetAlert(msg: "Something went wrong, please try again.")
                    }
                }
            })
        }
    }
    
    func updatePwdInDB() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let userDict = ["Password" : newPwdText.text!]
        self.ref!.child("User").child(user.uid).updateChildValues(userDict) { (error, ref) in
            if error == nil {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.resetAlert(msg: "Something went wrong, please try again.")
                }
            }
        }
    }
    
    func checkInput() -> Bool {
        let currentPwd = currentPwdText.text
        guard (currentPwd?.count)! >= 8 else {
            resetAlert(msg : "Current password has less than 8 digits, please type in correct password.")
            return false
        }
        let newPwd = newPwdText.text
        guard (newPwd?.count)! >= 8 else {
            resetAlert(msg : "New password has less than 8 digits, please try a new password.")
            return false
        }
        let confirmPwd = confirmPwdText.text
        guard (confirmPwd?.count)! >= 8 && confirmPwd! == newPwd! else {
            resetAlert(msg : "New password doesn't not match or is too short.")
            return false
        }
        return true
    }
    
    func resetAlert(msg : String) {
        let alertController = UIAlertController(title: "Unable to reset", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive) { (okAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}
