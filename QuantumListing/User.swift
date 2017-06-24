//
//  User.swift
//  QuantumListing
//
//  Created by lucky clover on 3/25/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import Foundation
class User: NSObject {
    var user_id: String = ""
    var session_id: String = ""
    var uname: String = ""
    var umail: String = ""
    var birthday: String = ""
    var phone_num: String = ""
    var password: String = ""
    var user_photo: String = ""
    var user_bio: String = ""
    var user_blog: String = ""
    var tw_id: String = ""
    var longitude: String = ""
    var latitude: String = ""
    var isUpdatedProfile: Bool = false
    //Membership
    var ms_type: String?
    var ms_startDate: String = ""
    var ms_endDate: String = ""
    var ms_isAuto: String = ""
    //Filter
    var uf_dateFrom: String = ""
    var uf_dateTo: String = ""
    var uf_priceStart: String = ""
    var uf_priceEnd: String = ""
    var uf_distanceStart: String = ""
    var uf_distanceEnd: String = ""
    var uf_lease: String = ""
    var uf_building: String = ""
    var uf_sort: String = ""
}
