//
//  ViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/20/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import TwitterKit
import Fabric
import Crashlytics
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import CircularSpinner

class ViewController: UIViewController {

    
    @IBOutlet weak var fbBtn: UIButton!
    @IBOutlet weak var twBtn: UIButton!
    
    @IBAction func onFBBtn(_ sender: Any)
    {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                }
            }
        }
        
    }
    
    func getFBUserData()
    {
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let data = result as! NSDictionary
                    
                    print(data.description)
                    
                    var parameters : [String : String] = [:]
                    let email = data["email"] as! String
                    parameters["email"] = email
                    parameters["username"] = (data["name"] as! String)
                    parameters["full_name"] = (data["name"] as! String)
                    let picture = ((data["picture"] as! NSDictionary)["data"] as! NSDictionary)["url"] as! String
                    
                    parameters["profile_pic"] = picture
                    parameters["socialmedia"] = "Facebook"
                    
                    CircularSpinner.show("Log In", animated: true, type: .indeterminate, showDismissButton: false)
                    
                    ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=registerWithSocialMedia", parameters: parameters, success: {
                        
                        (operation, responseObject) in
                        
                        do
                        {
                            print(String.init(data: responseObject as! Data, encoding: .utf8)!)
                            
                            let delegate = UIApplication.shared.delegate as! AppDelegate
                            
                            let responseJson = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: []) as! NSDictionary
                            
                            
                            if (responseJson.object(forKey: "status") as! String) == "true"
                            {
                                let profile = responseJson.object(forKey: "profile") as! NSDictionary
                                
                                delegate.user?.uname = profile.object(forKey: "username") as! String
                                delegate.user?.umail = profile.object(forKey: "email") as! String
                                delegate.user?.user_id = "\(responseJson.object(forKey: "user_id")!)"
                                
                                delegate.user?.user_blog = profile.object(forKey: "website") as! String
                                delegate.user?.phone_num = profile.object(forKey: "mobile") as! String
                                delegate.user?.user_bio = profile.object(forKey: "about_me") as! String
                                delegate.user?.user_photo = profile.object(forKey: "profile_pic") as! String
                                delegate.user?.ms_type = (profile.object(forKey: "membership_type") as! String)
                                delegate.user?.ms_startDate = profile.object(forKey: "membership_start") as! String
                                delegate.user?.ms_endDate = profile.object(forKey: "membership_end") as! String
                                
                                if responseJson.object(forKey: "isUpdatedProfile") as! String == "yes"
                                {
                                    delegate.user?.isUpdatedProfile = true
                                    delegate.configureRootNav()
                                }
                                else
                                {
                                    delegate.user?.isUpdatedProfile = false
                                    delegate.configureRootNav()
                                }
                                let transition = CATransition()
                                transition.type = kCATransitionFade
                                transition.duration = 0.3
                                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                delegate.window?.layer.add(transition, forKey: "transition")
                                delegate.saveUserInfo()
                                
                                CircularSpinner.hide()
                                
                            }
                            else{
                                //show message
                                CircularSpinner.hide()
                            }
                        }
                        catch(_){
                            CircularSpinner.hide()
                            print("Failed to parse JSON")
                        }
                    })

                }
            })
        }

    }
    
    @IBAction func onTWBtn(_ sender: Any) {


        Twitter.sharedInstance().logIn(withMethods : .webBased,  completion: {
        
            (session, error) in
            
            if session == nil
            {
                return
            }
            
            let delegate = UIApplication.shared.delegate as! AppDelegate

            delegate.user?.tw_id = (session?.userName)!
            
            let client = TWTRAPIClient.withCurrentUser()
            
            let request = client.urlRequest(withMethod: "GET",
                                            url: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                            parameters: ["include_email": "true", "skip_status": "true"],
                                            error: nil)
            client.sendTwitterRequest(request, completion: { (response, data, connectionError) in
                
                do{
                    CircularSpinner.show("Log In", animated: true, type: .indeterminate, showDismissButton: false)
                    
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
                    print(jsonResponse)
                    
                    
                    let parameters : NSMutableDictionary = ["socialmedia":"Twitter", "username":jsonResponse["name"] as! String, "profile_pic" : jsonResponse["profile_image_url"] as! String, "full_name":jsonResponse["name"] as! String]
                    if let email = jsonResponse["email"] as? String {
                        parameters["email"] = email
                    }else{
                        parameters["email"] = "testemail@test.com"
                    }
                    
                    ConnectionManager.sharedClient().get("\(BASE_URL)?apiEntry=registerWithSocialMedia", parameters: parameters, success: {
                        
                        (operation, responseObject) in
                        
                        do
                        {
                            let responseJson = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: []) as! NSDictionary
                            
                            
                            if (responseJson.object(forKey: "status") as! String) == "true"
                            {
                                let profile = responseJson.object(forKey: "profile") as! NSDictionary
                                
                                delegate.user?.uname = profile.object(forKey: "username") as! String
                                delegate.user?.umail = profile.object(forKey: "email") as! String
                                delegate.user?.user_id = "\(responseJson.object(forKey: "user_id")!)"
                                delegate.user?.user_blog = profile.object(forKey: "website") as! String
                                delegate.user?.phone_num = profile.object(forKey: "mobile") as! String
                                delegate.user?.user_bio = profile.object(forKey: "about_me") as! String
                                delegate.user?.user_photo = profile.object(forKey: "profile_pic") as! String
                                delegate.user?.ms_type = (profile.object(forKey: "membership_type") as! String)
                                delegate.user?.ms_startDate = profile.object(forKey: "membership_start") as! String
                                delegate.user?.ms_endDate = profile.object(forKey: "membership_end") as! String
                                
                                if responseJson.object(forKey: "isUpdatedProfile") as! String == "yes"
                                {
                                    delegate.user?.isUpdatedProfile = true
                                    delegate.configureRootNav()
                                }
                                else
                                {
                                    delegate.user?.isUpdatedProfile = false
                                    delegate.configureRootNav()
                                }
                                let transition = CATransition()
                                transition.type = kCATransitionFade
                                transition.duration = 0.3
                                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                delegate.window?.layer.add(transition, forKey: "transition")
                                delegate.saveUserInfo()
                                
                                CircularSpinner.hide()
                                
                            }
                            else{
                                //show message
                                CircularSpinner.hide()
                            }
                        }
                        catch(_){
                            CircularSpinner.hide()
                        }
                    })
 
                }catch{
                    CircularSpinner.hide()
                    return
                }
                
            })

        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        let image = UIImage(named : "my_top_header.png")
        let width = self.navigationController?.navigationBar.frame.size.width
        let height = self.navigationController?.navigationBar.frame.size.height
        let newimage = resizeImage(image: image!, newWidth: width!, newHeight: height!)
        self.navigationController?.navigationBar.setBackgroundImage(newimage, for: UIBarMetrics.default)
        
    }

    func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

