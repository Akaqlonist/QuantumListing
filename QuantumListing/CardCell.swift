//
//  CardCell.swift
//  QuantumListing
//
//  Created by Colin Taylor on 6/19/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

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
    @IBOutlet weak var lblLeaseType: UILabel!
    @IBOutlet weak var lblRentPSF: UILabel!
    @IBOutlet weak var ivListing: UIImageView!
    @IBOutlet weak var txtEditTitle: UITextField!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var vwPortrait: UIView!
    @IBOutlet weak var ivAvartar: UIImageView!
    @IBOutlet weak var ivPortrait: UIImageView!
    @IBOutlet weak var lblSQFT: UILabel!
    @IBOutlet weak var lblAssetType: UILabel!
    @IBOutlet weak var bgView: UIView!
    

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

        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = Utilities.borderGrayColor.cgColor
        
        bgView.layer.shadowColor = UIColor.gray.cgColor
        bgView.layer.shadowOpacity = 0.6
        bgView.layer.shadowRadius = 2.0
        bgView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        
        self.selectionStyle = .none
    }


}
