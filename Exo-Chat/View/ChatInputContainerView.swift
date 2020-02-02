//
//  ChatInputContainerView.swift
//  Exo-Chat
//
//  Created by Salim SAÏD on 29/01/2020.
//  Copyright © 2020 Salim SAÏD. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    var chatLogController: ChatLogController? {
        didSet {
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(chatLogController?.handleUploadImage)))
            sendButton.addTarget(chatLogController, action: #selector(chatLogController?.handleSendButton), for: .touchUpInside)
        }
    }
    
    let separatorLineView: UIView = {
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 230, green: 230, blue: 230)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        return separatorLineView
    }()
    
    lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.placeholder = "Write message..."
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        return inputTextField
    }()

    let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "addImage")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
    let sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/4).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSendButton()
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
