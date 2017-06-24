//
//  CollectionViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/24/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner

class CollectionViewController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let kCollectionCellId = "CollectionCell"
    var listings: NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listings = NSMutableArray()
        self.updateData()
        self.collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: kCollectionCellId)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(actSwipe))
        collectionView.addGestureRecognizer(swipeGesture)
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func actSwipe(_ gesture: UISwipeGestureRecognizer) {
        let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
        if (indexPath != nil) {
            self.deleteItemAtIndexPath(indexPath!)
        }
    }
    
    func updateData() {
        self.getCollections()
    }
    
    func getCollections() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let parameters: NSMutableDictionary = ["user_id": (delegate?.user?.user_id)!]
        
        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=get_favorites", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            
            if ((self.listings?.count)! > 0) {
                self.listings?.removeAllObjects()
            }
            else {
                self.listings = NSMutableArray()
            }
            
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! [Any]
                print(responseJson)
                
                
                self.listings?.addObjects(from: responseJson)
                self.collectionView.reloadData()
                
                if (self.listings?.count == 0) {
                    self.lblNotification.isHidden = false
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
    
    // UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (listings?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionCellId, for: indexPath) as! CollectionCell
        let listing = listings?.object(at: indexPath.row) as! NSDictionary
        let listing_images = NSDictionary(object: (listing["property_image"] as! NSArray)[0] as! NSDictionary, forKey: "images" as NSCopying)
        cell.listing = listing_images
        cell.configureCell()
        cell.backgroundColor = UIColor.darkGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        let dict = listings?[indexPath.row] as? NSDictionary
        
        dc.listing = dict
        dc.isOwner = false
        
        self.navigationController?.pushViewController(dc, animated: true)

    }
    
    func deleteItemAtIndexPath(_ indexPath: IndexPath) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let listing = listings?.object(at: indexPath.row) as! NSDictionary
        let listing_property = listing["property_info"] as! NSDictionary
        let parameters: NSMutableDictionary = ["property_id": listing_property["property_id"] as! String, "user_id": (delegate?.user?.user_id)!]
        
        CircularSpinner.show("Deleting", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=delete_favorites", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            
            if ((self.listings?.count)! > 0) {
                self.listings?.removeAllObjects()
            }
            else {
                self.listings = NSMutableArray()
            }
            
            do {
                
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! [Any]
                print(responseJson)
                
                
                
                self.listings?.addObjects(from: responseJson)
            }catch{
                
            }

            self.collectionView.reloadData()
 
            if (self.listings?.count == 0) {
                self.lblNotification.isHidden = false
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


}
