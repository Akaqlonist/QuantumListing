//
//  SearchViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import MapKit
import CircularSpinner
import JPSThumbnailAnnotation
import Alamofire

class SearchViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var btnListings: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    // Card view items
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var ivListing: UIImageView!
    @IBOutlet weak var lblSqft: UILabel!
    @IBOutlet weak var lblAssetType: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblFor: UILabel!
    @IBOutlet weak var btnFavorite: UIButton!
    
    
    var is_trend : Bool?
    var currentPlacemark : CLPlacemark?
    var locationManager : CLLocationManager?
    var geocodingResults : NSMutableArray?
    var geocoder : CLGeocoder?
    var searchTimer : Timer?
    var kSearchTextKey : String?
    var currentMode : Int?
    var annotations : NSMutableArray? = NSMutableArray()
    var raw_searches : NSMutableArray?  = NSMutableArray()
    var delegate : AppDelegate?
    var listing_list : NSMutableArray? = NSMutableArray()
    var currentIndex : Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
        delegate = UIApplication.shared.delegate as? AppDelegate
        currentMode = 1
        kSearchTextKey = "Search Text"
        annotations = NSMutableArray()
        geocodingResults = NSMutableArray()
        geocoder = CLGeocoder()
        
        configUI()
    }
    
    func configUI()
    {
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = Utilities.borderGrayColor.cgColor
        
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOpacity = 0.3
        cardView.layer.shadowRadius = 4.0
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        //cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 4
        cardView.isHidden = true
        
        ivListing.layer.borderColor = Utilities.borderGrayColor.cgColor
        ivListing.layer.borderWidth = 1
    }

    override func viewDidLayoutSubviews() {
        self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        if (is_trend == false && currentMode == 0) {
            if ((raw_searches?.count)! > 0) {
                self.applyFilter()
            }
        }
        
        if currentMode == 1
        {
            CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
            
            if (delegate?.user?.latitude != "" && delegate?.user?.longitude != "") {
                let nowLocation = CLLocationCoordinate2DMake(CLLocationDegrees(NSString(string: (delegate?.user?.latitude)!).doubleValue), CLLocationDegrees(NSString(string: (delegate?.user?.longitude)!).doubleValue))
                let viewRegion = MKCoordinateRegionMakeWithDistance(nowLocation, 15000, 15000)
                let adjustedRegion = self.mapView.regionThatFits(viewRegion)
                self.mapView.setRegion(adjustedRegion, animated: false)
                
                self.reverseGeocodeCoordinate(nowLocation)
            }
            else {
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.requestAlwaysAuthorization()
            }
        }
        
        self.cardView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func getTrends() {
        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=get_trends", parameters: nil, success: {(operation, responseObject) in

            
            do {
                print("\(String(describing: responseObject))")
             
                let responseJson = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: []) as! [Any]
                
                
                self.listing_list = NSMutableArray(array: responseJson)
                self.is_trend = true
            }
            catch{
                
            }
 
            self.myTableView.reloadData()
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
    
    func applyFilter() {
        listing_list?.removeAllObjects()
        listing_list = NSMutableArray(array: raw_searches!)
        
        let predicates = NSMutableArray()
        var result = NSMutableArray()
        if (delegate?.user?.uf_lease != "" && delegate?.user?.uf_lease != "Any") {
            var leasePredicate : NSPredicate?
            if (delegate?.user?.uf_lease == "For Sale") {
                leasePredicate = NSPredicate(block: {(object, _) -> Bool in
                    let evaulatedObject = object as! [String:Any]
                    let temp1 = evaulatedObject["property_info"] as! [String: Any]
                    let temp2 = temp1["property_for"] as! String
                    if (temp2 == "sale") {
                        return true
                    }
                    return false
                }
                )
            }
            else if (delegate?.user?.uf_lease == "For Lease"){
                
                leasePredicate = NSPredicate(block: {(object, _) -> Bool in
                    let evaulatedObject = object as! [String:Any]
                    let temp1 = evaulatedObject["property_info"] as! [String: Any]
                    let temp2 = temp1["property_for"] as! String
                    if (temp2 == "lease") {
                        return true
                    }
                    return false
                })
            }
            else
            {
                leasePredicate = NSPredicate(block: {(object, _) -> Bool in
                    let evaulatedObject = object as! [String:Any]
                    let temp1 = evaulatedObject["property_info"] as! [String: Any]
                    let temp2 = temp1["property_for"] as! String
                    if (temp2 == "sale&lease") {
                        return true
                    }
                    return false
                })
            }
            predicates.add(leasePredicate!)
        }
        
        if (((delegate?.user?.uf_building) != "") && delegate?.user?.uf_building != "Any") {
            let key = delegate?.user?.uf_building.uppercased()
            let buildingPredicate = NSPredicate(block: {(object, _) -> Bool in
                let evaulatedObject = object as! [String:Any]
                let temp1 = evaulatedObject["property_info"] as! [String: Any]
                let temp2 = temp1["property_type"] as! String
                if (temp2.uppercased() == key) {
                    return true
                }
                return false
            })
            predicates.add(buildingPredicate)
        }
        
        
        if (delegate?.user?.uf_priceStart != "" && delegate?.user?.uf_priceEnd != "") {
            if (Double((delegate?.user?.uf_priceStart)!)! == 0 && Double((delegate?.user?.uf_priceEnd)!)! == 1000) {
                
            }
            else {
                let pricePredicate = NSPredicate(block: {(object, _) -> Bool in
                    
                    let evaulatedObject = object as! [String:Any]
                    let temp1 = evaulatedObject["property_info"] as! [String: Any]
    
                    let temp2 = (temp1["rent_psf"] as! String) == "" ? 0 : Double(temp1["rent_psf"] as! String)!
                    if (temp2 >= Double((self.delegate?.user?.uf_priceStart)!)! && temp2 <= Double((self.delegate?.user?.uf_priceEnd)!)!) {
                        return true
                    }
                    return false
                })
                predicates.add(pricePredicate)
            }
        }
        
        if (delegate?.user?.uf_distanceStart != "" && delegate?.user?.uf_distanceEnd != "") {
            if (Double((delegate?.user?.uf_distanceStart)!)! == 0 && Double((delegate?.user?.uf_distanceEnd)!)! == 20) {
                
            }
            else {
                let distancePredicate = NSPredicate(block: {(object, _) -> Bool in
                    
                    let evaulatedObject = object as! [String:Any]
                    let temp1 = evaulatedObject["property_info"] as! [String: Any]
                    let longitude = Double(temp1["lognitude"] as! String)!
                    let latitude = Double(temp1["latitude"] as! String)!
                    
                    let objLocation = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
                    let currentLocation = CLLocationCoordinate2DMake(CLLocationDegrees(Double((self.delegate?.user?.latitude)!)!), CLLocationDegrees(Double((self.delegate?.user?.longitude)!)!))
                    let distance = Utilities.distance(fromLocation: currentLocation, toLocation: objLocation)
                    if (distance >= Float((self.delegate?.user?.uf_distanceStart)!)! && distance < Float((self.delegate?.user?.uf_distanceEnd)!)!) {
                        return true
                    }
                    return false
                    })
                predicates.add(distancePredicate)
            }
        }
        
        if (delegate?.user?.uf_dateFrom != "") {
            let datePredicate = NSPredicate(block: {(object, _) -> Bool in
                
                let evaluatedObject = object as! [String:Any]
                let temp1 = evaluatedObject["property_info"] as! [String: Any]
                let temp2 = temp1["created_date"] as! String
                let createdDate = Utilities.date(fromString: temp2)
                if (createdDate.timeIntervalSince(Utilities.date(fromStringShort: (self.delegate?.user?.uf_dateFrom)!)) > 0) {
                    return true
                }
                return false
                })
            predicates.add(datePredicate)
        }
        
        let temp = NSCompoundPredicate(andPredicateWithSubpredicates: predicates as NSArray as! [NSPredicate])
        result = NSMutableArray(array: (listing_list?.filtered(using: temp))!)
        
        //listing_list?.removeAllObjects()
        if (delegate?.user?.uf_sort != "" && delegate?.user?.uf_sort != "Any") {
            if (delegate?.user?.uf_sort == "Most Recent") {
                result.sort(comparator: { (o1, o2) -> ComparisonResult in
                    
                    let obj1 = o1 as! NSDictionary
                    let obj2 = o2 as! NSDictionary
                    let temp1 = obj1["property_info"] as! NSDictionary
                    let temp2 = temp1["created_date"] as! String
                    let date1 = Utilities.date(fromString: temp2)
                    
                    let temp3 = obj2["property_info"] as! NSDictionary
                    let temp4 = temp3["created_date"] as! String
                    let date2 = Utilities.date(fromString: temp4)
                    
                    if (date1 > date2) {
                        return .orderedDescending
                    }
                    else if (date1 == date2) {
                        return .orderedSame
                    }
                    else {
                        return .orderedAscending
                    }
                })
            }
            else {
                result.sort(comparator: { (o1, o2) -> ComparisonResult in
                    
                    let obj1 = o1 as! NSDictionary
                    let obj2 = o2 as! NSDictionary
                    let temp1 = obj1["property_info"] as! NSDictionary
                    let temp2 = temp1["created_date"] as! String
                    let date1 = Utilities.date(fromString: temp2)
                    
                    let temp3 = obj2["property_info"] as! NSDictionary
                    let temp4 = temp3["created_date"] as! String
                    let date2 = Utilities.date(fromString: temp4)
                    
                    if (date1 > date2) {
                        return .orderedAscending
                    }
                    else if (date1 == date2) {
                        return .orderedSame
                    }
                    else {
                        return .orderedDescending
                    }
                })
            }
        }
        listing_list = result
        self.myTableView.reloadData()
    }
    
    // Search Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        
        if (currentMode == 0) {
            self.searchByKeyword(searchBar.text!)
        }
        else {
            self.geocodeFromSearchText(searchBar.text!)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        if (currentMode == 0) {
            
        }
        else {
            myTableView.isHidden = true
        }
        self.getTrends()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        myTableView.isHidden = false
        cardView.isHidden = true
        myTableView.reloadData()
        searchBar.text = ""
    }
    
    func searchByKeyword(_ keyword: String) {
        let parameters: NSMutableDictionary = ["user_id": (delegate?.user?.user_id)!, "keyword": keyword]
        
        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=search_by_keyword", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! [Any]
                print(responseJson)
                
                self.listing_list?.removeAllObjects()
                self.raw_searches?.removeAllObjects()
                
                self.listing_list = NSMutableArray()
                self.raw_searches = NSMutableArray()
                
                for object in responseJson
                {
                    let dict = object as! NSDictionary
                    if dict["user_info"] as? NSDictionary != nil && dict["property_info"] as? NSDictionary != nil
                    {
                        let mutableDict = NSMutableDictionary(dictionary : dict)
                        self.listing_list?.add(mutableDict)
                        self.raw_searches?.add(mutableDict)
                    }
                }
                //self.listing_list = NSMutableArray(array: responseJson)
                //self.raw_searches = NSMutableArray(array: responseJson)
                
                self.searchBar .resignFirstResponder()
                self.is_trend = false
                self.applyFilter()
                //self.myTableView.reloadData()
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
    
    func downloadImage(with url: URL, completionBlock: @escaping (_ succeeded: Bool, _ image: UIImage) -> Void) {
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                let image = UIImage(data: data!)
                completionBlock(true, image!)
            }
            else {
                let image = UIImage()
                completionBlock(false, image)
            }
        }
    }
    
    func groupAnnotationsByLocationValue(_ annotations: [MKAnnotation]) -> NSDictionary {
        let result = NSMutableDictionary()
        for pin in annotations {
            let coordinate = pin.coordinate
            let coordinateValue = NSValue(mkCoordinate: coordinate)
            
            var annotationsAtLocation = result[coordinateValue] as? NSMutableArray
            
            if (annotationsAtLocation == nil) {
                annotationsAtLocation = NSMutableArray()
                result[coordinateValue] = annotationsAtLocation
            }
            
            annotationsAtLocation?.add(pin)
        }
        return result
    }
    
    func calculateCoordinate(from coordinate: CLLocationCoordinate2D, onBearing bearingInRadians: Double, atDistance distanceInMetres: Double) -> CLLocationCoordinate2D {
        let coordinateLatitudeInRadians: Double = coordinate.latitude * .pi / 180
        let coordinateLongitudeInRadians: Double = coordinate.longitude * .pi / 180
        let distanceComparedToEarth: Double = distanceInMetres / 6378100
        let resultLatitudeInRadians: Double = asin(sin(coordinateLatitudeInRadians) * cos(distanceComparedToEarth) + cos(coordinateLatitudeInRadians) * sin(distanceComparedToEarth) * cos(bearingInRadians))
        let resultLongitudeInRadians: Double = coordinateLongitudeInRadians + atan2(sin(bearingInRadians) * sin(distanceComparedToEarth) * cos(coordinateLatitudeInRadians), cos(distanceComparedToEarth) - sin(coordinateLatitudeInRadians) * sin(resultLatitudeInRadians))
        var result = CLLocationCoordinate2D()
        result.latitude = resultLatitudeInRadians * 180 / .pi
        result.longitude = resultLongitudeInRadians * 180 / .pi
        return result
    }
    
    func repositionAnnotations(_ _annotations: [MKAnnotation]) {
        if _annotations.count < 1 {
            return
        }
        let firstPin: MKAnnotation? = _annotations.first
        let coordinate: CLLocationCoordinate2D? = firstPin?.coordinate
        let distance: Double = 10 * Double(_annotations.count) / 2.0
        let radiansBetweenAnnotations: Double = (.pi * 2) / Double(_annotations.count)
        for i in 0..<_annotations.count {
            let heading: Double = radiansBetweenAnnotations * Double(i)
            let newCoordinate: CLLocationCoordinate2D = calculateCoordinate(from: coordinate!, onBearing: heading, atDistance: distance)
            var annotation: MKAnnotation = _annotations[i]
            //annotation.coordinate = newCoordinate
            
        }
    }
    
    func searchByLocation(_ placemark: CLPlacemark) {
        let coordinate = placemark.location?.coordinate
        let parameters: Parameters = ["user_id": (delegate?.user?.user_id)!, "latitude": String(format: "%f", (coordinate?.latitude)!), "longitude": String(format: "%f", (coordinate?.longitude)!)]
        
        //let parameters : Parameters = ["latitude" : 40.73, "longitude" : -74.0059]

        print("\(parameters)")
        
        
        
        //replaced by alamofire
        
        
        Alamofire.request("http://quantumlisting.com/api.php?apiEntry=search_by_location", method: HTTPMethod.post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON(completionHandler: { response in
            
            switch response.result
            {
            case .success:
                //self.myTableView.isHidden = true
                self.zoomMapToPlacemark(placemark)
                self.mapView.removeAnnotations(self.annotations as! [MKAnnotation])
                self.annotations?.removeAllObjects()
                
                if response.result.value is NSNull
                {
                    CircularSpinner.hide()
                    break
                }
                
                self.listing_list?.removeAllObjects()
                
                
                let data = response.result.value as! [[String:Any]]
                print(data.description)
                
                let list = NSMutableArray(array: data)
                for listing1:Any in list
                {
                    self.listing_list?.add(NSMutableDictionary(dictionary : listing1 as! NSDictionary  ))
                }
                
                //self.listing_list = NSMutableArray(array: data)
                
                var dirtyListing : [Any] = [Any]()
                
                for listing1:Any in self.listing_list! {
    
                    let listing = listing1 as! NSMutableDictionary
                    
                    if listing["user_info"] as? NSDictionary == nil  //wrong user info , ignore 
                        || listing["property_info"] as? NSDictionary == nil  //wrong property info , ignore
                    {
                        dirtyListing.append(listing)
                        continue
                    }
                    
                    //let listing_images = listing["property_image"] as! NSArray
                    let listing_property = listing["property_info"] as! NSDictionary
                    let user_info = listing["user_info"] as! NSDictionary
                    let listingThumbnail = JPSThumbnail()
                    listingThumbnail.image = UIImage(named: "Icon-Small-40")
                    listingThumbnail.title = listing_property["property_name"] as! String
                    
                    if ((listing_property["property_for"] as! String) == "lease") {
                        listingThumbnail.subtitle = "For Lease"
                    }
                    else {
                        listingThumbnail.subtitle = "For Sale"
                    }
                    
                    listingThumbnail.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees((listing_property["latitude"] as! NSString).floatValue), CLLocationDegrees((listing_property["lognitude"] as! NSString).floatValue))
                    
                    listingThumbnail.disclosureBlock = {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                        
                        dc.listing = listing
                        dc.isOwner = user_info["user_id"] as! String == (UIApplication.shared.delegate as! AppDelegate).user!.user_id ? true : false
                        
                        self.navigationController?.pushViewController(dc, animated: true)
                    }
                    
                    self.annotations?.add(JPSThumbnailAnnotation(thumbnail: listingThumbnail))
                }
                
                for dirtyItem in dirtyListing
                {
                    self.listing_list?.remove(dirtyItem)
                }
                
                self.raw_searches = NSMutableArray(array: self.listing_list!)
                
                self.applyFilter()
                
                let groupedPins = self.groupAnnotationsByLocationValue(self.annotations! as NSArray as! [MKAnnotation])
                
                
                for (_, value) in groupedPins
                {
                    let newGroup = value as! [MKAnnotation]
                    if (newGroup.count > 1) {
                        self.repositionAnnotations(newGroup)
                    }
                    self.mapView.addAnnotations(newGroup)
                }
                
                if (self.listing_list?.count)! > 0
                {
                    self.cardView.isHidden = false
                    self.setupCardView(index : 0)
                }
                CircularSpinner.hide()
                break;
            case .failure(let error):
                print("\(error)")
                CircularSpinner.hide()
                break;
            }

            }
        
        )
 
        //
            
        
            
        }
    /*,
    failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(error)")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
    }
 */
    
    // UITableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentMode == 0) {
            if listing_list == nil
            {
                return 0
            }
            
            return (listing_list?.count)!
        }
        else if (currentMode == 1) {
            if geocodingResults == nil
            {
                return 0
            }
            
            return (geocodingResults?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MyIdentifier = String(format: "MyIdentifier%d", indexPath.row)
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: MyIdentifier)
            cell?.selectionStyle = .none
        }
        
        if (currentMode == 0) {
 
            let listing =  listing_list?.object(at: indexPath.row >= listing_list!.count ? listing_list!.count - 1 : indexPath.row) as! NSDictionary
            
            if (is_trend == true) {
                let strTitle = listing["keyword"] as? String
                if (strTitle != nil) {
                    cell?.textLabel?.text = strTitle
                }
                cell?.detailTextLabel?.text = "\(listing["search_count"] as! String) searches"
            }
            else {
                let listing_property = listing["property_info"] as! NSDictionary
                let strTitle = listing_property["property_name"] as? String
                if (strTitle != nil) {
                    cell?.textLabel?.text = strTitle
                }
                cell?.detailTextLabel?.text = ""
            }

        }
        else {
            let placemark = geocodingResults?.object(at: indexPath.row) as! CLPlacemark
            cell?.textLabel?.text = placemark.name
            cell?.detailTextLabel?.text = ""
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (currentMode == 0) {
            if (is_trend == true) {
                let listing = listing_list?.object(at: indexPath.row) as! NSDictionary
                self.searchByKeyword(listing["keyword"] as! String)
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                let dict = listing_list?.object(at: indexPath.row) as! NSDictionary
                dc.listing = dict
                dc.isOwner = false
                
                self.navigationController?.pushViewController(dc, animated: true)
            }
        }
        else {
            searchBar.resignFirstResponder()
            let placemark = geocodingResults?.object(at: indexPath.row) as! CLPlacemark
            tableView.isHidden = true
            mapView.isHidden = false
            self.searchByLocation(placemark)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didLongPress(_ gr: UILongPressGestureRecognizer) {
        if (gr.state == .began) {
            let touchPoint = gr.location(in: mapView)
            let coord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            self.reverseGeocodeCoordinate(coord)
        }
    }
    
    @IBAction func actFilter(_ sender: Any) {
    }

    @IBAction func actListings(_ sender: Any) {
        currentMode = 0
        listing_list?.removeAllObjects()
        
        myTableView.reloadData()
        
        searchBar.text = ""
        btnListings.isSelected = true
        btnMap.isSelected = false
        myTableView.isHidden = false
        mapView.isHidden = true
        cardView.isHidden = true
        self.getTrends()
        
        //myTableView.reloadData()
    }
    
    @IBAction func actMap(_ sender: Any) {
        currentMode = 1
        searchBar.text = ""
        searchBar.resignFirstResponder()
        btnListings.isSelected = false
        listing_list?.removeAllObjects()
        btnMap.isSelected = true
        myTableView.isHidden = true
        mapView.isHidden = false
        
        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
        
        if (delegate?.user?.latitude != "" && delegate?.user?.longitude != "") {
            let nowLocation = CLLocationCoordinate2DMake(CLLocationDegrees(NSString(string: (delegate?.user?.latitude)!).doubleValue), CLLocationDegrees(NSString(string: (delegate?.user?.longitude)!).doubleValue))
            let viewRegion = MKCoordinateRegionMakeWithDistance(nowLocation, 15000, 15000)
            let adjustedRegion = self.mapView.regionThatFits(viewRegion)
            self.mapView.setRegion(adjustedRegion, animated: false)
            
            self.reverseGeocodeCoordinate(nowLocation)
        }
        else {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        }

    }
    
    // Geocoding Methods
    
    func geocodeFromSearchText(_ searchString: String) {
        if (geocoder?.isGeocoding == true) {
            geocoder?.cancelGeocode()
        }
        
        geocoder?.geocodeAddressString(searchString, completionHandler: { (placemark: [CLPlacemark]?, error: Error?) in
            if (!(error != nil)) {
                self.processForwardGeocodingResults(placemark!)
            }
        })
    }
    
    func processForwardGeocodingResults(_ placemarks: [Any]) {
        geocodingResults?.removeAllObjects()
        geocodingResults?.addObjects(from: placemarks)
        myTableView.reloadData()
    }
    
    func reverseGeocodeCoordinate(_ coord: CLLocationCoordinate2D) {
        if (geocoder?.isGeocoding == true) {
            geocoder?.cancelGeocode()
        }
        
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        geocoder?.reverseGeocodeLocation(location, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) in
            if (!(error != nil)) {
                self.processReverseGeocodingResults(placemarks!)
            }
        })
    }
    
    func processReverseGeocodingResults(_ placemarks: [Any]) {
        if (placemarks.count == 0) {
            return
        }
        
        let placemark = placemarks[0] as! CLPlacemark
        currentPlacemark = placemark
        
        let address = placemark.addressDictionary?["FormattedAddressLines"] as? Array<String>
        
        if (currentMode == 1) {
            searchBar.text = address?[0]
        }
        
        self.searchByLocation(currentPlacemark!)
    }
    
    func addPinAnnotationForPlacemark(_ placemark: CLPlacemark) {
        let placemarkAnnotation = MKPointAnnotation()
        placemarkAnnotation.coordinate = (placemark.location?.coordinate)!
        let address = placemark.addressDictionary?["FormattedAddressLines"] as? Array<String>
        placemarkAnnotation.title = address?[0]
        mapView.addAnnotation(placemarkAnnotation)
    }
    
    func addPinAnnotationForCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let placemarkAnnotation = MKPointAnnotation()
        placemarkAnnotation.coordinate = coordinate
        mapView.addAnnotation(placemarkAnnotation)
    }
    
    func zoomMapToPlacemark(_ selectedPlacemark: CLPlacemark) {
        let coordinate = selectedPlacemark.location?.coordinate
        let mapPoint = MKMapPointForCoordinate(coordinate!)
        //let cregion = selectedPlacemark.region as! CLCircularRegion
        //let radius = MKMapPointsPerMeterAtLatitude((coordinate?.latitude)!) * cregion.radius
        let radius = 15000.0
        let size = MKMapSize(width: radius, height: radius)
        var mapRect = MKMapRect(origin: mapPoint, size: size)
        mapRect = MKMapRectOffset(mapRect, -radius / 2, -radius / 2)
        mapView.setVisibleMapRect(mapRect, animated: false)
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
        let viewRegion = MKCoordinateRegionMakeWithDistance(nowLocation, 15000, 15000)
        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: false)
        self.reverseGeocodeCoordinate(nowLocation)
        locationManager?.stopUpdatingLocation()
    }
    
    // MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if (view.conforms(to: JPSThumbnailAnnotationViewProtocol.self)) {
            (view as? JPSThumbnailAnnotationViewProtocol)?.didSelectAnnotationView(inMap: mapView)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if (view.conforms(to: JPSThumbnailAnnotationViewProtocol.self)) {
            (view as? JPSThumbnailAnnotationViewProtocol)?.didDeselectAnnotationView(inMap: mapView)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation.conforms(to: JPSThumbnailAnnotationProtocol.self)) {
            return (annotation as? JPSThumbnailAnnotationProtocol)?.annotationView(inMap: mapView)
        }
        return nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupCardView(index : Int)
    {
        if index >= (self.listing_list?.count)!
        {
            currentIndex = 0
        }
        else if index < 0
        {
            currentIndex = self.listing_list!.count - 1
        }
        else
        {
            currentIndex = index
        }
        
        let listing = self.listing_list?[currentIndex] as! NSDictionary
        let property_info = listing["property_info"] as! [String : String]
        let property_image = (listing["property_image"] as! NSArray)[0] as! [String : String]
        
        lblTitle.text = property_info["property_name"]
        btnLocation.setTitle(property_info["address"], for: .normal)
        lblSqft.text = "\(property_info["sqft"]!) SQFT"
        lblFor.text = property_info["property_for"]
        lblAssetType.text = property_info["property_type"]
        lblPrice.text = "$\(property_info["amount"]!)"
        
        if listing["isFavorite"] as! Int == 0
        {
            btnFavorite.setImage(UIImage(named: "flag@4x"), for: .normal)
        }
        else
        {
            btnFavorite.setImage(UIImage(named: "flag_fill@4x"), for: .normal)
        }
        
        ivListing.setIndicatorStyle(.gray)
        ivListing.setShowActivityIndicator(true)
        ivListing.sd_setImage(with: URL(string: property_image["property_image"]!)!)
        
        //move map center
        let latitude = Double(property_info["latitude"]!)
        let longitude = Double(property_info["lognitude"]!)
        let nowLocation = CLLocationCoordinate2DMake(CLLocationDegrees(latitude!), CLLocationDegrees(longitude!))
        self.mapView.setCenter(nowLocation, animated: true)
    }

    // MARK: - Card View Actions
    @IBAction func actLocation(_ sender: Any) {
        let dict = listing_list?[currentIndex] as! NSDictionary
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
    @IBAction func actFavorite(_ sender: Any) {
        let listing = listing_list?[currentIndex] as! NSMutableDictionary
        let listing_property = listing["property_info"] as! NSDictionary
        
        let parameters: NSMutableDictionary = ["property_id": listing_property["property_id"] as! String, "user_id": (delegate?.user?.user_id)!]
        
        //CircularSpinner.show("", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=favorite_property", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! [String:Any]
                print(responseJson)
                let status = responseJson["status"] as! Int
                
                listing["isFavorite"] = status
                if status == 0
                {
                    self.btnFavorite.setImage(UIImage(named: "flag@4x"), for: .normal)
                }
                else
                {
                    self.btnFavorite.setImage(UIImage(named: "flag_fill@4x"), for: .normal)
                }
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
    @IBAction func actPrev(_ sender: Any) {
        currentIndex = currentIndex - 1
        setupCardView(index: currentIndex)
    }
    @IBAction func actNext(_ sender: Any) {
        currentIndex = currentIndex + 1
        setupCardView(index: currentIndex)
    }
    @IBAction func actListing(_ sender: Any) {

        let listing = self.listing_list?[currentIndex] as! NSDictionary
        let user_info = listing["user_info"] as! NSDictionary
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
        dc.listing = listing
        dc.isOwner = user_info["user_id"] as! String == (UIApplication.shared.delegate as! AppDelegate).user!.user_id ? true : false
            
        self.navigationController?.pushViewController(dc, animated: true)
    }
    
    
    
    
}
