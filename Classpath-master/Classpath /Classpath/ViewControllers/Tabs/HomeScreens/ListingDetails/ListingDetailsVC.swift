//
//  ListingDetailsVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/11/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import AVFoundation
import AVKit
import FirebaseStorage
import FirebaseUI

class ImageCollectionViewCell:UICollectionViewCell{
    @IBOutlet weak var imageListing:UIImageView!
    @IBOutlet weak var btnPlay:UIButton!
}
protocol removeFavouriteDelegate {
    func hideRemovedFavorite(isRemoved:Bool, listingId:String)
}
class ListingDetailsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,NVActivityIndicatorViewable,UICollectionViewDelegateFlowLayout {
   
    @IBOutlet weak var btnDecrement: UIButton!
    @IBOutlet weak var btnIncrement: UIButton!
    @IBOutlet weak var lblTicketsCount: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var lblListingName: UILabel!
    @IBOutlet weak var viewRatings: HCSStarRatingView!
    @IBOutlet weak var lblListingOwner: UILabel!
    @IBOutlet weak var imgListingImage: UIImageView!
    @IBOutlet weak var lblDistance: UIButton!
    @IBOutlet weak var btnDetails: UIButton!
    @IBOutlet weak var btnReviews: UIButton!
    @IBOutlet weak var reviewLeading: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var selection_leading: NSLayoutConstraint!
    @IBOutlet weak var view_Options: UIView!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
     var delegate : removeFavouriteDelegate!
    var isFromHome = false
    var isReported = false
    var ticketsCount = 1
    
    //MARK: Scroll Details Outlets
    @IBOutlet weak var lblProgramName: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblCertificate: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblRegistrationCount: UILabel!
    @IBOutlet weak var viewRecommendation: HCSStarRatingView!
    @IBOutlet weak var tagClassHours: UIScrollView!
    
    //MARK: Scroll Details Reviews
    @IBOutlet weak var lblTotalReview: UILabel!
    @IBOutlet weak var viewRatingsOverAll: HCSStarRatingView!
    @IBOutlet weak var lblReviewsCount: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var viewDefault: UIView!
    @IBOutlet weak var constBarSize: NSLayoutConstraint!
    
    var model = ListingModel()
    var xReview:CGFloat = 500.0
    var isToday = false
    var ref: DatabaseReference!
    var arrData = NSMutableArray()
    var thumbnailImage = #imageLiteral(resourceName: "ic_cover_default")
    
    var arrSlotServices = NSMutableArray()
    var slotSelected = ""
    var alreadyBookedSlotsAprooved = NSMutableArray()
    var alreadyBookedSlotsPending = NSMutableArray()
    var alreadyBookedSlotsRejected = NSMutableArray()
    var alreadyBookedSlotsCancelled = NSMutableArray()
    var SlotsBooked : NSMutableArray = [false,false,false]
    var isRegistered = false
    
//    var serviceName = ""
//    var serviceCost = ""
    var serviceId = ""
    var isInstantBook = false
    let bookingMod = BookingModel()
    
    
    var slotIndex = 0
    
    let formatter = DateFormatter()
    var result  = ""
    var date = Date()
    var isFromFavoriteVC:Bool!
    var isFavorite = false
    var arrReviewcount = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromHome {
            if screenHeight >= 812{
                constBarSize.constant = 88
            }else{
                constBarSize.constant = 64
            }
        }else{
            constBarSize.constant = 0
        }
        
        btnDecrement.setRadiusWithShadow()
        btnIncrement.setRadiusWithShadow()
        
        if(!isToday)
        {
            date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        }
        formatter.dateFormat = "MM-dd-yyyy"
        result = formatter.string(from: self.date)
        if model.userid == snapUtils.currentUserModel.userId{
            view_Options.isHidden = true
        }
        reviewLeading.constant = xReview
        btnDetails.isSelected = true
        btnReviews.isSelected = false
        btnDetails.setTitleColor(textThemeColor, for: .normal)
        btnReviews.setTitleColor(textThemeColor, for: .normal)
        btnDetails.setTitleColor(themeColor, for: .selected)
        btnReviews.setTitleColor(themeColor, for: .selected)
        
        for _ in 1...5{
            arrReviewcount.add(0)
        }
        
