//
//  IroIroTextView.swift
//  IroIro
//
//  Created by Ezhik on 6/19/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit

class IroIroTextView: UITextView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        replace(selectedTextRange!, withText: pasteboard.string ?? "")
    }
    override func copy(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = text(in: selectedTextRange!)
    }

}
