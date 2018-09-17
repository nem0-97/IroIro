//
//  UITextFieldExtension.swift
//  IroIro
//
//  Created by Ezhik on 6/19/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//
//  https://stackoverflow.com/a/41087703

import UIKit

extension UITextField
{
    func setBottomBorder(borderColor: UIColor)
    {
        
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        let width = 1.0
        
        let borderLine = UIView()
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - width, width: Double(self.frame.width), height: width)
        
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}
