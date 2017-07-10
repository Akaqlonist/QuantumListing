//
//  ListingViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CoreLocation
import CircularSpinner
import AFNetworking
import Alamofire
import DKImagePickerController
import JVFloatLabeledTextField

class ListingViewController: UIViewController ,UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, LCItemPickerDelegate, PDFManageViewControllerDelegate, MapViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heightOfContentView: NSLayoutConstraint!
    @IBOutlet weak var txtTitle: JVFloatLabeledTextField!
    @IBOutlet weak var vwDetails: UIView!
    @IBOutlet weak var ivListing: UIImageView!
    @IBOutlet weak var lblUploadPhoto: UILabel!
    @IBOutlet weak var txtDetailComments: UITextView!
    @IBOutlet weak var txtBuildingSize: JVFloatLabeledTextField!
    @IBOutlet weak var txtFTAvailable: JVFloatLabeledTextField!
    @IBOutlet weak var txtRentPSF: JVFloatLabeledTextField!
    @IBOutlet weak var txtTaxesPSF: JVFloatLabeledTextField!
    @IBOutlet weak var txtCommonCharges: JVFloatLabeledTextField!
    @IBOutlet weak var txtParking: JVFloatLabeledTextField!
    @IBOutlet weak var txtCoTenants: JVFloatLabeledTextField!
    @IBOutlet weak var txtDateAvailable: JVFloatLabeledTextField!
    @IBOutlet weak var vwContacts: UIView!
    @IBOutlet weak var txtContacts: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnChooseFile: UIButton!
    @IBOutlet weak var vwBuildingInfo: UIView!
    @IBOutlet weak var txtBuildingType: UITextField!
    @IBOutlet weak var txtLeaseType: UITextField!
    @IBOutlet weak var txtAmountPrice: JVFloatLabeledTextField!
    @IBOutlet weak var collectionThumbnail: UICollectionView!
    
    
    var selectedImages: [UIImage] = [UIImage]()
    var attachedPDFURL: URL?
    var currentPlacemark: CLPlacemark?
    var activeField: UIView?
    var isGeneratingPDF: Bool?
    var pickerCategory: LCTableViewPickerControl?
    var pickerLease: LCTableViewPickerControl?
    var delegate: AppDelegate?
    var theDatePicker: UIDatePicker?
    var pickerToolbar: UIToolbar?
    var pickerViewDate: UIAlertController?
    var pickValue: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var contentRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        for view in self.contentView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        heightOfContentView.constant = contentRect.size.height
        // Do any additional setup after loading the view.
        
        delegate = UIApplication.shared.delegate as? AppDelegate
        //self.registerForKeyboardNotifications()
        isGeneratingPDF = true
        self.configureUI()
        self.actChangePhoto(self)
        
        let color = UIColor.lightGray
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.autoFillContractInfo()
    }
    
    func autoFillContractInfo() {
        txtEmail.text = delegate?.user?.umail
        txtPhone.text = delegate?.user?.phone_num
        txtContacts.text = delegate?.user?.user_blog
    }
    
    func resetFields() {
        txtBuildingSize.text = ""
        txtCommonCharges.text = ""
        txtCoTenants.text = ""
        txtDateAvailable.text = ""
        txtDetailComments.text = ""
        txtFTAvailable.text = ""
        txtParking.text = ""
        txtRentPSF.text = ""
        txtTaxesPSF.text = ""
        txtTitle.text = ""
        ivListing.image = nil
        btnChooseFile.setTitle("", for: .normal)
        attachedPDFURL = nil
        lblUploadPhoto.isHidden = false
        txtBuildingType.text = ""
        txtLeaseType.text = ""
        activeField?.resignFirstResponder()
        
        self.selectedImages.removeAll()
    }
    
    func configureUI() {
        btnChooseFile.layer.borderWidth = 1
        btnChooseFile.layer.borderColor = Utilities.registerBorderColor.cgColor

        vwContacts.layer.cornerRadius = 5
        vwContacts.layer.masksToBounds = true
        vwDetails.layer.cornerRadius = 5
        vwDetails.layer.masksToBounds = true
        vwBuildingInfo.layer.cornerRadius = 5
        vwBuildingInfo.layer.masksToBounds = true
        
        txtDetailComments.layer.cornerRadius = 5
        txtDetailComments.layer.borderColor = Utilities.borderGrayColor.cgColor
        txtDetailComments.layer.borderWidth = 1
        txtDetailComments.layer.masksToBounds = true
        
        pickerCategory = LCTableViewPickerControl(frame: CGRect(x: 0, y: Int(self.view.frame.size.height), width: Int(self.view.frame.size.width), height: Int(kPickerControlAgeHeight - 44)), title: "Please Choose an Asset Type", value: pickValue, items: ["Office", "Retail", "Industrial", "MultiFamily", "Medical", "Land", "Entertainment", "Specialty", "Hospitality", "Mixed Use", "Residential"], offset: CGPoint(x: 0, y: 0))
        
        pickerCategory?.delegate = self
        pickerCategory?.tag = 1002
        self.view.addSubview(pickerCategory!)
        
        pickerLease = LCTableViewPickerControl(frame: CGRect(x: 0, y: Int(self.view.frame.size.height), width: Int(self.view.frame.size.width), height: Int(kPickerControlAgeHeight)), title: "Please Choose One", value: pickValue, items: ["For Lease", "For Sale", "For Sale & Lease"], offset: CGPoint(x: 0, y: 0))
        
        pickerLease?.delegate = self
        pickerLease?.tag = 1001
        self.view.addSubview(pickerLease!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyBoard))
        vwDetails.addGestureRecognizer(tapGesture)
        
        ivListing.addDashedBorderLayerWithColor(color: Utilities.registerBorderColor.cgColor)

        txtTitle.addUnderline()
        txtBuildingSize.addUnderline()
        txtFTAvailable.addUnderline()
        txtRentPSF.addUnderline()
        txtTaxesPSF.addUnderline()
        txtCommonCharges.addUnderline()
        txtParking.addUnderline()
        txtCoTenants.addUnderline()
        txtDateAvailable.addUnderline()
        txtAmountPrice.addUnderline()
        
        
        pickerViewDate = UIAlertController(title: "Date Availabe", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        theDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 44, width: 0, height: 0))
        theDatePicker?.datePickerMode = .date
        theDatePicker?.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        
        pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        pickerToolbar?.barStyle = .blackOpaque
        pickerToolbar?.sizeToFit()

        pickerToolbar?.setItems([UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.datePickerDoneClick))], animated: true)
        pickerViewDate?.view.addSubview(pickerToolbar!)
        pickerViewDate?.view.addSubview(theDatePicker!)
        pickerViewDate?.view.bounds = CGRect(x: 0, y: 0, width: 320, height: 264)
        txtDateAvailable.inputView = pickerViewDate?.view
    }
    
    // MARK - Date Picker Delegate , Methods
    
    func datePickerDoneClick() {
        _ = self.closeDatePicker()
    }
    
    func closeDatePicker() -> Bool {
        pickerViewDate?.dismiss(animated: true, completion: nil)
        txtDateAvailable.resignFirstResponder()
        return true
    }
    
    func dateChanged() {
        txtDateAvailable.text = Utilities.str(fromDateShort: (theDatePicker?.date)!)
    }
    
    // --- //

    
    func resignKeyBoard() {
        activeField?.resignFirstResponder()
    }

    
