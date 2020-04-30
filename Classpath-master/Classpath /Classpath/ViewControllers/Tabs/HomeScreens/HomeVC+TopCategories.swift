//
//  Home+TopCategories.swift
//  Classpath
//
//  Created by coldfin_lb on 8/3/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgCategory:UIImageView!
    @IBOutlet weak var lblCategory:UILabel!
    @IBOutlet weak var lblListingCount:UILabel!
    @IBOutlet weak var viewBorder:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgCategory.layer.borderWidth = 2
        imgCategory.layer.borderColor = UIColor.white.cgColor
    }
}

extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if utils.userForCategory != "" {
            return arrCategory.count+1
        }
        return arrCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        if(indexPath.row == arrCategory.count) {
            cell.lblCategory.text = utils.userListingData["0"] as? String
            cell.imgCategory.image = utils.userListingData["profilePic"] as? UIImage
            cell.lblListingCount.text = "\(arrData.count) Listing"
        }else {
            var dic = [String:UIImage]()
            dic = mainArray.object(at: indexPath.row) as! [String:UIImage]
            cell.lblCategory.text = ((dic as NSDictionary).allKeys[0] as! NSString) as String
            cell.imgCategory.image = (dic as NSDictionary).value(forKey: ((dic as NSDictionary).allKeys[0] as! NSString) as String) as? UIImage
            cell.lblListingCount.text = ""
            
            if let c = self.noOfListing.value(forKey: "\((dic as NSDictionary).allKeys[0] as! NSString)") as? Int
            {
                cell.lblListingCount.text = "\(c)" + " Listings"
            }else{
                cell.lblListingCount.text = "0 Listing"
            }
        }
        if selected_index == indexPath.row{
            cell.viewBorder.backgroundColor = themeColor
        }else{
            cell.viewBorder.backgroundColor = .white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected_index = indexPath.row
//        arrData = NSMutableArray()
//        tableView.reloadData()
//
//        startAnimating(size, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        if indexPath.row != arrCategory.count {
            utils.userForCategory = ""
            self.topCollectionView.reloadData()
        }
        if indexPath.row != mainArray.count {
            tableView.isUserInteractionEnabled = false
            lblLoading.isHidden = false
            var dic = [String:UIImage]()
            dic = mainArray.object(at: indexPath.row) as! [String:UIImage]
            let category = (dic as NSDictionary).allKeys[0] as! NSString as String
            if category == "Promoted Listings" {
                self.callShowAll(selected_category: category)
                btnFilter.isHidden = false
            }else{
                self.callforSpecifCategory(selected_category : category)
                btnFilter.isHidden = true
                self.arrfilterCategories.removeAllObjects()
            }
            utils.home_category_select = category
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 1 {
            return CGSize(width: 105, height: 130)
        }else{
            return CGSize(width: 100, height: 130)
        }
    }
    
   
}
