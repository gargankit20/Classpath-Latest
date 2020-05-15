//
//  ReportDetailVC.swift
//  Classpath
//
//  Created by Coldfin on 9/11/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

protocol reportDeleteDelegate {
    func reportDeleted(index:Int)
}
class ReportDetailVC: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var lblReportedByID: UILabel!
    @IBOutlet weak var lblreportedListingTitle: UILabel!
    @IBOutlet weak var lblReportedToID: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblReportedby: UILabel!
    @IBOutlet weak var lblReportedTo: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    var modelListing : ListingModel = ListingModel()
    var delegate:reportDeleteDelegate!
    
    var ref = Database.database().reference()
    
    var model : ReportModel!
    var profileImage = ""
    var module = ""
    var tblIndex : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDesign()
        fetchListingDetails()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadlistingData(_:)), name: NSNotification.Name(rawValue: "listingDetailAdmin"), object: nil)
    }
    func fetchListingDetails()  {
        if module != "User"{
            let _ = ref.child(nodeListings).child(model.r_listingId).observe(.value, with: { snapshot in
                self.ref.child(nodeListings).child(self.model.r_listingId).removeAllObservers()
                if snapshot.exists(){
                    if snapshot.value != nil {
                        snapUtils.parseSnapShot(snapshot: snapshot,notiName: "listingDetailAdmin")
                    }
                }
            })
        }
    }
    
    @objc func reloadlistingData(_ notification: NSNotification){
        
        if let model = notification.userInfo?["model"] as? ListingModel {
            modelListing = model
        }
        
    }
    
    
    func setDesign(){
        
        btnDelete.setTitle("Delete \(module.lowercased())", for: .normal)
        
        lblReportedby.text = "Username: \(model.rBy_username)"
        lblReportedTo.text = "Username: \(model.rl_username)"
        lblReportedByID.text = "Email id: \(model.rBy_emailId)"
        lblReportedToID.text = "Email id: \(model.rl_emailId)"
        
        lblDate.text = "Reported on: \(model.date)"
        lblDescription.text = "Description: \(model.desc)"
        lblType.text = "Report Type: \(model.type)"
        
        var placeholder = UIImage()
        if module == "User"{
            profileImage = model.profileImage
            placeholder = #imageLiteral(resourceName: "ic_profile_default")
        }else{
            lblreportedListingTitle.text = "Listing Name: \(model.rl_title)"
            profileImage = model.rl_images.object(at: 0) as! String
            placeholder = #imageLiteral(resourceName: "ic_listing_default")
        }
        if profileImage != "" {
            let storageRef=Storage.storage().reference(forURL:profileImage as String)
            img.sd_setImage(with:storageRef, placeholderImage:placeholder)
        }else {
            self.img.image = placeholder
        }
        
    }
    
    @IBAction func onClick_imageClick(_ sender: Any) {
        if module == "User" {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextpage = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
            nextpage.userID = model.reportU_Id
            nextpage.isShowBar = true
            self.present(nextpage, animated: true, completion: nil)
        }else{
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextpage = storyboard.instantiateViewController(withIdentifier: "ListingDetailsVC") as! ListingDetailsVC
            nextpage.isFromFavoriteVC = false
            nextpage.model = modelListing
            nextpage.isToday = true
            self.navigationController?.pushViewController(nextpage,animated: true)
        }
    }
    
    @IBAction func onClick_Delete(_ sender: Any) {
        
        let v = UIView()
        let custAlert = customAlertView(title: "Message", message: "Are you sure you want to delete this \(self.module.lowercased())?", customView: v, leftBtnTitle: "NO", rightBtnTitle: "YES", image: #imageLiteral(resourceName: "ic_done"))
        custAlert.onRightBtnSelected = {(Value:String) in
            custAlert.dismiss(animated: true)
             
            self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
            if self.module == "User" {
                self.deleteUserAuthentication(Userid: self.model.r_UserId, reportId: self.model.reportU_Id)
            }else if self.module == "Listing"{
                self.deleteList(listingID: self.model.r_listingId, images:self.model.rl_images, reportId: self.model.reportL_Id, repertedUid: self.model.r_UserId)
            }
        }
        custAlert.show(animated: true)
        
    }
    
    func deleteList(listingID:String, images:NSArray,reportId:String, repertedUid:String) {
        
        //remove all bookings
        let storage =  Storage.storage()
        
        let _ = ref.child(nodeListingsRegistered).queryOrdered(byChild: keyListingId).queryEqual(toValue: listingID).observe(.value, with: { snapshot in
            self.ref.child(nodeListingsRegistered).queryOrdered(byChild: keyListingId).queryEqual(toValue: listingID).removeAllObservers()
            if snapshot.exists() {
                for child in snapshot.children
                {
                    self.ref.child(nodeListingsRegistered).child((child as! DataSnapshot).key).removeValue()
                    
                    
                }
            }
        })
        
        // Remove the post from the DB
        ref.child(nodeListings).child(listingID).removeValue()
        self.stopAnimating()
        
        // Remove the image from storage
        for i in images
        {
            let imageRef = storage.reference(forURL: i as! String)
            imageRef.delete { error in
                if error != nil {
                    print("Uh-oh, an error occurred!")
                } else {
                    print("File deleted successfully")
                }
            }
        }
        ref.child(nodeListingReports).child(reportId).removeValue()
        
        updateOwnerBadge(repertedUid: repertedUid)
        let alert = UIAlertController(title: "", message: "Listing deleted successfully!", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        delegate.reportDeleted(index: tblIndex)
        let when = DispatchTime.now() + 2.5
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func updateOwnerBadge(repertedUid:String) {
        let userRef = self.ref.child(nodeUsers).child(repertedUid)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if var defaults = (snapshot.value as! NSDictionary)[keyListingCount] as? Int {
                defaults -= 1
                if defaults >= 0 {
                    userRef.updateChildValues([keyListingCount:defaults])
                }
                if defaults == 0{
                    let arr = ["Athlete"]
                    userRef.updateChildValues([keyBadges:arr])
                }
            }
            self.stopAnimating()
        }
        
    }
    
    func deleteUserAuthentication(Userid:String, reportId: String){
        let strurl = "\(BaseURl)/authUserDelete/deleteuser.php"
        let params = NSMutableDictionary()
        params.setValue(Userid, forKey: "uid")
        
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html", "application/json"])
        manager.post(strurl, parameters: params, success: {(operation, responseObject) in
            let element : NSDictionary = responseObject as! NSDictionary
            let success:Int = element.object(forKey: "success") as! Int
            if success == 1{
                self.DeleteAccount(Userid:Userid, reportId: reportId)
            }else{
                let v = UIView()
                let custAlert = customAlertView(title: "Error", message: "Something went wrong!Unable to delete", customView: v, leftBtnTitle: "NO", rightBtnTitle: "YES", image: #imageLiteral(resourceName: "ic_done"))
                custAlert.onRightBtnSelected = {(Value:String) in
                    custAlert.dismiss(animated: true)
                     
                    self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                    if self.module == "User" {
                        self.deleteUserAuthentication(Userid: self.model.r_UserId, reportId: self.model.reportU_Id)
                    }else if self.module == "Listing"{
                        self.deleteList(listingID: self.model.r_listingId, images:self.model.rl_images, reportId: self.model.reportL_Id, repertedUid: self.model.r_UserId)
                    }
                }
                custAlert.show(animated: true)
        
            }
        }, failure: { (operation, error) in
            print(error as Any)
        })
    }
    
    func DeleteAccount(Userid:String, reportId: String){
        
        let LisingList = self.ref.child(nodeListings)
        LisingList.observeSingleEvent(of :.value ,with: { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot]  {
                for item in children {
                    let GetId = (item.childSnapshot(forPath: keyUserID).value as? String)!
                    if GetId == Userid{
                        LisingList.child(item.key).removeValue()
                    }
                }
            }
        })
        
        
        
        //remove ListingReports
        print(Userid)
        let listReport = self.ref.child(nodeListingReports)
        listReport.queryOrdered(byChild: keyReportedTo).queryEqual(toValue: Userid).observeSingleEvent(of :.value ,with: { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                for item in children {
                    listReport.child(item.key).removeValue()
                }
            }
        })
        
        //remove ListingReview
        let ListReview = self.ref.child(nodeReviews)
        ListReview.observeSingleEvent(of :.value ,with: { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot]  {
                for item in children {
                    let GetId = (item.childSnapshot(forPath: keyUserID).value as? String)!
                    if GetId == Userid{
                        ListReview.child(item.key).removeValue()
                    }
                }
            }
        })
        //remove listingRegister
        let ListRegister = self.ref.child(nodeListingsRegistered)
        ListRegister.observeSingleEvent(of :.value ,with: { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                for item in children {
                    let GetId = (item.childSnapshot(forPath: keyUid).value as? String)!
                    if GetId == Userid{
                        ListRegister.child(item.key).removeValue()
                    }
                }
            }
        })
        
        //remove Notifications
        let ListNotifications = self.ref.child(nodeNotifications)
        ListNotifications.observeSingleEvent(of :.value ,with: { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot]  {
                for item in children {
                    var key4 = String()
                    key4 = item.key
                    ListNotifications.child(key4).observeSingleEvent(of :.value ,with: { snapshot3 in
                        if let children = snapshot3.children.allObjects as? [DataSnapshot] {
                            for item3 in children {
                                let val1 = item3.value as! NSDictionary
                                if let GetID1 = val1[keyToUid] as? String {
                                    var GetID12 = String()
                                    GetID12 = val1[keyFromUid] as! String
                                    if GetID1 == Userid{
                                        ListNotifications.child(key4).child(item3.key).removeValue()
                                    }else if GetID12 == Userid{
                                        ListNotifications.child(key4).child(item3.key).removeValue()
                                    }
                                }
                            }
                        }
                    })
                }
            }
        })
        
        //remove chatMessages
        let ListchatMessages = self.ref.child(nodeChatMessages)
        ListchatMessages.observeSingleEvent(of :.value ,with: { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot]  {
                for item in children {
                    let string = item.key
                    if string.range(of:Userid) != nil {
                        ListchatMessages.child(item.key).removeValue()
                    }
                }
            }
        })
        
        //remove chats
        let Listchats = self.ref.child(nodeChats)
        Listchats.observeSingleEvent(of :.value ,with: { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot]  {
                for item in children {
                    let string = item.key
                    if string.range(of:Userid) != nil {
                        Listchats.child(item.key).removeValue()
                    }
                }
            }
        })
        
        
        //remove chats
        let ListuserChats = self.ref.child(nodeUserChats).child(Userid)
        ListuserChats.observeSingleEvent(of :.value ,with: { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                for item in children {
                    ListuserChats.child(item.key).removeValue()
                }
            }
        })
        
        //remove userChats
        let ListuserChatsChild = self.ref.child(nodeUserChats)
        ListuserChatsChild.observeSingleEvent(of :.value ,with: { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                for item in children {
                    var key1 = String()
                    key1 = item.key
                    ListuserChatsChild.child(key1).child(keyChatID).observeSingleEvent(of :.value ,with: { snapshot1 in
                        var value1 = NSMutableArray()
                        if !snapshot1.exists(){return}
                        value1 = snapshot1.value as! NSMutableArray
                        for i in 0..<value1.count{
                            let temp = value1.object(at: i) as! String
                            let myString = String(i)
                            
                            if temp.range(of:Userid) != nil {
                                ListuserChatsChild.child(key1).child(keyChatID).child(myString).removeValue()
                            }
                        }
                    })
                }
            }
        })
        
        self.ref.child(nodeUserReports).child(reportId).removeValue()
        
        let UserList = self.ref.child(nodeUsers).child(Userid)
        UserList.observeSingleEvent(of :.value ,with: { snapshot in
            UserList.removeValue()
            self.stopAnimating()
            let alert = UIAlertController(title: "", message: "User deleted successfully!", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            self.delegate.reportDeleted(index: self.tblIndex)
            let when = DispatchTime.now() + 2.5
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            
        })
        
        
    }
}
