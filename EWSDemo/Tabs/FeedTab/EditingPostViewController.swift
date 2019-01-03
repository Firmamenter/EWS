//
//  EditingPostViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/26/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class EditingPostViewController: UIViewController {
    var ref : DatabaseReference?
    var imgToPost : UIImage?

    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postText: UITextField!
    @IBOutlet weak var postBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        ref = Database.database().reference()
        hideKeyboard()
    }
    
    func setupUI() {
        postImg.image = imgToPost
        postImg.layer.borderColor = UIColor.white.cgColor
        postImg.layer.borderWidth = 1
        postImg.clipsToBounds = true
        postBtn.layer.masksToBounds = true
        postBtn.layer.cornerRadius = 24
    }
    
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        postText.resignFirstResponder()
    }
    
    @IBAction func sendPost(_ sender: UIButton) {
        let postKey = ref!.childByAutoId().key
        if let description = postText.text, !description.isEmpty {
            SVProgressHUD.show()
            let postDict = ["PostId" : postKey!, "UserId" : Auth.auth().currentUser?.uid, "Description" : description, "Timestamp" : String(NSDate().timeIntervalSince1970)]
            ref!.child("Post").child(postKey!).setValue(postDict) { (error, ref) in
                if error == nil {
                    WebService.shared.uploadImage(directory: "PostImg", id: postKey!, img: self.postImg.image!, completion: { (hasError) in
                        if hasError {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                self.showAlert(title : "Oops", msg: "Uploading image failed, please try again later.")
                            }
                        } else {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.showAlert(title : "Oops", msg: "Uploading image failed, please try again later.")
                    }
                }
            }
        } else {
            showAlert(title: "Oops", msg: "Please type in something.")
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