//    func registerForKeyboardNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: Notification.Name.UIKeyboardDidShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: Notification.Name.UIKeyboardWillHide, object: nil)
//    }
//    
//    func keyboardWasShown(_ aNotification: Notification) {
//        
//        if activeField == nil
//        {
//            return
//        }
//        
//        let info = aNotification.userInfo
//        let kbSize = (info?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let contentInsets = UIEdgeInsetsMake(0, 0, (kbSize.height), 0)
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
//        
//        var aRect = self.view.frame
//        aRect.size.height -= (kbSize.height)
//        
//        if(!aRect.contains((activeField?.frame.origin)!)) {
//            let scrollPoint = CGPoint(x: 0, y: (activeField?.frame.origin.y)! - (kbSize.height))
//            scrollView.setContentOffset(scrollPoint, animated: true)
//        }
//        
//    }
//    
//    func keyboardWillBeHidden(_ aNotificaton: Notification) {
//        let contentInsets = UIEdgeInsets.zero
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actMap(_ sender: Any) {
        activeField?.resignFirstResponder()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        dc.selectedLocation = currentPlacemark?.location?.coordinate
        dc.selectedPlacemark = currentPlacemark
        dc.delegate = self
        self.navigationController?.pushViewController(dc, animated: true)
    }
    
    @IBAction func actMap1(_ sender: Any) {
        activeField?.resignFirstResponder()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        dc.selectedLocation = currentPlacemark?.location?.coordinate
        dc.selectedPlacemark = currentPlacemark
        dc.delegate = self
        self.navigationController?.pushViewController(dc, animated: true)
    }
    
    @IBAction func actScrollToTop(_ sender: Any) {
        scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    @IBAction func actChangePhoto(_ sender: Any) {
        txtAmountPrice.resignFirstResponder()
        pickerLease?.dismiss()
        pickerCategory?.dismiss()
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let photo = UIAlertAction(title: "Photo", style: .default) { (_ alert: UIAlertAction) in

            self.selectedImages.removeAll()
            
            let pickerController = DKImagePickerController()
            pickerController.maxSelectableCount = Utilities.MAX_UPLOAD_COUNT
            pickerController.allowMultipleTypes = false
            pickerController.assetType = .allPhotos
            pickerController.showsEmptyAlbums = false
            pickerController.didCancel = { () in
                
                UIApplication.shared.isStatusBarHidden = true
            }
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                print("didSelectAssets")
                print(assets)
                
                for asset in assets
                {
                    asset.fetchOriginalImage(true, completeBlock: {(image, _) in
                        
                        if image != nil
                        {
                            self.selectedImages.append(image!)
                        }
                    })
                }
            
                if self.selectedImages.count != 0
                {
                    self.ivListing.image = self.selectedImages[0]
                    UIApplication.shared.isStatusBarHidden = true
                    self.lblUploadPhoto.isHidden = true
                    
                    self.collectionThumbnail.reloadData()
                }
            }
            
            self.present(pickerController, animated: true) {}
        }
        let pdf = UIAlertAction(title: "PDF", style: .default) { (_ alert: UIAlertAction) in
            self.isGeneratingPDF = true
            self.actChooseFile(self)
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //sheet.addAction(camera)
        sheet.addAction(photo)
        sheet.addAction(pdf)
        self.present(sheet, animated: true)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        self.present(
            alertVC,
            animated: true,
            completion: nil)
    }

    @IBAction func onPublish(_ sender: Any) {
        activeField?.resignFirstResponder()
        txtDetailComments.resignFirstResponder()
        
        if (self.txtTitle.text == "" || ivListing.image == nil || currentPlacemark == nil || txtPhone.text == "" || txtEmail.text == "" || txtFTAvailable.text == "" || txtAmountPrice.text == "" || txtRentPSF.text == "" || self.txtDateAvailable.text == "") {
            let alert = UIAlertController(title: "QuantumListing", message: "Please input all required fields", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (!(delegate?.user?.isUpdatedProfile)!) {
            let alert = UIAlertController(title: "QuantumListing", message: "Please update profile including contact info before you submit", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.txtTitle.resignFirstResponder()
        if (self.isValidMembership()) {
            let main_params: NSMutableDictionary = ["user_id": (delegate?.user?.user_id)!, "property_name": self.txtTitle.text!, "amount": txtAmountPrice.text!.replacingOccurrences(of: "$", with: ""), "floors": "0", "offices": "0", "bathrooms": "0", "description": txtDetailComments.text!
            ]
            
            
            if  txtBuildingType.text != ""
            {
                main_params.setValue(txtBuildingType.text!, forKey: "property_type")
            }

            
            if (txtLeaseType.text == "For Lease") {
                main_params.setValue("lease", forKey: "property_for")
            }
            else if txtLeaseType.text == "For Sale"
            {
                main_params.setValue("sale", forKey: "property_for")
            }
            else
            {
                main_params.setValue("sale", forKey: "property_for")
            }
            
            let detail_params: NSMutableDictionary = ["building_size":txtBuildingSize.text!, "rent_psf": txtRentPSF.text!, "taxes_psf": txtTaxesPSF.text!, "common_charges": txtCommonCharges.text!, "co_tenent": txtCoTenants.text!, "sqft": txtFTAvailable.text!, "parkings":txtParking.text!, "date_available" : txtDateAvailable.text!]
            
            if (currentPlacemark != nil) {
                main_params.setValue("\((currentPlacemark?.location?.coordinate.latitude)!)", forKey: "latitude")
                main_params.setValue("\((currentPlacemark?.location?.coordinate.longitude)!)", forKey: "lognitude")
                main_params.setValue(currentPlacemark?.name, forKey: "address")
            }
            
            let parameters: Parameters = ["main_params": main_params, "detail_params": detail_params]
            
            print("\(parameters)")
            
            CircularSpinner.show("Publishing", animated: true, type: .indeterminate, showDismissButton: false)
  
            Alamofire.requestWithoutArrayWrap("\(BASE_URL)?apiEntry=publish_property", method : HTTPMethod.post, parameters: parameters, encoding: URLEncoding.httpBody).responseString(completionHandler: {
                response in
                
                switch response.result
                {
                case .success(let value):
                    
                    let responseString = value 
                    print(responseString)
                    
                    let characters = responseString.characters
                    let start = characters.index(of: ":")
                    let end = characters.index(of: "}")
                    
                    if start == nil || end == nil
                    {
                        CircularSpinner.hide()
                        self.view.endEditing(true)
                        let alert = UIAlertController(title: "QuantumListing", message: "Failed to publish property, try again please", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break;
                    }
                    let id = responseString[characters.index(after: start!)..<end!]
                    self.uploadImagesWithPropertyId(id, self.attachedPDFURL)
                        
                    
                    break;
                case .failure(let error):
                
                    print("\(error)")
                    let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.view.endEditing(true)
                    self.resetFields()
                    CircularSpinner.hide()
                    
                    break;
            }
            })
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Please upgrade your membership to access all Premium features of QuantumListing", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            let action = UIAlertAction(title: "Upgrade", style: .default, handler: { (alertAction: UIAlertAction) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let dc = storyboard.instantiateViewController(withIdentifier: "MembershipViewController") as! MembershipViewController
                self.navigationController?.pushViewController(dc, animated: true)
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func uploadImagesWithPropertyId(_ property_id: String, _ pdfURL: URL?) {
        let parameters: NSMutableDictionary = ["property_id": property_id, "featured" : "featured.jpg"]
 
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=publish_property_images", parameters: parameters, constructingBodyWith: { (_ formData: AFMultipartFormData) in
            
            if self.selectedImages.count == 0
            {
                formData.appendPart(withFileData: UIImageJPEGRepresentation(self.ivListing.image!, 1.0)!, name: "fileToUpload[]", fileName: "featured.jpg", mimeType: "image/jpeg")
            }
            else
            {
                formData.appendPart(withFileData: UIImageJPEGRepresentation(self.selectedImages[0], 1.0)!, name: "fileToUpload[]", fileName: "featured.jpg", mimeType: "image/jpeg")
                
                for index in 1..<self.selectedImages.count
                {
                    formData.appendPart(withFileData: UIImageJPEGRepresentation(self.selectedImages[index], 1.0)!, name: "fileToUpload[]", fileName: "photo\(index).jpg", mimeType: "image/jpeg")
                }
            }
            
        }, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in

            do {
          
                
                let responseJson = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: []) as! [String:Any]
                
                print(responseJson)
                
                if pdfURL != nil
                {
                    self.uploadDocumentWithPropertyId(property_id, pdfURL!)
                }
                else {
                    self.resetFields()
                    CircularSpinner.hide()
                    let alert = UIAlertController(title: "QuantumListing", message: "Successfully Uploaded", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }catch{
             
                CircularSpinner.hide()
            }
            self.view.endEditing(true)
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(String(describing: error))")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.resetFields()
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
    }
    
    func uploadDocumentWithPropertyId(_ property_id: String, _ pdfURL: URL) {
        let parameters: NSMutableDictionary = ["property_id": property_id]
        
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=publish_property_documents", parameters: parameters, constructingBodyWith: { (_ formData: AFMultipartFormData) in
            do {
            let d = try NSData(contentsOfFile: (self.attachedPDFURL?.path)!, options: NSData.ReadingOptions(rawValue: 0))
                formData.appendPart(withFileData: d as Data, name: "fileToUpload", fileName: (self.attachedPDFURL?.pathComponents.last)!, mimeType: "")
            }
            catch {
                
            }
        }, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! NSDictionary
                if (responseJson["result"] as! NSArray).object(at: 0) as! Int == 1 {
                    self.resetFields()
                    CircularSpinner.hide()
                    let alert = UIAlertController(title: "QuantumListing", message: "Successfully Uploaded", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }catch{
                CircularSpinner.hide()
            }
            self.view.endEditing(true)
            
            
        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(String(describing: error))")
            
            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.resetFields()
            self.view.endEditing(true)
            CircularSpinner.hide()
        })
    }
    
    func isValidMembership() -> Bool {
        let str_end = delegate?.user?.ms_endDate
        if (str_end != nil) {
            let endDate = Utilities.date(fromString: str_end!)
            if (endDate.timeIntervalSinceNow > 0) {
                return true
            }
        }
        return false
    }
    
    @IBAction func actAssetType(_ sender: Any) {
        self.view.endEditing(true)
        pickerCategory?.show(in: self.view)
    }
    
    @IBAction func actChooseFile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "PDFManageViewController") as! PDFManageViewController
        dc.delegate = self
        let pdfNav = UINavigationController.init(rootViewController: dc)
        pdfNav.isNavigationBarHidden = true
        self.navigationController?.present(pdfNav, animated: true, completion: nil)
    }
    
    @IBAction func actLeaseType(_ sender: Any) {
        self.view.endEditing(true)
        pickerLease?.show(in: self.view)
    }
    
    // UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        if (textField == txtAmountPrice) {
            txtAmountPrice.text = txtAmountPrice.text?.replacingOccurrences(of: "$", with: "")
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == txtAmountPrice) {
            txtAmountPrice.text = "$\(txtAmountPrice.text!)"
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        activeField = textView
        
        return true
    }
    
    // Touches Delegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeField?.resignFirstResponder()
    }
    

    // PDFManagerViewControllerDelegate
    func getAttachedDocumentRef(_ filePath: String) -> CGPDFDocument? {
        let inputPDFFileAsCString = filePath.cString(using: .ascii)
        let path = CFStringCreateWithCString(nil, inputPDFFileAsCString, CFStringEncoding(CFStringEncodings.UTF7.rawValue))
        
        let url = CFURLCreateWithFileSystemPath(nil, path, CFURLPathStyle.cfurlposixPathStyle, false)
        
        let document = CGPDFDocument(url!)
        
        if (document?.numberOfPages == 0) {
            return nil
        }
        
        return document
    }
    
    func generatePDFImage() -> UIImage? {
        
        let document = getAttachedDocumentRef((self.attachedPDFURL?.path)!)
        guard let page = document?.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height);
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0);
            
            ctx.cgContext.drawPDFPage(page);
        }
        
        return img
    }
    
    func didAttachedPDFWithDictionary(_ pdf: String) {
        btnChooseFile.setTitle(pdf, for: .normal)
        self.attachedPDFURL = self.fullPathWithFileName(pdf)
        if (isGeneratingPDF)! {
            ivListing.image = self.generatePDFImage()
            lblUploadPhoto.isHidden = true
        }
    }
    func fullPathWithFileName(_ filename: String) -> URL {
        return URL(fileURLWithPath: "\(self.inboxPath())/\(filename)")
    }
    
    func documentsPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    func inboxPath() -> String {
        return self.documentsPath().appending("/Inbox")
    }
    
    // MapViewControllerDelegate

    func didSelectedPlacemark(_ placemark: CLPlacemark) {
        lblLocation.text = placemark.locality
        self.currentPlacemark = placemark
    }
    
    // LCTableViewPickerDelegate
    func dismissPickerControl(_ view: LCTableViewPickerControl) {
        view.dismiss()
    }
    
    func select(_ view: LCTableViewPickerControl!, didSelectWithItem item: Any!) {
        self.pickValue = item
        if (item as! String == "") {
            
        }
        else {
            if (view.tag == 1001) {
                txtLeaseType.text = item as? String
            }
            else if (view.tag == 1002) {
                txtBuildingType.text = item as? String
            }
        }
        
        self.dismissPickerControl(view)
    }
    
    func select(_ view: LCTableViewPickerControl!, didCancelWithItem item: Any!) {
        self.dismissPickerControl(view)
    }

    
    // MARK :- CollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Utilities.MAX_UPLOAD_COUNT
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        let plusLabel = cell.viewWithTag(2) as! UILabel
        
        if indexPath.row < selectedImages.count
        {
            plusLabel.isHidden = true
            imageView.image = selectedImages[indexPath.row]
        }
        else
        {
            plusLabel.isHidden = false
            imageView.addDashedBorderLayerWithColor(color: Utilities.registerBorderColor.cgColor)
            imageView.image = UIImage()
        }
        
        return cell
    }
}
