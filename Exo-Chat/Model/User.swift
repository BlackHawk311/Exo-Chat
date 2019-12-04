//
//  User.swift
//  Exo-Chat
//
//  Created by Salim SAÏD on 02/05/2019.
//  Copyright © 2019 Salim SAÏD. All rights reserved.
//

import UIKit

class User: NSObject {
    
    private var id: String?
    private var name: String?
    private var email: String?
    private var profileImageUrl: String?
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
    
    func getId() -> String? {
        return self.id
    }
    
    func setId(insertId: String) {
        self.id = insertId
    }
    
    func getName() -> String? {
        return self.name
    }
    
    func setName(insertName: String) {
        self.name = insertName
    }
    
    func getEmail() -> String? {
        return self.email
    }
    
    func setEmail(insertEmail: String) {
        self.email = insertEmail
    }
    
    func getProfileImageUrl() -> String? {
        return self.profileImageUrl
    }
    
    func setProfileImageUrl(insertProfileImageUrl: String) {
        self.profileImageUrl = insertProfileImageUrl
    }
    
}
