//
//  BookingVC+ListTableView.swift
//  Classpath
//
//  Created by Coldfin on 21/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import UserNotifications
import EventKit
import Firebase
import FirebaseStorage
import FirebaseUI

class BookingTableViewCell:UITableViewCell{
    @IBOutlet weak var view_shadow: UIView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgList: UIImageView!
    @IBOutlet weak var btn_Review: UIButton!
    @IBOutlet weak var btn_ListingDetail: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view_shadow.layer.shadowOpacity = 0.8
        view_shadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_shadow.layer.shadowRadius = 4.0
        view_shadow.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
        
        btnShare.layer.shadowOffset = CGSize(width: 0, height: 1)
        btnShare.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1).cgColor
        btnShare.layer.shadowOpacity = 1
        btnShare.layer.shadowRadius = 2
        
        btnPay.layer.borderWidth = 0.8
        btnPay.layer.borderColor = themeColor.cgColor
    }
}

extension BookingVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(arr.count > 0)
        {
            self.viewDefault.isHidden = true
        }else
        {
            self.viewDefault.isHidden = false
        }
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as! BookingTableViewCell
        if let model = arr.object(at: indexPath.row) as? BookingModel
        {
            cell.lblTitle.text = model.title
            cell.imgList.image = #imageLiteral(resourceName: "ic_listing_default")
            let image = model.images[0] as! String
            if image != "" {
                let storageRef=Storage.storage().reference(forURL:image)
                cell.imgList.sd_setImage(with:storageRef, placeholderImage:#imageLiteral(resourceName: "ic_listing_default"))
            }else{
                cell.imgList.image = #imageLiteral(resourceName: "ic_listing_default")
            }
    
            cell.btnDate.setTitle("  " + model.strDate, for: .normal)
            cell.btnDate.tag = indexPath.row
            cell.btnDate.addTarget(self, action:#selector(timeStampAction(sender:)), for: .touchUpInside)
            
            cell.lblStatus.text = model.listingStatus
            cell.btn_Review.tag = indexPath.row
            cell.btnShare.tag = indexPath.row
            
//            //cell.btn_Review.addTarget(self, action:#selector(onClick_WriteReview(sender:)), for: .touchUpInside)
//            if(cell.lblStatus.text == "APPROVED") || (cell.lblStatus.text == "CONFIRMED"){
            
                let dateArr = model.strDate.components(separatedBy: " from")
                var timeSlot:String = dateArr[1]
                timeSlot = timeSlot.trimmingCharacters(in: .whitespaces)
                
                let timeArr = timeSlot.components(separatedBy: "to")
                var startTime:String = timeArr[0]
                startTime = startTime.trimmingCharacters(in: .whitespaces)
                
                var endTime:String = timeArr[1]
                endTime = endTime.trimmingCharacters(in: .whitespaces)
                
                var dateAsString = "\(model.dateReminder) \(startTime)"
                dateAsString = dateAsString.replacingOccurrences(of: "-", with: ".")
                
                if model.requestTime == "" {
                    model.requestTime = "10.25.2018 2:28 PM"
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM.dd.yyyy hh:mm a"
                var startdate:Date = dateFormatter.date(from: dateAsString)!
                startdate = utils.convertStringToDate(startdate.localDateString(), dateFormat: "MM.dd.yyyy hh:mm a")
                let currentTime = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM.dd.yyyy hh:mm a")

                
//                if model.listingURL != ""{
//                    cell.btnPay.isHidden = true
//                }else{
//                    cell.btnPay.isHidden = false
//                }
                if model.strDate == "Fri, Jan 18 from 5:00 PM to 6:00 PM" {
                    print(cell.lblStatus.text!)
                }
                if currentTime > startdate{
                    cell.btnShare.isHidden = true
                    cell.btnDate.isUserInteractionEnabled = false
                }else{
                    cell.btnShare.isHidden = false
                    cell.btnDate.isUserInteractionEnabled = true
                }
            
//                if (cell.lblStatus.text == "CONFIRMED") {
//                    if currentTime > timeAfter48hrs{
//                        cell.btn_Review.isHidden = false
//                        cell.btn_Review.setTitle("View Listing", for: .normal)
//                        cell.btn_Review.addTarget(self, action:#selector(onClick_ViewListing), for: .touchUpInside)
//                    }else {
//
//                    }
//                }
//                if currentTime > startdate /*|| currentTime > timeAfter2hrs*/{
//                    cell.btnPay.isHidden = true
//                //    cell.lblStatus.text = "EXPIRED"
//
//                }else{
//                    cell.btnPay.isHidden = false
//                }
//            }
        
            if(cell.lblStatus.text == "APPROVED") {
                cell.lblStatus.textColor = colorPreApproved
                cell.btnPay.isHidden = false
                cell.btn_Review.isHidden = true
            } else if (cell.lblStatus.text == "CANCELLED")  {
                cell.lblStatus.textColor = colorCancelled
                 cell.btnPay.isHidden = true
                cell.btn_Review.isHidden = true
            } else if (cell.lblStatus.text == "CONFIRMED") {
                cell.btnPay.isHidden = true
                cell.lblStatus.textColor = colorConfirmed
                cell.btn_Review.isHidden = false
                cell.btn_Review.setTitle("Submit Review", for: .normal)
                cell.btn_Review.addTarget(self, action:#selector(onClick_WriteReview(sender:)), for: .touchUpInside)
            } else if (cell.lblStatus.text == "EXPIRED") || (cell.lblStatus.text == "COMPLETED") {
                cell.btnPay.isHidden = true
                cell.lblStatus.textColor = cell.lblStatus.text == "EXPIRED" ? colorPreApproved : colorConfirmed
                cell.btn_Review.isHidden = false
                cell.btn_Review.setTitle("View Listing", for: .normal)
                cell.btn_Review.addTarget(self, action:#selector(onClick_ViewListing), for: .touchUpInside)
            }
            
            cell.btnPay.tag = indexPath.row
            cell.btnPay.addTarget(self, action: #selector(onClick_Payment(_:)), for: .touchUpInside)
            cell.btnShare.addTarget(self, action:#selector(onClick_Share), for: .touchUpInside)
        }
        return cell
    }
    //MARK: Share Appointment on social platform
    @objc func onClick_Share(_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tblView.cellForRow(at: indexPath) as! BookingTableViewCell
        if cell.btnPay.isHidden {
            if cell.imgList.image != #imageLiteral(resourceName: "ic_listing_default") {
                
                if let model = arr.object(at: sender.tag) as? BookingModel
                {
                    let window = UIApplication.shared.keyWindow
                    let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShareOptionsVC") as! ShareOptionsVC
                    
                    modalViewController.image = cell.imgList.image
                    modalViewController.caption = "\(model.title)\n\(model.listing_description)"
                    
                    modalViewController.modalPresentationStyle = .overCurrentContext
                    modalViewController.modalTransitionStyle = .crossDissolve
                    window?.rootViewController?.present(modalViewController, animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: "", message: "Please wait till listing image will download, then try to share again.", preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                    alert.dismiss(animated: true, completion: {() -> Void in
                    })
                })
            }
        }else{
            let alert = UIAlertController(title: "", message: "You can only share confirmed booking.To confirm your booking make payment.", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alert.dismiss(animated: true, completion: {() -> Void in
                })
            })
        }
        
    }
    //MARK: Payment
    @objc func onClick_Payment(_ sender:UIButton){
        let window = UIApplication.shared.keyWindow
        let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "InvoiceVC") as! InvoiceVC
        if let model = arr.object(at: sender.tag) as? BookingModel
        {
            modalViewController.model = model
            modelPay = model
        }
        modalViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.modalTransitionStyle = .crossDissolve
        window?.rootViewController?.present(modalViewController, animated: true, completion: nil)
    }
    
    @objc func paymentDoneSuccess(_ notification: NSNotification){
        var timer = Timer()
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(payDone), userInfo: nil, repeats: false)
        ref.child(nodeListingsRegistered).child(modelPay.listingRegister).child(keySelectedSlot).child(keyAprooved).child(modelPay.slotDate).observe(.value, with: { snapshot in
            self.ref.child(nodeListingsRegistered).child(self.modelPay.listingRegister).child(keySelectedSlot).child(keyAprooved).child(self.modelPay.slotDate).removeAllObservers()
            
            if snapshot.exists(){
                self.ref.child(nodeListingsRegistered).child(self.modelPay.listingRegister).child(keySelectedSlot).child(keyAprooved).removeValue()
                self.ref.child(nodeListingsRegistered).child(self.modelPay.listingRegister).child(keySelectedSlot).child(keyConfirmed).child(self.modelPay.slotDate).setValue(self.modelPay.slotArr)
                snapUtils.SendNotification(receiverId : self.modelPay.userId, message : "\(snapUtils.currentUserModel.userName) has purchase your service for \(self.modelPay.title)", timeStamp : NSDate().timeIntervalSince1970,listingId: self.modelPay.listingRegister)
                self.getUserListings()
            }
        })
    }
    
    @objc func payDone() {
       let custAlert = customAlertView(title: "Payment successful", message: "You're all set. Tap the time slot to add the appointment to your calendar.", btnTitle: "OK")
        custAlert.show(animated: true)
    }
    //MARK: Submit Review actions
    @objc func onClick_WriteReview(sender: UIButton) {
        if sender.title(for: .normal) == "Submit Review" {
            if let model = self.arr.object(at: sender.tag) as? BookingModel{
                
                let dateArr = model.strDate.components(separatedBy: " from")
                var timeSlot:String = dateArr[1]
                timeSlot = timeSlot.trimmingCharacters(in: .whitespaces)
                
                let timeArr = timeSlot.components(separatedBy: "to")
                var startTime:String = timeArr[0]
                startTime = startTime.trimmingCharacters(in: .whitespaces)
                
                var endTime:String = timeArr[1]
                endTime = endTime.trimmingCharacters(in: .whitespaces)
                
                var dateAsString = "\(model.dateReminder) \(startTime)"
                dateAsString = dateAsString.replacingOccurrences(of: "-", with: ".")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM.dd.yyyy hh:mm a"
                var startdate:Date = dateFormatter.date(from: dateAsString)!
                startdate = utils.convertStringToDate(startdate.localDateString(), dateFormat: "MM.dd.yyyy hh:mm a")
                
                let todayDate = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM.dd.yyyy hh:mm a")
                
                print(startdate, todayDate)
                
                if startdate < todayDate{
                    tag = sender.tag
                    SetReview(tagIndex :sender.tag)
                    Deletetag = sender.tag
                    let indexPath = IndexPath(row: sender.tag, section: 0)
                    let cell = tblView.cellForRow(at: indexPath) as! BookingTableViewCell
                    if cell.btnPay.isHidden {
                        
                        if model.listingStatus == "CONFIRMED"{
                            let v = UIView()
                            let custAlert = customAlertView.init(title: "Message", message: "Did you attend "+listingTitle.trimmingCharacters(in:.whitespacesAndNewlines)+" on "+listTimeframe.trimmingCharacters(in:.whitespacesAndNewlines)+"?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
                            custAlert.onRightBtnSelected = { (Value: String) in
                                custAlert.dismiss(animated: true)
                                self.userAttendenceStatus(isAttended:true, tag: sender.tag)
                                self.openSubmitReviewPopUp(model:model)
                            }
                            custAlert.onBgBtnSelected = { (Value: String) in
                            }
                            custAlert.onLeftBtnSelected = { (Value: String) in
                                custAlert.dismiss(animated: true)
                                self.userAttendenceStatus(isAttended:false, tag: sender.tag)
                            }
                            custAlert.show(animated: true)
                        }else {
                            self.openSubmitReviewPopUp(model:model)
                        }
                    }else{
                        let alert = UIAlertController(title: "", message: "You can only share confirmed booking.To confirm your booking make payment.", preferredStyle: UIAlertController.Style.alert)
                        self.present(alert, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                            alert.dismiss(animated: true, completion: {() -> Void in
                            })
                        })
                    }
                }else{
                    let alert = UIAlertController(title: "", message: "Try submitting after your appointment", preferredStyle: UIAlertController.Style.alert)
                    self.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        alert.dismiss(animated: true, completion: {() -> Void in
                        })
                    })
                }
            }
        }
    }
    
    func userAttendenceStatus(isAttended:Bool,tag:Int) {

        let model = self.arr.object(at: tag) as! BookingModel
        var keyStatus = keyCancelled
        if isAttended {
            keyStatus = keyCompleted
            self.ref.child(nodeListings).child(model.listingID).observeSingleEvent(of : .value, with: { (snapshot) in
                
                var count = model.ticketsCount
                if let defaults = (snapshot.value as! NSDictionary)[keyNoofRegister] as? Int {
                    count = defaults + model.ticketsCount
                }
                let userInstance = self.ref.child(nodeListings).child(model.listingID)
                userInstance.updateChildValues([keyNoofRegister : count])
               
                self.updateOwnerBadge(userid: model.userId)
            })
        }
        
        let registerInstance = self.ref.child(nodeListingsRegistered).child(model.listingRegister).child(keySelectedSlot)
        
        registerInstance.child(keyConfirmed).observe(.value, with: { snapshot in
            if !snapshot.exists() {
                let arr2 = NSMutableDictionary()
                arr2.setValue([model.slot_selected], forKey: model.slotDate)
                
                registerInstance.child(keyStatus).setValue(arr2)
            }else{
                var arr2 = NSMutableArray()
                let arr3 = snapshot.value as! NSMutableDictionary
                if let k = arr3.value(forKey: model.slotDate) as? NSMutableArray
                {
                    arr2 = k
                }
                arr2.add(model.slot_selected)
                arr3.setValue(arr2, forKey: model.slotDate)
                registerInstance.child(keyStatus).setValue(arr3)
                
                registerInstance.child(keyConfirmed).child(model.slotDate).removeValue()
            }
            model.listingStatus = keyStatus == keyCompleted ? "COMPLETED" : "CANCELLED"
            self.tblView.reloadData()
        })
        
        if !isAttended {
            let alert = UIAlertController(title: "", message: "THANK YOU!", preferredStyle: UIAlertController.Style.alert)
            
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alert.dismiss(animated: true, completion: {() -> Void in
                })
            })
        }
    }
    
    func updateOwnerBadge(userid:String) {
        let userRef = self.ref.child(nodeListings).queryOrdered(byChild: keyUserID).queryEqual(toValue: userid)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists(){
                var noOfReg = 0
                for child in snapshot.children {
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyNoofRegister] as? Int{
                        noOfReg += defaults
                    }
                }
                if noOfReg >= 4{
                    let arr = ["Athlete","Pro Trainer","Master Trainer","World Class Trainer"]
                    self.ref.child(nodeUsers).child(userid).updateChildValues([keyBadges:arr])
                }else if noOfReg >= 2{
                    let arr = ["Athlete","Pro Trainer","Master Trainer"]
                    self.ref.child(nodeUsers).child(userid).updateChildValues([keyBadges:arr])
                }
            }
        }
    }
    
    func openSubmitReviewPopUp(model:BookingModel) {
        let window = UIApplication.shared.keyWindow
        let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "SubmitReviewPopUp") as! SubmitReviewPopUp
        modalViewController.listingid = sessionKey
        modalViewController.Deletetag = self.Deletetag
        modalViewController.isUserRating = false
        modalViewController.timeframe = self.listTimeframe
        modalViewController.listName = self.listingTitle
        modalViewController.model = model
        modalViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.modalTransitionStyle = .crossDissolve
        window?.rootViewController?.present(modalViewController, animated: true, completion: nil)
    }
    
    
    func SetReview(tagIndex :Int) {
        if let model = self.arr.object(at: tagIndex) as? BookingModel{
            let listingId = model.listingID
            print(listingId)
            sessionKey = listingId
            
            listingTitle = model.title
            listTimeframe = model.strDate
            DellistingRegister = model.listingRegister
            DeldateReminder = model.dateReminder
            DelkeySelectedSlot = keySelectedSlot
        }
    }
    
    //MARK: Save appointment reminder in calendar app
    @objc func timeStampAction(sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tblView.cellForRow(at: indexPath) as! BookingTableViewCell
        if cell.btnPay.isHidden != false {
            // Create the alert controller
            let v = UIView()
            let custAlert = customAlertView.init(title: "Message", message: "Would you like to add this appointment to your phone's calendar?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
                 self.addReminderToClander(tagIndex: sender.tag)
            }
            custAlert.onLeftBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
            }
            custAlert.show(animated: true)
            
        }else{
            let alert = UIAlertController(title: "", message: "If you would like to add this appointment to your phone's calendar, please confirm this booking.To confirm your booking make payment.", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(4.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alert.dismiss(animated: true, completion: {() -> Void in
                })
            })
        }
    }
    
    func addReminderToClander(tagIndex :Int) {
        let eventStore : EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                if let model = self.arr.object(at: tagIndex) as? BookingModel{
                    
                    let dateArr = model.strDate.components(separatedBy: " from")
                    var timeSlot:String = dateArr[1]
                    timeSlot = timeSlot.trimmingCharacters(in: .whitespaces)
                    
                    let timeArr = timeSlot.components(separatedBy: "to")
                    var startTime:String = timeArr[0]
                    startTime = startTime.trimmingCharacters(in: .whitespaces)
                    
                    var endTime:String = timeArr[1]
                    endTime = endTime.trimmingCharacters(in: .whitespaces)
                    
                    let dateAsString = "\(model.dateReminder) \(startTime)"
                    let dateEnd = "\(model.dateReminder) \(endTime)"
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
                    let startdate = dateFormatter.date(from: dateAsString)
                    let enddate = dateFormatter.date(from: dateEnd)
                    
                    let event:EKEvent = EKEvent(eventStore: eventStore)
                    event.title = model.title
                    event.startDate = startdate!
                    event.endDate = enddate!
                    let alarm1hour = EKAlarm(relativeOffset: -3600)
                    event.addAlarm(alarm1hour)
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let error as NSError {
                        print("failed to save event with error : \(error)")
                        return
                    }
                    let alert = UIAlertController(title: "", message: "Your appointment is saved in calender as an event", preferredStyle: UIAlertController.Style.alert)
                    self.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        alert.dismiss(animated: true, completion: {() -> Void in
                        })
                    })
                }
            }
            else{
                print("failed to save event with error : or access not granted")
            }
        }
    }
    func setReminder(tagIndex :Int) {
        if let model = arr.object(at: tagIndex) as? BookingModel{
            let notification = UNMutableNotificationContent()
            notification.title = model.title
            notification.body = "Your appointment schedule for now"
            notification.sound = UNNotificationSound.default
            
            let dateArr = model.strDate.components(separatedBy: "from")
            var strTimeslot:String = dateArr[1]
            strTimeslot = strTimeslot.trimmingCharacters(in: .whitespaces)
            
            let timeArr = strTimeslot.components(separatedBy: "to")
            var strtime:String = timeArr[0]
            strtime = strtime.trimmingCharacters(in: .whitespaces)
            
            let dateAsString = model.dateReminder
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let date = dateFormatter.date(from: dateAsString)
            
            dateFormatter.dateFormat = "d"
            let dat = dateFormatter.string(from: date!)
            
            dateFormatter.dateFormat = "MM"
            let month = dateFormatter.string(from: date!)
            
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: date!)
            
            let timeAsString = strtime
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let time = dateFormatter.date(from: timeAsString)
            
            dateFormatter.dateFormat = "HH"
            let datehours = dateFormatter.string(from: time!)
            
            dateFormatter.dateFormat = "mm"
            let datemins = dateFormatter.string(from: time!)
            
            notification.badge = 0;
            var dateComponents = DateComponents()
            dateComponents.day = Int(dat)
            dateComponents.month = Int(month)
            dateComponents.year = Int(year)
            dateComponents.hour = Int(datehours)
            dateComponents.minute = Int(datemins)
            
            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "notification", content: notification, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
    }

    //MARK: Navigate to Listing Details VC
    @objc func onClick_ViewListing(_ sender: UIButton) {
        if sender.title(for: .normal) == "View Listing" {
        var model:BookingModel = BookingModel()
        model = self.arr.object(at: sender.tag) as! BookingModel
        fetchListingDetails(listingId: model.listingID)
        }
    }
    func fetchListingDetails(listingId:String)  {
        let _ = ref.child(nodeListings).child(listingId).observe(.value, with: { snapshot in
            self.ref.child(nodeListings).child(listingId).removeAllObservers()
            if snapshot.exists(){
                if snapshot.value != nil {
                    snapUtils.parseSnapShot(snapshot: snapshot,notiName: "listingDetailBooking")
                }
            }
        })
    }
    @objc func reloadlistingData(_ notification: NSNotification){
        
        if let model = notification.userInfo?["model"] as? ListingModel {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextpage = storyboard.instantiateViewController(withIdentifier: "ListingDetailsVC") as! ListingDetailsVC
            nextpage.isFromFavoriteVC = false
            nextpage.model = model
            nextpage.isToday = true
            self.navigationController?.pushViewController(nextpage,animated: true)
        }
        
    }
}
