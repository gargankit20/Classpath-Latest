//
//  NotificationsVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/9/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseUI

class NotificationTableViewCell : UITableViewCell {
    @IBOutlet weak var imgProfileView: UIImageView!
    @IBOutlet weak var lblNotiMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnUserProfile: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        imgProfileView.layer.cornerRadius = imgProfileView.frame.height/2
//        imgProfileView.layer.masksToBounds = true
    }
}
class NotificationsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,NVActivityIndicatorViewable {

    
    @IBOutlet weak var tableview: UITableView!
    var ref = Database.database().reference()
    var arrNotify = NSMutableArray()
    @IBOutlet weak var viewDefault: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 110
        
        tableview.tableFooterView = UIView(frame: CGRect.zero)
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        let ap = UIApplication.shared.delegate as! AppDelegate
        let myTabBar = ap.window?.rootViewController as? UITabBarController
        defaults.setValue(0, forKey: keyNotificationBadge)
        myTabBar?.tabBar.items![3].badgeValue = nil
        callNotificationApi()
    }
        
    //MARK: Self defined functions
    func callNotificationApi() {
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let _ = ref.child(nodeNotifications).child(uid).observe(.value, with: { snapshot in
         //   self.ref.child(nodeNotifications).child(uid).removeAllObservers()
            self.arrNotify = NSMutableArray()
            if !snapshot.exists() {
                self.tableview.isHidden = true
                self.viewDefault.isHidden = false
                self.tableview.reloadData()
                self.stopAnimating()
                
                return
            }
            self.parseSnapShotForNoti(snapshotNoti: snapshot)
        })
    }
    func parseSnapShotForNoti(snapshotNoti: DataSnapshot){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        var count:Int = 0
        for child in snapshotNoti.children {
            let model =  NotificationsModel()
            
            
            model.notifyId = (child as! DataSnapshot).key
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyMessage] as? String {
                model.message = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyFromUid] as? String {
                model.sendby = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyToUid] as? String {
                model.sendTo = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)["ListingId"] as? String {
                model.listingId = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyTimeStamp] as? Double {
                model.timeStamp = defaults
                let date : Date = Date(timeIntervalSince1970: TimeInterval(defaults))
                model.notidate = utils.convertDateToString(date, format: "yyyy-MM-dd HH:mm:ss")
                
            }
          
            let ViewFlag = true
            
            self.ref.child(nodeNotifications).child(uid).child(model.notifyId).child("ViewFlag").setValue(ViewFlag)
            
//            if model.listingId != "" {
//                ref.child(nodeListings).child(model.listingId).observeSingleEvent(of: .value) { (snapshot1) in
//                    if snapshot1.exists() {
//
//                        var images = NSArray()
//                        if let defaults = (snapshot1.value as! NSDictionary)[keyImages] as? NSArray {
//                            images = defaults
//                            model.ProfilePic = images.object(at: 0) as! String
//                        }
//
//                        self.arrNotify.add(model)
//                    }
//                    if count == snapshotNoti.childrenCount-1{
//                        self.sortByTimeReference()
//                    }
//                    count += 1
//                }
//            }else {
            //if model.sendTo==uid {
                //if model.sendby != "" {
                    
            let _ = ref.child(nodeUsers).child(model.sendby).observe(.value, with: { snapshot1 in
                if snapshot1.exists()
                {
                    if let def = (snapshot1.value as! NSDictionary)[keyProfilePic] as? String {
                        model.ProfilePic = def
                    }
                }
            })
            self.arrNotify.add(model)
            
            if count==snapshotNoti.childrenCount-1
            {
                self.sortByTimeReference()
            }
            
            count += 1
        }
    }
    
    func sortByTimeReference(){
        
        var arr: NSArray!
        let sortedArray = self.arrNotify.sorted(by: { ($0 as! NotificationsModel).notidate > (($1 as! NotificationsModel).notidate)})
        arr = sortedArray as NSArray
        self.arrNotify = arr.mutableCopy() as! NSMutableArray

        self.tableview.reloadData()
        self.stopAnimating()
        
        
    }
    
    //MARK: TableView DataSource & Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(arrNotify.count > 0) {
            self.viewDefault.isHidden = true
        }else {
            self.viewDefault.isHidden = false
        }
        return self.arrNotify.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellNotification", for: indexPath) as! NotificationTableViewCell
        
        var model : NotificationsModel = NotificationsModel()
        model = arrNotify.object(at: indexPath.row) as! NotificationsModel
        
        let trimmedString = model.message.components(separatedBy: .newlines).joined()
        cell.lblNotiMessage.text = trimmedString
        
        var profileImg = String()
        profileImg = model.ProfilePic
        if profileImg != "" {
            cell.imgProfileView.sd_setImage(with:URL(string:profileImg), placeholderImage:#imageLiteral(resourceName: "ic_profile_default"))
        }else{
            cell.imgProfileView.image = #imageLiteral(resourceName: "ic_profile_default")
        }
        
        var lblTimeText = ""
        var time: Double?
        time = model.timeStamp
        let date : NSDate = NSDate(timeIntervalSince1970: TimeInterval(time!))
        print(date)
        let str1 = utils.getPostTime(date as Date).0
        let str2 = utils.getPostTime(date as Date).1
        if str2 == "year" || str2 == "month" || str2 == "day" {
            if str2 == "day" {
                let arr = str1.components(separatedBy: " ")
                if Int(arr[0])! > 7 {
                    lblTimeText = "\(utils.convertDateToString(date as Date, format: "dd MMM yy"))"
                }else{
                    lblTimeText = "\(str1)"
                }
            }else{
                let date : NSDate = NSDate(timeIntervalSince1970: TimeInterval(time!))
                lblTimeText = "\(utils.convertDateToString(date as Date, format: "dd MMM yy"))"
                print(lblTimeText)
            }
        }
        else{
            lblTimeText = utils.getPostTime(date as Date).0
        }
        cell.lblTime.text = lblTimeText
        cell.btnUserProfile.tag = indexPath.row
        cell.btnUserProfile.addTarget(self, action:#selector(onClick_UserProfile(_:)), for: .touchUpInside)
        return cell
    }
    
    
    @objc func onClick_UserProfile(_ sender: UIButton){
        var model : NotificationsModel = NotificationsModel()
        model = arrNotify.object(at: sender.tag) as! NotificationsModel
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        nextpage.userID = model.sendby
        nextpage.isShowBar = true
        self.present(nextpage, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Delete") { action, indexPath in
                        
            let v = UIView()
            let custAlert = customAlertView.init(title: "Message", message: "Are you sure you want to delete this notification?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
                guard let uid = Auth.auth().currentUser?.uid else{return}
                
                var model : NotificationsModel = NotificationsModel()
                model = self.arrNotify.object(at: indexPath.row) as! NotificationsModel
                
                let userInstance = self.ref.child(nodeNotifications).child(uid)
                userInstance.child(model.notifyId).removeValue()
                
                self.arrNotify.removeObject(at: indexPath.row)
                tableView.reloadData()
            }
            custAlert.onLeftBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
            }
            custAlert.show(animated: true)
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var modelNoti : NotificationsModel = NotificationsModel()
        modelNoti = arrNotify.object(at: indexPath.row) as! NotificationsModel
        
        ref.child(nodeListings).child(modelNoti.listingId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let userID = (snapshot.value as! NSDictionary)[keyUserID] as? String {
                    
                    if modelNoti.listingId != "" &&  snapUtils.currentUserModel.userId == userID {
                        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextpage = storyboard.instantiateViewController(withIdentifier: "RegistrationDetailVC") as! RegistrationDetailVC
                        nextpage.modelListingId = modelNoti.listingId
                        self.navigationController?.pushViewController(nextpage,animated: true)
                    }
                }
            }
        }
    }
}
