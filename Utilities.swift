//
//  Utilities.swift
//  QuantumListing
//
//  Created by lucky clover on 3/30/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class Utilities: NSObject {
    class func degreesToRadians(degrees: Float) -> Float {
        return (Float(M_PI) * degrees)/180
    }
    class func date(fromString str: String) -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let d = dateFormat.date(from: str)
       
        if d != nil {
            return d!
        }
        return Date(timeIntervalSince1970: 0)
    }
    
    class func str(from date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormat.string(from: date)
    }
    
    class func date(fromStringShort str: String) -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        return dateFormat.date(from: str)!
    }
    
    class func str(fromDateShort date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.string(from: date)
    }
    
    class func miles(fromKM km: Float) -> Float {
        return km * 1.60934
    }
    
    class func kM(fromMiles miles: Float) -> Float {
        return miles / 0.62137
    }
    
    class func distance(fromLocation: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) -> Float {
        let R = 6371000.0 as Float
        // metres
        let f1 = degreesToRadians(degrees: Float(fromLocation.latitude))
        let f2 = degreesToRadians(degrees: Float(fromLocation.latitude))
        
        let deltaF = degreesToRadians(degrees: Float(toLocation.latitude - fromLocation.latitude))
        let deltaR = self.degreesToRadians(degrees: Float(toLocation.longitude - fromLocation.longitude))
        let a = sinf(deltaF / 2) * sinf(deltaF / 2) + cosf(f1) * cosf(f2) * sinf(deltaR / 2) * sinf(deltaR / 2)
        let c = 2 * Float(atan2(sqrtf(a), sqrtf(1-a)))
        
        let d = R * c / 1000
        
        return self.miles(fromKM: d)
    }

    
    // Color Set //
    static var registerBorderColor = UIColor(red: 0xc1/0xff, green: 0xcd/0xff, blue: 0xdc/0xff, alpha: 1.0)
    static var txtMainColor = UIColor(red: 0x29/0xff, green: 0x42/0xff, blue: 0x62/0xff, alpha: 1.0)
    static var txtSubColor = UIColor(red: 0xae/0xff, green: 0xbc/0xff, blue: 0xcd/0xff, alpha: 1.0)
    static var greenColor = UIColor(red: 0x56/0xff, green: 0xbc/0xff, blue: 0x56/0xff, alpha: 1.0)
    static var borderGrayColor = UIColor(red: 0xdd/0xff, green: 0xe8/0xff, blue: 0xf3/0xff, alpha: 1.0)
    static var sliderTintColor = UIColor(red: 0xdc/0xff, green: 0xe0/0xff, blue: 0xe9/0xff, alpha: 1.0)
    static var loginBorderColor = UIColor(red: 0xeb/0xff, green: 0xe9/0xff, blue: 0xc7/0xff, alpha: 1.0)
}
