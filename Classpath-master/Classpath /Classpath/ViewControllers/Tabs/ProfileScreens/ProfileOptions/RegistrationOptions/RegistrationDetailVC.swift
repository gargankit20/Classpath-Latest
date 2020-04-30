//
//  RegistrationDetailVC.swift
//  Classpath
//
//  Created by Coldfin on 25/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

class RegDetailTableViewCell:UITableViewCell {
    @IBOutlet weak var lblServices: UILabel!
    @IBOutlet weak var btnDeny: UIButton!
    @IBOutlet weak var btnApprove: UIButton!
    @IBOutlet weak var lblTimeSlot: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnregistredBy: UIButton!
    @IBOutlet weak var imgList: UIImageView!
    @IBOutlet weak var view_shadow: UIView!
    //@IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblAttendees: UILabel!
    
    
    override func awakeFromNib() {
        view_shadow.layer.shadowOpacity = 1
        view_shadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_shadow.layer.shadowRadius = 4.0
        view_shadow.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
        btnDeny.layer.borderWidth = 0.8
        btnDeny.layer.borderColor = UIColor.red.cgColor
        
        //btnCancel.layer.borderWidth = 0.8
        //btnCancel.layer.borderColor = UIColor.red.cgColor
    }
}

class RegistrationDetailVC: UIViewController,NVActivityIndicatorViewable {
    @IBOutlet weak var tblView: UITableView!
    var arr = NSMutableArray()
    var arrAppointments = NSMutableArray()
    var ref: DatabaseReference!
    var modelRequest = ListingPendingRequest()
    var modelListingId = ""
    var senderUserName = ""
    var message = String()
    var registrationID = String()
    var isFromHistory = false
    
