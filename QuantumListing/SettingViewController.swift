//
//  SettingViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/24/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        return 6
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row
        {
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tipsViewController = storyboard.instantiateViewController(withIdentifier: "TipsViewController") as! TipsViewController
            self.navigationController?.pushViewController(tipsViewController, animated: true)
            break
        case 1:

            if MFMailComposeViewController.canSendMail() == true
            {
                let mc = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setSubject("Try This New App I'm Using")
                mc.setMessageBody("Hi,<br/>Try QuantumListing, a new app I've downloaded. It is a great new way to search, save and share listings. <br/>Get it by clicking the link:<br/> <a href=\"https://itunes.apple.com/us/app/quantumlisting/id1018441288?ls=1&mt=8\">QuantumListing - App Store</a>\n <br/><a href=\"https://play.google.com/store/apps/details?id=com.quantumlisting.quantumlisting&hl=en\">QuantumListing - Google Play Store</a>\n<br/>Or You can use the website - <a href=\"https://quantumlisting.com\">QuantumListing.com</a>\n", isHTML: true)
                mc.setToRecipients(nil)
                
                self.present(mc, animated: true, completion: nil)
            }
            else
            {
                
            }
            
            break
        case 2:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let membershipViewController = storyboard.instantiateViewController(withIdentifier: "MembershipViewController") as! MembershipViewController
            self.navigationController?.pushViewController(membershipViewController, animated: true)

            break
        case 3:

            if MFMailComposeViewController.canSendMail() == true
            {
                let mc = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setSubject("Contact Support")
                mc.setToRecipients(["support@quantumlisting.com"])
                mc.setMessageBody("", isHTML: false)
                self.present(mc, animated: true, completion: nil)
            }
            else
            {
                
            }

            break
        case 4:
            UIApplication.shared.open(URL(string: "https://quantumlisting.com/blog")!, options: [:], completionHandler: nil)
            break
        case 5:
            UIApplication.shared.open(URL(string: "https://www.youtube.com/channel/UCXOX1z251Jk2_MCfJriwVqA")!, options: [:], completionHandler: nil)
            break
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}
