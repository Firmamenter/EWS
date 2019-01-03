//
//  ChatViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/27/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class ChatViewController: UIViewController {
    var chatId : String?
    var friend : UserInfo?
    var ref : DatabaseReference?
    var chatArray = [ChatDetail]()
    var timer = Timer()

    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var msgText: UITextView!
    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    func setupUI() {
        ref = Database.database().reference()
        title = friend?.firstName
        tabBarController?.tabBar.isHidden = true
        backgroundImg.layer.masksToBounds = false
        backgroundImg.clipsToBounds = true
        msgText.layer.cornerRadius = 6
        msgText.text = "Say something..."
        msgText.textColor = UIColor.lightGray
        tbView.delegate = self
        tbView.dataSource = self
        tbView.allowsSelection = false
        tbView.tableFooterView = UIView()
        hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fetchUpdates), userInfo: nil, repeats: true)
        SVProgressHUD.show()
        fetchChat(chatId: chatId!)
    }
    
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        msgText.resignFirstResponder()
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
    
    @objc func fetchUpdates() {
        fetchChat(chatId: chatId!)
    }
    
    func fetchChat(chatId : String) {
        var chats = [ChatDetail]()
        self.ref!.child("Chats").child(chatId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String:[String:Any]] else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                return
            }
            for chat in value {
                let chatDetail = ChatDetail.init(senderId: chat.value["SenderId"] as? String, timestamp: chat.value["Timestamp"] as? String, message: chat.value["Message"] as? String)
                chats.append(chatDetail)
            }
            DispatchQueue.main.async {
                chats = chats.sorted(by: { $0.timestamp! < $1.timestamp!})
                let len = self.chatArray.count
                if chats.count - 1 >= len {
                    for chatIdx in len...(chats.count - 1) {
                        self.chatArray.append(chats[chatIdx])
                        let index = IndexPath(row: chatIdx, section: 0)
                        self.tbView.insertRows(at: [index], with: .bottom)
                    }
                    let index = IndexPath(row: chats.count - 1, section: 0)
                    self.tbView.scrollToRow(at: index, at: .bottom, animated: true)
                }
                SVProgressHUD.dismiss()
            }
        })
    }
    
    @IBAction func sendMsg(_ sender: UIButton) {
        let timeKey = String(Int(NSDate().timeIntervalSince1970))
        let chatDict = ["SenderId" : userInfo.userId!, "Timestamp" : timeKey, "Message" : msgText.text!]
        msgText.text = ""
        self.ref!.child("Chats").child(chatId!).child(timeKey).setValue(chatDict, withCompletionBlock: { (dbError, ref) in
            if dbError == nil {
                print("Success")
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let latestChat = ChatDetail(senderId : chatDict["SenderId"], timestamp : chatDict["Timestamp"], message : chatDict["Message"])
                    self.chatArray.append(latestChat)
                    let index = IndexPath(row: self.chatArray.count - 1, section: 0)
                    self.tbView.insertRows(at: [index], with: .bottom)
                    self.tbView.scrollToRow(at: index, at: .bottom, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Oops", msg: "Something went wrong, please try again later.")
                }
            }
        })
    }
}

extension ChatViewController : UITableViewDelegate {}

extension ChatViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
        let chat = chatArray[indexPath.row]
        if chat.senderId == userInfo.userId {
            cell.myMsg.text = chat.message
            cell.otherMsg.text = ""
            cell.myMsgView.layer.cornerRadius = 6
            cell.myMsgView.isHidden = false
            cell.otherMsgView.isHidden = true
        } else {
            cell.otherMsg.text = chat.message
            cell.myMsg.text = ""
            cell.otherMsgView.layer.cornerRadius = 6
            cell.otherMsgView.isHidden = false
            cell.myMsgView.isHidden = true
        }
        return cell
    }
}