        ref = Database.database().reference()
        setDetailsData()
        getreviews()
        getAlreadyBooked()
        reviewTableView.estimatedRowHeight = 78
        reviewTableView.rowHeight = UITableView.automaticDimension
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(loadCollectionView), userInfo: nil, repeats: false)
        
        updateListingViewCount()
        checkThisListingisReported()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "instantBook"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "tagSlotClicked"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.tagControlIndexTouch(notification:)), name: NSNotification.Name(rawValue: "tagSlotClicked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.paymentDoneSuccess(_:)), name: NSNotification.Name(rawValue: "instantBook"), object: nil)
    }
    
    func navigateToBookingTab()
    {
        self.dismiss(animated:true, completion:nil)
        UserDefaults.standard.set(true, forKey:"goToBooking")
    }
    
    func updateListingViewCount() {
        
        if model.userid != snapUtils.currentUserModel.userId {
            
            let str = Date().localDateStringOnlyDate()
            
            if model.views.count != 0{
                let date = model.views.allKeys[0] as! String
                
                let arrViews = model.views.object(forKey: model.views.allKeys[0]) as! NSMutableArray
                
                if str != date{
                    self.ref.child(nodeListings).child(self.model.listingID).child(keyViews).removeValue()
                    arrViews.removeAllObjects()
                }
                
                if !(arrViews.contains(snapUtils.currentUserModel.userId)){
                    arrViews.add(snapUtils.currentUserModel.userId)
                    self.ref.child(nodeListings).child(self.model.listingID).child(keyViews).child(str).setValue(arrViews)
                }
                
            }else {
                self.ref.child(nodeListings).child(self.model.listingID).child(keyViews).child(str).setValue([snapUtils.currentUserModel.userId])
            }
            
        }
    }
    
    @objc func loadCollectionView(){
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
    }
    
    //MARK: Self defined functions
    func setDetailsData()  {
        let image = model.images[0] as! String
        if image != "" {
            let storageRef=Storage.storage().reference(forURL:image)
            imgListingImage.sd_setImage(with:storageRef, placeholderImage:#imageLiteral(resourceName: "ic_listing_default"))
        }else{
             self.imgListingImage.image = #imageLiteral(resourceName: "ic_listing_default")
        }
        
        if snapUtils.currentUserModel.favorites.contains(model.listingID){
            isFavorite = true
        }
        
        if isFavorite{
            btnFavorite.tintColor = .red
        }else{
            btnFavorite.tintColor = .white
        }
        lblListingName.text = model.title
        lblListingOwner.text = model.userName
        let strDistance:String = utils.formatPoints(num: model.distance)
        lblDistance.setTitle(" \(strDistance) mi", for: .normal)
        viewRatings.value = CGFloat(model.star)
        
        pageControl.hidesForSinglePage = true
        self.pageControl.numberOfPages = model.images.count
        if model.Video != "" {
            getVideoThumbnail()
            self.pageControl.numberOfPages = model.images.count+1
        }
        self.pageControl.currentPage = 0
        lblProgramName.text = model.title
        lblOwner.text = model.userName
        lblCertificate.text = model.certificates
        lblCategory.text = model.category
        lblDescription.text = model.listing_description
        model.address = model.address.stringByReplacingFirstOccurrenceOfString(target: ", ", withString: ",\n")
        
        
        lblAddress.text = model.address
        lblWebsite.text = model.businessURL
        if model.businessURL == "" {
            lblWebsite.text = "NA"
        }
        lblRegistrationCount.text = "\(model.noofRegister)"
        viewRecommendation.value = CGFloat(model.starRecommend)
        
        if isToday{
            utils.tagDesign(tagControl: tagClassHours, dataArray : model.availableslotsToday, backColor: model.slotIsGrayToday, isActionable: true)
        }else{
            utils.tagDesign(tagControl: tagClassHours, dataArray : model.availableslotsTomorrow, backColor: model.slotIsGrayTomorrow, isActionable: true)
        }
        
        

        var weekday = ""
        var slots = NSArray()
        if(isToday) {
            let date = utils.convertDateToString(Date(), format: "EEEE")
            weekday = date
            slots = model.slotsToday
        }else{
            let dateSelected = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            let date = utils.convertDateToString(dateSelected, format: "EEEE")
            weekday = date
            slots = model.slotsTomorrow
        }
        
        if model.listingURL == "" {
            self.btnRegister.setTitle("Request a Session", for: .normal)
        }else {
            self.btnRegister.setTitle("Registration page", for: .normal) 
        }
        
        if let services = model.services.value(forKey: weekday) as? NSMutableDictionary {
            for i in slots{
                if let serviceids = services.object(forKey: i) as? String {
                    let serviceList = serviceids.components(separatedBy: " ")
                    if serviceids != "" {
                        let _ = ref.child(nodeService).child(model.userid).observe(.value, with: { snapshot in
                            self.ref.child(nodeService).child(self.model.userid).removeAllObservers()
                            
                            if snapshot.exists() {
                                let arrServices = NSMutableArray()
                                for child in snapshot.children {
                                    let model = ServiceModal()
                                    model.serviceID = (child as! DataSnapshot).key
                                    
                                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceName] as? String {
                                        model.serviceName = defaults
                                    }
                                    
                                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceCost] as? String {
                                        model.serviceCost = defaults
                                    }
                                    
                                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyInstantBook] as? Bool {
                                        model.instantBook = defaults
                                    }
                                    if serviceList.contains(model.serviceID){
                                        arrServices.add(model)
                                    }
                                }
                                self.arrSlotServices.add(arrServices)
                            }
                        })
                    }
                }
            }
        }
        let _ = checkUserOwnListing(uid:snapUtils.currentUserModel.userId)
    }
    
    func getVideoThumbnail(){
        let url = URL(string: model.Video)!
        utils.thumbnailForVideoAtURL(url: url, completionHandler: {image in
            self.thumbnailImage = image
            self.imageCollectionView.reloadData()
        })
    }
    
    func checkThisListingisReported(){
        ref.child(nodeListingReports).queryOrdered(byChild: keyUserID).queryEqual(toValue: snapUtils.currentUserModel.userId).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children {
                    
                    if let listingId = ((child as! DataSnapshot).value as! NSDictionary)[keyListingId] as? String{
                        if listingId  == self.model.listingID {
                            self.isReported = true
                            return
                        }
                    }
                }
            }
        })
    }
    
    
    //MARK: Actions
    @IBAction func onClick_TicketCountDown(_ sender: UIButton) {
        if sender == btnDecrement {
            ticketsCount -= 1
        }else {
            ticketsCount += 1
        }
        lblTicketsCount.text = "\(ticketsCount)"
        btnDecrement.isEnabled = ticketsCount == 1 ? false:true
    
    }
    
    @IBAction func onClick_btnBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onClick_btnUserProfile(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        nextpage.userID = model.userid
        nextpage.isShowBar = true
        self.present(nextpage, animated: true, completion: nil)
    }
    @objc func tagControlIndexTouch(notification:Notification){
        if let scrView = self.view.viewWithTag(25) as? UIScrollView {
            for btn in scrView.subviews{
                if btn.backgroundColor != UIColor.lightGray {
                    btn.backgroundColor = themeColor
                }
            }
        }
        
        if let sender = notification.userInfo?["btn"] as? UIButton {
            if (model.distance < 30){
                slotIndex = sender.tag
                sender.backgroundColor = UIColor(displayP3Red: 70/255, green: 181/255, blue: 3/255, alpha: 1.0)
                var value = ""
                if(isToday){
                    value = model.availableslotsToday.object(at: sender.tag) as! String
                }else
                {
                    value = model.availableslotsTomorrow.object(at: sender.tag) as! String
                }
                if((value.range(of: "Not available")) != nil)
                {
                    sender.backgroundColor = themeColor
                }else
                {
                    if(isToday){
                        let index = model.slotsToday.index(of: value)
                        SlotsBooked = [false,false,false]
                        self.SlotsBooked.replaceObject(at: index, with: true)
                        self.slotSelected = value
                    }else{
                        let index = model.slotsTomorrow.index(of: value)
                        SlotsBooked = [false,false,false]
                        self.SlotsBooked.replaceObject(at: index, with: true)
                        self.slotSelected = value
                    }
                }
            }else{
            
            }
            let _ = isAlreadySelected() 
        }
    }
    
    @IBAction func onClick_btnFavorites(_ sender: Any) {
        if isFavorite{
            btnFavorite.tintColor = .white
            isFavorite = false
        }else{
            btnFavorite.tintColor = .red
            isFavorite = true
        }
        updateFavorite(isfav: isFavorite)
    }
    
    func updateFavorite(isfav:Bool) {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let _ = ref.child(nodeUsers).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists()
            {
                //Not exist
                let arr = NSMutableArray()
                arr.add(self.model.listingID)
                let userInstance = self.ref.child(nodeUsers).child(uid)
                userInstance.updateChildValues([keyFavorite:arr])
            }else
            {
                //Exist
                var arr = NSMutableArray()
                if let defaults = (snapshot.value as! NSDictionary)[keyFavorite] as? NSArray {
                    arr = defaults.mutableCopy() as! NSMutableArray
                }
                
                if (!(arr.contains(self.model.listingID)))
                {
                    arr.add(self.model.listingID)
                }else if (arr.contains(self.model.listingID)){
                    arr.remove(self.model.listingID)
                }
                
//                else{
//                    let alert = UIAlertController(title: "", message: "You can only save 5 listings", preferredStyle: UIAlertControllerStyle.alert)
//                    self.present(alert, animated: true, completion: nil)
//                    // change to desired number of seconds (in this case 5 seconds)
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
//                        alert.dismiss(animated: true, completion: {() -> Void in
//                        })
//                    })
//                    self.btnFavorite.tintColor = .red
//                    self.isFavorite = false
//                }
                let userInstance = self.ref.child(nodeUsers).child(uid)
                userInstance.updateChildValues([keyFavorite:arr])
                snapUtils.currentUserDateFetchFromDB(completionHandler: { _ in })
            }
            if self.isFromFavoriteVC == true{
                self.delegate.hideRemovedFavorite(isRemoved: isfav,listingId: self.model.listingID)
            }
        })
    }
    
    @IBAction func onClick_Report(_ sender: Any) {
        var message = ""
        if(model.userid == snapUtils.currentUserModel.userId)
        {
           message = "You can't report your own listing"
        }else if self.isReported {
           message = "You've already reported this listing"
        }else {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let modalViewController = storyboard.instantiateViewController(withIdentifier: "ReportViewPopUp") as! ReportViewPopUp
            modalViewController.modalPresentationStyle = .overCurrentContext
            modalViewController.modalTransitionStyle = .crossDissolve
            modalViewController.type = "Listing"
            modalViewController.model = self.model
            present(modalViewController, animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        // change to desired number of seconds (in this case 5 seconds)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            alert.dismiss(animated: true, completion: {() -> Void in
            })
        })
    }
    
    @IBAction func onClick_btnChat(_ sender: Any) {
        if snapUtils.currentUserModel.Verification != "true"{
            let v = UIView()
            let custAlert = customAlertView.init(title: "Message", message: "Phone verification required. Would you like to proceed?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
                
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextpage = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                let nav = UINavigationController(rootViewController: nextpage)
                self.present(nav, animated: true, completion: nil)
            }
            custAlert.onLeftBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
            }
            custAlert.show(animated: true)
            return
        }
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "ChattingsVC") as! ChattingsVC
        nextpage.UserName = self.model.userName
        nextpage.ReceiverUserid = self.model.userid
        let nav = UINavigationController(rootViewController: nextpage)
        self.present(nav, animated: true, completion: nil)
