//
//  YoutubeVideoPlayerViewController.swift
//  QuantumListing
//
//  Created by Paradise on 2017/07/22.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import XCDYouTubeKit

class YoutubeVideoPlayerViewController: XCDYouTubeVideoPlayerViewController {

    var isPresented = true // This property is very important, set it to true initially
    
    override func viewWillDisappear(_ animated: Bool) {
        

        self.isPresented = false
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        super.viewWillDisappear(animated)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
