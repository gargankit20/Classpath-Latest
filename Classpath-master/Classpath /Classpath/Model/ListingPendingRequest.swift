//
//  ListingPendingRequest.swift
//  HIITList
//
//  Created by Ved on 24/11/17.
//  Copyright © 2017 Coldfin. All rights reserved.
//

import UIKit

class ListingPendingRequest: NSObject {
    var title : String = ""
    var images: NSArray!
    var listing_description: String = ""
    var pending_request: NSMutableAttributedString = NSMutableAttributedString(string:"No pending requests")
    var request_count: Int = 0
    var listingID: String = ""
    var listingURL: String = ""
    var status:String = ""
    var requestUserID = ""
    var recentAppointTime: Date!
    var address: String = ""
    var userId = ""
    var serviceId = ""
    var requestTime = ""
    var ticketsCount = "0"
}
