//
//  FollowUserTableViewController.swift
//  QuantumListing
//
//  Created by Colin Taylor on 5/27/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner

class FollowUserTableViewController: UITableViewController {
    
    var userIdList : [String] = [String]()
    var navTitle : String = ""
    var userList : [NSDictionary] = [NSDictionary]()
    var downloaded = 0
    
    @IBAction func onBackTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = navTitle
        
        loadData()
    }
    
    
    
    func loadData()
    {
        for user_id in userIdList
        {
            let parameters: NSMutableDictionary = ["user_id": user_id]
            
            CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
            ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=get_user_from_id", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
                print("JSON: \(responseObject)")
                do {
                    let responseJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! NSDictionary
                    
                    let user_info = responseJson["user_info"] as? NSDictionary
                    
                    if user_info != nil
                    {
                        self.userList.append(user_info!)
                    }
                    
                }catch{
                    
                }
                self.tableView.reloadData()
                CircularSpinner.hide()
                
            }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
                print("Error: \(String(describing: error))")
                
                let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

                CircularSpinner.hide()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        cell.lblUserName.text = userList[indexPath.row].value(forKey: "username") as? String
        
        cell.lblUserType.text = userList[indexPath.row].value(forKey: "type") as? String
        
        cell.setAvatarImageURL(imageURL: userList[indexPath.row].value(forKey: "profile_pic") as! String)
        
        cell.configureCell()
        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userVC = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        userVC.user_info = userList[indexPath.row] as NSDictionary
        self.navigationController?.pushViewController(userVC, animated: true)
    }
}
