//
//  MapViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI
import Contacts

protocol MapViewControllerDelegate{
    func didSelectedPlacemark(_ placemark: CLPlacemark)
}

class MapViewController: UIViewController ,CLLocationManagerDelegate, MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate{

    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var buttonEmail: UIButton!
    @IBOutlet weak var buttonPhone: UIButton!
    @IBOutlet weak var buttonWebsite: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapMode: UISegmentedControl!
    var selectedLocation : CLLocationCoordinate2D?
    var showContact : Bool?
    var listing_website : String?
    var listing_phone : String?
    var listing_email : String?
    var currentPlacemark : CLPlacemark?
    var locationManager : CLLocationManager?
    var selectedPlacemark : CLPlacemark?
    
    var geocodingResults : NSMutableArray?
    var geocoder : CLGeocoder?
    var searchTimer : Timer?
    
    var searchController : UISearchController?
    var searchResultsController : UITableViewController?
    var delegate : MapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        geocodingResults = NSMutableArray()
        geocoder = CLGeocoder()

        if (selectedLocation == nil) {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        }
        else if selectedLocation != nil
            
            {
            self.addPinAnnotationForCoordinate(selectedLocation!)
            let mapPoint = MKMapPointForCoordinate(selectedLocation!)
            let radius = MKMapPointsPerMeterAtLatitude((selectedLocation?.latitude)!) * 5000 / 2;
            let size = MKMapSize(width: radius, height: radius)
            var mapRect = MKMapRect(origin: mapPoint, size: size)
            mapRect = MKMapRectOffset(mapRect, -radius / 2, -radius / 2)
            
            mapView.setVisibleMapRect(mapRect, animated: true)
            let address = selectedPlacemark?.addressDictionary?["FormattedAddressLines"] as? Array<String>
            
            searchController?.searchBar.text = address?[0]
            currentPlacemark = selectedPlacemark
        }
        self.actChangeMapMode([])
        // Do any additional setup after loading the view.
        searchResultsController = UITableViewController()
        // Init UISearchController with the search results controller
        searchController = UISearchController(searchResultsController: searchResultsController)
        // Link the search controller
        searchController?.searchResultsUpdater = self
        // This is obviously needed because the search bar will be contained in the navigation bar
        searchController?.hidesNavigationBarDuringPresentation = false
        // Required (?) to set place a search bar in a navigation bar
        searchController?.searchBar.searchBarStyle = .default
        // This is where you set the search bar in the navigation bar, instead of using table view's header ...
        self.searchBarView.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.frame.size.width = self.view.frame.size.width
        //searchController?.searchBar.sizeToFit()
        // To ensure search results controller is presented in the current view controller
        definesPresentationContext = true
        // Setting delegates and other stuff
        searchResultsController?.tableView.dataSource = self
        searchResultsController?.tableView.delegate = self
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = true
        searchController?.searchBar.delegate = self
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if (showContact == true) {
            buttonEmail.isHidden = false
            buttonPhone.isHidden = false
            buttonWebsite.isHidden = false
        }
        else {
            buttonEmail.isHidden = true
            buttonPhone.isHidden = true
            buttonWebsite.isHidden = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
 
        if currentPlacemark != nil
        {
            self.delegate?.didSelectedPlacemark(currentPlacemark!)
        }
   
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func actGlobe(_ sender: Any) {
        if ((listing_website != nil) && ((listing_website?.characters.count)! > 4)) {
            let index = listing_website?.index((listing_website?.startIndex)!, offsetBy: 4)
            if (listing_website?.substring(to: index!) == "http") {
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
    
    @IBAction func actPhone(_ sender: Any) {
        if (listing_phone != nil) {
            UIApplication.shared.open(URL(string: "tel:\(listing_phone!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid phone number has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func actEmail(_ sender: Any) {
        if (listing_email != nil) {
            UIApplication.shared.open(URL(string: "mailto:\(listing_email!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid email address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func actChangeMapMode(_ sender: Any) {
        if (mapMode.selectedSegmentIndex == 0) {
            mapView.mapType = MKMapType.satellite
        }
        else if (mapMode.selectedSegmentIndex == 1) {
            mapView.mapType = MKMapType.standard
        }
        else {
            mapView.mapType = MKMapType.hybrid
        }
    }
    
    @IBAction func didLongPress(_ gr: UILongPressGestureRecognizer) {
        if (gr.state == UIGestureRecognizerState.began) {
            let touchPoint = gr.location(in: mapView)
            let coord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            self.reverseGeocodeCoordinate(coord)
        }
    }
    
    func reverseGeocodeCoordinate(_ coord: CLLocationCoordinate2D) {
        if (geocoder?.isGeocoding == true) {
            geocoder?.cancelGeocode()
        }
        
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        geocoder?.reverseGeocodeLocation(location, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) in
            if (error == nil) {
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
        
      //  let address = ABCreateStringWithAddressDictionary(placemark, false)
        let address = currentPlacemark?.addressDictionary?["FormattedAddressLines"] as? Array<String>
        
        searchController?.searchBar.text = address?[0]
    }
    
    func addPinAnnotationForPlacemark(_ placemark: CLPlacemark) {
        let placemarkAnnotation = MKPointAnnotation()
        placemarkAnnotation.coordinate = (placemark.location?.coordinate)!
        let address = selectedPlacemark?.addressDictionary?["FormattedAddressLines"] as? Array<String>
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
        let cregion = selectedPlacemark.region as! CLCircularRegion
        let radius = MKMapPointsPerMeterAtLatitude((coordinate?.latitude)!) * cregion.radius
        let size = MKMapSize(width: radius, height: radius)
        var mapRect = MKMapRect(origin: mapPoint, size: size)
        mapRect = MKMapRectOffset(mapRect, -radius / 2, -radius / 2)
        mapView.setVisibleMapRect(mapRect, animated: true)
    }
    // Geocoding Methods
    let kSearchTextKey = "Search Text"
    
    func geocodeFromTimer(_ timer: Timer) {
        let userinfo = timer.userInfo as! NSDictionary
        let searchString = userinfo[kSearchTextKey] as! String
        
        if (geocoder?.isGeocoding == true) {
            geocoder?.cancelGeocode()
        }
        
        geocoder?.geocodeAddressString(searchString, completionHandler: { (placemark: [CLPlacemark]?, error: Error?) in
            if (error != nil) {
            }
            else {
                self.processForwardGeocodingResults(placemark!)
            }
        })
    }
    
    func processForwardGeocodingResults(_ placemarks: [Any]) {
        geocodingResults?.removeAllObjects()
        geocodingResults?.addObjects(from: placemarks)
        searchResultsController?.tableView.reloadData()
    }
    
    // MKMapView Delegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let kPinIdentifier = "Pin"
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: kPinIdentifier)
        if (pin != nil) {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: kPinIdentifier)
        }
        
        pin?.annotation = annotation
        return pin
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
        let viewRegion = MKCoordinateRegionMakeWithDistance(nowLocation, 1000, 1000)
        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
        self.reverseGeocodeCoordinate(nowLocation)
        locationManager?.stopUpdatingLocation()
    }
    
    // TableViewController Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (geocodingResults?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        let placemark = geocodingResults?.object(at: indexPath.row) as! CLPlacemark
        
        let address = placemark.addressDictionary?["FormattedAddressLines"] as? Array<String>
        
        cell?.textLabel?.text = address?[0]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapView.removeAnnotations(mapView.annotations)
        
        let selectedPlacemark = geocodingResults?.object(at: indexPath.row) as! CLPlacemark
        self.addPinAnnotationForPlacemark(selectedPlacemark)
        
        self.searchController?.isActive = false
        
        geocodingResults?.removeAllObjects()
        
        self.zoomMapToPlacemark(selectedPlacemark)
        
        let address = selectedPlacemark.addressDictionary?["FormattedAddressLines"] as? Array<String>

        searchController?.searchBar.text = address?[0]
        currentPlacemark = selectedPlacemark
    }
    
    // UISearchController Delegate Methods
    func updateSearchResults(for searchController: UISearchController) {
        if (searchTimer?.isValid == true) {
            searchTimer?.invalidate()
        }
        
        let kSearchDelay = TimeInterval(0.25)
        let userInfo = NSDictionary(object: self.searchController!.searchBar.text!, forKey: kSearchTextKey as NSCopying)
        
        
        searchTimer = Timer.scheduledTimer(timeInterval: kSearchDelay, target: self, selector: #selector(self.geocodeFromTimer), userInfo: userInfo, repeats: false)
        
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
