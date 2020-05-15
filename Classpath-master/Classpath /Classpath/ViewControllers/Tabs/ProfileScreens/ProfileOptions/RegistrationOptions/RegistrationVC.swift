//
//  RegistrationVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/8/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

class RegistrationTableViewCell: UITableViewCell{
    @IBOutlet weak var imgList: UIImageView!
    @IBOutlet weak var lblListName: UILabel!
    @IBOutlet weak var lblPendingreq: UILabel!
    @IBOutlet weak var btnListingDetails: UIButton!
}

class RegistrationVC: UIViewController,NVActivityIndicatorViewable,requestHandleDelegate {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewDefault: UIView!
    var arr = NSMutableArray()
    var ref: DatabaseReference!

    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getUserListings()
        tblView.estimatedRowHeight = 120
        tblView.rowHeight = UITableView.automaticDimension
        tblView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadlistingData(_:)), name: NSNotification.Name(rawValue: "listingDetailRequest"), object: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tblView.reloadData()
    }
    
    //MARK: Server request for data
    func getUserListings()
    {
        self.arr.removeAllObjects()
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        let _ = ref.child(nodeListings).queryOrdered(byChild: keyUserID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            self.ref.child(nodeListings).queryOrdered(byChild: keyUserID).queryEqual(toValue: uid).removeAllObservers()
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
        let myGroup = DispatchGroup()
        for child in snapshot.children {
            myGroup.enter()
            let model = ListingPendingRequest()
            model.listingID = (child as! DataSnapshot).key
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyDescription] as? String {
                model.listing_description = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyTitle] as? String {
                model.title = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyImages] as? NSArray {
                model.images = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyURL] as? String {
                model.listingURL = defaults
            }
            
                let _ = ref.child(nodeListingsRegistered).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).observe(.value, with: { snapshot in
                    var count = 0
                    self.ref.child(nodeListingsRegistered).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).removeAllObservers()
                    var cAp = 0
                    var cPe = 0
                    var cCo = 0
                    var cCa = 0
                    var cRe = 0
                    var cCom = 0
                  //  var cEx = 0
                    for child in snapshot.children {
                        var reqdate:Date!
                        if model.listingURL == "" {
                            
                            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRequestTime] as? String
                            {
                                reqdate = utils.convertStringToDate(defaults, dateFormat: "MM.dd.yyyy h:mm a")
                                if model.recentAppointTime == nil {
                                    model.recentAppointTime = reqdate
                                }else if reqdate > model.recentAppointTime {
                                    model.recentAppointTime = reqdate
                                }
                            }
                            
                            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keySelectedSlot] as? NSDictionary
                            {
                                if let defaults = defaults.value(forKey: keyRejected) as? NSDictionary
                                {
                                    let keys = defaults.allKeys
                                    for i in keys
                                    {
                                        if let defaults = defaults.value(forKey: i as! String) as? NSArray
                                        {
                                            count += defaults.count
                                        }
                                        cRe+=1
                                    }
                                }
                                
                                if let defaults = defaults.value(forKey: keyPending) as? NSDictionary
                                {
                                    let keys = defaults.allKeys
                                    for i in keys
                                    {
                                        if let defaults = defaults.value(forKey: i as! String) as? NSArray
                                        {
                                            count += defaults.count
                                        }
                                        cPe+=1
                                    }
                                }
                                if let defaults = defaults.value(forKey: keyAprooved) as? NSDictionary
                                {
                                    let keys = defaults.allKeys
                                    
                                    for i in keys
                                    {
                                        if let defaults = defaults.value(forKey: i as! String) as? NSArray
                                        {
                                            count += defaults.count
                                        }
                                        cAp+=1
                                    }
                                    
                                }
                                if let defaults = defaults.value(forKey: keyConfirmed) as? NSDictionary
                                {
                                    
                                    let keys = defaults.allKeys
                                    for i in keys
                                    {
                                        if let defaults = defaults.value(forKey: i as! String) as? NSArray
                                        {
                                            count += defaults.count
                                        }
                                        cCo+=1
                                        
                                    }
                                    
                                }
                                if let defaults = defaults.value(forKey: keyCancelled) as? NSDictionary
                                {
                                    let keys = defaults.allKeys
                                    for i in keys
                                    {
                                        if let defaults = defaults.value(forKey: i as! String) as? NSArray
                                        {
                                            count += defaults.count
                                        }
                                        cCa+=1
                                    }
                                }
                                
                                if let defaults = defaults.value(forKey: keyCompleted) as? NSDictionary
                                {
                                    let keys = defaults.allKeys
                                    for i in keys
                                    {
                                        if let defaults = defaults.value(forKey: i as! String) as? NSArray
                                        {
                                            count += defaults.count
                                        }
                                        cCom+=1
                                    }
                                }
                            }
                        }
                    }
                    model.request_count = count
                    if(count > 0)
                    {
                        var r1 = (model.status as NSString).range(of: "")
                        var r2 = (model.status as NSString).range(of: "")
                        var r3 = (model.status as NSString).range(of: "")
                        var r4 = (model.status as NSString).range(of: "")
                        var r5 = (model.status as NSString).range(of: "")
                        var r6 = (model.status as NSString).range(of: "")

                        if cRe != 0{
                            model.status += "\(cRe) Rejected Request(s) \n"
                            r1 = (model.status as NSString).range(of: "\(cRe) Rejected Request(s) \n")
                        }
                        if cPe != 0{
                            model.status += "\(cPe) Request(s') Pending \n"
                            r2 = (model.status as NSString).range(of: "\(cPe) Request(s') Pending \n")
                        }
                        if cAp != 0{
                            model.status += "\(cAp) Payment Pending Request(s') \n"
                            r3 = (model.status as NSString).range(of: "\(cAp) Payment Pending Request(s') \n")
                        }
                        if cCo != 0{
                            model.status += "\(cCo) Confirmed Request(s) \n"
                            r4 = (model.status as NSString).range(of: "\(cCo) Confirmed Request(s) \n")
                        }
                        if cCa != 0{
                            model.status += "\(cCa) Cancelled Request(s) \n"
                            r5 = (model.status as NSString).range(of: "\(cCa) Cancelled Request(s) \n")
                        }
                        if cCom != 0{
                            model.status += "\(cCom) Completed Request(s) \n"
                            r6 = (model.status as NSString).range(of: "\(cCom) Completed Request(s) \n")
                        }
            
                        let attributedString = NSMutableAttributedString(string:model.status)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: r1)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorRequest , range: r2)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorPreApproved , range: r3)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorConfirmed , range: r4)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorCancelled , range: r5)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorConfirmed , range: r6)
                        
                        model.pending_request = attributedString//model.status
                        print(model.pending_request)
                        self.arr.add(model)
                    }
                    myGroup.leave()
                })
            }
           
        myGroup.notify(queue: .main) {
            self.sortByTimeReference()
        }
    }
    func sortByTimeReference(){
        var arr1: NSArray!
        let sortedArray = self.arr.sorted(by: { ($0 as! ListingPendingRequest).recentAppointTime > (($1 as! ListingPendingRequest).recentAppointTime)})
        arr1 = sortedArray as NSArray
        self.arr = arr1.mutableCopy() as! NSMutableArray
    
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.reloadData()
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let userInstance = self.ref.child(nodeUsers).child(uid)
        userInstance.updateChildValues([keyPendingNotificationCount : 0])
        defaults.setValue(0, forKey: keyPendingNotificationCount)
        self.stopAnimating()
    }
    
    func fetchListingDetails(listingId:String)  {
        let _ = ref.child(nodeListings).child(listingId).observe(.value, with: { snapshot in
            self.ref.child(nodeListings).child(listingId).removeAllObservers()
            if snapshot.exists(){
                if snapshot.value != nil {
                    snapUtils.parseSnapShot(snapshot: snapshot,notiName: "listingDetailRequest")
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
extension RegistrationVC:  UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let model = self.arr.object(at: indexPath.row) as? ListingPendingRequest
        if(model!.request_count > 0)
        {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextpage = storyboard.instantiateViewController(withIdentifier: "RegistrationDetailVC") as! RegistrationDetailVC
            nextpage.modelRequest = model!
            nextpage.delegate = self
            self.navigationController?.pushViewController(nextpage,animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(arr.count > 0){
            self.viewDefault.isHidden = true
        }else{
            self.viewDefault.isHidden = false
        }
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCell") as! RegistrationTableViewCell
        cell.selectionStyle = .none
        var model : ListingPendingRequest = ListingPendingRequest()
        model = arr.object(at: indexPath.row) as! ListingPendingRequest
        cell.lblListName.text = model.title
        cell.lblPendingreq.attributedText = model.pending_request
        let image = model.images[0] as! String
        if image != "" {
            let storageRef=Storage.storage().reference(forURL:image)
            cell.imgList.sd_setImage(with:storageRef, placeholderImage:#imageLiteral(resourceName: "ic_listing_default"))
        }else{
            cell.imgList.image = #imageLiteral(resourceName: "ic_listing_default")
        }
        cell.btnListingDetails.tag = indexPath.row
        cell.btnListingDetails.addTarget(self, action: #selector(onClick_imageListing(_:)), for: .touchUpInside)
        return cell
    }
    @objc func onClick_imageListing(_ sender:UIButton){
        var model:ListingPendingRequest = ListingPendingRequest()
        model = self.arr.object(at: sender.tag) as! ListingPendingRequest
        fetchListingDetails(listingId: model.listingID)
    }
    
    
    //MARK:- Report delete Delegate
    func requestHandleReload() {
        getUserListings()
    }
}
