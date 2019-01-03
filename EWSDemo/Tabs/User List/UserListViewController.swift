//
//  UserListViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/24/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SVProgressHUD

class UserListViewController: UIViewController {
    var ref : DatabaseReference?
    let storageRef = Storage.storage().reference()
    var userInfoArray : [UserInfo] = []
    var userImg : [String : UIImage] = [:]

    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        ref = Database.database().reference()
        tbView.allowsSelection = false
        tbView.tableFooterView = UIView()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        setupBarBtn()
        
        fetchAllUsers { (userArray) in
            self.userInfoArray = userArray as! [UserInfo]
            SVProgressHUD.dismiss()
            self.tbView.delegate = self
            self.tbView.dataSource = self
            self.tbView.reloadData()
        }
    }
    
    func setupBarBtn() {
        let righttBarBtn = UIBarButtonItem(image: UIImage(named: "Map"), style: .plain, target: self, action: #selector(openUsersMap))
        navigationItem.rightBarButtonItem = righttBarBtn
    }
    
    @objc func openUsersMap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let usersMapVC = storyboard.instantiateViewController(withIdentifier: "UsersMapVC") as! UsersMapViewController
        usersMapVC.userInfoArray = userInfoArray
        usersMapVC.userImg = userImg
        navigationController?.pushViewController(usersMapVC, animated: true)
    }
    
    func fetchAllUsers(completion: @escaping (Any?) -> ()) {
        let fetchUserGroup = DispatchGroup()
        let fetchUserComponentsGroup = DispatchGroup()
        fetchUserGroup.enter()
        
        ref!.observeSingleEvent(of: .value) { (snapshot, error) in
            if error == nil {
                var userInfoArray : [UserInfo] = []
                
                if let allData = snapshot.value as? [String:[String:Any]],
                    let users = allData["User"] as? [String:[String:Any]] {
                    for user in users {
                        let userInfo = UserInfo.init(userId: user.key,
                                                     userName: user.value["UserName"] as? String,
                                                     firstName: user.value["FirstName"] as? String,
                                                     lastName: user.value["LastName"] as? String,
                                                     emailId: user.value["Email"] as? String,
                                                     address: user.value["Address"] as? String,
                                                     phoneNumber: user.value["PhoneNumber"] as? String,
                                                     password: user.value["Password"] as? String,
                                                     latitude: user.value["Latitude"] as? String,
                                                     longitude: user.value["Longitude"] as? String)
                        fetchUserComponentsGroup.enter()
                        self.fetchAllUserImage(userID: user.key, completion: { (img, error) in
                            if error == nil && !(img == nil) {
                                self.userImg[userInfo.userId!] = img as? UIImage
                            }
                            userInfoArray.append(userInfo)
                            fetchUserComponentsGroup.leave()
                        })
                    }
                    fetchUserComponentsGroup.notify(queue: .main) {
                        fetchUserGroup.leave()
                    }
                    fetchUserGroup.notify(queue: .main) {
                        // now the currentUser should be properly configured
                        completion(userInfoArray)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func fetchAllUserImage(userID: String, completion: @escaping (Any?, Error?) -> ()) {
        let imageName = "UserImg/\(String(describing: userID)).jpeg"
        
        storageRef.child(imageName).getData(maxSize: 10*1024*1024) { (data, error) in
            if error == nil {
                let image = UIImage(data: data!)
                
                completion(image, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    @objc func addNewFriend(sender: UIButton) {
        let selectedUser = userInfoArray[sender.tag]
        if selectedUser.userId == userInfo.userId {
            alert(title: "Oops", msg: "You can't add yourself as friend.")
        } else {
            self.addFriendAlert(name: selectedUser.userName!, id: selectedUser.userId!)
        }
    }
    
    func alert(title : String, msg : String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive) { (okAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    func addFriendAlert(name: String, id : String) {
        let alertController = UIAlertController(title: "Add friend", message: "You wanna add \(name) as your new friend?", preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "Cancle", style: .destructive) { (cancleAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (yesAction) in
            alertController.dismiss(animated: true, completion: nil)
            self.addNewFriendToFirebase(userId: id)
        }
        alertController.addAction(yesAction)
        alertController.addAction(cancleAction)
        self.present(alertController, animated: true)
    }
    
    func addNewFriendToFirebase(userId : String) {        
        let currentUserId = Auth.auth().currentUser?.uid
        self.ref?.child("User").child(currentUserId!).child("Friends").child(userId).updateChildValues([userId : userId], withCompletionBlock: { (error, ref) in
            print("Success")
        })
        self.ref?.child("User").child(userId).child("Friends").child(currentUserId!).updateChildValues([userId : userId], withCompletionBlock: { (error, ref) in
            print("Success")
        })
    }
}

extension UserListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension UserListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTbCell", for: indexPath) as! UsersTableViewCell
        let currentUser = userInfoArray[indexPath.row]
        cell.rootView.makeShadow()
        cell.cellUserName.text = currentUser.userName
        cell.cellName.text = "\(currentUser.firstName!) \(currentUser.lastName!)"
        cell.cellImg.makeCircle()
        if userImg[currentUser.userId!] != nil {
            cell.cellImg.image = userImg[currentUser.userId!]
        } else {
            cell.cellImg.image = UIImage(named: "UserProfileBackground")
        }
        cell.cellBtn.tag = indexPath.row
        cell.cellBtn.addTarget(self, action: #selector(addNewFriend(sender:)), for: .touchUpInside)
        return cell
    }
}
