//
//  JVFloatLabeledTextField+Underline.swift
//  QuantumListing
//
//  Created by Colin Taylor on 6/17/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import Foundation
import JVFloatLabeledTextField

extension JVFloatLabeledTextField
{
    func addUnderline()
    {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = Utilities.borderGrayColor.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
