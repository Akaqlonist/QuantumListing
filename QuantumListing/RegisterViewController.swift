//
//  RegisterViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/21/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner
import Alamofire

class RegisterViewController: UIViewController ,CircularSpinnerDelegate{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtWebsite: UITextField!
    @IBOutlet weak var btnAgree: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapView)))
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func onTapView()
    {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onAgree(_ sender: Any) {
        btnAgree.isSelected = !btnAgree.isSelected
    }

    @IBAction func onSubmit(_ sender: Any) {
        if self.checkValidation() {
            Thread.detachNewThreadSelector(#selector(self.registerUser), toTarget: self, with: nil)
        }
    }
    
    func registerUser() {
        let parameters: NSMutableDictionary = ["username": self.txtFullName.text!, "email": self.txtEmail.text!, "password": self.txtPass.text!]
        if !(self.txtPhone.text?.isEmpty)! {
            parameters["mobile"] = self.txtPhone.text!
        }
        else
        {
            parameters["mobile"] = ""
        }
        if !(self.txtWebsite.text?.isEmpty)! {
            parameters["website"] = self.txtWebsite.text!
        }
        else
        {
            parameters["website"] = ""
        }
        
        
        
        CircularSpinner.show("Register", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=register", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            do {
                
            let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: [JSONSerialization.ReadingOptions.allowFragments]) as! [String:Any]
                print(responseJson)
                
                //register successful,  do login
                DispatchQueue.main.async(execute: {
                    self.loginUser()
                })
                
                
            }catch{
                
            }
            self.view.endEditing(true)
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
    
    func checkValidation() ->Bool {
        if(txtFullName.text?.isEmpty)! {
            let alert = UIAlertController(title: "QuantumListing", message: "Username is Empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if(txtEmail.text?.isEmpty)! {
            let alert = UIAlertController(title: "QuantumListing", message: "Email is Empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if(txtPass.text?.isEmpty)! {
            let alert = UIAlertController(title: "QuantumListing", message: "Password is Empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }

        if(txtPhone.text?.isEmpty)! {
            let alert = UIAlertController(title: "QuantumListing", message: "Phone is Empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if(!btnAgree.isSelected) {
            let alert = UIAlertController(title: "QuantumListing", message: "You must agree terms & policy to register", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func loginUser() {
        let parameters: NSMutableDictionary = ["email": self.txtEmail.text!, "password": self.txtPass.text!]
        
        CircularSpinner.show("Log In", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=login", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! [String:Any]
                print(responseJson)
                
                if ((responseJson["status"] as! String) == "true") {
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    let profile = responseJson["profile"] as? [String:Any]
                    if (profile != nil) {
                        delegate.user?.user_blog = (profile?["website"] as? String)!
                        delegate.user?.user_bio = (profile?["about_me"] as? String)!
                        delegate.user?.phone_num = (profile?["mobile"] as? String)!
                        delegate.user?.user_photo = (profile?["profile_pic"] as? String)!
                        delegate.user?.ms_startDate = (profile?["membership_start"] as! String)
                        delegate.user?.ms_endDate = (profile?["membership_end"] as! String)
                        delegate.user?.isUpdatedProfile = true
                        delegate.user?.ms_type = (profile?["membership_type"] as? String)!
                    }
                    else {
                        delegate.user?.isUpdatedProfile = false
                    }
                    
                    delegate.user?.uname = (responseJson["username"] as? String)!
                    delegate.user?.umail = self.txtEmail.text!
                    delegate.user?.password = self.txtPass.text!
                    delegate.user?.user_id = "\(responseJson["user_id"] as! String)"
                    delegate.saveUserInfo()
                    delegate.configureRootNav()
                    
                    CircularSpinner.hide()
                }
                else {
                    let alert = UIAlertController(title: "QuantumListing", message: responseJson["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                let alert = UIAlertController(title: "QuantumListing", message: responseJson["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }catch{
                
            }
            self.view.endEditing(true)
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

}
