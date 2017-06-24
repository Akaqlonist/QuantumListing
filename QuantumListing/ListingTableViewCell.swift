//
//  ListingTableViewCell.swift
//  QuantumListing
//
//  Created by lucky clover on 3/30/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import KImageView
import SDWebImage

protocol ListingCellDelegate {
    func didPressedLikeButton(_ index: Int)
    
    func didPressedCommentButton(_ index: Int)
    
    func didPressedShowCommentButton(_ index: Int)
    
    func didPressedShowLikeButton(_ index: Int)
    
    func didPressedActionButton(_ index: Int)
    
    func didPressedHashTag(_ hashtag: String)
    
    func didPressedUserIndex(_ index: Int)
    
    func didPressedAddressIndex(_ index: Int)
}

class ListingTableViewCell: UITableViewCell {
    
    var index: Int?
    var listing_id: String?
    var listing_contacts: String?
    var listing_website: String?
    var listing_phone: String?
    var listing_email: String?
    var isHaveContact: Bool?
    var is_Owner: Bool?
    var delegate: ListingCellDelegate?
    var isBEditable: Bool?

    @IBOutlet weak var kiTitle: UILabel!
    @IBOutlet weak var buttonAddress: UIButton!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var iconEdit: UIImageView!
    @IBOutlet weak var lblLeaseType: UILabel!
    @IBOutlet weak var lblRentPSF: UILabel!
    @IBOutlet weak var ivListing: UIImageView!
    @IBOutlet weak var txtEditTitle: UITextField!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var vwPortrait: UIView!
    @IBOutlet weak var ivAvartar: UIImageView!
    @IBOutlet weak var ivPortrait: UIImageView!
    
    @IBAction func actUser(_ sender: Any) {
        self.delegate?.didPressedUserIndex(self.index!)
    }
    @IBAction func actReport(_ sender: Any) {
        self.delegate?.didPressedActionButton(self.index!)
    }
    @IBAction func onAddress(_ sender: Any) {
        if self.delegate != nil {
            self.delegate?.didPressedAddressIndex(self.index!)
        }
    }
    @IBAction func actEmail(_ sender: Any) {
        if (self.listing_email != nil) {
            UIApplication.shared.open(URL(string: "mailto:\(self.listing_email!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid email address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }

    }
    @IBAction func actPhone(_ sender: Any) {
        if (self.listing_phone != nil) {
            listing_phone = listing_phone?.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
            UIApplication.shared.open(URL(string: "tel:\(self.listing_phone!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid phone number has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func actGlobe(_ sender: Any) {
        if (self.listing_website != nil) && (self.listing_website?.characters.count ?? 0) > 4 {
            if (self.listing_website?.substring(to: (self.listing_website?.index((self.listing_website?.startIndex)!, offsetBy: 4))!) == "http") {
                UIApplication.shared.open(URL(string: self.listing_website!)!, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.open(URL(string: "http://\(self.listing_website!)")!, options: [:], completionHandler: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid website address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            
        }

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImageURL(imageURL: String) {

        self.ivListing.setShowActivityIndicator(true)
        self.ivListing.setIndicatorStyle(.gray)
        self.ivListing.sd_setImage(with: URL(string: imageURL)!)
    }
    
    func setAvatarImageURL(imageURL: String)
    {
        self.ivAvartar.sd_setImage(with: URL(string: imageURL)!)
        self.ivAvartar.setShowActivityIndicator(true)
        self.ivAvartar.setIndicatorStyle(.gray)
        
    }
    
    func setHaveContact(hc: Bool) {
        isHaveContact = hc
    }
    
    func configureCell() {
        vwPortrait.layer.cornerRadius = vwPortrait.bounds.width / 2.0
        vwPortrait.layer.masksToBounds = true
        let gradient = CAGradientLayer()
        gradient.frame = viewAddress.bounds
        gradient.colors = [(UIColor(white: CGFloat(1.0), alpha: CGFloat(0.0)).cgColor), UIColor(white: CGFloat(1.0), alpha: CGFloat(0.8)).cgColor, (UIColor.white.cgColor)]
        viewAddress.layer.insertSublayer(gradient, at: 0)
    
        
        self.selectionStyle = .none
    }


}
