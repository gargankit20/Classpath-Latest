//
//  BookingModel.swift
//  HIITList
//
//  Created by Ved on 28/11/17.
//  Copyright © 2017 Coldfin. All rights reserved.
//

import UIKit

class BookingModel: NSObject {
    var title: String = ""
    var listingID: String = ""
    var listingRegister: String = ""
    var slotArr = NSArray()
    var requestTime = ""
    var slotDate = ""
    var listingStatus = ""
    var ticketsCount = 1
    var listingOwnerName = ""
    var listingURL = ""
    var listingAddress = ""
    var listing_description: String = ""
    var slot_selected: String = ""
    var strDate: String = ""
    var dateReminder = ""
    var appoint_date : Date!
    var userName: String = ""
    var weekDay: String = ""
    var images: NSArray!
    var isReview = false
    var starValue : CGFloat = 0.0
    var reviewComment = ""
    var userId:String = ""
    var serviceId:String = ""
    var registers = NSDictionary()
}
