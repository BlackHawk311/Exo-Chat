//
//  NewMessageControllerExtension.swift
//  Exo-Chat
//
//  Created by Salim SAÏD on 13/05/2019.
//  Copyright © 2019 Salim SAÏD. All rights reserved.
//

import UIKit
import Firebase

extension NewMessageController {
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                
                if user.getName() != currentUser.displayName && user.getEmail() != currentUser.email {
                    user.setId(insertId: snapshot.key)
                    self.users.append(user)
                }
//                This will crash because of background thread, so let's use dispatch_async to fix this
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }, withCancel: nil)
    }
}
