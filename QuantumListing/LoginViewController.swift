//
//  LoginViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/21/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner

class LoginViewController: UIViewController {

    @IBOutlet weak var cbKeepSignin: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        
        // Do any additional setup after loading the view.

    }
    
    @IBAction func onKeepBtnClicked(_ sender: Any) {
        cbKeepSignin.isSelected = !cbKeepSignin.isSelected
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        Thread.detachNewThreadSelector(#selector(self.loginUser), toTarget: self, with: nil)
    }

    @IBAction func onForgotPass(_ sender: Any) {
    }
    
    func loginUser() {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.saveAutoLoginInfo(autologin: cbKeepSignin.isSelected)
        
        let parameters: NSMutableDictionary = ["email": self.txtEmail.text!, "password": self.txtPass.text!]
        
        CircularSpinner.show("Log In", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=login", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! [String:Any]
                print(responseJson)
                
                if ((responseJson["status"] as! String) == "true") {
                    //let delegate = UIApplication.shared.delegate as! AppDelegate
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
