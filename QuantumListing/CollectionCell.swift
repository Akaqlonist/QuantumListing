//
//  CollectionCell.swift
//  QuantumListing
//
//  Created by gOd on 4/13/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    var imgView: UIImageView?
    var listing: NSDictionary?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgView = UIImageView(frame: CGRect(x: 2, y: 2, width: frame.size.width - 4, height: frame.size.height - 4))
        imgView?.clipsToBounds = true
        imgView?.contentMode = .scaleAspectFill
        
        self.addSubview(imgView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        let images = listing?["images"]
        var strURL = ""
        if images is NSDictionary
        {
            strURL = (images as! NSDictionary)["property_image"] as! String
        }
        else
        {
            strURL = ((images as! NSArray)[0] as! NSDictionary)["property_image"] as! String
        }

        imgView?.setShowActivityIndicator(true)
        imgView?.setIndicatorStyle(.gray)
        imgView?.sd_setImage(with: URL(string: strURL)!)
        
    }
}
