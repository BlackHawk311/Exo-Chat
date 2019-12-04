//
//  ChatMessageCell.swift
//  Exo-Chat
//
//  Created by Salim SAÏD on 26/09/2019.
//  Copyright © 2019 Salim SAÏD. All rights reserved.
//

import UIKit
import AVKit

class ChatMessageCell: UICollectionViewCell {
    
    static let blueBubbleMessage = UIColor(red: 0, green: 137, blue: 249)
    static let greyBubbleMessage = UIColor(red: 240, green: 240, blue: 240)
    
    let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.layer.cornerRadius = 24
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        return profileImageView
    }()
    
    let bubbleView: UIView = {
        let bubbleView = UIView()
        bubbleView.backgroundColor = blueBubbleMessage
        bubbleView.layer.cornerRadius = 12
        bubbleView.layer.masksToBounds = true
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        return bubbleView
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    lazy var messageImageView: UIImageView = {
        let messageImageView = UIImageView()
        messageImageView.layer.cornerRadius = 12
        messageImageView.layer.masksToBounds = true
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.isUserInteractionEnabled = true
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMediaTapOn)))
        return messageImageView
    }()
    
    lazy var playButton: UIButton = {
        let buttonImage = UIImage(named: "playButton")
        
        let playButton = UIButton(type: .system)
        playButton.tintColor = UIColor.white
        playButton.setImage(buttonImage, for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(handlePlayButton), for: .touchUpInside)
        
        return playButton
    }()
    
    var chatLogController: ChatLogController?
    var message: Message?
    
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        setupProfileImageView()
        setupBubbleView()
        setupTextView()
        setupMessageImageView()
        setupActivityIndicatorView()
        setupPlayButton()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    func setupBubbleView() {
        addSubview(bubbleView)
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 225)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func setupTextView() {
        bubbleView.addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func setupMessageImageView() {
        bubbleView.addSubview(messageImageView)
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    
    func setupActivityIndicatorView() {
        bubbleView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupPlayButton() {
        bubbleView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bringSubviewToFront(playButton)
    }
    
    @objc func handleMediaTapOn(_ tapGesture: UITapGestureRecognizer) {
        if message?.getVideoUrl() != nil {
            return
        }
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(imageView)
        }
    }
    
    @objc func handlePlayButton() {
        if let videoUrlString = message?.getVideoUrl(), let url = URL(string: videoUrlString) {
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
