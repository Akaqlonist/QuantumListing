//
//  ConnectionManager.swift
//  QuantumListing
//
//  Created by lucky clover on 3/25/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import Foundation
import AFNetworking

let BASE_URL = "https://quantumlisting.com/api.php"
let SECURE_BASE_URL = "https://quantumlisting.com/api.php"

private var _sharedClient : ConnectionManager? = nil
class ConnectionManager : AFHTTPSessionManager{
    
    class func sharedClient() -> ConnectionManager {
        
        if _sharedClient == nil
        {
            _sharedClient = ConnectionManager()
            _sharedClient?.securityPolicy.validatesDomainName = false
            _sharedClient?.securityPolicy.allowInvalidCertificates = true
            _sharedClient?.requestSerializer.timeoutInterval = 120
            _sharedClient?.responseSerializer = AFHTTPResponseSerializer()
            _sharedClient?.requestSerializer = AFHTTPRequestSerializer()
        }
        return _sharedClient!

    }
}
