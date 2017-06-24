//
//  UserViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import BSKeyboardControls
import CircularSpinner
import AFNetworking

class UserViewController: UIViewController ,BSKeyboardControlsDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, DLCImagePickerDelegate{
    
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonWebsite: UIButton!
    @IBOutlet weak var buttonPhone: UIButton!
    @IBOutlet weak var buttonEmail: UIButton!
    @IBOutlet weak var vwPortrait: UIView!
    @IBOutlet weak var ivAvartar: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var txtBio: UITextView!
    @IBOutlet weak var lblListings: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var lblName: UILabel!
    
    var user_info : NSDictionary?
    var is_following: Bool?
    var listing: NSMutableArray?
    var delegate: AppDelegate?
    let kCollectionCellId = "CollectionCell"
    @IBOutlet weak var followBtnHConstraint: NSLayoutConstraint!
    var keyboardControls: BSKeyboardControls?
    var userFollowings : [String] = [String]()
    var userFollowers : [String] = [String]()
    var followerTapped = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = UIApplication.shared.delegate as? AppDelegate
        
        is_following = false
        
        self.collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: kCollectionCellId)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 2.0
        vwPortrait.layer.cornerRadius = vwPortrait.bounds.width / 2.0
        vwPortrait.layer.masksToBounds = true
        listing = NSMutableArray()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        self.configureUserInterface()
        self.getProfileInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureUserInterface() {
        if user_info == nil
        {
            return
        }
        
        if (user_info?["user_id"] as! String) == delegate?.user?.user_id {
            if ((self.navigationController?.viewControllers.count)! > 1) {
                btnBack.isHidden = false
            }
            else {
                btnBack.isHidden = true
            }
            
            btnUpload.isHidden = false
            //txtBio.isEditable = true
            btnFollow.isHidden = true
            followBtnHConstraint.constant = 0.0
            
            btnAccount.isHidden = false
            btnSettings.isHidden = false
            buttonWebsite.isUserInteractionEnabled = false
            buttonPhone.isUserInteractionEnabled = false
            buttonEmail.isUserInteractionEnabled = false
            keyboardControls = BSKeyboardControls()
            keyboardControls?.delegate = self
            //keyboardControls?.fields = [txtBio]
            if !(delegate?.user?.isUpdatedProfile)! {
                lblReminder.isHidden = false
            }
            lblName.text = delegate?.user?.uname
        }
        else {
            lblTitle.text = "Profile"
            lblName.text = user_info?["username"] as! String?
            btnBack.isHidden = false
            btnUpload.isHidden = true
            //txtBio.isEditable = false
            btnFollow.isHidden = false
            btnAccount.isHidden = true
            btnSettings.isHidden = true
            buttonWebsite.isHidden = false
            buttonEmail.isHidden = false
            buttonPhone.isHidden = false
        }
        let path = user_info?["profile_pic"] as! String
        if path.characters.count > 0 {
            self.ivAvartar.setShowActivityIndicator(true)
            self.ivAvartar.setIndicatorStyle(.gray)
            self.ivAvartar.sd_setImage(with: URL(string: path)!)

            self.imgProfile.isHidden = true
        }

        
        //
        buttonEmail.setTitle("  \(user_info?["email"] as! String)", for: .normal)
        buttonWebsite.setTitle("  \(user_info?["website"] as! String)", for: .normal)
        buttonPhone.setTitle("  \(user_info?["mobile"] as! String)", for: .normal)
        
        
        //add tap gestures to follower & following label
        lblFollowers.isUserInteractionEnabled = true
        lblFollowing.isUserInteractionEnabled = true
        lblFollowers.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFollower)))
        lblFollowing.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFollowing)))
    }
    
    func onTapFollower(_ : UITapGestureRecognizer)
    {
        self.followerTapped = true
        performSegue(withIdentifier: "ProfileToUserList", sender: nil)
    }
    
    func onTapFollowing(_ : UITapGestureRecognizer)
    {
        self.followerTapped = false
        performSegue(withIdentifier: "ProfileToUserList", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ProfileToUserList"
        {
            let vc = segue.destination as! FollowUserTableViewController
            
            if followerTapped == true
            {
                vc.userIdList = self.userFollowers
                vc.navTitle = "FOLLOWERS"
            }
            else
            {
                vc.userIdList = self.userFollowings
                vc.navTitle = "FOLLOWING"
            }
        }
        
        //super.prepare(for: segue, sender: sender)
    }
    
    
    func getProfileInfo() {
        if user_info == nil
        {
            return
        }
        
        
        
        let parameters: NSMutableDictionary = ["user_id": user_info!["user_id"] as! String]
        
        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=user_profile_from_id", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! NSDictionary
                
                if (self.listing?.count)! > 0 {
                    self.listing?.removeAllObjects()
                }
                else {
                    self.listing = NSMutableArray()
                }
                
                let user_listings = responseJson["user_listings"] as? [Any]
                if (user_listings != nil) {
                    self.lblListings.text = "\((user_listings?.count)!) Listings"
                    self.listing?.addObjects(from: user_listings!)
                }
                else
                {
                    self.lblListings.text = "0 Listings"
                }
                
                self.collectionView.reloadData()
                
                let user_followings = responseJson["user_followings"] as? NSArray
                if (user_followings != nil) {
                    self.lblFollowing.text = "\((user_followings?.count)!) Following"
                
                    self.userFollowings.removeAll()
                    
                    for item in user_followings!
                    {
                        let user_id = (item as! NSDictionary)["to_user_id"] as! String
                        self.userFollowings.append(user_id)
                    }
                }
                
                let user_followers = responseJson["user_followers"] as? NSArray
                if (user_followers != nil) {
                    self.lblFollowers.text = "\((user_followers?.count)!) Followers"
                    let temp = user_followers?.value(forKey: "from_user_id") as! NSArray
                    if(temp.contains((self.delegate?.user?.user_id)!)) {
                        self.is_following = true
                        self.btnFollow.setTitle("Following", for: .normal)
                    }
                    else
                    {
                        self.is_following = false
                        self.btnFollow.setTitle("Follow", for: .normal)
                    }
                
                    
                
                    if self.listing?.count == 0 {
                        self.lblNotification.isHidden = false
                    }
                    else
                    {
                        self.lblNotification.isHidden = true
                    }
                    
                    self.userFollowers.removeAll()
                    
                    for item in user_followers!
                    {
                        let user_id = (item as! NSDictionary)["from_user_id"] as! String
                        self.userFollowers.append(user_id)
                    }
                }
                
            }catch{
                
            }
            CircularSpinner.hide()
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(String(describing: error))")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
    }
    
    @IBAction func actSettings(_ sender: Any) {
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actAccount(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.delegate = self.delegate
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actFollow(_ sender: Any) {
        if !is_following! {
            self.follow_user()
        }
        else {
            self.unfollow_user()
        }
    }
    @IBAction func actUpload(_ sender: Any) {
        
        
    }
    @IBAction func onEmail(_ sender: Any) {
        let listing_email = user_info?["email"] as? String
        if (listing_email != nil) {
            UIApplication.shared.open(URL(string: "mailto:\(listing_email!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid email address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    @IBAction func onPhone(_ sender: Any) {
        var listing_phone = user_info?["mobile"] as? String
        if (listing_phone != nil) {
            listing_phone = listing_phone?.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
            UIApplication.shared.open(URL(string: "tel:\(listing_phone!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid phone number has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func onWebsite(_ sender: Any) {
        let listing_website = user_info?["website"] as? String
        if (listing_website != nil) && (listing_website?.characters.count)! > 4 {
            if (listing_website!.substring(to: (listing_website?.index((listing_website?.startIndex)!, offsetBy: 4))!) == "http") {
                UIApplication.shared.open(URL(string: listing_website!)!, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.open(URL(string: "http://\(listing_website!)")!, options: [:], completionHandler: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid website address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func follow_user() {
        let parameters: NSMutableDictionary = ["to_user_id": user_info!["user_id"] as! String, "from_user_id":(delegate!.user?.user_id)!]
        
        CircularSpinner.show("", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=follow_user", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")

            self.getProfileInfo()

            CircularSpinner.hide()
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(String(describing: error))")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
    }
    
    func unfollow_user() {
        let parameters: NSMutableDictionary = ["to_user_id": user_info!["user_id"] as! String, "from_user_id":(delegate!.user?.user_id)!]
        
        CircularSpinner.show("", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=unfollow_user", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")

            self.getProfileInfo()

            CircularSpinner.hide()
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(String(describing: error))")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
    }
    
    // BSKeyboardControls Delegate
    
    func keyboardControlsDonePressed(_ keyboardControls: BSKeyboardControls!) {
        //self.txtBio.resignFirstResponder()
        self.updateProfileDetail()
    }
    
    func updateProfileDetail() {
        /*
        //let detail: NSMutableDictionary = ["about_me":txtBio.text, "user_id":(delegate?.user?.user_id)!]
        let master: NSMutableDictionary = ["user_id":(delegate?.user?.user_id)!]
        let parameters: NSMutableDictionary = ["detail": detail, "master":master]
        
        CircularSpinner.show("Updating", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=update_profile_detail", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
   
            //self.delegate?.user?.user_bio = self.txtBio.text
            self.delegate?.saveUserInfo()

            CircularSpinner.hide()
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(error)")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
 */
    }
    
    // UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (listing?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionCellId, for: indexPath) as! CollectionCell
        
        cell.listing = listing?.object(at: indexPath.row) as! NSDictionary?
        cell.configureCell()
        cell.backgroundColor = UIColor.darkGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        let dict = listing?[indexPath.row] as! NSDictionary
        let listing_images = dict["images"] is NSDictionary ? (dict["images"] as! NSDictionary) : ((dict["images"] as! NSArray)[0] as! NSDictionary)

        let listing_user: NSDictionary = user_info!
        
        let listing_info: NSDictionary = ["property_info":dict, "property_image":listing_images, "user_info":listing_user]
        
        vc.listing = listing_info
        
        vc.isOwner = (listing_info["user_info"] as! NSDictionary)["user_id"] as! String == (UIApplication.shared.delegate as! AppDelegate).user!.user_id ? true : false
        self.navigationController?.pushViewController(vc, animated: true)
 
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //DLCPickerController delegate
    func imagePickerControllerDidCancel(_ picker: DLCImagePickerController!) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: DLCImagePickerController!, didFinishPickingMediaWithInfo info: [AnyHashable : Any]!) {
        picker.dismiss(animated: true, completion: nil)
        
        ivAvartar.image = ((info as NSDictionary).object(forKey: "image") as! UIImage)
        imgProfile.isHidden = true
        self.uploadProfileImage()
    }
    
    func uploadProfileImage()
    {
        
        let parameters : NSMutableDictionary = ["user_id" : delegate!.user!.user_id]
        
        CircularSpinner.show("Updating", animated: true, type: .indeterminate, showDismissButton: false)
        
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=update_profile_image", parameters: parameters, constructingBodyWith: { (_ formData: AFMultipartFormData) in
            formData.appendPart(withFileData: UIImageJPEGRepresentation(self.ivAvartar.image!, 1.0)!, name: "fileToUpload", fileName: "photo.jpg", mimeType: "image/jpeg")
        }, progress: nil, success: {
        (operation , responseObject) in
        
            print("JSON: \(String(describing: responseObject))")
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! NSDictionary
                
                if responseJson.value(forKey: "status") as! String == "success"
                {
                    self.delegate?.user?.user_photo = responseJson.value(forKey: "path") as! String
                    self.delegate?.saveUserInfo()
                }
                
            }catch{
                
            }
            CircularSpinner.hide()
    }
    , failure: {
    (operation , error) in

        let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        self.view.endEditing(true)
        CircularSpinner.hide()
    })
    }

}
