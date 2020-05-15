//
//  AppConstant.swift
//  Classpath
//
//  Created by coldfin_lb on 8/1/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import UIKit
//MARK: - App Color
let themeColor = UIColor(red:0.32, green:0.71, blue:0.72, alpha:1.0) //#51B5B8
let textThemeColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:1) //#7A8691

//MARK:- Booking Status Color
let colorPreApproved = UIColor(red:1.00, green:0.75, blue:0.22, alpha:1.0) //#FFBE37
let colorConfirmed = UIColor(red:0.24, green:0.66, blue:0.35, alpha:1.0) //#3EA858
let colorCancelled = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0) //#FF0000
let colorRequest = UIColor(red:0.20, green:0.55, blue:0.87, alpha:1.0)//#348cdf

//Utilities
let defaults = UserDefaults.standard
let utils : Utills = Utills()
let snapUtils : SnapshotUtils = SnapshotUtils()
var userSnapShot : NSDictionary!

//KeyWords
let AlertTitle = "Classpath"

//MARK: - Screen size
let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

let sizeProgress = CGSize(width: 30, height:30)

//APP DELEGATE
let appDelegate = UIApplication.shared.delegate! as! AppDelegate

//Firebase Nodes
let nodeUsers = "users"
let nodeListings = "listings"
let nodeListingsRegistered = "listingRegister"
let nodeChats = "chats"
let nodeUserChats = "userChats"
let nodeChatMessages = "chatMessages"
let nodeListingReports = "ListingReports"
let nodeReviews = "ListingReview"
let nodeUserReports = "UserReports"
let nodeUserBlocked = "UserBlocked"
let nodeNotifications = "Notifications"
let nodeService = "Services"
let nodeFOD = "fod"

// Error messages
let serverError = "Something went wrong. Please try again"

//Firebase keys
let keyUsername = "username"
let keyEmail = "email"
let keyAddress = "address"
let keyMobileno = "mobileno"
let keyDeviceToken = "deviceToken"
let keyFCMToken = "FCMToken"
let keyNoofRegister = "noofRegister"
let keyViews = "views"

let keyNoofView = "noofViews"
let keyProfilePic = "profilePic"
let keyCoverPic = "coverPic"
let keyVerification = "Verification"
let keyBlockBy = "blockedBy"
let keyBlockedUID = "blockedUID"
let keyBlockedDate = "blockDate"
let keyIsAdmin = "isAdmin"
let keyListingCount = "listingCount"
let keyWorkoutPlanCount = "workoutPlanCount"
let keyBadges = "badges"
let keyNoOfRegUser = "noOfRegUser"

//MARK: Card Info
let keyCardInfo = "cardInfo"
let keyCardNumber = "cardNumber"
let keyCardName = "cardName"
let keyCardYear = "cardYear"
let keyCardMonth = "cardMonth"
let keyCustomerId = "customerId"

//MARK: Account Detail Firbase Keys
let keyFull_name = "full_name"
let keyDob = "dob"
let keyAdd_line1 = "add_line1"
let keyAdd_line2 = "add_line2"
let keyCity = "city"
let keyState = "state"
let keyCountry = "country"
let keyPostal_code = "postal_code"
let keyPersonal_id = "le_personal_id_number"
let keyBusiness_name = "business_name"
let keyEmail_id = "email_id"
let keyPhone_no = "phone_no"
let keyBusinessUrl = "url"
let keyBusinessType = "type"
let keyBusinessTax = "business_tax_id"
let keyAc_holder_name = "ac_holder_name"
let keyAc_holder_type = "ac_holder_type"
let keyAc_no = "ex_ac_account_no"
let keyAc_routing = "ex_ac_routing_no"
let keyssn = "ssn_last_4"
let keyKanaCity = "kanacity"
let keyKanaState = "kanastate"
let keyKanaCountry = "kanacountry"
let keyKanaAdd_line1 = "kanaadd_line1"
let keyKanaAdd_line2 = "kanaadd_line2"
let keyKanaPostal_code = "kanapostal_code"

