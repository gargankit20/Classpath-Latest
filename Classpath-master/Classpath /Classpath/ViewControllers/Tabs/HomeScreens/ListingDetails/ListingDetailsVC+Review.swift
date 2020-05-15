//
//  ListingDetailsVC+Review.swift
//  Classpath
//
//  Created by coldfin_lb on 8/13/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

class ReviewTableViewCell : UITableViewCell {
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblReview:UILabel!
}

extension ListingDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Api Call for reviews
    func getreviews(){
        overallReviewDetail()
        arrData  = NSMutableArray()
      //   
     //   self.startAnimating(size, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        let _ = ref.child(nodeReviews).queryOrdered(byChild: keyListingId).queryEqual(toValue: model.listingID).observe(.value, with: { snapshot in
            self.ref.child(nodeReviews).queryOrdered(byChild: keyListingId).queryEqual(toValue: self.model.listingID).removeAllObservers()
            if snapshot.exists() {
                self.parseSnapShot(snapshot: snapshot)
            }else{
                self.reviewTableView.reloadData()
                self.stopAnimating()
            }
        })
    }
    
    func overallReviewDetail(){
        lblTotalReview.text = "\(utils.formatPoints(num: model.star))"
        viewRatingsOverAll.value = CGFloat(model.star)
        lblReviewsCount.text = "\(model.reviewCount) Reviews"
        if lblTotalReview.text == "0.0"{
            lblTotalReview.text = "N/A"
            lblReviewsCount.text = ""
        }
    }
    
    func parseSnapShot(snapshot : DataSnapshot)
    {
        var count:Int = 0
        
        for child in snapshot.children {
            let model = ReviewModel()
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyStars] as? CGFloat {
                model.stars = defaults
                let index = defaults-1
                var starCount = arrReviewcount.object(at: Int(index)) as! Int
                starCount += 1
                arrReviewcount.replaceObject(at: Int(index), with: starCount)
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyComment] as? String {
                model.comment = defaults
            }
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyUserID] as? String {
                model.userId = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyDate] as? Double {
                
                let k : NSDate = NSDate(timeIntervalSince1970: TimeInterval(defaults))
                let str1 = utils.getPostTime(k as Date).0
                let str2 = utils.getPostTime(k as Date).1
                if str2 == "year" || str2 == "month" || str2 == "day" {
                    if str2 == "day" {
                        let arr = str1.components(separatedBy: " ")
                        if Int(arr[0])! > 7 {
                            model.date = "\(utils.convertDateToString(k as Date, format: "dd MMM yy"))"
                        }else{
                            model.date = "\(str1)"
                        }
                    }else {
                        model.date = "\(utils.convertDateToString(k as Date, format: "dd MMM yy"))"
                    }
                }
                else{
                    model.date = utils.getPostTime(k as Date).0
                }
            }
            
            let _ = self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: model.userId).observe(.childAdded, with: { snapshot1 in
                if !snapshot1.exists() {return}
                var name = ""
                
                if let defaults = (snapshot1.value as! NSDictionary)[keyUsername] as? String {
                    name =  name + defaults
                }
                
                if let defaults = (snapshot1.value as! NSDictionary)[keyProfilePic] as? String {
                    model.profileImage = defaults
                }
                
                model.userName = name
                self.arrData.add(model)
                if count == snapshot.childrenCount-1{
                    self.stopAnimating()
                    self.updateIndividualStarRating()
                    self.reviewTableView.reloadData()
                    self.reviewTableView.layoutIfNeeded()
                    self.reviewTableView.heightAnchor.constraint(equalToConstant: self.reviewTableView.contentSize.height).isActive = true
                }
                count += 1
            })
        }
    }
    func updateIndividualStarRating(){
        var count = 16
        if model.reviewCount != 0 {
            for i in arrReviewcount{
                if let progressView = self.view.viewWithTag(count) as? UIProgressView {
                    let percentage = ((i as! Float) / Float(model.reviewCount))
                    progressView.progress = percentage;
                    progressView.trackTintColor = .clear
                    progressView.backgroundColor = .white
                    progressView.progressTintColor = UIColor(hex: 0xFFD55A)
                    progressView.progressViewStyle = .bar
                }
                count += 1
            }
        }
    }
    
    //MARK: TableView Delegate & Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrData.count == 0{
            viewDefault.isHidden = false
        }else{
            viewDefault.isHidden = true
        }
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
        var model:ReviewModel = ReviewModel()
        model = arrData.object(at: indexPath.row) as! ReviewModel
        cell.lblReview.text = model.comment
        cell.lblDate.text = model.date
        cell.lblName.text = model.userName
        if(model.profileImage != "")
        {
            let storageRef=Storage.storage().reference(forURL:model.profileImage as String)
            cell.profileImage.sd_setImage(with:storageRef, placeholderImage:#imageLiteral(resourceName: "ic_profile_default"))
        }
        return cell
    }
}
