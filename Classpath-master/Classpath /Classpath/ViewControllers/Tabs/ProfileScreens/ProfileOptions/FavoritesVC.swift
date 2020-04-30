//
//  FavoritesVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/8/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation
import FirebaseStorage
import FirebaseUI

class FavoritesVC: UIViewController,UITableViewDelegate, UITableViewDataSource,NVActivityIndicatorViewable {
 
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var viewDefault: UIView!
    var arr = NSMutableArray()
    var arrData = NSMutableArray()
    var arrforBool = NSMutableArray()
    var ref: DatabaseReference!
    var listCount:Int = 0
    var count:Int = 0
    var isBack:Bool = true
    var isInitail:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.tableFooterView = UIView()
        tblView.rowHeight = 110
        ref = Database.database().reference()
         
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        self.getFavoriteListing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadlistingData(_:)), name: NSNotification.Name(rawValue: "listingReady"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        if isBack {
            isInitail = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        isBack = true
        
    }
    // MARK: - Data retirving functions
    func getFavoriteListing() {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let _ = ref.child(nodeUsers).child(uid).observe(.value, with: { (snapshot) in
            self.ref.child(nodeUsers).child(uid).removeAllObservers()
            if snapshot.exists()
            {
                if let defaults = (snapshot.value as! NSDictionary)[keyFavorite] as? NSArray {
                    self.arr = defaults.mutableCopy() as! NSMutableArray
                    for _ in self.arr{
                        self.arrforBool.add(true)
                    }
                    self.getFavoriteListDatas()
                }else{
                    self.stopAnimating()
                    self.tblView.delegate = self
                    self.tblView.dataSource = self
                    self.tblView.reloadData()
                }
            }
        })
    }

    func getFavoriteListDatas() {
        listCount = arr.count
        for i in arr {
            let _ = ref.child(nodeListings).child(i as! String).observe(.value, with: { snapshot in
                self.ref.child(nodeListings).child(i as! String).removeAllObservers()
                if snapshot.exists(){
                    if snapshot.value != nil {
                        snapUtils.parseSnapShot(snapshot: snapshot,notiName: "listingReady")
                    }
                }
                else{
                    self.stopAnimating()
                    self.viewDefault.isHidden = false
                }
            })
        }
    }
    
    @objc func reloadlistingData(_ notification: NSNotification) {
        if isInitail{
            arrData = NSMutableArray()
            isInitail = false
        }
        if let model = notification.userInfo?["model"] as? ListingModel {
            
            self.arrData.add(model)
            
            self.stopAnimating()
            self.tblView.delegate = self
            self.tblView.dataSource = self
            self.tblView.reloadData()
            
            self.count += 1
        }
    }

    //MARK: Tableview delegate and database
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(arrData.count)
        let arr:NSMutableArray = NSMutableArray()
        if arrData.count>0 {
            for i in 0...self.arrData.count-1 {
                let isFavo:Bool = self.arrforBool.object(at: i) as! Bool
                if isFavo == true{
                    arr.add(self.arrData.object(at: i))
                }
            }
        }
        
        if(arr.count > 0)
        {
            self.viewDefault.isHidden = true
        }else
        {
            self.stopAnimating()
            self.viewDefault.isHidden = false
        }
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath) as! ListingTableViewCell
        cell.selectionStyle = .none
        let arr:NSMutableArray = NSMutableArray()
        
        for i in 0...arrData.count - 1 {
            let isFavo:Bool = arrforBool.object(at: i) as! Bool
            if isFavo == true{
                arr.add(self.arrData.object(at: i))
            }
        }
        
        var model : ListingModel = ListingModel()
        model = arr.object(at: indexPath.row) as! ListingModel
        cell.lblListName.text = model.title
        cell.lblListingOwner.text = model.userName

        cell.btnDistance.setTitle(" \(model.distance.rounded(toPlaces: 1)) mi", for: .normal)
        cell.viewRating.value = CGFloat(model.star)
        cell.txtTags.subviews.forEach({ $0.removeFromSuperview() })
        
        print(model.slotIsGrayToday)
        utils.tagDesign(tagControl: cell.txtTags, dataArray : model.slotsToday, backColor: model.slotIsGrayToday, isActionable: false)
        
        let image = model.images[0] as! String
        if image != "" {
            cell.imgList.sd_setImage(with:URL(string:image), placeholderImage:#imageLiteral(resourceName: "ic_listing_default"))
        }else{
            cell.imgList.image = #imageLiteral(resourceName: "ic_listing_default")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let arr:NSMutableArray = NSMutableArray()
        for i in 0...arrData.count-1 {
            let isFavo:Bool = arrforBool.object(at: i) as! Bool
            if isFavo == true{
                arr.add(self.arrData.object(at: i))
            }
        }
        isBack = false
        var model : ListingModel = ListingModel()
        model = arr.object(at: indexPath.row) as! ListingModel
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "ListingDetailsVC") as! ListingDetailsVC
        nextpage.model = model
        nextpage.isToday = true
        nextpage.delegate = self
        nextpage.isFromFavoriteVC = true
        self.navigationController?.pushViewController(nextpage,animated: true)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
extension FavoritesVC:removeFavouriteDelegate{
    func hideRemovedFavorite(isRemoved:Bool, listingId:String){
        
        for i in 0...arrData.count-1  {
            var model : ListingModel = ListingModel()
            model = self.arrData.object(at: i) as! ListingModel
            if model.listingID == listingId{
                arrforBool.insert(isRemoved, at: i)
                
            }
        }
        tblView.reloadData()
    }
}
