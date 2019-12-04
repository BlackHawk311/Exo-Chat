//
//  Message.swift
//  Exo-Chat
//
//  Created by Salim SAÏD on 13/05/2019.
//  Copyright © 2019 Salim SAÏD. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    private var messageId: String?
    private var fromId: String?
    private var toId: String?
    private var timestamp: NSNumber?
    private var text: String?
    private var imageName: String?
    private var imageUrl: String?
    private var videoName: String?
    private var videoUrl: String?
    private var imageWidth: NSNumber?
    private var imageHeight: NSNumber?
    
    init(dictionary: [String: Any]) {
        self.messageId = dictionary["messageId"] as? String
        self.fromId = dictionary["fromId"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.text = dictionary["text"] as? String
        self.imageName = dictionary["imageName"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.videoName = dictionary["videoName"] as? String
        self.videoUrl = dictionary["videoUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
    }
    
    func getMessageId() -> String? {
        return self.messageId
    }
    
    func setMessageId(messageId: String) {
        self.messageId = messageId
    }
    
    func getFromId() -> String? {
        return self.fromId
    }
    
    func setFromId(fromId: String) {
        self.fromId = fromId
    }
    
    func getToId() -> String? {
        return self.toId
    }
    
    func setToId(toId: String) {
        self.toId = toId
    }
    
    func getTimestamp() -> NSNumber? {
        return self.timestamp
    }
    
    func setTimestamp(timestamp: NSNumber) {
        self.timestamp = timestamp
    }
    
    func getText() -> String? {
        return self.text
    }
    
    func setText(text: String) {
        self.text = text
    }
    
    func getImageName() -> String? {
        return self.imageName
    }
    
    func setImageName(imageName: String) {
        self.imageName = imageName
    }
    
    func getImageUrl() -> String? {
        return self.imageUrl
    }
    
    func setImageUrl(imageUrl: String) {
        self.imageUrl = imageUrl
    }
    
    func getVideoName() -> String? {
        return self.videoName
    }
    
    func setVideoName(videoName: String) {
        self.videoName = videoName
    }
    
    func getVideoUrl() -> String? {
        return self.videoUrl
    }
    
    func setVideoUrl(videoUrl: String) {
        self.videoUrl = videoUrl
    }
    
    func getImageWidth() -> NSNumber? {
        return self.imageWidth
    }
    
    func setImageWidth(imageWidth: NSNumber) {
        self.imageWidth = imageWidth
    }
    
    func getImageHeight() -> NSNumber? {
        return self.imageHeight
    }
    
    func setImageHeight(imageHeight: NSNumber) {
        self.imageHeight = imageHeight
    }
    
    func chatPartnerId() -> String? {
        return getFromId() == Auth.auth().currentUser?.uid ? getToId() : getFromId()
    }
}
