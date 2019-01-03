//
//  FeedViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/26/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SVProgressHUD

class FeedViewController: UIViewController {
    let imgPickerController = UIImagePickerController()
    var imgToPost : UIImage?
    var feedList = [PostDetail]()
    var postImgs = [String : UIImage]()
    var userList = [String : UserInfo]()
    var userImgs = [String : UIImage]()
    var ref : DatabaseReference?
    let storageRef = Storage.storage().reference()
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchPostList()
    }
    
    func setupUI() {
        title = "Feed News"
        SVProgressHUD.show()
        ref = Database.database().reference()
        refreshControl.addTarget(self, action: #selector(fetchPostList), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        tbView.tableFooterView = UIView()
        tbView.delegate = self
        tbView.dataSource = self
        tbView.allowsSelection = false
        tbView.refreshControl = refreshControl
        imgPickerController.delegate = self
        imgPickerController.sourceType = .photoLibrary
        let leftBarBtn = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takeAPicture))
        navigationItem.leftBarButtonItem = leftBarBtn
    }
    
    @objc func fetchPostList() {
        feedList = []
        postImgs = [:]
        userList = [:]
        userImgs = [:]
        let fetchPostGroup = DispatchGroup()
        let fetchPostComponentsGroup = DispatchGroup()
        fetchPostGroup.enter()
        
        ref!.observeSingleEvent(of: .value) { (snapshot, error) in
            guard (snapshot.value as? [String : Any]) != nil else {
                self.refreshControl.endRefreshing()
                SVProgressHUD.dismiss()
                return
            }
            
            if error == nil {
                var postArray : [PostDetail] = []
                
                if let allData = snapshot.value as? [String:[String:Any]],
                    let posts = allData["Post"] as? [String:[String:Any]] {
                    for post in posts {
                        let postDetail = PostDetail.init(postId: post.key, userId: post.value["UserId"] as? String, timestamp: post.value["Timestamp"] as? String, description: post.value["Description"] as? String)
                        fetchPostComponentsGroup.enter()
                        WebService.shared.fetchAllImage(directory: "PostImg", id: post.key, completion: { (img, error) in
                            if error == nil && !(img == nil) {
                                self.postImgs[postDetail.postId!] = img as? UIImage
                            }
                            postArray.append(postDetail)
                            fetchPostComponentsGroup.leave()
                        })
                    }
                    fetchPostComponentsGroup.notify(queue: .main) {
                        fetchPostGroup.leave()
                    }
                    fetchPostGroup.notify(queue: .main) {
                        self.feedList = postArray.sorted(by: {$0.timestamp! > $1.timestamp!})
                        self.fecthUsersList()
                    }
                }
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func fecthUsersList() {
        for post in feedList {
            WebService.shared.fetchUserInfo(usrID: post.userId!) { (userInfom) in
                WebService.shared.fetchImage(directory: "UserImg", id: userInfom.userId!, completion: { (data, error) in
                    if error == nil {
                        let image = UIImage(data: data! as! Data)
                        self.userImgs[userInfom.userId!] = image
                    }
                    self.userList[post.postId!] = userInfom
                    SVProgressHUD.dismiss()
                    self.refreshControl.endRefreshing()
                    self.tbView.reloadData()
                })
            }
        }
    }
    
    @objc func takeAPicture() {
        self.present(imgPickerController, animated: true)
    }
    
    func editPost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editingPostVC = storyboard.instantiateViewController(withIdentifier: "EditingPostVC") as! EditingPostViewController
        if imgToPost != nil {
            editingPostVC.imgToPost = imgToPost
        }
        self.present(editingPostVC, animated: true)
    }
}

extension FeedViewController : UINavigationControllerDelegate {}

extension FeedViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let img = info[.originalImage] as! UIImage
        imgToPost = img
        imgPickerController.dismiss(animated: true, completion: nil)
        editPost()
    }
}

extension FeedViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
}

extension FeedViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedNewsCell", for: indexPath) as! FeedNewsTableViewCell
        if indexPath.row < feedList.count {
            let currentPost = feedList[indexPath.row]
            if let currentUser = userList[currentPost.postId!] {
                cell.userImg.image = userImgs[currentUser.userId!]
                cell.userName.text = currentUser.firstName
            }
            cell.postImg.image = postImgs[currentPost.postId!]
            cell.postImg.layer.masksToBounds = false
            cell.postImg.clipsToBounds = true
            cell.label.text = currentPost.description
        }
        cell.rootView.makeShadow()
        cell.userImg.makeCircle()
        return cell
    }
}
