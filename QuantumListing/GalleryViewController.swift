//
//  GalleryViewController.swift
//  QuantumListing
//
//  Created by Colin Taylor on 6/7/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource {
    @IBOutlet weak var collectionGallery: UICollectionView!

    var galleryUrls : [String] = [String]()
    var property_id : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getGalleryList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func getGalleryList()
    {
        let parameters = ["property_id" : property_id]
        
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=gallery_list_from_id", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            
            
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! NSDictionary
                
                print(responseJson)
                
                let result = responseJson["images"] as? [[String : String]]
                
                if result == nil
                {
                    return
                }
                
                for object in result!
                {
                    let url = object["url_image"]
                    self.galleryUrls.append(url!)
                }
                
                print(self.galleryUrls)
                
                self.collectionGallery.reloadData()
            }catch{
                
            }
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(String(describing: error))")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    //collection view datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return galleryUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath)
        
        let imageView = cell.viewWithTag(1) as! UIImageView

        imageView.setShowActivityIndicator(true)
        imageView.setIndicatorStyle(.gray)
        imageView.sd_setImage(with: URL(string: galleryUrls[indexPath.row])!)
        
        
        return cell
    }

}
