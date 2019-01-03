//
//  FriendsListViewController.swift
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

class FriendsListViewController: UIViewController {
    var ref : DatabaseReference?
    let storageRef = Storage.storage().reference()
    var friendsArray : [UserInfo] = []
    var friendsImg : [String : UIImage] = [:]
    let currentUser = Auth.auth().currentUser
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        title = "Friend List"
        ref = Database.database().reference()
        refreshControl.addTarget(self, action: #selector(fecthFriendsList), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        
        tbView.allowsSelection = false
        tbView.tableFooterView = UIView()
        tbView.delegate = self
        tbView.dataSource = self
        tbView.refreshControl = refreshControl
        setupBarBtn()
        
        fecthFriendsList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setupBarBtn() {
        let righttBarBtn = UIBarButtonItem(image: UIImage(named: "Map"), style: .plain, target: self, action: #selector(openUsersMap))
        navigationItem.rightBarButtonItem = righttBarBtn
    }
    
    @objc func openUsersMap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let usersMapVC = storyboard.instantiateViewController(withIdentifier: "UsersMapVC") as! UsersMapViewController
        usersMapVC.userInfoArray = friendsArray
        usersMapVC.userImg = friendsImg
        navigationController?.pushViewController(usersMapVC, animated: true)
    }
    
    @objc func fecthFriendsList() {
        friendsArray = []
        ref!.child("User").child(currentUser!.uid).child("Friends").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String : Any] else {
                self.refreshControl.endRefreshing()
                SVProgressHUD.dismiss()
                return
            }
            
            for i in value {
                self.ref?.child("User").child(i.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let friend = snapshot.value as? [String : Any] {
                        let friendInfo = UserInfo.init(userId: friend["UserId"] as? String,
                                                     userName: friend["UserName"] as? String,
                                                     firstName: friend["FirstName"] as? String,
                                                     lastName: friend["LastName"] as? String,
                                                     emailId: friend["Email"] as? String,
                                                     address: friend["Address"] as? String,
                                                     phoneNumber: friend["PhoneNumber"] as? String,
                                                     password: friend["Password"] as? String,
                                                     latitude: friend["Latitude"] as? String,
                                                     longitude: friend["Longitude"] as? String)
                        let imageName = "UserImg/\(friendInfo.userId!).jpeg"
                        self.storageRef.child(imageName).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                            if error == nil {
                                let image = UIImage(data: data!)
                                self.friendsImg[friendInfo.userId!] = image
                            }
                            self.friendsArray.append(friendInfo)
                            SVProgressHUD.dismiss()
                            self.refreshControl.endRefreshing()
                            self.tbView.reloadData()
                        })
                    }
                })
            }
        }
    }
    
    @objc func removeFriend(sender: UIButton) {
        let friendInfo = friendsArray[sender.tag]
        self.removeFriendAlert(name: friendInfo.userName!, id: friendInfo.userId!)
    }
    
    func removeFriendAlert(name: String, id : String) {
        let alertController = UIAlertController(title: "Remove friend", message: "You wanna delete \(name) from your friend list?", preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "Cancle", style: .destructive) { (cancleAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (yesAction) in
            alertController.dismiss(animated: true, completion: nil)
            self.removeFriendFromFirebase(userId: id)
        }
        alertController.addAction(yesAction)
        alertController.addAction(cancleAction)
        self.present(alertController, animated: true)
    }
    
    func removeFriendFromFirebase(userId : String) {
        let currentUserId = Auth.auth().currentUser?.uid
        self.ref?.child("User").child(currentUserId!).child("Friends").child(userId).removeValue(completionBlock: { (error, ref) in
            if error == nil {
                let newList = self.friendsArray.filter({ (friend) -> Bool in
                    friend.userId! != userId
                })
                self.friendsArray = newList
                self.friendsImg[userId] = nil
                UIView.transition(with: self.tbView, duration: 0.18, options: .transitionCrossDissolve, animations: {self.tbView.reloadData()}, completion: nil)
            }
        })
        self.ref?.child("User").child(userId).child("Friends").child(currentUserId!).removeValue(completionBlock: { (error, ref) in
            if error == nil {
                print("Success")
            }
        })
    }
    
    @objc func startChat(sender: UIButton) {
        let friendInfo = friendsArray[sender.tag]
        let chatId = friendInfo.userId! < userInfo.userId! ? friendInfo.userId! + userInfo.userId! : userInfo.userId! + friendInfo.userId!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
        chatVC.chatId = chatId
        chatVC.friend = friendInfo
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

extension FriendsListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension FriendsListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTbCell", for: indexPath) as! FriendsTableViewCell
        if indexPath.row < friendsArray.count {
            let friend = friendsArray[indexPath.row]
            if friendsImg[friend.userId!] != nil {
                cell.cellImg.image = friendsImg[friend.userId!]
            } else {
                cell.cellImg.image = UIImage(named: "UserProfileBackground")
            }
            cell.cellName.text = "\(friend.firstName!) \(friend.lastName!)"
            cell.cellUserName.text = friend.userName
        }
        cell.rootView.makeShadow()
        cell.cellImg.makeCircle()
        cell.cellBtn.tag = indexPath.row
        cell.cellBtn.addTarget(self, action: #selector(removeFriend(sender:)), for: .touchUpInside)
        cell.chatBtn.tag = indexPath.row
        cell.chatBtn.addTarget(self, action: #selector(startChat(sender:)), for: .touchUpInside)
        return cell
    }
}
