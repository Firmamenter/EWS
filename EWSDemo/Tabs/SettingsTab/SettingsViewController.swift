//
//  SettingsViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/21/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    var options = ["Edit Profile", "Change Password", "Language Setting"]

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var signOutBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load user profile image
        getUserImage()
    }
    
    func uiSetup() {
        background.image = UIImage(named: "SignUpBackground")
        userNameLabel.text = userInfo.userName
        emailLabel.text = userInfo.emailId
        // Removes line at bottom of navigation bar
        navigationController?.navigationBar.shadowImage = UIImage()
        // Makes navigation bar completely transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        tbView.delegate = self
        tbView.dataSource = self
        tbView.tableFooterView = UIView()
        // Disable scroll, make tableview still
        tbView.isScrollEnabled = false
        // Remove last cell's seperator
        tbView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tbView.frame.size.width, height: 1))
        userPhoto.makeCircle()
        signOutBtn.layer.masksToBounds = true
        signOutBtn.layer.cornerRadius = 24
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            self.goToSignUpScreen()
        } catch {
            print(error)
        }
    }
    
    func goToSignUpScreen() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let signupScreen = storyboard.instantiateViewController(withIdentifier: "SignUpVC")
        UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.6, options: UIView.AnimationOptions.transitionFlipFromRight, animations: {
            UIApplication.shared.keyWindow?.rootViewController = signupScreen
        }, completion: nil)
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
                        self.userPhoto.image = img
                    }
                }
            }
        }
    }
}

extension SettingsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Settings"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        switch indexPath.row {
        case 0:
            let editingProfileVC = storyboard.instantiateViewController(withIdentifier: "EditingProfileVC")
            navigationController?.pushViewController(editingProfileVC, animated: true)
        case 1:
            let changingPwdVC = storyboard.instantiateViewController(withIdentifier: "ChangingPwdVC")
            navigationController?.pushViewController(changingPwdVC, animated: true)
        default:
            let languageSettingVC = storyboard.instantiateViewController(withIdentifier: "LanguageSettingVC")
            navigationController?.pushViewController(languageSettingVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.textLabel?.text = options[indexPath.row]
        switch indexPath.row {
        case 0 :
            cell.imageView?.image = UIImage(named: "EditingProfile")
        case 1:
            cell.imageView?.image = UIImage(named: "ChangingPassword")
        default:
            cell.imageView?.image = UIImage(named: "Language")
        }
        return cell
    }
}
