//
//  HomeVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/1/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth

class HomeVC: UIViewController,NVActivityIndicatorViewable {
   
    
    var selected_index = 0
    
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var tableHeightConstraint:NSLayoutConstraint!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var const_selected_day:NSLayoutConstraint!
    @IBOutlet weak var btnToday:UIButton!
    @IBOutlet weak var btnTomorrow:UIButton!
    @IBOutlet weak var lblTitleText:UILabel!
    @IBOutlet weak var topCollectionView:UICollectionView!
    @IBOutlet weak var viewDefault:UIView!
    @IBOutlet weak var btnUpArrow: UIButton!
    var mainArray = NSMutableArray()
    var arrData = NSMutableArray()
    var arrToday = NSMutableArray()
    var arrTomorrow = NSMutableArray()
    var arrfilterCategories = NSMutableArray()
    
    var isFilterFirst = true
    var locationManager = CLLocationManager()
    var locationCoordinate : CLLocationCoordinate2D!
    var noOfListing = NSMutableDictionary()
    var noOfFilterListing = NSMutableDictionary()
    var called = false
    let formatter = DateFormatter()
    var result  = ""
    var date = Date()
    @IBOutlet weak var lblLoading: UILabel!
    
    var didFindMyLocation: Bool{
        get{
            return self.didFindMyLocation
        }
        set{
            if(newValue == true)
            {
                if(called == false)
                {
                    called = true
                    self.callAPI()
                }
            }
        }
    }
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        snapUtils.currentUserDateFetchFromDB(completionHandler: { isComplete in
            print(isComplete, snapUtils.currentUserModel.mobileNo)
        })
        
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "HomeNavBg").resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0,bottom: 0, right: 0), resizingMode: .stretch), for: .default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        setUpDesign()
        ref = Database.database().reference()
        
        mainArray = (arrCategory as NSArray).mutableCopy() as! NSMutableArray
        
        formatter.dateFormat = "MM.dd.yyyy"
        result = formatter.string(from: self.date)
      
        called = false
        didFindMyLocation = false
         
        startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        btnToday.isSelected = true
        //for Get current Location and address of user
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }

