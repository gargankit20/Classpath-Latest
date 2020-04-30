//
//  MyListingsVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/8/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseUI

class MyListingTableViewCell: UITableViewCell {
    @IBOutlet weak var imgList: UIImageView!
    @IBOutlet weak var lblListName: UILabel!
    @IBOutlet weak var viewRating: HCSStarRatingView!
    @IBOutlet weak var viewNoOfRatings: UILabel!
    @IBOutlet weak var lblExpirationDate: UILabel!
    @IBOutlet weak var btnExtend_Listing: UIButton!
    @IBOutlet weak var lblNoofView: UILabel!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnReview: UIButton!
    @IBOutlet weak var view_shadow: UIView!
    @IBOutlet weak var lblNoofRegistration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view_shadow.layer.shadowOpacity = 1
        view_shadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_shadow.layer.shadowRadius = 4.0
        view_shadow.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
    }
}


class MyListingsVC: UIViewController,NVActivityIndicatorViewable {
    
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewDefault: UIView!
    var tag = 0
    var redirect = String()
    var arr = NSMutableArray()
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        tblView.rowHeight = 160
        tblView.tableFooterView = UIView()
        tblView.allowsMultipleSelectionDuringEditing = false
        getUserListings()

    }
    
    func getUserListings()
    {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
         
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        let _ = ref.child(nodeListings).queryOrdered(byChild: keyUserID).queryEqual(toValue: uid).observe(.value, with: { snapshot in
            self.ref.child(nodeListings).removeAllObservers()
            if !snapshot.exists() {
                
                self.stopAnimating()
                if(self.arr.count > 0)
                {
                    //  self.viewDefault.isHidden = true
                }else
                {
                   // self.viewDefault.isHidden = false
                }
                return
            }
            self.parseSnapShot(snapshot: snapshot)
        })
    }
    func refresh(){
        arr = NSMutableArray()
        getUserListings()
    }
    
    func parseSnapShot(snapshot : DataSnapshot)
    {
        var count = 0
        for child in snapshot.children {
            let model = ListingModel()
            model.listingID = (child as! DataSnapshot).key
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyDescription] as? String {
                model.listing_description = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyURL] as? String {
                model.listingURL = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyBusinessWebsite] as? String {
                model.businessURL = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyTitle] as? String {
                model.title = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[KeyListingAddress] as? String {
                model.address = defaults
            }
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyCertificates] as? String {
                model.certificates = defaults
                print(model.certificates)
            }
            
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyCategory] as? String {
                model.category = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyLat] as? Double {
                model.latitude = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyLong] as? Double {
                model.longitude = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyImages] as? NSArray {
                model.images = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyIsOpen] as? Bool {
                model.isOpen = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyUserID] as? String {
                model.userid = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyNoofRegister] as? Int{
                model.noofRegister = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyViews] as? NSDictionary {
                model.views = defaults
                let arrViews = model.views.object(forKey: model.views.allKeys[0]) as! NSArray
                model.noofViews = arrViews.count
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRatings] as? Double {
                model.ratings = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyExpirationDate] as? String {
                model.Expiration_Date = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyPromoted] as? String {
                model.Promoted = defaults
            }
            
            //Video
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyVideo] as? String {
                model.Video = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServices] as? NSMutableDictionary {
                model.services = defaults
            }
            
            
            let slotModel2 = SlotSelectionModel()
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceHour] as? NSMutableDictionary {
                
                if let default2 = defaults.value(forKey: "Sunday") as? NSArray {
                    slotModel2.Sunday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Monday") as? NSArray {
                    slotModel2.Monday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Tuesday") as? NSArray {
                    slotModel2.Tuesday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Wednesday") as? NSArray {
                    slotModel2.Wednesday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Thursday") as? NSArray {
                    slotModel2.Thursday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Friday") as? NSArray {
                    slotModel2.Friday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Saturday") as? NSArray {
                    slotModel2.Saturday = default2.mutableCopy() as! NSMutableArray
                }
                model.serviceHours = slotModel2
            }
            
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyNoofTimesReviewed] as? Double {
                model.NoofTimesReviewed = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyNoofTimesRecommended] as? Double {
                model.NoofTimesRecommended = defaults
            }
            
            let _ = ref.child(nodeReviews).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).observe(.value, with: { snapshot1 in
                self.ref.child(nodeReviews).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).removeAllObservers()
                
                var rating = 0.0
                var reviewdTotal = 0.0
                var recommend = 0.0
                var recommendTotal = 0.0
                if snapshot1.exists() {
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
                self.arr.add(model)
                
                if count == snapshot.childrenCount-1{
                    self.tblView.delegate = self
                    self.tblView.dataSource = self
                    self.tblView.reloadData()
                    self.stopAnimating()
                }
                count += 1
            })
        }
    }
}
extension MyListingsVC : addEditListdelegate{
    func reloadList()
    {
        self.tblView.reloadData()
    }
    
