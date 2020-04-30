//
//  snapshotUtils.swift
//  Classpath
//
//  Created by coldfin_lb on 8/10/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation

class SnapshotUtils: NSObject {
    
    var latCurrent : CLLocation!
    var currentUserModel = UserDataModel()
    var userModel = UserDataModel()
    
    func userDateFetchFromDB(userid:String,notiName:String){
        let _ = ref.child(nodeUsers).child(userid).observeSingleEvent(of: .value, with: { snapshot in

            if snapshot.exists(){
                self.parseDataForUser(snapshot: snapshot,model: snapUtils.userModel)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notiName), object: nil, userInfo: nil)
            }
           
        })
    }
    
    func currentUserDateFetchFromDB(completionHandler: @escaping (Bool) -> ()){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let _ = ref.child(nodeUsers).child(uid).observe(.value, with: { snapshot in
            
            guard (Auth.auth().currentUser?.uid) != nil else{
                return
            }
            if snapshot.exists(){
                userSnapShot = (snapshot.value as! NSDictionary)
                self.parseDataForUser(snapshot: snapshot,model: snapUtils.currentUserModel)
//                if snapUtils.currentUserModel.encryptionKey == "" {
//                    do {
//                        let encryptionKey = try crypUtils.generateEncryptionKey(withPassword: snapUtils.currentUserModel.userId)
//                        let _ = ref.child(nodeUsers).child(snapUtils.currentUserModel.userId).updateChildValues([keyEncryptionKey: encryptionKey])
//                    }catch{}
//                }
                completionHandler(true)
            }
            print(snapshot)
            
        })
    }
    
    func parseDataForUser(snapshot:DataSnapshot,model:UserDataModel){
        model.userId = snapshot.key
        model.Verification = ""
        if let defaults = (snapshot.value as! NSDictionary)[keyEmail] as? String {
            model.email = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyVerification] as? String {
            model.Verification = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyMerchantId] as? String {
            model.merchantId = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyMerchantAccountInfo] as? [String:String]{
            model.accountInfo = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyUsername] as? String {
            model.userName = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyProfilePic] as? String {
            model.profilePic = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyAddress] as? String {
            model.address = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyMobileno] as? String {
            model.mobileNo = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyJoinDate] as? String {
            model.joinDate = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyConnectedBy] as? String {
            model.connectedBy = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyCoverPic] as? String {
            model.coverPic = defaults
        }
        if let fcmToken = (snapshot.value as! NSDictionary)[keyDeviceToken] as? String {
            model.fcmToken = fcmToken
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyFavorite] as? NSArray {
            model.favorites = defaults
        }
//        if let defaults = (snapshot.value as! NSDictionary)[keyEncryptionKey] as? String {
//            model.encryptionKey = defaults
//        }
        if let defaults = (snapshot.value as! NSDictionary)[keyCardInfo] as? NSDictionary{
            model.cardInfo = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyIsAdmin] as? Bool{
            model.isAdmin = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyLat] as? Double {
            model.lat = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyLong] as? Double {
            model.long = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyNotificationState] as? Bool {
            model.notificationState = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyListingCount] as? Int {
            model.listingCount = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyWorkoutPlanCount] as? Int {
            model.workoutPlanCount = defaults
        }
        if let defaults = (snapshot.value as! NSDictionary)[keyBadges] as? NSArray {
            model.badges = defaults
        }
    }
    
    func parseSnapShot(snapshot : DataSnapshot,notiName : String)
    {
        var myGroup = DispatchGroup()
        var result  = ""
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        result = formatter.string(from: date)
        
        let model = ListingModel()
        
        model.listingID = snapshot.key
        
        if let defaults = (snapshot.value as! NSDictionary)[keyDescription] as? String {
            model.listing_description = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyURL] as? String {
            model.listingURL = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyBusinessWebsite] as? String {
            model.businessURL = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[KeyListingAddress] as? String {
            model.address = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyCategory] as? String {
            model.category = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyCertificates] as? String {
            model.certificates = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyLat] as? Double {
            model.latitude = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyLong] as? Double {
            model.longitude = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyImages] as? NSArray {
            model.images = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyIsOpen] as? Bool {
            model.isOpen = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyUserID] as? String {
            model.userid = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyViews] as? NSDictionary {
            model.views = defaults
            let arrViews = model.views.object(forKey: model.views.allKeys[0]) as! NSArray
            model.noofViews = arrViews.count
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyNoofRegister] as? Int{
            model.noofRegister = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyRatings] as? Double {
            model.ratings = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyTitle] as? String {
            model.title = defaults
        }
        
        
        if let defaults = (snapshot.value as! NSDictionary)[keyNoofTimesReviewed] as? Double {
            model.NoofTimesReviewed = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyNoofTimesRecommended] as? Double {
            model.NoofTimesRecommended = defaults
        }
        
        if let defaults = (snapshot.value as! NSDictionary)[keyServices] as? NSMutableDictionary {
            model.services = defaults
        }
        
        let _ = ref.child(nodeUsers).child(model.userid).observe(.value, with: { snapshot in
            ref.child(nodeUsers).child(model.userid).removeAllObservers()
            if snapshot.exists(){
                if let defaults = (snapshot.value as! NSDictionary)[keyUsername] as? String {
                    model.userName = defaults
                }
                if let defaults = (snapshot.value as! NSDictionary)[keyEmail] as? String {
                    model.email_id = defaults
                }
            }
        })
        
        let _ = ref.child(nodeReviews).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).observe(.value, with: { snapshot1 in
            ref.child(nodeReviews).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).removeAllObservers()
            myGroup.enter()
            var rating = 0.0
            var reviewdTotal = 0.0
            var recommend = 0.0
            var recommendTotal = 0.0
            if snapshot1.exists() {
                defer { myGroup.leave()}
                
                for child in snapshot1.children {
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyStars] as? Double {
                        reviewdTotal += defaults
                        let rate = defaults * defaults
                        rating += rate
                    }
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyrecommend] as? Double {
                        recommendTotal += defaults
                        let rec = defaults * defaults
                        recommend += rec
                    }
                    
                }
                if model.NoofTimesReviewed != 0{
                    model.star = rating / reviewdTotal
                    model.reviewCount = Int(model.NoofTimesReviewed)
                }
                
                if model.NoofTimesRecommended != 0{
                    model.starRecommend = recommend / recommendTotal
                }
            }
            
            let latLIST = CLLocation(latitude:  model.latitude, longitude:  model.longitude)
           // print("lat current = \(self.latCurrent)")
            model.distance = self.latCurrent.distance(from: latLIST) / 1609.34
            
            let dateSelected = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            
            if (model.distance < 30 && model.isOpen == true)
            {
                if let defaults = (snapshot.value as! NSDictionary)[keyServiceHour] as? NSDictionary
                {
                    let key = "\(dateSelected.dayOfWeek()!)"
                    
                    if let default2 = defaults.value(forKey: key) as? NSMutableArray {
                        model.slotsTomorrow = default2
                    }
                    
                    let slotIsGray = NSMutableArray()
                    for i in model.slotsTomorrow
                    {
                        if("\(i)".range(of: "Not available") == nil)
                        {
                            model.availableslotsTomorrow.add("\(i)")
                            slotIsGray.add(false)
                        }else{
                            var dayAvailable = ""
                            for i in 2...7{
                                let nextDay = Calendar.current.date(byAdding: .day, value: i, to: Date())!
                                let keyDay = "\(nextDay.dayOfWeek()!)"
                                if let def = defaults.value(forKey: keyDay) as? NSArray {
                                    if("\( def.object(at: 0))".range(of: "Not available") == nil)
                                    {
                                        dayAvailable = keyDay
                                        break
                                    }
                                }
                            }
                            if dayAvailable == "" {
                                model.availableslotsTomorrow.add("Not available")
                            }else{
                                model.availableslotsTomorrow.add("Not available until \(dayAvailable)")
                            }
                            slotIsGray.add(true)
                        }
                    }
                    model.slotIsGrayTomorrow = slotIsGray
                }
            }
            if (model.distance < 30 && model.isOpen == true)
            {
                // self.From = "favourite"
                if let defaults = (snapshot.value as! NSDictionary)[keyServiceHour] as? NSDictionary
                {
                    let key = "\(Date().dayOfWeek()!)"
                    
                    if let default2 = defaults.value(forKey: key) as? NSMutableArray {
                        model.slotsToday = default2
                    }
                    
                    let slotIsGray = NSMutableArray()
                    for i in model.slotsToday
                    {
                        if("\(i)".range(of: "Not available") == nil){
                            let arr = "\(i)".components(separatedBy: "-")
                            let fromDate = utils.convertStringToDate("\(result) \(arr[0])", dateFormat: "MM.dd.yyyy h:mm a")
                            
                            let currentDate = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM.dd.yyyy h:mm a")
                            
                            if(fromDate < currentDate){
                                slotIsGray.add(true)
                            }else{
                                slotIsGray.add(false)
                            }
                            model.availableslotsToday.add("\(i)")
                        }else{
                            var dayAvailable = ""
                            for i in 1...6{
                                let nextDay = Calendar.current.date(byAdding: .day, value: i, to: Date())!
                                let keyDay = "\(nextDay.dayOfWeek()!)"
                                if let def = defaults.value(forKey: keyDay) as? NSArray {
                                    if("\( def.object(at: 0))".range(of: "Not available") == nil)
                                    {
                                        dayAvailable = keyDay
                                        break
                                    }
                                }
                            }
                            if dayAvailable == "" {
                                model.availableslotsToday.add("Not available")
                            }else{
                                model.availableslotsToday.add("Not available until \(dayAvailable)")
                            }
                            slotIsGray.add(true)
                        }
                    }
                    print(slotIsGray)
                    model.slotIsGrayToday = slotIsGray
                }
            }
            
            let modelData:[String: ListingModel] = ["model": model]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: notiName), object: nil, userInfo: modelData)
        })
        
    }
    
    //MARK: - Notification
    func SendNotification(receiverId : String, message : String, timeStamp : Double, listingId: String)
    {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        //chatsMessages Node
        let paramchatsMessages = NSMutableDictionary()
        paramchatsMessages.setValue(uid, forKey:keySentBy)
        paramchatsMessages.setValue(message, forKey:keyMessage)
        paramchatsMessages.setValue(timeStamp, forKey:keyTimeStamp)
        paramchatsMessages.setValue(false, forKey:keyViewFlag)
        
        let key = ref.child(nodeNotifications).child(receiverId).childByAutoId().key
        print(key)
        let Note = ["FromUid": uid,
                    "ToUid": receiverId,
                    "message": message,
                    "timeStamp": timeStamp,
                    "ListingId": listingId,
                    "ViewFlag": false] as [String : Any]
        
        
        let _ = ref.child(nodeUsers).child(receiverId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists()
            {
                var notificationState = true
                if let defaults = (snapshot.value as! NSDictionary)[keyNotificationState] as? Bool {
                    notificationState = defaults
                }
                
                if notificationState || !(message.contains("A new listing")) {
                    let childUpdates = ["/Notifications/\(receiverId)/\(key)": Note]
                    ref.updateChildValues(childUpdates)
                    
                    if let fcmToken = (snapshot.value as! NSDictionary)[keyDeviceToken] as? String {
                        self.sendFCMNotification(token: fcmToken, message: message)
                    }
                }
            }
        })
    }
    //fhgpSnRO8dQ:APA91bH-VmIPWy3jlV_BKnOc5poa1D4aJPLx4Xa63F-iPybHK_pXMhfKPLVZnLX2VLPU-DUp9AfGkdA-co97YRrxAAoMQtNz5LcBWJkZOs0FjJ_WprLejw3y4rvFBle1ZkkKj_KAVgqz
    
    func sendFCMNotification(token: String, message: String) {
        
        let strUrl = NSString(format: "https://fcm.googleapis.com/fcm/send") as String
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json","text/html") as Set<NSObject>
        
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("key=AAAA2reorDM:APA91bE1mH4hlBZgBBz_PI8cnlrxbfSbhQyPOlY2svW1ZIIxknA1tPgCWnzc4L2UnUPLBphp3_dQbNoEApQViv-Nhzs0do6teLaODA6myUkU8FtP_HyWg2t0--EOVsM0JEDA2-mCHXNl", forHTTPHeaderField: "Authorization")
        
        let param: [String: Any] = ["to": token,
                                    "notification": ["body": message,
                                                     "badge": "1",
                                                     "sound": "default"]]
        manager.post(strUrl, parameters: param, success: {
            (operation,responseObject) in
            print(responseObject!)
        },failure: { (operation,error) in
            print(error!,operation!)
        })
    }
    
    func sendMultipleNotifications(listingName:String,listingId:String) {
        
        var listingLatitude=0.0
        var listingLongitude=0.0
        
        ref.child(nodeListings).child(listingId).observeSingleEvent(of:.value, with:{(snapshot) in
            
            listingLatitude=(snapshot.value as! NSDictionary)[keyLat] as! Double
            listingLongitude=(snapshot.value as! NSDictionary)[keyLong] as! Double
            
        })
        
        ref.child(nodeUsers).queryOrdered(byChild: keyNotificationState).queryEqual(toValue: true).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            for child in snapshot.children {
                if (child as! DataSnapshot).key != snapUtils.currentUserModel.userId {
                    var user = ""
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyUsername] as? String {
                        user = defaults
                    }
                    var latitude = 0.0
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyLat] as? Double {
                        latitude = defaults
                    }
                    
                    var longitude = 0.0
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyLong] as? Double {
                        longitude = defaults
                    }
                    
                    let latLIST = CLLocation(latitude:  latitude, longitude:  longitude)
                    let listingLocation=CLLocation(latitude:listingLatitude, longitude:listingLongitude)
                    // print("lat current = \(self.latCurrent)")
                    let distance = listingLocation.distance(from: latLIST) / 1609.34
                    
                    if (distance < 30) {
                        print(child as! DataSnapshot)
                          let message = "Hi \(user)! There’s a new listing \"\(listingName)\" in \(utils.listingCity). Check it out!"
                          snapUtils.SendNotification(receiverId : (child as! DataSnapshot).key, message : message, timeStamp : NSDate().timeIntervalSince1970, listingId: listingId)
                    }
                }
            }
        })
    }
}