//        let btnNotification = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
//        btnNotification.setTitle("Notification", for: .normal)
//        btnNotification.backgroundColor = UIColor.black
//        btnNotification.setTitleColor(.white, for: .normal)
//        btnNotification.addTarget(self, action: #selector(notificationAction), for: .touchUpInside)
//        self.view.addSubview(btnNotification)
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ref.child(nodeListings).queryOrdered(byChild: keyIsOpen).queryEqual(toValue: true).removeAllObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey:"goToBooking")
        {
            UserDefaults.standard.set(false, forKey:"goToBooking")
            tabBarController?.selectedIndex=1
        }
        
        utils.getProfileBadge()
        utils.getNotificationBadge()
        called = false
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        if utils.home_category_select == "Promoted Listings"{
            callShowAll(selected_category: utils.home_category_select)
        }else if utils.userForCategory != "" {
            callforUserListings()
        }else{
            callforSpecifCategory(selected_category: utils.home_category_select)
        }
    }
    
    func setUpDesign(){
        tableView.rowHeight = 110
        
        btnToday.setTitleColor(themeColor, for: .selected)
        btnToday.setTitleColor(UIColor(red:0.48, green:0.53, blue:0.57, alpha:1), for: .normal)
        
        btnTomorrow.setTitleColor(themeColor, for: .selected)
        btnTomorrow.setTitleColor(UIColor(red:0.48, green:0.53, blue:0.57, alpha:1), for: .normal)
    }
    
    func callAPI()
    {
        let _ = ref.child(nodeListings).queryOrdered(byChild: keyIsOpen).queryEqual(toValue: true).observe(.value, with: { snapshot in
            for i in (0..<self.mainArray.count)
            {
                var dic = [String:UIImage]()
                dic = self.mainArray.object(at: i) as! [String:UIImage]
                self.noOfListing.setValue(0, forKey: (dic as NSDictionary).allKeys[0] as! NSString as String)
            }
            if !snapshot.exists()
            {
                self.stopAnimating()
            }
            else
            {
                for i in (0..<self.mainArray.count)
                {
                    var arr = [String:UIImage]()
                    arr = self.mainArray.object(at: i) as! [String:UIImage]
                    self.noOfListing.setValue(0, forKey: (arr as NSDictionary).allKeys[0] as! NSString as String)
                    self.noOfFilterListing.setValue(0, forKey: (arr as NSDictionary).allKeys[0] as! NSString as String)
                }
                
                self.noOfFilterListing.removeObject(forKey: "Promoted Listings")
                
                for child in snapshot.children {
                    let model = ListingModel()
                    
                    model.listingID = (child as! DataSnapshot).key
                    var dataDate = Date()
                    var todayDate = Date()
                    
                    if  let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyExpirationDate] as? String {
                        if defaults != "" {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM.dd.yyyy HH:mm:ss"
                            let exdate = formatter.date(from: defaults)
                            model.Expiration_Date = utils.convertDateToString(exdate!, format: "yyyy-MM-dd HH:mm:ss")
                            dataDate = formatter.date(from: defaults)!
                            todayDate = utils.convertStringToDate(Date().localDateStringFullDate(), dateFormat: "MM.dd.yyyy HH:mm:ss")
                        }
                    }
                    
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyCategory] as? String {
                        model.category = defaults
                    }
                    
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyIsOpen] as? Bool {
                        model.isOpen = defaults
                    }
                    
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyLat] as? Double {
                        model.latitude = defaults
                    }
                    
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyLong] as? Double {
                        model.longitude = defaults
                    }
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyUserID] as? String {
                        model.userid = defaults
                    }
                    
                    self.ref.child(nodeUsers).child(model.userid).observeSingleEvent(of: .value, with: { snapshotUser in
                        if snapshotUser.exists(){
                            if let defaults = (snapshotUser.value as! NSDictionary)[keyUsername] as? String {
                                model.userName = defaults
                            }
                            if let defaults = (snapshotUser.value as! NSDictionary)[keyEmail] as? String {
                                model.email_id = defaults
                            }
                            
                            let latLIST = CLLocation(latitude:  model.latitude, longitude:  model.longitude)
                            let latCurrent = CLLocation(latitude:  self.locationCoordinate.latitude, longitude:  self.locationCoordinate.longitude)
                            model.distance = latCurrent.distance(from: latLIST) / 1609.34
                            
                            if (model.distance < 30 && model.isOpen == true){
                                let dateSelected = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                                if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceHour] as? NSDictionary
                                {
                                    let key = "\(dateSelected.dayOfWeek()!)"
                                    if let default2 = defaults.value(forKey: key) as? NSMutableArray {
                                        model.slotsTomorrow = default2
                                    }
                                    
                                    let slotIsGray = NSMutableArray()
                                    for _ in model.slotsTomorrow
                                    {
                                        slotIsGray.add(true)
                                    }
                                    model.slotIsGrayTomorrow = slotIsGray
                                }
                                
                            }
                            if (model.distance < 30)
                            {
                                if (model.distance < 30 && model.isOpen == true){
                                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceHour] as? NSDictionary
                                    {
                                        let key = "\(Date().dayOfWeek()!)"
                                        
                                        if let default2 = defaults.value(forKey: key) as? NSMutableArray {
                                            model.slotsToday = default2
                                        }
                                        let slotIsGray = NSMutableArray()
                                        for _ in model.slotsToday {
                                            slotIsGray.add(true)
                                        }
                                        model.slotIsGrayToday = slotIsGray
                                    }
                                }
                            }
                            if(model.slotIsGrayTomorrow.count > 0 || model.slotIsGrayToday.count > 0)
                            {
                                self.noOfListing.setValue((self.noOfListing.value(forKey: model.category) as! Int) + 1, forKey: model.category)
                                if model.Expiration_Date != "" {
                                    if dataDate > todayDate{
                                        self.noOfListing.setValue((self.noOfListing.value(forKey: "Promoted Listings") as! Int) + 1, forKey: "Promoted Listings")
                                    }
                                }
                            }
                        }
                        self.topCollectionView.reloadData()
                        if utils.userForCategory != "" {
                            self.selected_index = arrCategory.count
                            let indexPath = IndexPath(item: arrCategory.count, section: 0)
                            self.topCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                        }
                        self.stopAnimating()
                    })
                }
            }
        })
    }
    
    func callShowAll(selected_category : String)
    {
       let _ = ref.child(nodeListings).queryOrdered(byChild: keyIsOpen).queryEqual(toValue: true).observeSingleEvent(of: .value, with: { snapshot in
            self.arrToday = NSMutableArray()
            self.arrTomorrow = NSMutableArray()
            self.arrData = NSMutableArray()
            if !snapshot.exists() {
                self.lblLoading.isHidden = true
                self.tableView.reloadData()
                self.stopAnimating()
                return
            }
            self.parseSnapShot(snapshot: snapshot,selected_category : selected_category)
        })
    }
    func callforSpecifCategory(selected_category : String)
    {
        let _ = ref.child(nodeListings).queryOrdered(byChild: keyCategory).queryEqual(toValue: selected_category).observeSingleEvent(of: .value, with: { snapshot in
            self.arrToday = NSMutableArray()
            self.arrTomorrow = NSMutableArray()
            self.arrData = NSMutableArray()
       //     self.ref.child(nodeListings).removeAllObservers()
           
            if !snapshot.exists() {
                self.lblLoading.isHidden = true
                self.tableView.reloadData()
                self.stopAnimating()
                return
            }
            self.parseSnapShot(snapshot: snapshot, selected_category : selected_category)
        })
    }
    
    func callforUserListings()
    {
        let _ = ref.child(nodeListings).queryOrdered(byChild: keyUserID).queryEqual(toValue: utils.userForCategory).observe(.value, with: { snapshot in
            self.arrToday = NSMutableArray()
            self.arrTomorrow = NSMutableArray()
            self.arrData = NSMutableArray()
            //     self.ref.child(nodeListings).removeAllObservers()
            if !snapshot.exists() {
                self.lblLoading.isHidden = true
                self.tableView.reloadData()
                self.stopAnimating()
                return
            }
            self.parseSnapShot(snapshot: snapshot, selected_category : "")
        })
    }
    
    func parseSnapShot(snapshot : DataSnapshot,selected_category : String)
    {
        var count:Int = 0
       
        for child in snapshot.children {
            let model = ListingModel()
            
            model.listingID = (child as! DataSnapshot).key
            
            var dataDate = Date()
            var todayDate = Date()
            if model.Expiration_Date != "Not Applicable"{
                
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyExpirationDate] as? String {
                if defaults != "" {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM.dd.yyyy HH:mm:ss"
                    model.Expiration_Date = defaults
                    dataDate = formatter.date(from: model.Expiration_Date)!
                    todayDate = utils.convertStringToDate(Date().localDateStringFullDate(), dateFormat: "MM.dd.yyyy HH:mm:ss")
                }
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyDescription] as? String {
                model.listing_description = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyURL] as? String {
                model.listingURL = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyBusinessWebsite] as? String {
                model.businessURL = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[KeyListingAddress] as? String {
                model.address = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyCategory] as? String {
                model.category = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyCertificates] as? String {
                model.certificates = defaults
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
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyViews] as? NSDictionary {
                model.views = defaults
                let arrViews = model.views.object(forKey: model.views.allKeys[0]) as! NSArray
                model.noofViews = arrViews.count
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyNoofRegister] as? Int{
                model.noofRegister = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRatings] as? Double {
                model.ratings = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyTitle] as? String {
                model.title = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyNoofTimesReviewed] as? Double {
                model.NoofTimesReviewed = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyVideo] as? String {
                model.Video = defaults
            }
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyNoofTimesReviewed] as? Double {
                model.NoofTimesReviewed = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyNoofTimesRecommended] as? Double {
                model.NoofTimesRecommended = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServices] as? NSMutableDictionary {
                model.services = defaults
            }
            ref.child(nodeUsers).child(model.userid).observeSingleEvent(of: .value, with: { snapshotUser in
                if snapshotUser.exists(){
                    if let defaults = (snapshotUser.value as! NSDictionary)[keyUsername] as? String {
                        model.userName = defaults
                    }
                    if let defaults = (snapshotUser.value as! NSDictionary)[keyEmail] as? String {
                        model.email_id = defaults
                    }
                    let _ = self.ref.child(nodeReviews).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).observe(.value, with: { snapshot1 in
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
                        let latLIST = CLLocation(latitude:  model.latitude, longitude:  model.longitude)
                        if self.locationCoordinate != nil {
                            let latCurrent = CLLocation(latitude:  self.locationCoordinate.latitude, longitude:  self.locationCoordinate.longitude)
                            model.distance = latCurrent.distance(from: latLIST) / 1609.34
                            let dateSelected = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                            
                            if (model.distance < 30 && model.isOpen == true){
                                if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceHour] as? NSDictionary
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
                                        }else {
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
                                if(model.slotIsGrayTomorrow.count > 0)
                                {
                                    if selected_category == "Promoted Listings" && model.Expiration_Date != ""{
                                        if dataDate > todayDate{
                                            self.arrTomorrow.add(model)
                                        }
                                    }else if selected_category != "Promoted Listings"{
                                        self.arrTomorrow.add(model)
                                    }
                                }
                            }
                            if (model.distance < 30 && model.isOpen == true){
                                if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceHour] as? NSDictionary
                                {
                                    let key = "\(Date().dayOfWeek()!)"
                                    
                                    if let default2 = defaults.value(forKey: key) as? NSMutableArray {
                                        model.slotsToday = default2
                                    }
                                    let slotIsGray = NSMutableArray()
                                    for i in model.slotsToday {
                                        if("\(i)".range(of: "Not available") == nil){
                                            let arr = "\(i)".components(separatedBy: "-")
                                            let fromDate = utils.convertStringToDate("\(self.result) \(arr[0])", dateFormat: "MM.dd.yyyy h:mm a")
                                            
                                            let currentDate = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM.dd.yyyy h:mm a")
                                            
                                            if(fromDate < currentDate){
                                                slotIsGray.add(true)
                                            }else{
                                                slotIsGray.add(false)
                                            }
                                            model.availableslotsToday.add("\(i)")
                                        }else {
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
                                    model.slotIsGrayToday = slotIsGray
                                }
                                
                                if(model.slotIsGrayToday.count > 0)
                                {
                                    if selected_category == "Promoted Listings" && model.Expiration_Date != "" {
                                        if dataDate > todayDate{
                                            self.arrToday.add(model)
                                        }
                                    }else if selected_category != "Promoted Listings"{
                                        self.arrToday.add(model)
                                    }
                                }
                            }
                            if count == snapshot.childrenCount-1{
                                self.stopAnimating()
                                if(self.arrToday.count != 0 || self.arrTomorrow.count != 0)
                                {
                                    
                                    if (self.btnToday.isSelected)
                                    {
                                        self.arrData = self.arrToday
                                    }else
                                    {
                                        self.arrData = self.arrTomorrow
                                    }
                                    let arr = self.arrData
                                    if self.arrfilterCategories.count != 0{
                                        self.arrData = NSMutableArray()
                                        for i in 0...arr.count-1{
                                            var model : ListingModel = ListingModel()
                                            model = arr.object(at: i) as! ListingModel
                                            if self.arrfilterCategories.contains(model.category){
                                                self.arrData.add(model)
                                            }
                                        }
                                    }else
                                    {
                                    }
                                    
                                    self.sortArraybyTimeDinstanceReference()
                                    
                                }
                                if utils.home_category_select == "Promoted Listings" && self.arrData.count != 0{
                                    self.btnFilter.isHidden = false
                                }
                                
                                self.tableView.isUserInteractionEnabled = true
                                self.lblLoading.isHidden = true
                                self.tableView.reloadData()
                                self.topCollectionView.reloadData()
                            }
                            count += 1
                        }
                    })
                
            }else{
                    count += 1
                    self.tableView.isUserInteractionEnabled = true
                    self.lblLoading.isHidden = true
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func sortArraybyTimeDinstanceReference() {
        var arrSortData: NSArray!
        if utils.home_category_select == "Promoted Listings"{
            let sortedArray = self.arrData.sorted(by: { ($0 as! ListingModel).Expiration_Date < (($1 as! ListingModel).Expiration_Date)})
            arrSortData = sortedArray as NSArray
            self.arrData = arrSortData.mutableCopy() as! NSMutableArray
        }else{
            let sortedArray = self.arrData.sorted(by: { ($0 as! ListingModel).distance < (($1 as! ListingModel).distance)})
            arrSortData = sortedArray as NSArray
            self.arrData = arrSortData.mutableCopy() as! NSMutableArray
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == scrView{
            if scrollView.contentOffset.y > scrollView.frame.height {
                btnUpArrow.isHidden = false
            }else{
                btnUpArrow.isHidden = true
            }
        }
    }
    
    //MARK: Actions
    @IBAction func btnUpArrow(_ sender: Any) {
        scrView.setContentOffset(CGPoint.zero, animated: true)
    }
    @IBAction func onClick_Day(_ sender: UIButton) {
        arrData = NSMutableArray()
        // 
        //startAnimating(size, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        if sender.tag == 1 {
            btnToday.isSelected = true
            btnTomorrow.isSelected = false
        }else {
            btnToday.isSelected = false
            btnTomorrow.isSelected = true
        }
        if(btnToday.isSelected)
        {
            arrData = arrToday
        }
        else if (btnTomorrow.isSelected)
        {
            arrData = arrTomorrow
        }
        self.sortArraybyTimeDinstanceReference()
        tableView.reloadData()
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.const_selected_day.constant = sender.frame.origin.x
                self.view.setNeedsDisplay()
        })
    }
    
    func noofFilterListingCount(){
        if arrData.count > 0 {
            for i in 0...arrData.count-1 {
                var model : ListingModel = ListingModel()
                model = arrData.object(at: i) as! ListingModel
                self.noOfFilterListing.setValue((self.noOfFilterListing.value(forKey: model.category) as! Int) + 1, forKey: model.category)
            }
        }
    }
    
    @IBAction func onClick_Filter(_ sender: UIButton) {
        if isFilterFirst{
            noofFilterListingCount()
            isFilterFirst = false
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        modalViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.noOfListing = self.noOfFilterListing
        modalViewController.delegate = self
        present(modalViewController, animated: true, completion: nil)
    }
    
    //MARK: Statusbar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
extension HomeVC:filterDelegate{
    func filterCategory(category: String, arrCategories:NSMutableArray) {
        arrfilterCategories = arrCategories
        if arrfilterCategories.count != 0{
            self.callShowAll(selected_category: category)
        }
    }
}
