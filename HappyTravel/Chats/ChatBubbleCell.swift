//
//  ChatBubbleCell.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/3.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

import UIKit

let incomingTag = 0, outgoingTag = 1
//let incomingTag = 1, outgoingTag = 0
let bubbleTag = 8

class ChatBubbleCell: UITableViewCell {
    
    let bubbleImageView: UIImageView
    
    static let bubbleImage: (incoming: UIImage, incomingHighlighed: UIImage, outgoing: UIImage, outgoingHighlighed: UIImage) = {
        let maskOutgoing = UIImage(named: "msg-bubble")!
        let maskIncoming = UIImage(cgImage: maskOutgoing.cgImage!, scale: 2, orientation: .upMirrored)
        
        let capInsetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17.5, right: 21)
        let capInsetsOutgoing = UIEdgeInsets(top: 17, left: 21, bottom: 17.5, right: 26.5)
        
        let incoming = maskIncoming.imageWithRed(20/255, green: 31/255, blue: 49/255, alpha: 1).resizableImage(withCapInsets: capInsetsIncoming)
        let incomingHighlighted = maskIncoming.imageWithRed(40/255, green: 60/255, blue: 90/255, alpha: 1).resizableImage(withCapInsets: capInsetsIncoming)
        let outgoing = maskOutgoing.imageWithRed(255/255, green: 255/255, blue: 255/255, alpha: 1).resizableImage(withCapInsets: capInsetsOutgoing)
        let outgoingHighlighted = maskOutgoing.imageWithRed(240/255, green: 240/255, blue: 240/255, alpha: 1).resizableImage(withCapInsets: capInsetsOutgoing)
        
        return (incoming, incomingHighlighted, outgoing, outgoingHighlighted)
    }()
    let messageLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        bubbleImageView = UIImageView(image: ChatBubbleCell.bubbleImage.incoming, highlightedImage: ChatBubbleCell.bubbleImage.incomingHighlighed)
        bubbleImageView.tag = bubbleTag
        bubbleImageView.isUserInteractionEnabled = true // #CopyMesage
        
        messageLabel = UILabel(frame: CGRect.zero)
        messageLabel.font = UIFont.systemFont(ofSize: S15)
        messageLabel.numberOfLines = 0
        messageLabel.isUserInteractionEnabled = false   // #CopyMessage
        messageLabel.preferredMaxLayoutWidth = 218
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
        
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bubbleImageView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(4.5)
            make.width.equalTo(messageLabel.snp.width).offset(30)
            make.bottom.equalTo(contentView).offset(-4.5)
        }
        messageLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(bubbleImageView).offset(3)
            make.centerY.equalTo(bubbleImageView).offset(-0.5)
            make.height.equalTo(bubbleImageView).offset(-15)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithMessage(_ message: Message) {
        messageLabel.text = message.text
        if message.incoming {
            messageLabel.textColor = .white
        }
        
        if message.incoming != (tag == incomingTag) {
            var layoutAttribute: NSLayoutAttribute
            var layoutConstant: CGFloat
            
            if message.incoming {
                tag = incomingTag
                bubbleImageView.image = ChatBubbleCell.bubbleImage.incoming
                bubbleImageView.highlightedImage = ChatBubbleCell.bubbleImage.incomingHighlighed
                messageLabel.textColor = .white
                layoutAttribute = .left
                layoutConstant = 10
            } else { // outgoing
                tag = outgoingTag
                bubbleImageView.image = ChatBubbleCell.bubbleImage.outgoing
                bubbleImageView.highlightedImage = ChatBubbleCell.bubbleImage.outgoingHighlighed
                messageLabel.textColor = .black
                layoutAttribute = .right
                layoutConstant = -10
            }
            
            let layoutConstraint: NSLayoutConstraint = bubbleImageView.constraints[1] // `messageLabel` CenterX
            layoutConstraint.constant = -layoutConstraint.constant
            
            let constraints: NSArray = contentView.constraints as NSArray
            let indexOfConstraint = constraints.indexOfObject (passingTest: { constraint, idx, stop in
                return (constraint.firstItem ).tag == bubbleTag && (constraint.firstAttribute == .left || constraint.firstAttribute == .right)
            })
            contentView.removeConstraint(constraints[indexOfConstraint] as! NSLayoutConstraint)
            contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: layoutAttribute, relatedBy: .equal, toItem: contentView, attribute: layoutAttribute, multiplier: 1, constant: layoutConstant))
        }
    }
    
    // Highlight cell #CopyMessage
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleImageView.isHighlighted = selected
    }
}

extension UIImage {
    func imageWithRed(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.draw(in: rect)
        context?.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
        context?.setBlendMode(CGBlendMode.sourceAtop)
        context?.fill(rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
