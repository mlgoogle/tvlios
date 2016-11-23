//
//  InputTextView.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/3.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation

class InputTextView: UITextView {
    // Only show "Copy" when selecting a row while `textView` is first responder #CopyMessage
    override func canPerformAction(_ action: Selector, withSender sender: Any!) -> Bool {
        if (delegate as! ChatVC).chatTable!.indexPathForSelectedRow != nil {
            return action == #selector(ChatVC.messageCopyTextAction(_:))
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    // More specific than implementing `nextResponder` to return `delegate`, which might cause side effects?
    func messageCopyTextAction(_ menuController: UIMenuController) {
        (delegate as! ChatVC).messageCopyTextAction(menuController)
    }
}

