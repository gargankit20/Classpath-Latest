//
//  userModel.swift
//  HIITList
//
//  Created by Ved on 23/11/17.
//  Copyright © 2017 Coldfin. All rights reserved.
//

import UIKit

class UserDataModel: NSObject {
    var userId : String = ""
    var userName : String = ""
    var address : String = ""
    var email : String = ""
    var mobileNo : String = ""
    var profilePic : String = ""
    var joinDate : String = ""
    var connectedBy : String = ""
    var Verification : String = "false"
    var star: Double = 0.0
    var NoofTimesReviewed: Double = 0.0
    var merchantId = ""
    var accountInfo = [String: String]()
    var coverPic: String = ""
    var fcmToken: String = ""
    var favorites: NSArray = NSArray()
    var lat = 0.0
    var long = 0.0
    var notificationState = true
    var listingCount = 0
    var workoutPlanCount = 0
    var badges: NSArray = NSArray()
    
//    var encryptionKey: String = ""
    var cardInfo = NSDictionary()
    var isAdmin = false
    var bagdes = NSMutableArray()


    open func encodeToJSON() -> [String:Any] {
        var nillableDictionary = [String:Any]()
        nillableDictionary[keyUsername] = self.userName
        nillableDictionary[keyAddress] = self.address
        nillableDictionary[keyEmail] = self.email
        nillableDictionary[keyMobileno] = self.mobileNo
        nillableDictionary[keyProfilePic] = self.profilePic
        nillableDictionary[keyJoinDate] = self.joinDate
        nillableDictionary[keyConnectedBy] = self.connectedBy
        nillableDictionary[keyVerification] = self.Verification
        nillableDictionary[keyStars] = self.star
        nillableDictionary[keyNoofTimesReviewed] = self.NoofTimesReviewed
        nillableDictionary[keyMerchantId] = self.merchantId
        nillableDictionary[keyAc_no] = self.accountInfo
        nillableDictionary[keyCoverPic] = self.coverPic
        nillableDictionary[keyFCMToken] = self.fcmToken
        nillableDictionary[keyFavorite] = self.favorites
//        nillableDictionary[keyEncryptionKey] = self.encryptionKey
        nillableDictionary[keyCardInfo] = self.cardInfo
        nillableDictionary[keyIsAdmin] = self.isAdmin
        nillableDictionary[keyLat] = self.lat
        nillableDictionary[keyLong] = self.long
        nillableDictionary[keyNotificationState] = self.notificationState
        nillableDictionary[keyListingCount] = self.listingCount
        nillableDictionary[keyWorkoutPlanCount] = self.workoutPlanCount
        nillableDictionary[keyBadges] = self.badges
        return nillableDictionary
    }
}