//        self..pushViewController(nextpage,animated: true)
    }
    
    @IBAction func onClick_btnSection(_ sender: UIButton) {
        if sender == btnDetails {
            btnDetails.isSelected = true
            btnReviews.isSelected = false
            xReview = 500.0
        }else {
            btnDetails.isSelected = false
            btnReviews.isSelected = true
            xReview = 0.0
        }
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.reviewLeading.constant = self.xReview
            self.selection_leading.constant = sender.frame.origin.x
            self.view.setNeedsDisplay()
        })
    }
    
    //MARK: ScrollView
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width: CGFloat = scrollView.frame.size.width
        let page = Int((scrollView.contentOffset.x + (0.5 * width)) / width)
        self.pageControl.currentPage = page
    }
    
    //MARK: Collection Delegate & DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if model.Video != "" {
            return model.images.count+1
        }
        return model.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        if indexPath.row == model.images.count {
            cell.imageListing.image = thumbnailImage
            cell.btnPlay.isHidden = false
            cell.btnPlay.addTarget(self, action: #selector(self.onClick_btnPlay(_:)), for: .touchUpInside)
        }else{
            let storageRef=Storage.storage().reference(forURL:model.images[indexPath.row] as! String)
            cell.imageListing.sd_setImage(with:storageRef, placeholderImage:#imageLiteral(resourceName: "ic_listing_default"))
            cell.btnPlay.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == model.images.count {
            playVideo()
        }else{
            let mediaBrowser = MediaBrowser(media: model.images, index: indexPath.row)
            present(mediaBrowser.browser, animated: true, completion: nil)
        }
    }
    @IBAction func onClick_btnPlay(_ sender:UIButton){
        playVideo()
    }
    func playVideo(){
        let videoURL = URL(string: model.Video)!
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}
extension String
{
    func stringByReplacingFirstOccurrenceOfString(
        target: String, withString replaceString: String) -> String
    {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}
