//
//  HistoryVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/8/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HistoryTableViewCell : UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRequests: UILabel!
    @IBOutlet weak var btnListingDetails: UIButton!
}

class HistoryVC: UIViewController {
    
  //  @IBOutlet weak var tblView: UITableView!
  //  @IBOutlet weak var viewDefault: UIView!
    
  //  let arr = NSMutableArray()
   // var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
  //      tblView.rowHeight = 95
  //      tblView.tableFooterView = UIView()
  //      ref = Database.database().reference()
  //      getUserListings()
   //     NotificationCenter.default.addObserver(self, selector: #selector(self.reloadlistingData(_:)), name: NSNotification.Name(rawValue: "listingDetailHistory"), object: nil)
    }
//    func getUserListings()
//    {
//        guard let uid = Auth.auth().currentUser?.uid else{
//            return
//        }
//         
//        self.startAnimating(size, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
//        let _ = ref.child(nodeListings).queryOrdered(byChild: keyUserID).queryEqual(toValue: uid).observe(.value, with: { snapshot in
//            self.ref.child(nodeListings).queryOrdered(byChild: keyUserID).queryEqual(toValue: uid).removeAllObservers()
//            if !snapshot.exists() {
//                self.stopAnimating()
//                if(self.arr.count > 0){
//                    self.viewDefault.isHidden = true
//                }else{
//                    self.viewDefault.isHidden = false
//                }
//                return
//            }
//            self.parseSnapShot(snapshot: snapshot)
//        })
//    }
//
//    func parseSnapShot(snapshot : DataSnapshot)
//    {
//        let myGroup = DispatchGroup()
//        for child in snapshot.children {
//            myGroup.enter()
//            let model = ListingPendingRequest()
//            model.listingID = (child as! DataSnapshot).key
//            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyDescription] as? String {
//                model.listing_description = defaults
//                print(defaults)
//            }
//
//            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyTitle] as? String {
//                model.title = defaults
//            }
//
//            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyImages] as? NSArray {
//                model.images = defaults
//            }
//
//            let _ = ref.child(nodeListingsRegistered).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).observe(.value, with: { snapshot in
//                var count = 0
//                self.ref.child(nodeListingsRegistered).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).removeAllObservers()
//                for child in snapshot.children {
//                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keySelectedSlot] as? NSDictionary{
//                        if let defaults = defaults.value(forKey: keyAprooved) as? NSDictionary{
//                            let keys = defaults.allKeys
//                            for i in keys{
//                                if let defaults = defaults.value(forKey: i as! String) as? NSArray{
//                                    count += defaults.count
//                                }
//                            }
//                        }
//                    }
//                }
//                model.request_count = count
//                if(count > 0){
//                    model.pending_request = "\(count) Request(s) Approved"
//                    self.arr.add(model)
//                }
//                myGroup.leave()
//            })
//        }
//        myGroup.notify(queue: .main) {
//            self.tblView.delegate = self
//            self.tblView.dataSource = self
//            self.tblView.reloadData()
//            self.stopAnimating()
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        self.tblView.reloadData()
//    }
//
//    //MARK: Tableview delegate and datasources
//    func numberOfSections(in tableView: UITableView) -> Int
//    {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        if(arr.count > 0)
//        {
//            self.viewDefault.isHidden = true
//        }else
//        {
//            self.viewDefault.isHidden = false
//        }
//        return arr.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryTableViewCell
//        cell.selectionStyle = .none
//        var model : ListingPendingRequest = ListingPendingRequest()
//        model = arr.object(at: indexPath.row) as! ListingPendingRequest
//        cell.lblTitle.text = model.title
//        cell.lblRequests.text = model.pending_request
//        let image = model.images[0] as! String
//        if image != "" {
//            let imageRequest = NSURLRequest(url:URL(string: image)!, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 600)
//            cell.imgView.setImageWith(imageRequest as URLRequest, placeholderImage: #imageLiteral(resourceName: "ic_listing_default"), success: { (URLRequest, HTTPURLResponse, Image) in
//                cell.imgView.image = Image
//            }, failure: { (URLRequest, HTTPURLResponse, Error) in
//            })
//        }else{
//            cell.imgView.image = #imageLiteral(resourceName: "ic_listing_default")
//        }
//
//        cell.btnListingDetails.tag = indexPath.row
//        cell.btnListingDetails.addTarget(self, action: #selector(onClick_imageListing(_:)), for: .touchUpInside)
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        let model = self.arr.object(at: indexPath.row) as? ListingPendingRequest
//        if(model!.request_count > 0)
//        {
//            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let nextpage = storyboard.instantiateViewController(withIdentifier: "RegistrationDetailVC") as! RegistrationDetailVC
//            nextpage.model = model!
//            nextpage.isFromHistory = true
//            self.navigationController?.pushViewController(nextpage,animated: true)
//        }
//    }
//    @objc func onClick_imageListing(_ sender:UIButton){
//        var model:ListingPendingRequest = ListingPendingRequest()
//        model = self.arr.object(at: sender.tag) as! ListingPendingRequest
//        fetchListingDetails(listingId: model.listingID)
//    }
//    func fetchListingDetails(listingId:String)  {
//        let _ = ref.child(nodeListings).child(listingId).observe(.value, with: { snapshot in
//            self.ref.child(nodeListings).child(listingId).removeAllObservers()
//            if snapshot.exists(){
//                if snapshot.value != nil {
//                    snapUtils.parseSnapShot(snapshot: snapshot,notiName: "listingDetailHistory")
//                }
//            }
//        })
//    }
//    func reloadlistingData(_ notification: NSNotification){
//
//        if let model = notification.userInfo?["model"] as? ListingModel {
//            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let nextpage = storyboard.instantiateViewController(withIdentifier: "ListingDetailsVC") as! ListingDetailsVC
//            nextpage.isFromFavoriteVC = false
//            nextpage.model = model
//            nextpage.isToday = true
//            self.navigationController?.pushViewController(nextpage,animated: true)
//        }
//
//    }
}