let keyCategory = "category"
let keyCertificates = "certificates"
let keyTitle = "ListingTitle"
let keyDescription = "Description"
let keyImages = "images"
let keyLat = "latitude"
let keyLong = "longitude"
let KeyListingAddress = "Address"
let keyListingId = "listingId"
let keyURL = "ListingURL"
let keyServiceHour = "ServiceHours"
let keyServices = "Services"
let keyAvailableSlots = "AvailableSlots"
let keySelectedSlot = "SelectedSlots"
let keyIsOpen = "isOpen"
let keyUserID = "userID"
let keyUid = "uid"
let keyBusinessWebsite = "businessWebsite"
let keyNotificationCount = "NotificationCountBooking"
let keyPendingNotificationCount = "pendingCount"
let keyReviewNotificationCount = "reviewCount"
let keyExpirationDate = "Expiration_Date"
let keyPromoted = "Promoted"
let keyVideo = "Video"
let keyJoinDate = "joinDate"
let keyConnectedBy = "connectedBy"
let keyMerchantId = "merchantId"
let keyMerchantAccountInfo = "merchantAccountInfo"
let keyPasscode = "passcode"

let keyAboutMe = "about_me"
let keyCoverImage = "coverImg"
let keyDays = "days"
let keyDisclaimer = "disclaimer"
let keyDraftImg = "dreaftImg"
let keyLevel = "level"
let keyLocation = "location"
let keyMealPlan = "meal_plan"
let keyPlanCost = "plan_cost"
let keyPlanDesc = "plan_desc"
let keyPlanId = "plan_id"
let keyPlanName = "plan_name"
let keyPromoCode = "promo_code"
let keySuited = "suited"
let keyThingsNeeded = "things_client"
let keyTrainingType = "training_type"
let keyvideo = "video"


let keyRatings = "ratings"
//let keyEncryptionKey = "encryptionSecretKey"
let keyTerms = "termsAgreed"
let keyAprooved = "approved"
let keyPending = "pendings"
let keyConfirmed = "confirm"
let keyRejected = "rejected"
let keyCancelled = "cancelled"
let keyCompleted = "completed"
let keyIsNewBooking = "isNewBooking"
let keyTransactionId = "transactionId"
let keyRequestTime = "requestTime"
let keyTicketsCount = "ticketsCount"

let keyReportType = "reportType"
let keyReportDesc = "description"
let keyReportDate = "date"
let keyNoofTimesReported = "NoofTimesReported"
let keyDate = "date"
let keyReportedTo = "reportedTo"
let keyReportedBy = "reportedby"
let keyRBEmail = "rb_email"
let keyRBUsername = "rb_username"
let keyRLEmail = "rl_email"
let keyRLTitle = "rl_title"
let keyRLUsername = "rl_username"
let keyIsReviewed = "isReviewed"
let keyBlockFlag = "blockFlag"
let keyReviewTo = "ReviewTo"
let keyReviewBy = "ReviewBy"
let keytimeframe = "timeframe"
let keyReviewedDate = "ReviewedDate"
let keyRecommend = "Recommend"
let keylistingName = "listingName"
let keyStars = "stars"
let keyComment = "comment"
let keyListingReviewed = "lisitngReviewed"
let keyNoofTimesReviewed = "NoofTimesReviewed"
let keyNoofTimesRecommended = "NoofTimesRecommended"
let keyNoofTimesUserReviewed = "NoofTimesUserReviewed"
let keyUserRegistration = "userRegistration"
let keyrecommend = "recommend"
let keyNotificationState = "notificationState"

//Chatting
let keyChatID = "chatID"
let keyMembers = "members"
let keyLastMessage = "lastMessageSent"
let keyTimeStamp = "timeStamp"
let keyMessage = "message"
let keyViewFlag = "viewFlag"
let keySentBy = "sentBy"
let keyMessageID = "messageID"
let keyIsBlocked = "isBlocked"
let keyBlockedBy = "blockedby"
let keyShow = "Show"
let keyBlock = "blockKey"

//Services
let keyServiceId = "serviceId"
let keyServiceName = "serviceName"
let keyServiceDesc = "serviceDesc"
let keyServiceCost = "serviceCost"
let keyServiceDeal = "serviceDeal"
let keyServicePolicy = "servicePolicy"
let keyInstantBook = "instantBook"

//Report
let keyToUid = "ToUid"
let keyFromUid = "FromUid"


//Favorite
let keyFavorite = "Favorite"

//Register Click
let keyRegisterClick = "RegisterClick"

//ListingViewClick
let keyListingViewClick = "ListingViewClick"

var DisplayPrompt = String()
var sessionKey = String()
var DelnodeListingsRegistered = String()
var DellistingRegister = String()
var DeldateReminder = String()
var DelkeySelectedSlot = String()


