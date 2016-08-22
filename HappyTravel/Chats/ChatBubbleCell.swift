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
        let maskIncoming = UIImage(CGImage: maskOutgoing.CGImage!, scale: 2, orientation: .UpMirrored)
        
        let capInsetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17.5, right: 21)
        let capInsetsOutgoing = UIEdgeInsets(top: 17, left: 21, bottom: 17.5, right: 26.5)
        
        let incoming = maskIncoming.imageWithRed(20/255, green: 31/255, blue: 49/255, alpha: 1).resizableImageWithCapInsets(capInsetsIncoming)
        let incomingHighlighted = maskIncoming.imageWithRed(40/255, green: 60/255, blue: 90/255, alpha: 1).resizableImageWithCapInsets(capInsetsIncoming)
        let outgoing = maskOutgoing.imageWithRed(255/255, green: 255/255, blue: 255/255, alpha: 1).resizableImageWithCapInsets(capInsetsOutgoing)
        let outgoingHighlighted = maskOutgoing.imageWithRed(240/255, green: 240/255, blue: 240/255, alpha: 1).resizableImageWithCapInsets(capInsetsOutgoing)
        
        return (incoming, incomingHighlighted, outgoing, outgoingHighlighted)
    }()
    let messageLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        bubbleImageView = UIImageView(image: ChatBubbleCell.bubbleImage.incoming, highlightedImage: ChatBubbleCell.bubbleImage.incomingHighlighed)
        bubbleImageView.tag = bubbleTag
        bubbleImageView.userInteractionEnabled = true // #CopyMesage
        
        messageLabel = UILabel(frame: CGRectZero)
        messageLabel.font = UIFont.systemFontOfSize(15)
        messageLabel.numberOfLines = 0
        messageLabel.userInteractionEnabled = false   // #CopyMessage
        messageLabel.preferredMaxLayoutWidth = 218
        
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
        
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bubbleImageView.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(4.5)
            make.width.equalTo(messageLabel.snp_width).offset(30)
            make.bottom.equalTo(contentView).offset(-4.5)
        }
        messageLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(bubbleImageView).offset(3)
            make.centerY.equalTo(bubbleImageView).offset(-0.5)
            make.height.equalTo(bubbleImageView).offset(-15)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithMessage(message: Message) {
        messageLabel.text = message.text
        if message.incoming {
            messageLabel.textColor = .whiteColor()
        }
        
        if message.incoming != (tag == incomingTag) {
            var layoutAttribute: NSLayoutAttribute
            var layoutConstant: CGFloat
            
            if message.incoming {
                tag = incomingTag
                bubbleImageView.image = ChatBubbleCell.bubbleImage.incoming
                bubbleImageView.highlightedImage = ChatBubbleCell.bubbleImage.incomingHighlighed
                messageLabel.textColor = .whiteColor()
                layoutAttribute = .Left
                layoutConstant = 10
            } else { // outgoing
                tag = outgoingTag
                bubbleImageView.image = ChatBubbleCell.bubbleImage.outgoing
                bubbleImageView.highlightedImage = ChatBubbleCell.bubbleImage.outgoingHighlighed
                messageLabel.textColor = .blackColor()
                layoutAttribute = .Right
                layoutConstant = -10
            }
            
            let layoutConstraint: NSLayoutConstraint = bubbleImageView.constraints[1] // `messageLabel` CenterX
            layoutConstraint.constant = -layoutConstraint.constant
            
            let constraints: NSArray = contentView.constraints
            let indexOfConstraint = constraints.indexOfObjectPassingTest { constraint, idx, stop in
                return (constraint.firstItem as! UIView).tag == bubbleTag && (constraint.firstAttribute == NSLayoutAttribute.Left || constraint.firstAttribute == NSLayoutAttribute.Right)
            }
            contentView.removeConstraint(constraints[indexOfConstraint] as! NSLayoutConstraint)
            contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: layoutAttribute, relatedBy: .Equal, toItem: contentView, attribute: layoutAttribute, multiplier: 1, constant: layoutConstant))
        }
    }
    
    // Highlight cell #CopyMessage
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleImageView.highlighted = selected
    }
}

extension UIImage {
    func imageWithRed(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.drawInRect(rect)
        CGContextSetRGBFillColor(context, red, green, blue, alpha)
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
        CGContextFillRect(context, rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
