//
//  ChatLogController.swift
//  Exo-Chat
//
//  Created by Salim SAÏD on 11/05/2019.
//  Copyright © 2019 Salim SAÏD. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let cellId = "cellId"
    
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 55))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    var user: User? {
        didSet {
            navigationItem.title = user?.getName()
            observeMessages()
        }
    }
    var messages = [Message]()
    var inputContainerViewBottomAnchor: NSLayoutConstraint?
    
    var startingFrame: CGRect?
    var startingImageView: UIImageView?
    var blackBackgroundView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 9, left: 0, bottom: 59, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.getText()
        
        setupCell(cell, message: message)
        
        if let text = message.getText() {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.getImageUrl() != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.getVideoUrl() == nil
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.getText() {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.getImageWidth()?.floatValue, let imageHeight = message.getImageHeight()?.floatValue {
//             h1 / w1 = h2 / w2
//             h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.getId() else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("userMessages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                self.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
//                    Automatically scroll down to the last message sent/received
//                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
//                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedForUrl(videoUrl)
        } else {
            handleImageSelectedForInfo(info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                // h1 / w1 = h2 / w2
                // h2 = h1 / w1 * w2
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: { (completed) in
//                Nothing to do here
            })
        }
    }
    
    @objc func handleSendButton() {
        let properties = ["text": inputContainerView.inputTextField.text!]
        sendMessageWithProperties(properties as [String : AnyObject])
    }
    
    @objc func handleUploadImage() {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        imagePickerViewController.allowsEditing = true
        imagePickerViewController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerViewController, animated: true, completion: nil)
    }
    
    @objc func handleImageZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomImageView = tapGesture.view {
            zoomImageView.layer.cornerRadius = 12
            zoomImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.getProfileImageUrl() {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        if message.getFromId() == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueBubbleMessage
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = ChatMessageCell.greyBubbleMessage
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.getImageUrl() {
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromId = Auth.auth().currentUser!.uid
        let toId = user!.getId()!
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["messageId": childRef.key as AnyObject,"fromId": fromId as AnyObject, "toId": toId as AnyObject, "timestamp": timestamp as AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.inputContainerView.inputTextField.text = nil
            
            guard let messageId = childRef.key else { return }
            
            let userMessageRef = Database.database().reference().child("userMessages").child(fromId).child(toId).child(messageId)
            userMessageRef.setValue(1)
            
            let recipientUserMessageRef = Database.database().reference().child("userMessages").child(toId).child(fromId).child(messageId)
            recipientUserMessageRef.setValue(1)
        }
    }
    
    fileprivate func handleImageSelectedForInfo(_ info: [UIImagePickerController.InfoKey: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            uploadImageToFirebaseStorage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            })
        }
    }
    
    fileprivate func handleVideoSelectedForUrl(_ videoUrl: URL) {
        let filename = UUID().uuidString + ".mov"
        let ref = Storage.storage().reference().child("messageVideos").child(filename)
        let uploadTask = ref.putFile(from: videoUrl, metadata: nil, completion: { (_, err) in
            if let err = err {
                print("Failed to upload video :", err)
                return
            }
            
            ref.downloadURL(completion: { (downloadUrl, err) in
                if let err = err {
                    print("Failed to get download url :", err)
                    return
                }
                
                guard let downloadUrl = downloadUrl else { return }
                
                if let thumbnailImage = self.thumbnailImageForVideoUrl(videoUrl) {
                    self.uploadImageToFirebaseStorage(thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": downloadUrl as AnyObject]
                        self.sendMessageWithProperties(properties)
                    })
                }
            })
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = String("Completed")
            self.navigationItem.title = self.user?.getName()
        }
    }
    
    fileprivate func thumbnailImageForVideoUrl(_ videoUrl: URL) -> UIImage? {
        let videoAsset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    fileprivate func uploadImageToFirebaseStorage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString + ".jpeg"
        let ref = Storage.storage().reference().child("messageImages").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image :", error!)
                    return
                }
                
                ref.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    completion(url?.absoluteString ?? "")
                })
            })
        }
    }
    
    fileprivate func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator
//fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
//    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
//}

// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
//    guard let input = input else { return nil }
//    return Dictionary(uniqueKeysWithValues: input.map { key, value in
//        (NSAttributedString.Key(rawValue: key), value)
//    })
//}

// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
//    return input.rawValue
//}
