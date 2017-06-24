//
//  UIImageView+DashedBorder.swift
//  QuantumListing
//
//  Created by Colin Taylor on 6/17/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import Foundation

extension UIImageView
{
    func addDashedBorderLayerWithColor(color:CGColor)
    {
        
        let  borderLayer = CAShapeLayer()
        borderLayer.name  = "borderLayer"
        let frameSize = self.frame.size
        //frameSize.width = frameSize.width - 40
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        borderLayer.bounds=shapeRect
        borderLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color
        borderLayer.lineWidth=1
        borderLayer.lineJoin=kCALineJoinRound
        borderLayer.lineDashPattern = [5, 5]
        
        let path = UIBezierPath.init(roundedRect: shapeRect, cornerRadius: 0)
        
        borderLayer.path = path.cgPath

        self.layer.addSublayer(borderLayer)
    }
}
