//
//  ChangeViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner
import ESPullToRefresh
import CoreLocation

class ChangeViewController: UIViewController, ListingCellDelegate, UITableViewDelegate, UITableViewDataSource{

    var listings: NSMutableArray?
    var currentIndex: Int?
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var lblNoListings: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        listings = NSMutableArray()
        currentIndex = 0;

        self.myTableView.es_addPullToRefresh {
            self.updateData()
        }
        self.myTableView.es_addInfiniteScrolling {
            self.loadMore()
        }
        self.myTableView.es_startPullToRefresh()

        //add tap gesture recognizer to the title view
        let titleView = UILabel()
        titleView.text = "MY LISTINGS"
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width : width, height : 500))
        self.navigationItem.titleView = titleView
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        self.navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapTitle)))
    }
    
    func onTapTitle(_ : UITapGestureRecognizer)
    {
        //scroll to top
        self.myTableView.es_startPullToRefresh()
    }
    
    
    func updateData() {
        listings?.removeAllObjects()
        currentIndex = 0
        self.myTableView.reloadData()
        self.getFeed()
    }
    
    func getFeed() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let parameters: NSMutableDictionary = ["user_id": (delegate?.user?.user_id)!, "index": String(format: "%d", currentIndex!)]
        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=property_list_from_user_id_by_index", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            do {
                let responseJson = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: []) as! [Any]
                print(responseJson)
                //self.listings?.addObjects(from: responseJson)
                
                for object in responseJson
                {
                    let info = (object as! NSDictionary)
                    if info["user_info"] is NSDictionary && info["property_info"] is NSDictionary
                    {
                        self.listings?.add(object)
                    }
                }
                
                self.myTableView.reloadData()
                if ((self.listings?.count)! > 0) {
                    self.lblNoListings.isHidden = true
                }
                
                
            }catch{
                
            }
            self.myTableView.es_stopLoadingMore()
            self.myTableView.es_stopPullToRefresh()
            self.view.endEditing(true)
            CircularSpinner.hide()
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(String(describing: error))")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
        })
        
    }


    func loadMore()
    {
        currentIndex! += 10
        self.getFeed()
    }
    

    // TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (listings?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! CardCell
        
        if listings?.count == 0 {
            return cell
        }
        
        let listing = listings?[indexPath.row] as! NSDictionary
        let listing_images = listing["property_image"] as? NSArray
        
        var listing_image = NSDictionary()
        
        if(listing_images != nil) {
            listing_image = listing_images?[0] as! NSDictionary
            let strPath = listing_image["property_image"] as? String
            if strPath != nil {
                cell.setImageURL(imageURL: strPath!)
            }
        }
        
        let listing_user = listing["user_info"] as! NSDictionary
        if(true) {
            cell.setHaveContact(hc: true)
            cell.listing_email = listing_user["email"] as? String
            cell.listing_phone = listing_user["mobile"] as? String
            cell.listing_phone = listing_user["website"] as? String
            let strUser = listing_user["username"] as? String
            if (strUser != nil) {
                //cell.lblUser.text = strUser
            }
            
            let strAvartar = listing_user["profile_pic"] as? String
            if strAvartar != nil {
                cell.setAvatarImageURL(imageURL: strAvartar!)
                cell.ivPortrait.isHidden = true
            }
 
        }
        
        let temp = listings?.object(at: indexPath.row) as! NSDictionary
        //cell.lblDate?.text = "\(abs((temp["time_elapsed"] as! NSString).integerValue)) days"
        
        let listing_property = listing["property_info"] as! NSDictionary
        if(true) {
            let strTitle = listing_property["property_name"] as? String
            if strTitle != nil {
                cell.kiTitle.text = strTitle!
            }

            //cell.lblDate?.text = "\(abs((temp["time_elapsed"] as! NSString).integerValue)) days"
            cell.lblRentPSF?.text = "$\((listing_property["amount"] as! NSString).integerValue)"
            cell.lblSQFT.text = "\(listing_property["sqft"] as! String) SQFT"
            cell.lblAssetType.text = listing_property["property_type"] as! String

            if ((listing_property["property_for"] as! String) == "lease") {
                cell.lblLeaseType.text = "For Lease"
            }
            else {
                cell.lblLeaseType.text = "For Sale"
            }
        }
        cell.buttonAddress.setTitle("   \(listing_property["address"] as! String)", for: UIControlState.normal)
        
        cell.buttonAddress.isHidden = false
        //cell.viewAddress.isHidden = false
        
        
        cell.delegate = self
        cell.index = indexPath.row
        cell.configureCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        print(indexPath.row)
        let dict = listings?[indexPath.row] as? NSDictionary
        dc.listing = dict
        dc.isOwner = true
        
        self.navigationController?.pushViewController(dc, animated: true)
    }

    // Cell Delegate
    func didPressedLikeButton(_ index: Int) {
        
    }
    
    func didPressedAddressIndex(_ index: Int) {
        let dict = listings?[index] as! NSDictionary
        let listing_property = dict["property_info"] as! NSDictionary
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees((listing_property["latitude"] as! NSString).doubleValue), CLLocationDegrees((listing_property["lognitude"] as! NSString).doubleValue))
        if (coordinate.latitude != 0 && coordinate.longitude != 0) {
            mapVC.selectedLocation = coordinate
            self.navigationController?.pushViewController(mapVC, animated: true)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no map location was added", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didPressedActionButton(_ index: Int) {
        let listing = listings?.object(at: index) as! NSDictionary
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        let albumAction = UIAlertAction(title: "Save to album", style: .default) { (alert: UIAlertAction!) -> Void in
            let cell = self.myTableView.cellForRow(at: IndexPath(row: index, section: 0)) as! CardCell
            UIImageWriteToSavedPhotosAlbum(cell.ivListing.image!, nil, nil, nil)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (alert: UIAlertAction!) -> Void in
            let id = ((listing["property_info"] as! NSDictionary)["property_id"] as! String)
            //let temp = listing["property_info"] as! NSDictionary
            self.deleteProperty(id)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert: UIAlertAction!) in
            
        }
        
        actionSheet.addAction(albumAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion:nil)
    }
    
    func didPressedCommentButton(_ index: Int) {
        
    }
    
    func didPressedShowCommentButton(_ index: Int) {
        
    }
    
    func didPressedShowLikeButton(_ index: Int) {
        
    }
    
    func didPressedHashTag(_ hashtag: String) {
        
    }
    
    func didPressedUserIndex(_ index: Int) {
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userVC = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
    
        self.navigationController?.pushViewController(userVC, animated: true)
        */
    }
    
    func didPressedUsername(_ username: String) {
        
    }
    
    func reportProperty(_ property_id : String) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let parameters: NSMutableDictionary = ["property_id": property_id, "user_id": (delegate?.user?.user_id)!]
        
        CircularSpinner.show("Reporting", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=flag_property", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! [String:Any]
                print(responseJson)
                let alert = UIAlertController(title: "QuantumListing", message: responseJson["Successfully reported"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }catch{
                
            }
            CircularSpinner.hide()
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(error)")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
    }
    
    func deleteProperty(_ property_id: String) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let parameters: NSMutableDictionary = ["property_id": property_id, "user_id": (delegate?.user?.user_id)!]
        
        CircularSpinner.show("Deleting", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=delete_property", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            
            self.updateData()
            CircularSpinner.hide()
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(error)")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
    }
    
    func isValidMembership() -> Bool {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let str_end = delegate!.user!.ms_endDate
        let endDate = Utilities.date(fromString: str_end)
        if (endDate.timeIntervalSinceNow > 0) {
            return true
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func actStore(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pdfVC = storyboard.instantiateViewController(withIdentifier: "PDFManageViewController") as! PDFManageViewController
        pdfVC.isHideDisclaimer = true
        let pdfNav = UINavigationController(rootViewController: pdfVC)
        pdfNav.isNavigationBarHidden = true
        self.navigationController?.present(pdfNav, animated: true, completion: nil)
    }

    @IBAction func actCollection(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let collectionVC = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
        self.navigationController?.pushViewController(collectionVC, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
