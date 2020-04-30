//
//  HomeVC+Listings.swift
//  Classpath
//
//  Created by coldfin_lb on 8/3/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseUI

class ListingTableViewCell: UITableViewCell {
    @IBOutlet weak var imgList: UIImageView!
    @IBOutlet weak var lblListName: UILabel!
    @IBOutlet weak var viewRating: HCSStarRatingView!
  //  @IBOutlet weak var viewNoOfRatings: UILabel!
    @IBOutlet weak var btnDistance: UIButton!
    @IBOutlet weak var txtTags: UIScrollView!
    @IBOutlet weak var lblListingOwner: UILabel!
 //   @IBOutlet weak var btnReview: UIButton!
    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var lblPromote: UILabel!
    
    override func awakeFromNib() {
        if lblPromote != nil {
            lblPromote.clipsToBounds = true
            lblPromote.layer.cornerRadius = 5
            lblPromote.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
}

extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrData.count == 0 {
            viewDefault.isHidden = false
        }else{
            viewDefault.isHidden = true
        }
        updateViewConstraint()
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath) as! ListingTableViewCell
        cell.selectionStyle = .none
        if arrData.count != 0{
            var model : ListingModel = ListingModel()
            model = arrData.object(at: indexPath.row) as! ListingModel
            
            cell.lblListName.text = model.title
            cell.lblListingOwner.text = model.userName
            
            cell.btnDistance.setTitle(" \(model.distance.rounded(toPlaces: 1)) mi", for: .normal)
            if model.star != 0.0 {
                cell.viewRating.value = CGFloat(model.star)
            }else{
                cell.viewRating.value = 0
            }
            cell.btnUserProfile.tag = indexPath.row
            cell.btnUserProfile.addTarget(self, action:#selector(onClick_ListingScreen(_:)), for: .touchUpInside)
            
            cell.txtTags.subviews.forEach({ $0.removeFromSuperview() })
            if(btnToday.isSelected)
            {
                utils.tagDesign(tagControl: cell.txtTags, dataArray : model.availableslotsToday, backColor: model.slotIsGrayToday, isActionable: false)
            }else
            {
                utils.tagDesign(tagControl: cell.txtTags, dataArray : model.availableslotsTomorrow, backColor: model.slotIsGrayTomorrow, isActionable: false)
            }
            let image = model.images[0] as! String
            if image != "" {
                cell.imgList.sd_setImage(with:URL(string:image), placeholderImage:#imageLiteral(resourceName: "ic_listing_default"))
            }else{
                cell.imgList.image = #imageLiteral(resourceName: "ic_listing_default")
            }
            if utils.home_category_select == "Promoted Listings" {
                cell.lblPromote.isHidden = false
            }else {
                cell.lblPromote.isHidden = true
            }
        }
        return cell
    }
 
    
    func updateViewConstraint(){
        tableHeightConstraint.constant = CGFloat(arrData.count*110)
    }
    @objc func onClick_ListingScreen(_ sender: UIButton){
        if arrData.count != 0 {
            var model : ListingModel = ListingModel()
            model = arrData.object(at: sender.tag) as! ListingModel
            let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "ListingDetailsVC") as! ListingDetailsVC
            nextPage.model = ListingModel()
            nextPage.model = model
            nextPage.isToday = btnToday.isSelected
          // self.navigationController?.pushViewController(nextPage, animated: true)
            nextPage.isFromHome = true
            self.present(nextPage, animated: true, completion: nil)
            
        
        }
    }
//    @objc func onClick_UserProfile(_ sender: UIButton){
//        if arrData.count != 0 {
//            var model : ListingModel = ListingModel()
//            model = arrData.object(at: sender.tag) as! ListingModel
//            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let nextpage = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
//            nextpage.userID = model.userid
//            self.navigationController?.pushViewController(nextpage,animated: true)
//        }
//    }
}
