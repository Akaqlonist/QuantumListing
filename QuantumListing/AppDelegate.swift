//
//  AppDelegate.swift
//  QuantumListing
//
//  Created by lucky clover on 3/20/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit
import FBSDKCoreKit
import SDWebImage
import Alamofire
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var user: User?
    var isOwner: Bool?
    var products: NSArray?
    var deviceToken: NSString = ""
    var msg: NSDictionary?

    var loginNav = UINavigationController()
    var tc = UITabBarController()

    func saveUserInfo() {
        let defaults = UserDefaults.standard
        
        defaults.set(user?.user_id, forKey: "user_id")
        defaults.set(user?.umail, forKey: "umail")
        defaults.set(user?.uname, forKey: "uname")
        defaults.set(user?.session_id, forKey: "session_id")
        defaults.set(user?.password, forKey: "password")
        defaults.set(user?.phone_num, forKey: "phone_num")
        defaults.set(user?.user_blog, forKey: "blog")
        defaults.set(user?.user_bio, forKey: "bio")
        defaults.set(user?.user_photo, forKey: "photo")
        defaults.set(user?.ms_type, forKey: "ms_type")
        defaults.set(user?.ms_startDate, forKey: "ms_startdate")
        defaults.set(user?.ms_endDate, forKey: "ms_enddate")
        defaults.set(user?.ms_isAuto, forKey: "ms_isauto")
        defaults.set(user?.uf_sort, forKey: "uf_sort")
        defaults.set((user?.uf_priceStart)!, forKey: "uf_priceStart")
        defaults.set((user?.uf_priceEnd)!, forKey: "uf_priceEnd")
        defaults.set(user?.uf_lease, forKey: "uf_lease")
        defaults.set(user?.uf_distanceStart, forKey: "uf_distanceStart")
        defaults.set(user?.uf_distanceEnd, forKey: "uf_distanceEnd")
        defaults.set(user?.uf_dateTo, forKey: "uf_dateTo")
        defaults.set(user?.uf_dateFrom, forKey: "uf_dateFrom")
        defaults.set(user?.uf_building, forKey: "uf_building")
        
        defaults.set(user?.isUpdatedProfile, forKey: "isUpdatedProfile")

        defaults.set(user?.latitude, forKey: "latitude")
        defaults.set(user?.longitude, forKey: "longitude")
        defaults.synchronize()
    }
    
    func getUserInfo(key : String) -> String
    {
        let defaults = UserDefaults.standard
        
        if let data = defaults.string(forKey: key)
        {
            return data
        }
        else
        {
            return ""
        }
    }
    
    func shouldAutoLogin() -> Bool {
        
        let defaults = UserDefaults.standard
        
        guard defaults.value(forKey: "autologin") != nil else
        {
            return false
        }
        
        return defaults.bool(forKey: "autologin")
    }
    
    func saveAutoLoginInfo(autologin : Bool)
    {
        let defaults = UserDefaults.standard
        
        defaults.set(autologin, forKey: "autologin")
    }
    
    func loadUserInfo() {
        let defaults = UserDefaults.standard
        
        user?.user_id = getUserInfo(key: "user_id")
        
        
        user?.umail = getUserInfo(key: "umail")
        user?.uname = getUserInfo(key: "uname")
        user?.session_id = getUserInfo(key: "session_id")
        user?.password = getUserInfo(key: "password")
        user?.phone_num = getUserInfo(key: "phone_num")
        user?.user_blog = getUserInfo(key: "blog")
        user?.user_photo = getUserInfo(key: "photo")
        user?.user_bio = getUserInfo(key: "bio")
        user?.ms_isAuto = getUserInfo(key: "isauto")
        user?.ms_endDate = getUserInfo(key: "ms_enddate")
        user?.ms_startDate = getUserInfo(key: "ms_startdate")
        user?.ms_type = getUserInfo(key: "ms_type")
        user?.uf_building = getUserInfo(key: "uf_building")
        user?.uf_dateFrom = getUserInfo(key: "uf_dateFrom")
        user?.uf_dateTo = getUserInfo(key: "uf_dateTo")
        user?.uf_distanceEnd = getUserInfo(key: "uf_distanceEnd")
        user?.uf_distanceStart = getUserInfo(key:"uf_distanceStart")
        user?.uf_lease = getUserInfo(key: "uf_lease")
        user?.uf_priceEnd = getUserInfo(key:"uf_priceEnd")
        user?.uf_priceStart = getUserInfo(key: "uf_priceStart")
        user?.uf_sort = getUserInfo(key: "uf_sort")
        
        user?.isUpdatedProfile = defaults.bool(forKey: "isUpdatedProfile")
        
        user?.latitude = getUserInfo(key: "latitude")
        user?.longitude = getUserInfo(key: "longitude")
    }
    
    func configureRootNav() {
        let user_info: NSMutableDictionary = [
            "user_id" : (user?.user_id)!,
            "profile_pic" : (user?.user_photo)!,
            "about_me" : (user?.user_bio)!,
            "email": (user?.umail)!,
            "website": (user?.user_blog)!,
            "mobile": (user?.phone_num)!,
            "full_name": (user?.uname)!,
            "membership_type":(user?.ms_type)!,
            "membership_start":(user?.ms_startDate)!,
            "membership_end":(user?.ms_endDate)!
        ]
        tc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        
        let image = UIImage(named : "my_top_header.png")
        for i in 0...4 {
            let vc = tc.viewControllers?[i] as! UINavigationController
            let width = (window?.bounds.width)!
            let height = vc.navigationBar.frame.size.height
            
            let newimage = resizeImage(image: image!, newWidth: width, newHeight: height)
            vc.navigationBar.setBackgroundImage(newimage, for: UIBarMetrics.default)
        }
        
        let nc = tc.viewControllers?[4] as! UINavigationController
        let uc = nc.viewControllers[0] as! UserViewController
        uc.user_info = user_info
        
        self.window?.rootViewController = tc
        
    }
    
    func configureLoginNav()
    {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.loginNav = UINavigationController(rootViewController: vc)
        self.loginNav.navigationBar.isHidden = true
        self.window?.rootViewController = loginNav
    }
    
    func removeSession() {
        let defaults = UserDefaults.standard
        
        defaults.set("", forKey: "session_id")
        defaults.set("", forKey: "user_id")
        
        defaults.synchronize()
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Crashlytics.self, Twitter.self])
    
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 10
        SDWebImageDownloader.shared().maxConcurrentDownloads = 6
        
        
        // Override point for customization after application launch.
        user = User()
        self.loadUserInfo()
        if user?.user_id == nil || (user?.user_id == "") || shouldAutoLogin() == false {
            self.configureLoginNav()
        }
        else {
            
            self.configureRootNav()
        }
        
        RentagraphAPHelper.sharedInstance().requestProducts { (success, products) in
            
            if success
            {
                self.products = products! as NSArray
            }
        }
        
        IQKeyboardManager.shared().isEnabled = true
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        FBSDKAppEvents.activateApp()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let scheme = url.scheme
        
        if scheme!.hasPrefix("file")
        {
            return PDFManageViewController.handleOpenURL(importedURL: url)
        }
        else
        {
        
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication : sourceApplication, annotation : annotation)
        }
    }

}

