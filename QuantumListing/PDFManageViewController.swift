//
//  PDFManageViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/24/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import Foundation
import UXMPDFKit
import CircularSpinner
import AFNetworking

protocol PDFManageViewControllerDelegate :NSObjectProtocol{
    func didAttachedPDFWithDictionary(_ pdf: String)
}

class PDFManageViewController: UITableViewController {

    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var buttonDeleteAll: UIButton!
    @IBOutlet weak var lblDisclaimer: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    var isHideDisclaimer: Bool? = true
    var importURL: URL?
    var delegate: PDFManageViewControllerDelegate?
    var pdfs: NSMutableArray?
    
    class func handleOpenURL(importedURL : URL) -> Bool
    {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        let tabVC : UITabBarController = delegate.tc
        if let listvc = tabVC.viewControllers?[2]
        {
        tabVC.selectedViewController = listvc
        let lvc = (tabVC.viewControllers?[2] as! UINavigationController).viewControllers[0] as! ListingViewController
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "PDFManageViewController") as! PDFManageViewController
        dc.delegate = lvc
        dc.importURL = importedURL
        
        let pdfNav = UINavigationController.init(rootViewController: dc)
        pdfNav.isNavigationBarHidden = true
        lvc.navigationController?.present(pdfNav, animated: true, completion: nil)
        }
        return true
    }
    
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDeleteAll(_ sender: Any) {
        let alert = UIAlertController(title: "QuantumListing", message: "Do you want to delete all those PDF files?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        let deleteAction = UIAlertAction(title: "YES", style: .default) { (alert: UIAlertAction!) -> Void in
            for i in 0 ..< (self.pdfs?.count)! {
                let filePath = self.fullPathWithFileName(self.pdfs?.object(at: i) as! String)
                do {
                    try FileManager.default.removeItem(at: filePath)
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
            }
            self.refreshContents()
        }
        alert.addAction(deleteAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblDisclaimer.isHidden = isHideDisclaimer!
        pdfs = NSMutableArray()
        self.refreshContents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
    }

    func refreshContents() {
        pdfs?.removeAllObjects()
        let files = self.listFileAtPath(self.inboxPath())
        for object in files
        {
            pdfs!.add(object)
        }

        self.tableView.reloadData()
        
        if ((pdfs?.count)! > 0) {
            buttonDeleteAll.isEnabled = true
        }
        else {
            buttonDeleteAll.isEnabled = false
        }
    }
    
    func listFileAtPath(_ path: String) -> [Any] {
        var ret = [Any]()
        do {
            ret = try FileManager.default.contentsOfDirectory(atPath: path)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        return ret
    }
    
    func fullPathWithFileName(_ filename: String) -> URL {
        return URL(fileURLWithPath: "\(self.inboxPath())/\(filename)")
    }
    
    func documentsPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    func inboxPath() -> String {
        return documentsPath() + ("/Inbox")
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
        return (pdfs?.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pdfCell", for: indexPath)
        
        cell.textLabel?.text = pdfs?.object(at: indexPath.row) as! String?
        if ((delegate) != nil) {
            let btn = UIButton(type: .contactAdd)
            var frame = btn.frame
            frame.origin.x = 280
            frame.origin.y = 11
            btn.frame = frame
            btn.tag = indexPath.row + 1000
            btn.addTarget(self, action: #selector(actAttachPdf), for: .touchUpInside)
            cell.contentView.addSubview(btn)
        }
        
        cell.selectionStyle = .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.downloadPDFIfFromWeb(self.fullPathWithFileName(pdfs?.object(at: indexPath.row) as! String))
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if ((delegate) != nil) {
            return false
        }
        else {
            return true
        }
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.deletePDFAtIndex(indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    func deletePDFAtIndex(_ indexPath: IndexPath) {
        let filePath = self.fullPathWithFileName(pdfs?.object(at: indexPath.row) as! String)
        do {
            try FileManager.default.removeItem(at: filePath)
            pdfs?.removeObject(at: indexPath.row)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func actAttachPdf(_ sender: Any) {
        let btn = sender as! UIButton
        self.dismiss(animated: true) {
            if (self.delegate?.responds(to: #selector(self.didAttachedPDFWithDictionary)))! {
                _ = self.delegate?.perform(#selector(self.didAttachedPDFWithDictionary), with: self.pdfs?.object(at: btn.tag - 1000))
            }
        }
    }
    
    func didAttachedPDFWithDictionary(_ pdfName: String) {
        
    }
    
    func isFromWeb(_ pdfURL: URL) -> Bool {
        if (pdfURL.scheme == "file") {
            return false
        }
        return true
    }
    
    func downloadPDFIfFromWeb(_ pdfURL :URL) {
        if self.isFromWeb(pdfURL) {
            let pdfName = pdfURL.lastPathComponent
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let path = URL(fileURLWithPath: paths[0]).appendingPathComponent(pdfName).absoluteString
            var directory = ObjCBool(false)
            if (FileManager.default.fileExists(atPath: path, isDirectory: &directory)) {
                self.openLocalPdf(URL(string: path)!)
            }
            else {
                
                let request = URLRequest(url: pdfURL)
                
                let session = AFHTTPSessionManager()
                
                CircularSpinner.show("Downloading", animated: true, type: .indeterminate, showDismissButton: false)
                
                let downloadTask = session.downloadTask(with: request, progress: { (progress: Progress) in
                    
                }, destination: { (url :URL, response :URLResponse) -> URL in
                    URL(string: path)!
                }, completionHandler: { (response: URLResponse, url: URL?, error: Error?) in
                    print("response \(response)")
                    CircularSpinner.hide()
                })
                
                downloadTask.resume()
            }
        }
        else {
            self.openLocalPdf(pdfURL)
        }
    }
    
    func openLocalPdf(_ localPath : URL) {
        let filePath = localPath.path
        
        let document = try! PDFDocument(filePath: filePath, password: "password_if_needed")
        let pdf = PDFViewController(document: document)
        
        self.navigationController?.pushViewController(pdf, animated: true)
    }
    
    func dismissReaderViewController() {
        self.navigationController?.popViewController(animated: true)
    }

}
