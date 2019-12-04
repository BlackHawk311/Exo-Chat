//
//  MessagesController.swift
//  Exo-Chat
//
//  Created by Salim SAÏD on 02/05/2019.
//  Copyright © 2019 Salim SAÏD. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    
    var timer: Timer?
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(handleLogout))
        
        let newMessageIcon = UIImage(named: "newMessage")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageIcon, style: .plain, target: self, action: #selector(handleNewMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User(dictionary: dictionary)
            user.setId(insertId: chatPartnerId)
            self.showChatLogControllerForUser(user)
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let message = self.messages[indexPath.row]
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        while chatPartnerId == message.chatPartnerId() {
            let messageId = message.getMessageId()
            let currentUserMessagesNode = Database.database().reference().child("userMessages").child(currentUserUid).child(chatPartnerId)
            currentUserMessagesNode.removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete message :", error as Any)
                    return
                }
                
                Database.database().reference().child("messages").child(messageId!).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to delete message :", error as Any)
                        return
                    }
                })
            })
            
            let chatPartnerMessagesNode = Database.database().reference().child("userMessages").child(chatPartnerId).child(currentUserUid)
            chatPartnerMessagesNode.removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete message :", error as Any)
                    return
                }
            })
        }
        
        self.messagesDictionary.removeValue(forKey: chatPartnerId)
        self.attemptReloadOfTable()
        
//        if let chatPartnerId = message.chatPartnerId() {
//            Database.database().reference().child("userMessages").child(currentUserUid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
//                if error != nil {
//                    print("Failed to delete message :", error as Any)
//                    return
//                }
//
//                if message.getImageUrl() != nil {
//                    Storage.storage().reference().child("messageImage").child(message.getImageUrl()!).delete(completion: { (error) in
//                        if error != nil {
//                            print("Failed to delete image :", error as Any)
//                            return
//                        }
//                    })
//                } else if message.getVideoUrl() != nil {
//                    Storage.storage().reference().child("messageVideos").child(message.getVideoUrl()!).delete(completion: { (error) in
//                        if error != nil {
//                            print("Failed to delete video :", error as Any)
//                            return
//                        }
//                    })
//                }
//                Database.database().reference().child("messages").child(message.getMessageId()!).removeValue(completionBlock: { (error, ref) in
//                    if error != nil {
//                        print("Failed to delete message :", error as Any)
//                        return
//                    }
//                })
//                self.messagesDictionary.removeValue(forKey: chatPartnerId)
//                self.attemptReloadOfTable()
//            })
//        }
    }
    
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView: UIView = {
            let titleView = UIView()
            titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
            return titleView
        }()
        self.navigationItem.titleView = titleView
        
        let containerView: UIView = {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            return containerView
        }()
        
        titleView.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        let profileImageView: UIImageView = {
            let profileImageView = UIImageView()
            profileImageView.layer.cornerRadius = 20
            profileImageView.clipsToBounds = true
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            return profileImageView
        }()
        
        if let profileImageUrl = user.getProfileImageUrl() {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }

        containerView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel: UILabel = {
            let nameLabel = UILabel()
            nameLabel.text = user.getName()
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            return nameLabel
        }()
        
        containerView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatLogController)))
    }
    
    func showChatLogControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReloadTable), userInfo: nil, repeats: false)
    }
}

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) ->Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
