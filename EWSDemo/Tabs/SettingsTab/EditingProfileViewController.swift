//
//  EditingProfileViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/22/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class EditingProfileViewController: UIViewController {
    let imgPickerController = UIImagePickerController()
    var ref : DatabaseReference?

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
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
        userNameText.resignFirstResponder()
        firstNameText.resignFirstResponder()
        lastNameText.resignFirstResponder()
        emailText.resignFirstResponder()
        addressText.resignFirstResponder()
        phoneText.resignFirstResponder()
    }
    
    func uiSetup() {
        imgPickerController.delegate = self
        background.image = UIImage(named: "SignUpBackground")
        // Make image circle
        userImg.makeCircle()
        setBottomBorder(textField: userNameText)
        setBottomBorder(textField: firstNameText)
        setBottomBorder(textField: lastNameText)
        setBottomBorder(textField: emailText)
        setBottomBorder(textField: addressText)
        setBottomBorder(textField: phoneText)
        userNameText.text = userInfo.userName
        firstNameText.text = userInfo.firstName
        lastNameText.text = userInfo.lastName
        emailText.text = userInfo.emailId
        addressText.text = userInfo.address
        phoneText.text = userInfo.phoneNumber
        emailText.isUserInteractionEnabled = false
        saveBtn.layer.masksToBounds = true
        saveBtn.layer.cornerRadius = 24
        getUserImage()
    }
    
    func setBottomBorder(textField : UITextField) {
        textField.borderStyle = .none
        textField.layer.backgroundColor = UIColor.white.cgColor
        textField.layer.masksToBounds = false
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        textField.layer.shadowOpacity = 1.0
        textField.layer.shadowRadius = 0.0
    }
    
    @IBAction func changeImg(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take a picture", style: .default) { (cameraAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        let albumAction = UIAlertAction(title: "Choose from album", style: .default) { (albumAction) in
            self.imgPickerController.sourceType = .photoLibrary
            self.present(self.imgPickerController, animated: true)
        }
        let cancleAction = UIAlertAction(title: "Cancle", style: .destructive) { (cancleAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancleAction)
        self.present(alertController, animated: true)
    }
    
    func getUserImage() {
        let id = (Auth.auth().currentUser?.uid)!
        let imgName = "UserImg/\(String(describing: id)).jpeg"
        var storageRef = Storage.storage().reference()
        storageRef = storageRef.child(imgName)
        DispatchQueue.global().async {
            storageRef.getData(maxSize: 10*1024*1024) { (data, error) in
                if data != nil && error == nil {
                    DispatchQueue.main.async {
                        let img = UIImage(data: data!)
                        self.userImg.image = img
                    }
                }
            }
        }
    }
    
    @IBAction func saveUserInfo(_ sender: UIButton) {
        if checkInput() {
            SVProgressHUD.show()
            let user = Auth.auth().currentUser!
            let userName = self.userNameText.text!
            let firstName = self.firstNameText.text!
            let lastName = self.lastNameText.text!
            let address = self.addressText.text!
            let phone = self.phoneText.text!
            let userDict = ["UserName" : userName, "FirstName" : firstName, "LastName" : lastName, "Address" : address, "PhoneNumber" : phone]
            self.ref!.child("User").child(user.uid).updateChildValues(userDict) { (error, ref) in
                if error == nil {
                    userInfo.userName = userName
                    userInfo.firstName = firstName
                    userInfo.lastName = lastName
                    userInfo.address = address
                    userInfo.phoneNumber = phone
                    userInfo.phoneNumber = phone
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.showAlert(title: "Success", msg: "Thanks for your updating.")
                    }
                } else {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.showAlert(title : "Failed", msg: "Unable to update your profile, please try again later.")
                    }
                }
            }
        }
    }
    
    func checkInput() -> Bool {
        let userName = userNameText.text
        guard (userName?.count)! > 0 else {
            showAlert(title: "Error", msg: "User name is missing.")
            return false
        }
        let firstName = firstNameText.text
        guard (firstName?.count)! > 0 else {
            showAlert(title: "Error", msg: "First name is missing.")
            return false
        }
        let lastName = lastNameText.text
        guard (lastName?.count)! > 0 else {
            showAlert(title: "Error", msg: "Last name is missing.")
            return false
        }
        let address = addressText.text
        guard (address?.count)! > 0 else {
            showAlert(title: "Error", msg: "Address is missing.")
            return false
        }
        let phone = phoneText.text
        guard (phone?.count)! > 0 else {
            showAlert(title: "Error", msg: "Phone is missing.")
            return false
        }
        return true
    }
}

extension EditingProfileViewController : UINavigationControllerDelegate {}

extension EditingProfileViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let img = info[.originalImage] as! UIImage
        self.userImg.image = img
        WebService.shared.uploadImage(directory: "UserImg", id: (Auth.auth().currentUser?.uid)!, img: img) { (hasError) in
            if hasError {
                DispatchQueue.main.async {
                    self.showAlert(title : "Oops", msg: "Uploading image failed, please try again later.")
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
