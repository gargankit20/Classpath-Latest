//
//  BookingVC.swift
//  Classpath
//
//  Created by Coldfin on 21/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import UserNotifications
import EventKit

class BookingVC: UIViewController,NVActivityIndicatorViewable,UNUserNotificationCenterDelegate {
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var viewDefault: UIView!
    var arr = NSMutableArray()
    var ref: DatabaseReference!
    var Deletetag = Int()
    var tag:Int = 0
    var listingTitle = String()
    var listTimeframe: String = ""
    var modelPay = BookingModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DisplayPrompt = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.Alert), name: NSNotification.Name(rawValue: "submitReview"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.paymentDoneSuccess(_:)), name: NSNotification.Name(rawValue: "ServiceBought"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadlistingData(_:)), name: NSNotification.Name(rawValue: "listingDetailBooking"), object: nil)
        initNotificationSetupCheck()
        tblView.rowHeight = 160
        ref = Database.database().reference()
        
        let ap = UIApplication.shared.delegate as! AppDelegate
        let myTabBar = ap.window?.rootViewController as? UITabBarController
        defaults.setValue(0, forKey: keyNotificationBadge)
        myTabBar?.tabBar.items![2].badgeValue = nil
        
        
        var count = 5
        for _ in 0...count {
            print("here ",snapUtils.currentUserModel.userId)
            if snapUtils.currentUserModel.userId != "" {
                let userInstance = self.ref.child(nodeUsers).child(snapUtils.currentUserModel.userId)
                userInstance.updateChildValues([keyNotificationCount : 0])
                break
            }else {
               count += 1
            }
        }
        utils.getProfileBadge()
        
        
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        let when = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: when){
            utils.getProfileBadge()
            self.getUserListings()
        }
        let ap = UIApplication.shared.delegate as! AppDelegate
        let myTabBar = ap.window?.rootViewController as? UITabBarController
        defaults.setValue(0, forKey: keyNotificationBadge)
        myTabBar?.tabBar.items![2].badgeValue = nil
        
        //        let ref = Database.database().reference()
        //        let _ = ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: snapUtils.currentUserModel.userId).observe(.childAdded, with: { snapshot in
        //            ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: snapUtils.currentUserModel.userId).removeAllObservers()
        //            if !snapshot.exists() {return}
        
        self.tblView.reloadData()
        //        })
    }
        
    func getUserListings()
    {
        //    
        //   self.startAnimating(size, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        let _ = ref.child(nodeListingsRegistered).queryOrdered(byChild: keyUid).queryEqual(toValue: snapUtils.currentUserModel.userId).observe(.value, with: { snapshot in
            self.ref.child(nodeListingsRegistered).queryOrdered(byChild: keyUid).queryEqual(toValue: snapUtils.currentUserModel.userId).removeAllObservers()
            self.stopAnimating()
         //   self.tblView.pullToRefreshView.stopAnimating()
            self.arr.removeAllObjects()
            if !snapshot.exists() {
                self.stopAnimating()
                
                if(self.arr.count > 0)
                {
                    self.viewDefault.isHidden = true
                }else
                {
                    self.viewDefault.isHidden = false
                }
                return
            }
           
            self.parseSnapShot(snapshot: snapshot)
        })
    }
    func parseSnapShot(snapshot : DataSnapshot)
    {
        //  detailsSnap = snapshot
        
        let myGroup = DispatchGroup()
        
        arr = NSMutableArray()
        
        for child in snapshot.children
        {
            myGroup.enter()
            
            
            if let listingID = ((child as! DataSnapshot).value as! NSDictionary)[keyListingId] as? String {
                let model2 = ListingPendingRequest()
                model2.listingID = listingID
                let _ = ref.child(nodeListings).queryOrderedByKey().queryEqual(toValue: listingID).observeSingleEvent(of: .childAdded, with: { (snapshot2) in
                    self.ref.child(nodeListingsRegistered).queryOrdered(byChild: keyListingId).queryEqual(toValue:listingID).removeAllObservers()
                    
                    if let defaults = (snapshot2.value as! NSDictionary)[keyDescription] as? String {
                        model2.listing_description = defaults
                    }
                    if let defaults = (snapshot2.value as! NSDictionary)[keyTitle] as? String {
                        model2.title = defaults
                    }
                    if let defaults = (snapshot2.value as! NSDictionary)[KeyListingAddress] as? String {
                        model2.address = defaults
                    }
                    if let defaults = (snapshot2.value as! NSDictionary)[keyURL] as? String {
                        model2.listingURL = defaults
                    }
                    if let defaults = (snapshot2.value as! NSDictionary)[keyImages] as? NSArray {
                        model2.images = defaults
                    }
                    if let defaults = (snapshot2.value as! NSDictionary)[keyUserID] as? String {
                        model2.userId = defaults
                    }
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceId] as? String {
                        model2.serviceId = defaults
                    }
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRequestTime] as? String {
                        model2.requestTime = defaults
                    }
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyTicketsCount] as? String {
                        model2.ticketsCount = defaults
                    }
                    
                    let currentTime = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM.dd.yyyy hh:mm a")
                    
                    
                    if let def = ((child as! DataSnapshot).value as! NSDictionary)[keySelectedSlot] as? NSDictionary {
                        if let def = def.value(forKey: keyCancelled) as? NSDictionary {
                            let child2 = def.allKeys
                            for i  in child2
                            {
                                
                                let d = def.value(forKey: i as! String) as! NSArray
                                
                                for j in d
                                {
                                    let model = BookingModel()
                                    model.slotArr = d
                                    model.slot_selected = j as! String
                                    model.slotDate = i as! String
                                    model.listingRegister = (child as! DataSnapshot).key
                                    let g = (j as! String).components(separatedBy: "-")
                                    let start = g[0]
                                    let end = g[1]
                                    
                                    let k = utils.convertStringToDate(i as! String + " "  + start, dateFormat: "MM-dd-yyyy h:mm a")
                                    let m = utils.convertStringToDate(i as! String, dateFormat: "MM-dd-yyyy")
                                    model.weekDay = k.dayOfWeek() ?? ""
                                    model.appoint_date = k
                                    
                                    model.strDate = utils.convertDateToString(m, format: "E,MMM d") + " at \(start) to \(end)"
                                    model.dateReminder = i as! String
                                    if model2.listingURL == "" {
                                        model.listingStatus = "CANCELLED"
                                    }else{
                                        model.listingStatus = "CONFIRMED"
                                    }
                                    model.images = model2.images
                                    model.listingID = model2.listingID
                                    model.listing_description =  model2.listing_description
                                    model.title =  model2.title
                                    model.serviceId  = model2.serviceId
                                    model.requestTime = model2.requestTime
                                    model.userId = model2.userId
                                    model.listingAddress = model2.address
                                    model.listingURL = model2.listingURL
                                    model.ticketsCount = Int(model2.ticketsCount)!
                                    if let dic = userSnapShot[keyListingReviewed] as? NSDictionary
                                    {
                                        if((dic.allKeys as NSArray).contains(model.listingID))
                                        {
                                            model.starValue = dic[model.listingID] as! CGFloat
                                        }
                                    }
                                    print("Date ===>",model.appoint_date)
                                    self.arr.add(model)
                                }
                            }
                        }
                        if let def = def.value(forKey: keyAprooved) as? NSDictionary {
                            let child2 = def.allKeys
                            for i  in child2
                            {
                                let d = def.value(forKey: i as! String) as! NSArray
                                for j in d
                                {
                                    let strTime = j as! String
                                    if(strTime == "") {
                                        print(strTime)
                                    } else {
                                        let model = BookingModel()
                                        model.slotArr = d
                                        model.slot_selected = j as! String
                                        model.slotDate = i as! String
                                        model.listingRegister = (child as! DataSnapshot).key
                                        
                                        let g = (j as! String).components(separatedBy: "-")
                                        print(g)
                                        let start = g[0]
                                        // let end = ""
                                        let end = g[1]
                                        
                                        let k = utils.convertStringToDate(i as! String + " "  + start, dateFormat: "MM-dd-yyyy h:mm a")
                                        
                                        let m = utils.convertStringToDate(i as! String, dateFormat: "MM-dd-yyyy")
                                        
                                        
                                        model.weekDay = k.dayOfWeek() ?? ""
                                        model.appoint_date = k
                                        model.strDate = utils.convertDateToString(m, format: "E,MMM d") + " at \(start) to \(end)"
                                        model.dateReminder = utils.convertDateToString(m, format: "MM-dd-yyyy")
                                        
                                        model.requestTime = model2.requestTime
                                        let requestTime = utils.convertStringToDate(model.requestTime, dateFormat: "MM.dd.yyyy hh:mm a")
                                        let calendar = Calendar.current
                                        let timeAfter48hrs:Date = calendar.date(byAdding: .hour, value: 48, to: requestTime)!
                                        
                                        if model2.listingURL == "" {
                                            model.listingStatus = "APPROVED"
                                        }else{
                                            model.listingStatus = "CONFIRMED"
                                        }
                                        
                                        if currentTime > timeAfter48hrs{
                                            model.listingStatus = "EXPIRED"
                                        }
                                        
                                        model.listingID = model2.listingID
                                        model.images = model2.images
                                        model.listing_description =  model2.listing_description
                                        model.title =  model2.title
                                        model.serviceId  = model2.serviceId
                                       
                                        model.userId = model2.userId
                                        model.listingAddress = model2.address
                                        model.listingURL = model2.listingURL
                                        model.ticketsCount = Int(model2.ticketsCount)!
                                        if let dic = userSnapShot[keyListingReviewed] as? NSDictionary
                                        {
                                            if((dic.allKeys as NSArray).contains(model.listingID))
                                            {
                                                model.isReview = false
                                                model.starValue = dic[model.listingID] as! CGFloat
                                            }
                                        }
                                        print("Date ===>",model.appoint_date)
                                        self.arr.add(model)
                                    }
                                }
                            }
                        }
                        
                        if let def = def.value(forKey: keyConfirmed) as? NSDictionary {
                            let child2 = def.allKeys
                            for i  in child2
                            {
                                let d = def.value(forKey: i as! String) as! NSArray
                                
                                for j in d
                                {
                                    let strTime = j as! String
                                    
                                    if(strTime == "") {
                                        print(strTime)
                                    } else {
                                        let model = BookingModel()
                                        model.slotArr = d
                                        model.slot_selected = j as! String
                                        model.slotDate = i as! String
                                        model.listingRegister = (child as! DataSnapshot).key
                                        let g = (j as! String).components(separatedBy: "-")
                                        print(g)
                                        let start = g[0]
                                        // let end = ""
                                        let end = g[1]
                                        
                                        let k = utils.convertStringToDate(i as! String + " "  + start, dateFormat: "MM-dd-yyyy h:mm a")
                                        
                                        let m = utils.convertStringToDate(i as! String, dateFormat: "MM-dd-yyyy")
                                        model.weekDay = k.dayOfWeek() ?? ""
                                        model.appoint_date = k
                                        model.strDate = utils.convertDateToString(m, format: "E,MMM d") + " at \(start) to \(end)"
                                        model.dateReminder = utils.convertDateToString(m, format: "MM-dd-yyyy")
                                        
                                        model.requestTime = model2.requestTime
                                        let requestTime = utils.convertStringToDate(model.requestTime, dateFormat: "MM.dd.yyyy hh:mm a")
                                        let calendar = Calendar.current
                                        let timeAfter48hrs:Date = calendar.date(byAdding: .hour, value: 48, to: requestTime)!
                                        
                                        model.listingStatus = "CONFIRMED"
                                        
                                        if currentTime > timeAfter48hrs{
                                           model.listingStatus = "EXPIRED"
                                        }
                                        
                                        model.listingID = model2.listingID
                                        model.images = model2.images
                                        model.listing_description =  model2.listing_description
                                        model.title =  model2.title
                                        model.serviceId  = model2.serviceId
                                        model.userId = model2.userId
                                        model.listingAddress = model2.address
                                        model.listingURL = model2.listingURL
                                        model.ticketsCount = Int(model2.ticketsCount)!
                                        if let dic = userSnapShot[keyListingReviewed] as? NSDictionary
                                        {
                                            if((dic.allKeys as NSArray).contains(model.listingID))
                                            {
                                                model.isReview = false
                                                model.starValue = dic[model.listingID] as! CGFloat
                                            }
                                        }
                                        print("Date ===>",model.appoint_date)
                                        self.arr.add(model)
                                    }
                                }
                            }
                        }
                        
                        if let def = def.value(forKey: keyCompleted) as? NSDictionary {
                            let child2 = def.allKeys
                            for i  in child2
                            {
                                let d = def.value(forKey: i as! String) as! NSArray
                                
                                for j in d
                                {
                                    let strTime = j as! String
                                    
                                    if(strTime == "") {
                                        print(strTime)
                                    } else {
                                        let model = BookingModel()
                                        model.slotArr = d
                                        model.slot_selected = j as! String
                                        model.slotDate = i as! String
                                        model.listingRegister = (child as! DataSnapshot).key
                                        let g = (j as! String).components(separatedBy: "-")
                                        print(g)
                                        let start = g[0]
                                        // let end = ""
                                        let end = g[1]
                                        
                                        let k = utils.convertStringToDate(i as! String + " "  + start, dateFormat: "MM-dd-yyyy h:mm a")
                                        
                                        let m = utils.convertStringToDate(i as! String, dateFormat: "MM-dd-yyyy")
                                        model.weekDay = k.dayOfWeek() ?? ""
                                        model.appoint_date = k
                                        model.strDate = utils.convertDateToString(m, format: "E,MMM d") + " at \(start) to \(end)"
                                        model.dateReminder = utils.convertDateToString(m, format: "MM-dd-yyyy")
                                        
                                        model.requestTime = model2.requestTime
                                        model.listingStatus = "COMPLETED"
                                        
                                        model.listingID = model2.listingID
                                        model.images = model2.images
                                        model.listing_description =  model2.listing_description
                                        model.title =  model2.title
                                        model.serviceId  = model2.serviceId
                                        model.userId = model2.userId
                                        model.listingAddress = model2.address
                                        model.listingURL = model2.listingURL
                                        model.ticketsCount = Int(model2.ticketsCount)!
                                        if let dic = userSnapShot[keyListingReviewed] as? NSDictionary
                                        {
                                            if((dic.allKeys as NSArray).contains(model.listingID))
                                            {
                                                model.isReview = false
                                                model.starValue = dic[model.listingID] as! CGFloat
                                            }
                                        }
                                        print("Date ===>",model.appoint_date)
                                        self.arr.add(model)
                                    }
                                }
                            }
                        }
                        var arr1: NSArray!
                        let sortedArray = self.arr.sorted(by: { ($0 as! BookingModel).appoint_date > (($1 as! BookingModel).appoint_date)})
                        arr1 = sortedArray as NSArray
                        self.arr = arr1.mutableCopy() as! NSMutableArray
                        self.tblView.reloadData()
                        
                    }
                    myGroup.leave()
                })
                myGroup.notify(queue: .main) {
                }
            }
        }
        
        
    }
    @objc func Alert()
    {
        let alert = UIAlertController(title: "", message: "Review submitted. Thank you!", preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        // change to desired number of seconds (in this case 5 seconds)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            alert.dismiss(animated: true, completion: {() -> Void in
            })
//            if self.arr.count != 0{
//                self.arr.removeObject(at: self.tag)
//            }
//            self.tblView.reloadData()
        })
    }
    
    func initNotificationSetupCheck() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                if !granted{
                    
                }
        })
    }
}