//Badges
let keyProfileBadge = "profileBadge"
let keyPendingBadge = "pendingBadge"
let keyNotificationBadge = "NotificationBadge"
let keyReviewBadge = "ReviewBadge"

let arrCategory2 = ["Personal Training", "Yoga", "Spin Class", "HIIT Training", "Dancing", "Martial Arts", "Gymnastics", "Swimming", "Running Club", "Fitness Race", "Sports Therapy", "Social Sports"]

let arrCategory = [/*["Promoted Listings":#imageLiteral(resourceName: "Promoted_Listings")],*/["Personal Training":#imageLiteral(resourceName: "Personal_Trainer")], ["Yoga":#imageLiteral(resourceName: "Yoga")], ["Spin Class":#imageLiteral(resourceName: "Spin_Class")], ["HIIT Training":#imageLiteral(resourceName: "HIIT_Training")], ["Dancing":#imageLiteral(resourceName: "Dance_Studio")], ["Martial Arts":#imageLiteral(resourceName: "Martial_Art")], ["Gymnastics":#imageLiteral(resourceName: "Gymnastic")], ["Swimming":#imageLiteral(resourceName: "Swimming_Lesson")], ["Running Club":#imageLiteral(resourceName: "Running_Club")], ["Fitness Race":#imageLiteral(resourceName: "Fitness_Race")], ["Sports Therapy":#imageLiteral(resourceName: "Sports_Therapy")], ["Social Sports":#imageLiteral(resourceName: "Social Sports League")]]//SubscriptionAll

let arrfilterCategory = [["Social Sports League":#imageLiteral(resourceName: "Social_Sports_League_filter")],["Dance Studio":#imageLiteral(resourceName: "Dance_Studio_filter")],["Swim Lesson":#imageLiteral(resourceName: "Swimming_Lesson_filter")],["Martial Art":#imageLiteral(resourceName: "Martial_Art_filter")],["Personal Trainer":#imageLiteral(resourceName: "Personal_Trainer_filter")],["HIIT Training":#imageLiteral(resourceName: "HIIT_Training_filter")],["Yoga":#imageLiteral(resourceName: "Yoga_filter")],["Spin Class":#imageLiteral(resourceName: "Spin_Class_filter")],["Running Club":#imageLiteral(resourceName: "Running_Club_filter")],["Gymnastic":#imageLiteral(resourceName: "Gymnastic_filter")],["Fitness Race":#imageLiteral(resourceName: "Fitness_Race_filter")],["Sports Therapy":#imageLiteral(resourceName: "Sports_Therapy_filter")],["Show All":#imageLiteral(resourceName: "all_show_filter")]]

let GOOGLE_PLACES_API = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
let GOOGLE_PLACES_DETAILS_API = "https://maps.googleapis.com/maps/api/place/details/json"
let GOOGLE_MAPS_KEY = "AIzaSyBR2tQQSOcwYZAzlfK8NSiKpxbv1GbMW9Y"
let BaseURl = "http://www.classpathonline.com/ClassPath_API"
//let BaseURl = "http://www.classpathonline.com/ClassPath_API_Test"

let STRIPE_PUBLISHABLE_KEY = "pk_live_OitqrLwPZDmicQgfxeY0dm6d"
//let STRIPE_PUBLISHABLE_KEY = "pk_test_ayfS4Ewkyahh9LiBbkVUv2hc"
let STRIPE_CLIENT_ID="ca_D7ZrCwYWNy98OU7VWIefUOk35n1LDkyX"
//let STRIPE_CLIENT_ID="ca_D7Zr5xqbyBjXleAz4mP5IN3g5C5E8kdm"

//let AD_UNIT_ID="ca-app-pub-7666000398456991/6142401906"
let AD_UNIT_ID_TEST="ca-app-pub-3940256099942544/1033173712"

struct INSTAGRAM_IDS {
    
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    
    static let INSTAGRAM_APIURl  = "https://api.instagram.com/v1/users/"
    
    static let INSTAGRAM_CLIENT_ID  = "4aa7d18ba5c14822959e422e3e26e0b2"
    
    static let INSTAGRAM_CLIENTSERCRET = "0643425e83bc4fecaab6dcfb65e8a336"
    
    static let INSTAGRAM_REDIRECT_URI = "http://www.classpath.co"
    
    static let INSTAGRAM_ACCESS_TOKEN =  "access_token"
    
    static let INSTAGRAM_SCOPE = "basic"
}