    var delegate : requestHandleDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        tblView.tableFooterView = UIView()
        
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        if modelListingId == "" {
            getRegistrationRequest()
        }else {
            getListingDetailFirst()
        }
    }
    func getListingDetailFirst() {
        
        
        ref.child(nodeListings).child(modelListingId).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                self.modelRequest.listingID = snapshot.key
                if let defaults = (snapshot.value as! NSDictionary)[keyTitle] as? String {
                    self.modelRequest.title = defaults
                }
            }
            self.getRegistrationRequest()
        }
        
    }
    
    func getRegistrationRequest()
    {
         
       self.title = modelRequest.title
        let _ = ref.child(nodeListingsRegistered).queryOrdered(byChild: keyListingId).queryEqual(toValue: modelRequest.listingID).observe(.value, with: { snapshot in
            self.ref.child(nodeListingsRegistered).queryOrdered(byChild: keyListingId).queryEqual(toValue: self.modelRequest.listingID).removeAllObservers()
            
            
            if !snapshot.exists() {
                
                self.arr = NSMutableArray()
                self.arrAppointments = NSMutableArray()
                self.tblView.reloadData()
            }
            
            let Group2 = DispatchGroup()
            var isSlotAvailable = false
            for child in snapshot.children
            {
                Group2.enter()
                var username = ""
                var userID = ""
                var regID = ""
                var userProfilePic = ""
                
                if let s = ((child as! DataSnapshot).value as! NSDictionary)[keyUid] as? String
                {
                    userID = s
                    regID = (child as! DataSnapshot).key
                    let _ = self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: userID).observe(.childAdded, with: { snapshot in
                        self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: userID).removeAllObservers()
                        if !snapshot.exists() {return}
                        if let d = (snapshot.value as! NSDictionary)[keyUsername] as? String {
                            username = username + d
                        }
                        if let defaults = (snapshot.value as! NSDictionary)[keyProfilePic] as? String {
                            userProfilePic = defaults
                        }
                        
                        if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keySelectedSlot] as? NSDictionary
                        {
                            isSlotAvailable = true
                            if let defaults = defaults.value(forKey: keyRejected) as? NSDictionary
                            {
                                self.getData(defaults:defaults, userID: userID, regID: regID, username: username, userProfilePic: userProfilePic, status: "Rejected", child: child as! DataSnapshot)
                            }
                            if let defaults = defaults.value(forKey: keyAprooved) as? NSDictionary
                            {
                                self.getData(defaults:defaults, userID: userID, regID: regID, username: username, userProfilePic: userProfilePic, status: "Payment Pending", child: child as! DataSnapshot)
                            }
                            if let defaults = defaults.value(forKey: keyPending) as? NSDictionary {
                                self.getData(defaults:defaults, userID: userID, regID: regID, username: username, userProfilePic: userProfilePic, status: "Pending", child: child as! DataSnapshot)
                            }
                            if let defaults = defaults.value(forKey: keyCancelled) as? NSDictionary
                            {
                                self.getData(defaults:defaults, userID: userID, regID: regID, username: username, userProfilePic: userProfilePic, status: "Cancelled", child: child as! DataSnapshot)
                            }
                            if let defaults = defaults.value(forKey: keyConfirmed) as? NSDictionary
                            {
                                self.getData(defaults:defaults, userID: userID, regID: regID, username: username, userProfilePic: userProfilePic, status: "Confirmed", child: child as! DataSnapshot)
                            }
                            if let defaults = defaults.value(forKey: keyCompleted) as? NSDictionary
                            {
                                self.getData(defaults:defaults, userID: userID, regID: regID, username: username, userProfilePic: userProfilePic, status: "Completed", child: child as! DataSnapshot)
                            }
                        }
                        Group2.leave()
                    })
                }
            }
            Group2.notify(queue: .main) {
                if !isSlotAvailable {
                    self.arr = NSMutableArray()
                    self.arrAppointments = NSMutableArray()
                    self.tblView.reloadData()
                }
                self.stopAnimating()
            }
        })
    }
    
    func getData(defaults: NSDictionary, userID:String, regID:String, username:String, userProfilePic:String, status:String, child:DataSnapshot) {
        
        self.arr = NSMutableArray()
        self.arrAppointments = NSMutableArray()
        
        let keys = defaults.allKeys
        for i in keys {
            let date = i as! String
            if let defaults = defaults.value(forKey: i as! String) as? NSArray {
                let Group2 = DispatchGroup()
                for j in defaults {
                    Group2.enter()
                    let model = AcceptRejecModel()
                    model.userID = userID
                    model.registrationID = regID
                    model.registeredBy = username
                    model.regUserPic = userProfilePic
                    model.status = status
                    
                    model.slot_selected = j as! String
                    let k = utils.convertStringToDate(date, dateFormat: "MM-dd-yyyy")
                    
                    if let defaults = (child.value as! NSDictionary)[keyTransactionId] as? String {
                        model.transactionId = defaults
                    }
                    if let defaults = (child.value as! NSDictionary)[keyRequestTime] as? String {
                        model.requestTime = defaults
                    }
                    
                    if let defaults = (child.value as! NSDictionary)[keyTicketsCount] as? String {
                        model.ticketsCount = defaults
                    }
                    
                    if let defaults = (child.value as! NSDictionary)[keyListingId] as? String {
                        model.listingID = defaults
                    }
                    
                    if status == "Pending"{
                        if model.requestTime == "" {
                            model.requestTime = "10.25.2018 2:28 PM"
                        }
//                        let currentTime = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM.dd.yyyy hh:mm a")
//                        let timeAfter2hrs:Date = calendar.date(byAdding: .minute, value: 120, to: requestTime)!
                        
//                        if currentTime > timeAfter2hrs{
//                            model.status = "Expired"
//                        }
                    }
                    if var defaults = (child.value as! NSDictionary)[keyServiceId] as? String {
                        if defaults == "" {
                            defaults = "fdghkfvjg"
                        }
                        guard let uid = Auth.auth().currentUser?.uid else{
                            return
                        }
                        self.ref.child(nodeService).child(uid).child(defaults).observeSingleEvent(of: .value, with: { snapshot in
                            self.ref.child(nodeService).child(uid).queryOrdered(byChild: defaults).removeAllObservers()
                            if snapshot.exists() {
                                //for child in snapshot.children {
                                    if let defaults = (snapshot.value as! NSDictionary)[keyServiceName] as? String {
                                        model.service_selected = defaults
                                    }
                               //}
                            }
                            model.date = k
                            model.weekDay = k.dayOfWeek() ?? ""
                            model.dateString = date
                            
                            if model.status == "Payment Pending" || model.status == "Pending" {
                                let timeArr = model.slot_selected.components(separatedBy: "-")
                                var strTimeslot:String = timeArr[0]
                                strTimeslot = strTimeslot.trimmingCharacters(in: .whitespaces)
                                var date = model.dateString + " " + strTimeslot
                                date = date.replacingOccurrences(of: "-", with: ".")
                            }
                            self.arr.add(model)
                            Group2.leave()
                        })
                        Group2.notify(queue: .main) {
                            self.sortByTimeReference()
                        }
                    }
                }
            }
        }
    }
    
    func sortByTimeReference(){
        var arr1: NSArray!
        let sortedArray = self.arr.sorted(by: { ($0 as! AcceptRejecModel).date > (($1 as! AcceptRejecModel).date)})
        arr1 = sortedArray as NSArray
        print("gfhjg: ",arr1.count,self.arr.count,self.arrAppointments.count)
        self.arr = arr1.mutableCopy() as! NSMutableArray
        
        self.arrAppointments.removeAllObjects()
        
        var arrTemp = NSMutableArray()
        var count = 1
        var dateAhead = ""
        for i in arr1 {
            
            if count != arr1.count {
                dateAhead = (arr1.object(at: count) as! AcceptRejecModel).dateString
            }
            var key = ""
            
            let model = i as! AcceptRejecModel
            let todayDate = utils.convertStringToDate(Date().localDateStringOnlyDate(), dateFormat: "MM-dd-yyyy")
            
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: todayDate)!
            let temp = utils.convertDateToString(tomorrow, format: "MM-dd-yyyy")
            
            let dic = NSMutableDictionary()
            
            arrTemp.add(i)
            if model.dateString == Date().localDateStringOnlyDate() {
                key = "Today"
            }else if model.dateString == temp{
                key = "Tomorrow"
            }else {
                key = model.dateString
            }
            
            if dateAhead != model.dateString || count == arr1.count{
           //     if dateAhead != "" {
                    dic.setValue(arrTemp, forKey: key)
                    self.arrAppointments.add(dic)
            //    }
                arrTemp = NSMutableArray()
            }
            count += 1
        }
        
        self.tblView.reloadData()
        self.stopAnimating()
        
    }
    
    func getLoginUsername(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }

        let _ = self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: uid).observe(.childAdded, with: { snapshot in
            if !snapshot.exists() {return}
            var name = ""
            
            if let defaults = (snapshot.value as! NSDictionary)[keyUsername] as? String {
                name =  name + defaults
            }
            
            self.senderUserName = name
        })
    }
}
extension RegistrationDetailVC :  UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrAppointments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let dicData = arrAppointments.object(at: section) as? NSMutableDictionary
        let arrData = dicData?.object(forKey: (dicData?.allKeys[0] as! String)) as! NSArray
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegDetailCell") as! RegDetailTableViewCell
        
        let dicData = arrAppointments.object(at: indexPath.section) as? NSMutableDictionary
        let arrData = dicData?.object(forKey: (dicData?.allKeys[0] as! String)) as! NSArray
        
        var model : AcceptRejecModel = AcceptRejecModel()
        model = arrData.object(at: indexPath.row) as! AcceptRejecModel
        
        cell.btnregistredBy.setTitle(model.registeredBy, for: .normal)
        if model.regUserPic != "" {
            cell.imgList.sd_setImage(with:URL(string:model.regUserPic), placeholderImage:#imageLiteral(resourceName: "ic_profile_default"))
        }else{
            cell.imgList.image = #imageLiteral(resourceName: "ic_profile_default")
        }
        cell.lblDate.text = model.dateString + " " + model.weekDay
        cell.lblTimeSlot.text = model.slot_selected == "" ? "N/A" : model.slot_selected
        cell.lblServices.text = model.service_selected == "" ? "N/A" : model.service_selected
        cell.lblStatus.text = model.status
        cell.lblAttendees.text = model.ticketsCount == "" ? "1" : model.ticketsCount
        if(model.status == "Payment Pending" || model.status == "Pending") {
            cell.lblStatus.textColor = colorPreApproved
        } else if (model.status == "Confirmed") {
            cell.lblStatus.textColor = colorConfirmed
            cell.lblStatus.text = "Booked"
        } else if model.status == "Completed"{
            cell.lblStatus.textColor = colorConfirmed
            cell.lblStatus.text = "Completed"
        } else if model.status == "Cancelled" || model.status == "Rejected" || model.status == "Expired" {
            cell.lblStatus.textColor = colorCancelled
        }
        
        cell.btnApprove.tag = (indexPath.section*1000)+indexPath.row  //indexPath.row
        cell.btnDeny.tag = (indexPath.section*1000)+indexPath.row  //indexPath.row
        cell.btnregistredBy.tag = (indexPath.section*1000)+indexPath.row  //indexPath.row
        //cell.btnCancel.tag = (indexPath.section*1000)+indexPath.row  //indexPath.row
        
        cell.btnApprove.isHidden = false
        cell.btnDeny.isHidden = false
        //cell.btnCancel.isHidden = true
        
        //cell.btnCancel.isHidden = false
        //cell.btnCancel.setTitle("Cancel Appointment", for: .normal)
        //cell.btnCancel.addTarget(self, action:#selector(handleCancel(sender:)), for: .touchUpInside)
        
        if model.status == "Confirmed" || model.status == "Payment Pending" || model.status == "Pending"{
            cell.btnApprove.isHidden = true
            cell.btnDeny.isHidden = true
            //cell.btnCancel.isHidden = false

            if model.slot_selected != "" {
                let timeArr = model.slot_selected.components(separatedBy: "-")
                var strTimeslot:String = timeArr[0]
                strTimeslot = strTimeslot.trimmingCharacters(in: .whitespaces)
                var date = model.dateString + " " + strTimeslot
                date = date.replacingOccurrences(of: "-", with: ".")
                
                let startdate = utils.convertStringToDate(date, dateFormat: "MM.dd.yyyy hh:mm a")
                let todayDate = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM.dd.yyyy hh:mm a")
                
                if startdate < todayDate{
                    //cell.btnCancel.setTitle("Delete", for: .normal)
                    //cell.btnCancel.addTarget(self, action:#selector(handleDelete(sender:)), for: .touchUpInside)
                }else{
                    if model.status == "Pending" {
                        cell.btnApprove.isHidden = false
                        cell.btnDeny.isHidden = false
                        //cell.btnCancel.isHidden = true
                    }else {
                        //cell.btnCancel.isHidden = false
                        //cell.btnCancel.addTarget(self, action:#selector(handleCancel(sender:)), for: .touchUpInside)
                    }
                }
            }
        }
        else if model.status == "Cancelled" || model.status == "Rejected" || model.status == "Expired" {
            cell.btnApprove.isHidden = true
            cell.btnDeny.isHidden = true
            //cell.btnCancel.isHidden = true
            //cell.btnCancel.setTitle("Delete", for: .normal)
            //cell.btnCancel.addTarget(self, action:#selector(handleDelete(sender:)), for: .touchUpInside)
        }
        else if model.status == "Booked" || model.status == "Payment Pending"  {
            cell.btnApprove.isHidden = true
            cell.btnDeny.isHidden = true
            //cell.btnCancel.isHidden = false
            //cell.btnCancel.setTitle("Cancel Appointment", for: .normal)
            //cell.btnCancel.addTarget(self, action:#selector(handleCancel(sender:)), for: .touchUpInside)
        }else if model.status == "Completed" {
            cell.btnApprove.isHidden = true
            cell.btnDeny.isHidden = true
            //cell.btnCancel.isHidden = true
        }
        
        cell.btnApprove.addTarget(self, action:#selector(handleApprove(sender:)), for: .touchUpInside)
        cell.btnDeny.addTarget(self, action:#selector(handleDeny(sender:)), for: .touchUpInside)
        cell.btnregistredBy.addTarget(self, action:#selector(openProfile(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        
        let dicData = arrAppointments.object(at: section) as? NSMutableDictionary
       
        let label = UILabel(frame: CGRect(x: 24, y: 5, width: 120, height: 20))
        label.text = (dicData?.allKeys[0] as! String)
        label.textColor =  themeColor
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        label.font = UIFont(name: "SFProText-Semibold", size: 15)
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    @objc func openProfile(sender: UIButton){
        let section = sender.tag/1000
        let row = sender.tag%1000
        
        let dicData = arrAppointments.object(at: section) as? NSMutableDictionary
        let arrData = dicData?.object(forKey: (dicData?.allKeys[0] as! String)) as! NSArray
        
        var model : AcceptRejecModel = AcceptRejecModel()
        model = arrData.object(at: row) as! AcceptRejecModel
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        nextpage.userID = model.userID
        nextpage.isShowBar = true
        self.present(nextpage, animated: true, completion: nil)
    }
    
    @objc func approveRequest(sender: UIButton)
    {
        let section = sender.tag/1000
        let row = sender.tag%1000
        
        let dicData = arrAppointments.object(at: section) as? NSMutableDictionary
        let arrData = dicData?.object(forKey: (dicData?.allKeys[0] as! String)) as! NSArray
        
        var model : AcceptRejecModel = AcceptRejecModel()
        model = arrData.object(at: row) as! AcceptRejecModel

        let _ = ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyPending).child(model.dateString).observe(.value, with: { snapshot in
            self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyPending).child(model.dateString).removeAllObservers()
            if !snapshot.exists()
            {
                let custAlert = customAlertView(title: "", message: "Something went wrong, please try again.", image: #imageLiteral(resourceName: "ic_done"))
                custAlert.show(animated: true)
                return
            }else{
                let arr = snapshot.value as! NSMutableArray
                arr.remove(model.slot_selected)
               self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keyRequestTime).setValue(Date().localDateString())
                self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyPending).child(model.dateString).setValue(arr)
            }
        })
        
        let _ = ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: model.userID).observe(.childAdded, with: { snapshot in
            var count = 1
            if let defaults = (snapshot.value as! NSDictionary)[keyNotificationCount] as? Int {
                count = defaults + 1
            }
            let userInstance = self.ref.child(nodeUsers).child(model.userID)
            userInstance.updateChildValues([keyNotificationCount : count])
            
        })
        self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyAprooved).observe(.value, with: { snapshot in
            self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyAprooved).removeAllObservers()
            
            if !snapshot.exists() {
                let arr2 = NSMutableDictionary()
                arr2.setValue([model.slot_selected], forKey: model.dateString)
                self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keyRequestTime).setValue(Date().localDateString())
                self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyAprooved).setValue(arr2)
            }else{
                var arr2 = NSMutableArray()
                let arr3 = snapshot.value as! NSMutableDictionary
                if let k = arr3.value(forKey: model.dateString) as? NSMutableArray
                {
                    arr2 = k
                }
                arr2.add(model.slot_selected)
                arr3.setValue(arr2, forKey: model.dateString)
                self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keyRequestTime).setValue(Date().localDateString())
                self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyAprooved).setValue(arr3)
            }
            
            self.getRegistrationRequest()
            self.delegate.requestHandleReload()
            
            let custAlert = customAlertView(title: "Message", message: "Your invoice was successfully sent to the user. We will “confirm” your appointment once the user has successfully submitted the payment", btnTitle: "OK")
            custAlert.onBtnSelected = {(Value:String) in
            }
            custAlert.show(animated: true)
            self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyPending).child(model.dateString).observe(.value, with: { snapshot in
            })
           
           
            let todayDate = utils.convertStringToDate(Date().localDateStringOnlyDate(), dateFormat: "MM-dd-yyyy")
            
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: todayDate)!
            let temp = utils.convertDateToString(tomorrow, format: "MM-dd-yyyy")
            
            var day = ""
            if model.dateString == Date().localDateStringOnlyDate() {
                day = "Today"
            }else if model.dateString == temp{
                day = "Tomorrow"
            }
            
            let msg = "Hi \(model.registeredBy)! You request to attend \(self.modelRequest.title) \(day) at \(model.dateString + " " + model.slot_selected) is approved. Submit payment ASAP to confirm"
            let regID = model.registrationID
            self.message = msg
            self.registrationID = regID
            
            
            snapUtils.SendNotification(receiverId: model.userID, message: msg, timeStamp: NSDate().timeIntervalSince1970, listingId: model.listingID)
        })
    }
    @objc func handleDelete(sender: UIButton){
        if sender.titleLabel?.text == "Delete" {
            
            let section = sender.tag/1000
            let row = sender.tag%1000
            
            let dicData = arrAppointments.object(at: section) as? NSMutableDictionary
            let arrData = dicData?.object(forKey: (dicData?.allKeys[0] as! String)) as! NSMutableArray
            
            var model : AcceptRejecModel = AcceptRejecModel()
            model = arrData.object(at: row) as! AcceptRejecModel
            
            var key = ""
            if model.status == "Confirmed" {
                key = keyConfirmed
            }else if model.status == "Cancelled" {
                key = keyCancelled
            }else if model.status == "Rejected" {
                key = keyRejected
            }else if model.status == "Payment Pending" {
                key = keyAprooved
            }else if model.status == "Pending" || model.status == "Expired"{
                key = keyPending
            }else if model.status == "Completed" {
                key = keyCompleted
            }
            
            let userInstance = self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(key)
            userInstance.removeValue()
            
            self.getRegistrationRequest()
            self.delegate.requestHandleReload()
            
            let alert = UIAlertController(title: "", message: "Registered appointment deleted successfully", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            // change to desired number of seconds (in this case 5 seconds)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alert.dismiss(animated: true, completion: {() -> Void in
                })
            })
        }
    }
    @objc func handleCancel(sender: UIButton){
        if sender.titleLabel?.text == "Cancel Appointment" {
            let row = sender.tag%1000
            
            let v = UIView()
            let custAlert = customAlertView(title: "Message", message: "Are you sure you want to cancel?", customView: v, leftBtnTitle: "NO", rightBtnTitle: "YES", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = {(Value:String) in
                custAlert.dismiss(animated: true)
                var model : AcceptRejecModel = AcceptRejecModel()
                
                model = self.arr.object(at: row) as! AcceptRejecModel
                
                var key = ""
                if model.status == "Confirmed"{
                    key = keyConfirmed
                }else{
                    key = keyAprooved
                }
                
                let _ = self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(key).child(model.dateString).observe(.value, with: { snapshot in
                    self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(key).child(model.dateString).removeAllObservers()
                    if !snapshot.exists()
                    {
                        let alert = UIAlertController(title: "", message: "Something went wrong", preferredStyle: UIAlertController.Style.alert)
                        self.present(alert, animated: true, completion: nil)
                        // change to desired number of seconds (in this case 5 seconds)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                            alert.dismiss(animated: true, completion: {() -> Void in
                            })
                        })
                        
                        return
                    }else{
                        let arr = snapshot.value as! NSMutableArray
                        arr.remove(model.slot_selected)
                        self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(key).child(model.dateString).setValue(arr)
                    }
                })
                
                self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyCancelled).observe(.value, with: { snapshot in
                    self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyCancelled).removeAllObservers()
                    
                    if !snapshot.exists() {
                        let arr2 = NSMutableDictionary()
                        arr2.setValue([model.slot_selected], forKey: model.dateString)
                        self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyCancelled).setValue(arr2)
                        
                    }else{
                        var arr2 = NSMutableArray()
                        let arr3 = snapshot.value as! NSMutableDictionary
                        if let k = arr3.value(forKey: model.dateString) as? NSMutableArray
                        {
                            arr2 = k
                        }
                        arr2.add(model.slot_selected)
                        arr3.setValue(arr2, forKey: model.dateString)
                        self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyCancelled).setValue(arr3)
                        
                    }
                    
                    
                    var message = "Hi \(model.registeredBy)! \nYour registration for listing \"\(self.modelRequest.title)\" with timeslot \(model.dateString + " " + model.slot_selected) is Rejected."
                    if model.status == "Confirmed" {
                        message += " Your money will be securely refund to your account within & working days"
                        self.cancelAppointwithRefund(message:message, model:model)
                    }else {
                        self.cancelMessageandNotification(message: message, model:model)
                    }
                    
                })
            }
            custAlert.show(animated: true)
        }
    }
    
    func cancelMessageandNotification(message:String, model:AcceptRejecModel){
        
        self.getRegistrationRequest()
        self.delegate.requestHandleReload()
        let alert = UIAlertController(title: "", message: "Request cancelled successfully", preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        // change to desired number of seconds (in this case 5 seconds)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            alert.dismiss(animated: true, completion: {() -> Void in
            })
            
        })
        
        snapUtils.SendNotification(receiverId: model.userID, message: message, timeStamp: NSDate().timeIntervalSince1970, listingId: model.listingID)
    }
    
    func cancelAppointwithRefund(message:String, model:AcceptRejecModel) {
        // let url = ""
        let strUrl = "\(BaseURl)/stripe/create_refund.php"
        let params: [String: Any] = ["charge_id": model.transactionId]
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html", "application/json"])
        manager.requestSerializer.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        manager.securityPolicy.allowInvalidCertificates = true;
        manager.securityPolicy.validatesDomainName = false;
        manager.post(strUrl, parameters: params, success: {(operation, responseObject) in
            self.stopAnimating()
            let success = (responseObject as! NSDictionary).value(forKey: "succcess") as! Bool
            if success {
                self.cancelMessageandNotification(message: message, model: model)
            }
        }, failure: { (operation, error) in
            print(error as Any)
        })
    }
    
    @objc func handleApprove(sender: UIButton){
        let v = UIView(frame: CGRect(x: 0, y: -5, width: 310, height: 55))
        let lbl = UILabel(frame: CGRect(x: 10, y: 0, width: 290, height: 55))
        lbl.text = "Once their payment is received your appointment will be confirmed"
        lbl.textColor = textThemeColor
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "SFProDisplay-Regular", size: 14)
        v.addSubview(lbl)
        let custAlert = customAlertView(title: "Confirm Approval", message: "Great, your client will be notified of your approval.", customView: v, leftBtnTitle: "Cancel", rightBtnTitle: "Confirm", image: #imageLiteral(resourceName: "ic_done"))
        
        custAlert.onRightBtnSelected = {(Value:String) in
            custAlert.dismiss(animated: true)
            self.approveRequest(sender: sender)
        }
        custAlert.show(animated: true)
    }
    
    func denyRequest(sender: UIButton)
    {
        let section = sender.tag/1000
        let row = sender.tag%1000
        
        let dicData = arrAppointments.object(at: section) as? NSMutableDictionary
        let arrData = dicData?.object(forKey: (dicData?.allKeys[0] as! String)) as! NSArray
        
        var model : AcceptRejecModel = AcceptRejecModel()
        model = arrData.object(at: row) as! AcceptRejecModel
        
        ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyPending).child(model.dateString).observe(.value, with: { snapshot in
            self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyPending).child(model.dateString).removeAllObservers()
            if !snapshot.exists()
            {
                let custAlert = customAlertView(title: "", message: "Something went wrong, please try again.", image: #imageLiteral(resourceName: "ic_done"))
                custAlert.show(animated: true)
                return
            }else{
                let arr = snapshot.value as! NSMutableArray
                arr.remove(model.slot_selected)
                self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyPending).child(model.dateString).setValue(arr)
            }
        })
        
        let _ = ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyPending).observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {
                let arr2 = NSMutableDictionary()
                arr2.setValue([model.slot_selected], forKey: model.dateString)
                self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyRejected).setValue(arr2)
                
            }else{
                var arr2 = NSMutableArray()
                let arr3 = snapshot.value as! NSMutableDictionary
                if let k = arr3.value(forKey: model.dateString) as? NSMutableArray
                {
                    arr2 = k
                }
                arr2.add(model.slot_selected)
                if arr2.count == 2 {
                    arr2.removeObject(at: 1)
                }
                arr3.setValue(arr2, forKey: model.dateString)
                
                self.ref.child(nodeListingsRegistered).child(model.registrationID).child(keySelectedSlot).child(keyRejected).setValue(arr3)
            }
            
            self.getRegistrationRequest()
            self.delegate.requestHandleReload()
            let alert = UIAlertController(title: "", message: "Request rejected successfully", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            // change to desired number of seconds (in this case 5 seconds)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                    alert.dismiss(animated: true, completion: {() -> Void in
                })
            })
    
            let msg = "Hi \(model.registeredBy)! Your registration for listing \(self.modelRequest.title) with timeslot \(model.dateString + " " + model.slot_selected) is Rejected"
            let regID = model.registrationID
            self.message = msg
            self.registrationID = regID
            
      
            snapUtils.SendNotification(receiverId: model.userID, message: msg, timeStamp: NSDate().timeIntervalSince1970, listingId: model.listingID)
        })
    }
    
    @objc func handleDeny(sender: UIButton){
        let v = UIView()
        let custAlert = customAlertView(title: "Message", message: "Are you sure you want to decline?", customView: v, leftBtnTitle: "NO", rightBtnTitle: "YES", image: #imageLiteral(resourceName: "ic_done"))
        custAlert.onRightBtnSelected = {(Value:String) in
            custAlert.dismiss(animated: true)
            self.denyRequest(sender: sender)
        }
        custAlert.show(animated: true)
    }
    
    func removeObjectfromArr(model: AcceptRejecModel)
    {
        arr.remove(model)
        self.modelRequest.pending_request = NSMutableAttributedString(string:"\(arr.count) Request(s) Pending")
        self.tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 175
        
    }
    
    
}


protocol requestHandleDelegate {
    func requestHandleReload()
}