    func deletedList(list: ListingModel) {
        self.arr.remove(list)
        self.tblView.reloadData()
    }
}
extension MyListingsVC :  UITableViewDelegate, UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func deleteList(listingID : String,images : NSArray) {
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
        updateOwnerBadge()
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
    }
    
    func updateOwnerBadge() {
        let userRef = self.ref.child(nodeUsers).child(snapUtils.currentUserModel.userId)
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
            
        }
        
    }

    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Delete") { action, indexPath in
            let model = self.arr.object(at: indexPath.row) as? ListingModel
            
            let v = UIView()
            let custAlert = customAlertView.init(title: "Message", message: "Are you sure you want to Delete this listing?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
                self.deleteList(listingID: (model?.listingID)!, images: (model?.images)!)
                self.arr.removeObject(at: indexPath.row)
                self.tblView.reloadData()
            }
            custAlert.show(animated: true)
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let model = self.arr.object(at: indexPath.row) as? ListingModel
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "AddListingVC") as! AddListingVC
        nextpage.delegate = self
        nextpage.isForEdit = true
        nextpage.editListModel = model!
        self.navigationController?.pushViewController(nextpage,animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(arr.count > 0)
        {
            self.viewDefault.isHidden = true
        }else
        {
            self.viewDefault.isHidden = false
        }
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : MyListingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "myListingCell") as! MyListingTableViewCell
        cell.selectionStyle = .none
        var model : ListingModel = ListingModel()
        model = arr.object(at: indexPath.row) as! ListingModel
        cell.lblListName.text = model.title
        
        let image = model.images[0] as! String
        if image != "" {
            cell.imgList.sd_setImage(with:URL(string:image), placeholderImage:#imageLiteral(resourceName: "ic_listing_default"))
        }else{
            cell.imgList.image = #imageLiteral(resourceName: "ic_listing_default")
        }
        
        cell.lblNoofView.text = "Number of views: \(model.noofViews)"
        cell.lblNoofRegistration.text = "Number of registration: \(model.noofRegister)"
        
//        cell.btnExtend_Listing.tag = indexPath.row
        
 //       cell.btnReport.isHidden = false
 //       cell.btnExtend_Listing.isHidden = false
        cell.lblExpirationDate.isHidden = false
        
//        if model.Expiration_Date != ""{
//            cell.lblExpirationDate.text = "Promoted listing expires on \(model.Expiration_Date)"
//        }else {
//            cell.lblExpirationDate.text = ""
//        }
//        cell.btnExtend_Listing.addTarget(self, action:#selector(onclick_Promotedlisting(sender:)), for: .touchUpInside)
        
        cell.btnReport.tag = indexPath.row
        cell.btnReport.addTarget(self, action:#selector(onClick_btnReport(sender:)), for: .touchUpInside)
        
        if model.NoofTimesReviewed != 0.0{
            cell.viewNoOfRatings.text = "\(Int(model.NoofTimesReviewed)) Reviews"
        }
        cell.viewRating.value = CGFloat(model.star)
        cell.btnReview.tag = indexPath.row
        cell.btnReview.addTarget(self, action:#selector(reviewAction(sender:)), for: .touchUpInside)
        
        return cell
    }
    @objc func reviewAction(sender: UIButton){
//        var model : ListingModel = ListingModel()
//        model = arr.object(at: sender.tag) as! ListingModel
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let nextpage = storyboard.instantiateViewController(withIdentifier: "ReviewVC") as! ReviewVC
//        nextpage.model = model
//        nextpage.delegate = self
//        self.navigationController?.pushViewController(nextpage,animated: true)
    }
    
    @objc func onClick_btnReport(sender: UIButton){
        var model : ListingModel = ListingModel()
        model = arr.object(at: sender.tag) as! ListingModel
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "ReportViewPopUp") as! ReportViewPopUp
        modalViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.type = "Mylisting"
        modalViewController.model = model
        present(modalViewController, animated: true, completion: nil)
    }
    
//    @objc func onclick_Promotedlisting(sender: UIButton) {
//        tag = sender.tag
//        print(tag)
//        var model : ListingModel = ListingModel()
//        model = arr.object(at: sender.tag) as! ListingModel
//
//        var dataDate = Date()
//        var todayDate = Date()
//        if model.Expiration_Date != ""{
//            print(model.Expiration_Date)
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM.dd.yyyy HH:mm:ss"
//            dataDate = dateFormatter.date(from: model.Expiration_Date)!
//            dataDate = utils.convertStringToDate(dataDate.localDateStringFullDate(), dateFormat: "MM.dd.yyyy HH:mm:ss")
//            todayDate = utils.convertStringToDate(Date().localDateStringFullDate(), dateFormat: "MM.dd.yyyy HH:mm:ss")
//        }
//
//        if dataDate < todayDate || model.Expiration_Date == "" {
//
//            let parameter = NSMutableDictionary()
//            parameter.setValue(model.title, forKey:keyTitle)
//            parameter.setValue(model.category, forKey:keyCategory)
//            parameter.setValue(model.listing_description, forKey: keyDescription)
//            parameter.setValue(model.certificates, forKey: keyCertificates)
//            parameter.setValue(model.images, forKey: keyImages)
//            parameter.setValue(model.latitude, forKey: keyLat)
//            parameter.setValue(model.longitude, forKey: KeyLong)
//            parameter.setValue(model.address, forKey: KeyListingAddress)
//            parameter.setValue(model.listingURL, forKey: keyURL)
//            parameter.setValue(model.businessURL, forKey: keyBusinessWebsite)
//            parameter.setValue(model.isOpen, forKey: keyIsOpen)
//            parameter.setValue(model.userid, forKey: keyUserID)
//            parameter.setValue(model.Expiration_Date, forKey: keyExpirationDate)
//
//            let parameterServices = NSMutableDictionary()
//            var str = self.getSlotDays(str: model.serviceHours.Sunday)
//            parameterServices.setValue(str, forKey:"Sunday")
//
//            str = self.getSlotDays(str: model.serviceHours.Monday)
//            parameterServices.setValue(str, forKey: "Monday")
//
//            str = self.getSlotDays(str: model.serviceHours.Tuesday)
//            parameterServices.setValue(str, forKey: "Tuesday")
//
//            str = self.getSlotDays(str: model.serviceHours.Wednesday)
//            parameterServices.setValue(str, forKey: "Wednesday")
//
//            str = self.getSlotDays(str: model.serviceHours.Thursday)
//            parameterServices.setValue(str, forKey: "Thursday")
//
//            str = self.getSlotDays(str: model.serviceHours.Friday)
//            parameterServices.setValue(str, forKey: "Friday")
//
//            str = self.getSlotDays(str: model.serviceHours.Saturday)
//            parameterServices.setValue(str, forKey: "Saturday")
//
//            parameter.setValue(parameterServices, forKey: keyServiceHour)
//            print(parameter)
//
//            let List_Id = model.listingID
//            defaults.set(List_Id, forKey: "listingID")
//            defaults.set("forupdate", forKey: "forupdate")
//
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let nextpage = storyboard.instantiateViewController(withIdentifier: "PromoteVC") as! PromoteVC
//            nextpage.parameter = parameter
//            self.navigationController?.pushViewController(nextpage, animated: true)
//        }else{
//            let alert = UIAlertController(title: "", message: "Listing already promoted", preferredStyle: .alert)
//            self.present(alert, animated: true, completion: nil)
//            let when = DispatchTime.now() + 2.5
//            DispatchQueue.main.asyncAfter(deadline: when){
//                alert.dismiss(animated: true, completion: nil)
//
//            }
//        }
//    }
    
    func jump_profile(){
        let expireDate = defaults.object(forKey: "Expiration")
        var model : ListingModel = ListingModel()
        model = arr.object(at: tag) as! ListingModel
        model.Expiration_Date = expireDate as! String
        tblView.reloadData()
    }
    
    func getSlotDays(str: NSMutableArray) ->(NSMutableArray)
    {
        let strArr = NSMutableArray()
        for i in str
        {
            strArr.add("\(i)".trimmingCharacters(in: .whitespaces))
        }
        return (strArr)
    }
}

