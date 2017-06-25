//
//  ProfileViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/24/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner
import JVFloatLabeledTextField
import AFNetworking

class ProfileViewController: UIViewController ,UITextFieldDelegate, DLCImagePickerDelegate{

    @IBOutlet weak var btnPickAvatar: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var txtBlog: JVFloatLabeledTextField!
    @IBOutlet weak var txtPhone: JVFloatLabeledTextField!
    @IBOutlet weak var txtName: JVFloatLabeledTextField!
    @IBOutlet weak var txtConfirm: JVFloatLabeledTextField!
    @IBOutlet weak var txtPassword: JVFloatLabeledTextField!
    @IBOutlet weak var txtEmail: JVFloatLabeledTextField!
    @IBOutlet weak var txtSkype: JVFloatLabeledTextField!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heightOfContent: NSLayoutConstraint!
    
    var delegate : AppDelegate?
    var activeField : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerForKeyboardNotifications()
        configureUserInterface()
        // Do any additional setup after loading the view.
    }
    
    func configureUserInterface()
    {
        
        scrollView.contentInset = UIEdgeInsets(top: -44, left: 0, bottom: 0, right: 0)
        
        var contentRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        for view in self.contentView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        heightOfContent.constant = contentRect.size.height
        
        txtEmail.text = delegate?.user?.umail
        txtName.text = delegate?.user?.uname
        txtPassword.text = delegate?.user?.password
        txtConfirm.text = delegate?.user?.password
        txtPhone.text = delegate?.user?.phone_num
        txtBlog.text = delegate?.user?.user_blog
        
        txtEmail.addUnderline()
        txtName.addUnderline()
        txtPhone.addUnderline()
        txtPassword.addUnderline()
        txtConfirm.addUnderline()
        txtBlog.addUnderline()
        txtSkype.addUnderline()
        
        ivAvatar.layer.cornerRadius = ivAvatar.bounds.width / 2.0
        ivAvatar.layer.masksToBounds = true
        ivAvatar.clipsToBounds = true
        
        //ivAvatar.sd_setImage(with: URL(string: (delegate?.user?.user_photo)!)!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    func resignKeyboard()
    {
        self.view.endEditing(true)
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: Notification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ aNotification: Notification) {
        
        if activeField == nil
        {
            return
        }
        
        let info = aNotification.userInfo
        let kbSize = (info?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsetsMake(0, 0, (kbSize.height), 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= (kbSize.height)
        
        if(!aRect.contains((activeField?.frame.origin)!)) {
            let scrollPoint = CGPoint(x: 0, y: (activeField?.frame.origin.y)! - (kbSize.height))
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
        
    }
    
    func keyboardWillBeHidden(_ aNotificaton: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        return true
    }

    
    // *** //
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func actEdit(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if (txtPassword.text == txtConfirm.text) {

            updateProfileDetail()
        }
        else
        {
            let alert = UIAlertController(title: "QuantumListing", message: "Password mismatch", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

        }
    }
    
    @IBAction func actLogout(_ sender: Any) {
        let app = UIApplication.shared.delegate as? AppDelegate
        
        app?.removeSession()
        app?.user?.user_id = ""
        app?.configureLoginNav()
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        app?.window?.layer.add(transition, forKey: "transition")
    }
    
    @IBAction func actUploadAvatar(_ sender: Any) {
        self.view.endEditing(true)
        
        let picker = DLCImagePickerController()
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        
        
        
        
    }
    
    //DLCPickerController delegate
    func imagePickerControllerDidCancel(_ picker: DLCImagePickerController!) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: DLCImagePickerController!, didFinishPickingMediaWithInfo info: [AnyHashable : Any]!) {
        picker.dismiss(animated: true, completion: nil)
        
        ivAvatar.image = ((info as NSDictionary).object(forKey: "image") as! UIImage)
        
        uploadProfileImage()
    }
    
    func uploadProfileImage()
    {
        
        let parameters : NSMutableDictionary = ["user_id" : delegate!.user!.user_id]
        
        CircularSpinner.show("Updating", animated: true, type: .indeterminate, showDismissButton: false)
        
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=update_profile_image", parameters: parameters, constructingBodyWith: { (_ formData: AFMultipartFormData) in
            formData.appendPart(withFileData: UIImageJPEGRepresentation(self.ivAvatar.image!, 1.0)!, name: "fileToUpload", fileName: "photo.jpg", mimeType: "image/jpeg")
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
    
    func updateProfileDetail() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        let detail: NSMutableDictionary = ["mobile":txtPhone.text!, "website":txtBlog.text!, "user_id":(delegate?.user?.user_id)!]
        let master: NSMutableDictionary = ["user_id":(delegate?.user?.user_id)!, "username":txtName.text!, "email":txtEmail.text!]
        
        if (txtPassword.text == txtConfirm.text && txtPassword.text?.isEmpty == false) {
            master.setObject(txtPassword.text!, forKey: "password" as NSCopying)
        }
        
        let parameters: NSMutableDictionary = ["detail": detail, "master":master]
        
        CircularSpinner.show("Updating", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=update_profile_detail", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            
            delegate?.user?.umail = self.txtEmail.text!
            delegate?.user?.password = self.txtPassword.text!
            delegate?.user?.uname = self.txtName.text!
            delegate?.user?.user_blog = self.txtBlog.text!
            delegate?.user?.phone_num = self.txtPhone.text!
            delegate?.user?.isUpdatedProfile = true
            
            delegate?.saveUserInfo()
            
            do {
                _ = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! NSDictionary

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
