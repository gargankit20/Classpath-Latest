//
//  ListingModel.swift
//  Fitsitters
//
//  Created by Ved on 18/10/17.
//  Copyright © 2017 Coldfin. All rights reserved.
//

import UIKit

class ListingModel: NSObject {
    var listingID = ""
    var views = NSDictionary()
    var noofViews = 0
    var noofRegister = 0
    var listing_description: String!
    var certificates: String!
    var category: String!
    var Description: String!
    var title: String!
    var address: String!
    var listingURL: String!
    var businessURL : String = "N/A"
    var images: NSArray!
    var Video: String = ""
    var serviceHours: SlotSelectionModel!
    var services = NSMutableDictionary()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var distance : Double = 0.0
    var isOpen : Bool = false
    var slots : SlotSelectionModel!
    var slotsToday = NSMutableArray()
    var slotsTomorrow = NSMutableArray()
    var availableslotsToday = NSMutableArray()
    var availableslotsTomorrow = NSMutableArray()
    var slotIsGrayToday = NSMutableArray()
    var slotIsGrayTomorrow = NSMutableArray()
    var userid : String!
    var userName = ""
    var email_id = ""
    var ratings : Double = 0.0
    var star: Double = 0.0
    var reviewCount: Int = 0
    var NoofTimesReviewed: Double = 0.0
    var Expiration_Date: String = ""
    var Ex_Date: String = ""
    var Promoted: String = ""
    var NoofTimesRecommended: Double = 0.0
    var starRecommend: Double = 0.0
    //var openTag : Bool = false
    
}

