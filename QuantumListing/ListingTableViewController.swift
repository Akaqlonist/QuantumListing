//
//  ListingTableViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/30/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import AFNetworking
import CircularSpinner
import ESPullToRefresh
import UXMPDFKit

class ListingTableViewController: UITableViewController, ListingCellDelegate, CLLocationManagerDelegate{
    
    var delegate: AppDelegate?
    var listings : NSMutableArray?
    var selectedDict: NSDictionary?
    var locationManager: CLLocationManager?
    var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        listings = NSMutableArray()
        
        currentIndex = 0

        
        delegate = UIApplication.shared.delegate as? AppDelegate
        
        //add tap gesture recognizer to the title view
        let titleView = UILabel()
        titleView.text = "PUBLIC LISTINGS"
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width : width, height : 500))
        self.navigationItem.titleView = titleView
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        self.navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapTitle)))
        
        self.tableView.es_addPullToRefresh {
            self.updateData()
        }
        self.tableView.es_addInfiniteScrolling {
            self.loadMore()
        }
        self.tableView.es_startPullToRefresh()
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onTapTitle(_ : UITapGestureRecognizer)
    {
        //refresh
        self.tableView.es_startPullToRefresh()
    }

    func updateData() {
        listings?.removeAllObjects()
        self.tableView.reloadData()
        currentIndex = 0
        self.getFeed()
    }
    
    func getFeed() {
        let parameters: NSMutableDictionary = ["user_id": (delegate?.user?.user_id)!, "property_type": "recent", "index": String.init(format: "%d", currentIndex!)]
        
        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false, delegate: nil)
        
        ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=property_list_by_index", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! [Any]
                print(responseJson)
                
                for object in responseJson
                {
                    let info = (object as! NSDictionary)
                    if info["user_info"] is NSDictionary && info["property_info"] is NSDictionary
                    {
                        self.listings?.add(NSMutableDictionary(dictionary: object as! NSDictionary))
                    }
                }

                self.tableView.reloadData()
                
                
            }catch{
                
            }
            self.tableView.es_stopPullToRefresh()
            self.tableView.es_stopLoadingMore()
            self.view.endEditing(true)
            
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
    
    
    func loadMore()
    {
        if(currentIndex! >= 90) {
            self.tableView.es_stopPullToRefresh()
            self.tableView.es_stopLoadingMore()
            let alert = UIAlertController(title: "QuantumListing", message: "You can find more Listings in search", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            currentIndex! += 10
            self.getFeed()
        }
    }
    
        // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (listings?.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            cell.listing_website = listing_user["website"] as? String
            let strUser = listing_user["username"] as? String
            if (strUser != nil) {
                cell.lblUsername.text = strUser
            }
            let strAvartar = listing_user["profile_pic"] as? String
            if strAvartar != nil {
                cell.ivAvartar.setIndicatorStyle(.gray)
                cell.ivAvartar.setShowActivityIndicator(true)
                cell.ivAvartar.sd_setImage(with: URL(string: strAvartar!)!)
                
                cell.ivPortrait.isHidden = true
            }
        }
        
        
        
        let listing_property = listing["property_info"] as! NSDictionary
        if(true) {
            let strTitle = listing_property["property_name"] as? String
            if strTitle != nil {
                cell.kiTitle.text = strTitle
            }
            if ((listing_property["property_for"] as! String) == "lease") {
                cell.lblLeaseType.text = "For Lease"
            }
            else if((listing_property["property_for"] as! String) == "sale")
            {
                cell.lblLeaseType.text = "For Sale"
            }
            else
            {
                cell.lblLeaseType.text = "For Sale & Lease"
            }
            let temp = listing_property["amount"] as! String
            cell.lblRentPSF.text = "$\(temp)"
             
        }
        //let temp = listing["time_elapsed"] as! String
        //cell.lblDate.text = "\(temp)              days"
        cell.lblRentPSF?.text = "$\(listing_property["amount"] as! String)"
        cell.lblSQFT.text = "\(listing_property["sqft"] as! String)"
        cell.lblAssetType.text = listing_property["property_type"] as? String
        
        cell.buttonAddress.setTitle("   \(listing_property["address"] as! String)", for: UIControlState.normal)
        
        if listing["isFavorite"] as! Int == 0
        {
            cell.btnFavorite.setImage(UIImage(named: "flag@4x"), for: .normal)
        }
        else
        {
            cell.btnFavorite.setImage(UIImage(named: "flag_fill@4x"), for: .normal)
        }
        
        cell.delegate = self
        cell.index = indexPath.row
        cell.configureCell()
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        print(indexPath.row)
        let dict = listings?[indexPath.row] as? NSDictionary
        dc.listing = dict
        dc.scrollViewShouldMoveUp = false
        dc.isOwner = (dict?["user_info"] as! NSDictionary)["user_id"] as! String == (UIApplication.shared.delegate as! AppDelegate).user!.user_id ? true : false
        
        self.navigationController?.pushViewController(dc, animated: true)
    }

    // ListingCellDelegate
    
    func didPressedLikeButton(_ index: Int) {
        selectedDict = listings?[index] as?  NSDictionary
        favorite_property(index: index)
        
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
        selectedDict = listings?.object(at: index) as? NSDictionary
        let listing_property = selectedDict?["property_info"] as! NSDictionary
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
//        let viewAction = UIAlertAction(title: "View on Map", style: .default) { (alert: UIAlertAction!) -> Void in
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
//            
//            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees((listing_property["latitude"] as! NSString).doubleValue), CLLocationDegrees((listing_property["lognitude"] as! NSString).doubleValue))
//            if (coordinate.latitude != 0 && coordinate.longitude != 0) {
//                mapVC.selectedLocation = coordinate
//                self.navigationController?.pushViewController(mapVC, animated: true)
//            }
//            else {
//                let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no map location was added", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//        
//        let galleryAction = UIAlertAction(title: "Open Gallery", style: .default){
//            (alert : UIAlertAction!) -> Void in
//            
//            let galleryVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
//            galleryVC.property_id = listing_property["property_id"] as! String
//            
//            self.navigationController?.pushViewController(galleryVC, animated: true)
//            
//        }
        
        let attachAction = UIAlertAction(title: "Open Attachment", style: .default) { (alert: UIAlertAction!) -> Void in
            let attachment = listing_property["document"] as! NSString
            if(attachment.pathExtension == "pdf") {
                let pdfURL = URL(string: attachment as String)
                self.downloadPDFIfFromWeb(pdfURL: pdfURL!)
            }
            else {
                let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no attachment was added", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
//        let favAction = UIAlertAction(title: "Save to Favorites", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
//            //let defaults = UserDefaults.standard
//            
//            if self.delegate?.products?.count == 0 {
//                let alert = UIAlertController(title: "QuantumListing", message: "Error on our side, try again later", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                return
//            }
//            if self.isValidMembership() {
//                self.productPurchased()
//            }
//            else {
//                let alert = UIAlertController(title: "QuantumListing", message: "Please upgrade your membership to access all Premium features of QuantumListing", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                
//            }
//        }
        
        let flagAction = UIAlertAction(title: "Flag As Inappropriate", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
            self.reportProperty(listing_property["property_id"] as! String)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert: UIAlertAction!) in
            
        }
        
        //actionSheet.addAction(viewAction)
        //actionSheet.addAction(galleryAction)
        actionSheet.addAction(attachAction)
        //actionSheet.addAction(favAction)
        actionSheet.addAction(flagAction)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userVC = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        let listing = listings?[index] as! NSDictionary
        userVC.user_info = NSMutableDictionary(dictionary: listing.object(forKey: "user_info") as! NSDictionary)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    func didPressedUsername(_ username: String) {
        
    }

    func isValidMembership() -> Bool {
        let str_end = delegate!.user!.ms_endDate
        let endDate = Utilities.date(fromString: str_end)
        if (endDate.timeIntervalSinceNow > 0) {
            return true
        }
        return false
    }
    
    // CLLocation Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        let nowLocation = currentLocation.coordinate
        delegate?.user?.latitude = String(format: "%f", nowLocation.latitude)
        delegate?.user?.longitude = String(format: "%f", nowLocation.longitude)
        
        delegate?.saveUserInfo()
        locationManager?.stopUpdatingLocation()
    }
    
    // PDF Management
    
    func isFromWeb(pdfURL: URL) -> Bool {
        if (pdfURL.scheme == "file") {
            return false
        }
        return true
    }
    
    func downloadPDFIfFromWeb(pdfURL :URL) {
        
        if self.isFromWeb(pdfURL: pdfURL) {
            let pdfName = pdfURL.lastPathComponent
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let path = URL(fileURLWithPath: paths[0]).appendingPathComponent(pdfName).absoluteString
            
            let request = URLRequest(url: pdfURL)
            
            let session = AFHTTPSessionManager()
            
            CircularSpinner.show("Opening", animated: true, type: .indeterminate, showDismissButton: false)
            
            let downloadTask = session.downloadTask(with: request, progress: { (progress: Progress) in
                
            }, destination: { (url :URL, response :URLResponse) -> URL in
                URL(string: path)!
            }, completionHandler: { (response: URLResponse, url: URL?, error: Error?) in
                print("response \(response)")
                self.openLocalPdf(URL(string: path)!)
                CircularSpinner.hide()
            })
            
            downloadTask.resume()
        }
        else {
            self.openLocalPdf(pdfURL)
        }
    }
    
    func openLocalPdf(_ localPath : URL) {
        let filePath = localPath.path
        
        let document = try! PDFDocument(filePath: filePath, password: "password_if_needed")
        let pdf = PDFViewController(document: document)
        
        self.navigationController?.pushViewController(pdf, animated: true)
    }
    
    func dismissReaderViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Property Management
    
    func reportProperty(_ property_id : String) {
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
            print("Error: \(String(describing: error))")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
    }
    
    func favorite_property(index : Int) {
        if (selectedDict == nil) {
            return;
        }
        let listing_property = selectedDict?["property_info"] as! NSDictionary
        
        let parameters: NSMutableDictionary = ["property_id": listing_property["property_id"] as! String, "user_id": (delegate?.user?.user_id)!]
        
        //CircularSpinner.show("", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=favorite_property", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! [String:Any]
                print(responseJson)
                let status = responseJson["status"] as! Int
                
                (self.listings?[index] as! NSMutableDictionary)["isFavorite"] = status
                self.tableView.reloadData()
//                let alert = UIAlertController(title: "QuantumListing", message: "You successfully added the Listing to your favorites", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
            }catch{
                
            }
            //CircularSpinner.hide()
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(String(describing: error))")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
            //CircularSpinner.hide()
        })
    }
    
    // IAP Management
    
//    func productPurchased() {
//        self.favorite_property()
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
