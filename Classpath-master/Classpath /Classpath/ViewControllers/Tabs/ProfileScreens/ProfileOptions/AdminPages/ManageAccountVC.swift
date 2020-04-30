//
//  ManageAccountVC.swift
//  Classpath
//
//  Created by Coldfin on 9/11/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

class ManageAccountCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTo: UILabel!
    @IBOutlet weak var lblBy: UILabel!
}

class ManageAccountVC: UIViewController,UITableViewDelegate,UITableViewDataSource,NVActivityIndicatorViewable,reportDeleteDelegate {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var btnListing: UIButton!
    @IBOutlet weak var leadingSelection: NSLayoutConstraint!
    @IBOutlet weak var viewDefault: UIView!
    var arrListingData:NSMutableArray = NSMutableArray()
    
    var ref = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.tableFooterView = UIView()
        tblView.rowHeight = 110
        callUserReportList()
    }
    
    @IBAction func onClick_Section(_ sender:UIButton){
        btnUser.setTitleColor(textThemeColor, for: .normal)
        btnListing.setTitleColor(textThemeColor, for: .normal)
        sender.setTitleColor(themeColor, for: .normal)
        leadingSelection.constant = sender.frame.origin.x
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        if leadingSelection.constant == 24{
            callUserReportList()
        }else{
            callListingReportList()
        }
    }

    func callUserReportList() {
         
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        let _ = ref.child(nodeUserReports).queryOrdered(byChild: keyReportedBy).observe(.value, with: { snapshot in
            self.ref.child(nodeUserReports).queryOrdered(byChild: keyReportedBy).removeAllObservers()
            self.arrListingData = NSMutableArray()
            if !snapshot.exists() {
                self.tblView.reloadData()
                self.stopAnimating()
                return
            }
            self.parseSnapShotForUser(snapshotUser: snapshot)
        })
    }
    
    func callListingReportList() {
         
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        let _ = ref.child(nodeListingReports).queryOrdered(byChild: keyUserID).observe(.value, with: { snapshot in
            self.ref.child(nodeListingReports).queryOrdered(byChild: keyUserID).removeAllObservers()
            self.arrListingData = NSMutableArray()
            if !snapshot.exists() {
                self.tblView.reloadData()
                self.stopAnimating()
                return
                
            }
            self.parseSnapShotForListing(snapshotList: snapshot)
        })
    }
    
    func parseSnapShotForListing(snapshotList : DataSnapshot)
    {
        for child in snapshotList.children {
            let model =  ReportModel()
            
            model.reportL_Id = (child as! DataSnapshot).key
            
            model.r_listingId = ""
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyListingId] as? String {
                model.r_listingId = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyDate] as? String {
                model.date = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyReportDesc] as? String {
                model.desc = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyReportType] as? String {
                model.type = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRBUsername] as? String {
                model.rBy_username = defaults
            }
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRBEmail] as? String {
                model.rBy_emailId = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRLTitle] as? String {
                model.rl_title = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyImages] as? NSArray {
                model.rl_images = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRLUsername] as? String {
                model.rl_username = defaults
            }
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRLEmail] as? String {
                model.rl_emailId = defaults
            }
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyReportedTo] as? String {
                model.r_UserId = defaults
            }
            
            self.arrListingData.add(model)
            self.tblView.reloadData()
            self.stopAnimating()
        }
    }
    
    func parseSnapShotForUser(snapshotUser : DataSnapshot)
    {
        for child in snapshotUser.children {
            let model =  ReportModel()
            
            model.reportU_Id = (child as! DataSnapshot).key
            
            model.r_UserId = ""
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyReportedTo] as? String {
                model.r_UserId = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyDate] as? String {
                model.date = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyReportDesc] as? String {
                model.desc = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyReportType] as? String {
                model.type = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRBUsername] as? String {
                model.rBy_username = defaults
            }
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRBEmail] as? String {
                model.rBy_emailId = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRLUsername] as? String {
                model.rl_username = defaults
            }
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyProfilePic] as? String {
                model.profileImage = defaults
            }
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyRLEmail] as? String {
                model.rl_emailId = defaults
            }
            
            self.arrListingData.add(model)
            self.tblView.reloadData()
            self.stopAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrListingData.count == 0{
            viewDefault.isHidden = false
        }else
        {
            viewDefault.isHidden = true
        }
        return arrListingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "manageCell", for: indexPath) as! ManageAccountCell
        
        var model : ReportModel = ReportModel()
        model = arrListingData.object(at: indexPath.row) as! ReportModel
        
        var imageString = ""
        var placeHolder = UIImage()
        if leadingSelection.constant == 24 {
            cell.lblTitle.text = "Reported to : \(model.rl_username)"
            cell.lblTo.text = "Reported by: \(model.rBy_username)"
            cell.lblBy.isHidden = true
            imageString = model.profileImage
            placeHolder = #imageLiteral(resourceName: "ic_profile_default")
        }else{
            cell.lblTitle.text = "Listing Title : \(model.rl_title)"
            cell.lblTo.text = "Owner name : \(model.rl_username)"
            cell.lblBy.text = "Reported by: \(model.rBy_username)"
            cell.lblBy.isHidden = false
            imageString = model.rl_images[0] as! String
            placeHolder = #imageLiteral(resourceName: "ic_listing_default")
        }
        
        if imageString != ""{
            cell.imgView.sd_setImage(with:URL(string:imageString), placeholderImage:placeHolder)
        }else {
           cell.imgView.image = placeHolder
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var model : ReportModel = ReportModel()
        model = arrListingData.object(at: indexPath.row) as! ReportModel
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextPage = storyboard.instantiateViewController(withIdentifier: "ReportDetailVC") as! ReportDetailVC
        nextPage.model = model
        nextPage.module = "Listing"
        if leadingSelection.constant == 24{
            nextPage.module = "User"
        }
        nextPage.tblIndex = indexPath.row
        nextPage.delegate = self
        self.navigationController?.pushViewController(nextPage, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Disregard") {  action, indexPath in
            var model : ReportModel = ReportModel()
            model = self.arrListingData.object(at: indexPath.row) as! ReportModel
            
            let v = UIView()
            let custAlert = customAlertView(title: "Message", message: "Are you sure you want to delete this report? You can find this report in the register email account even after deleting.", customView: v, leftBtnTitle: "NO", rightBtnTitle: "YES", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = {(Value:String) in
                custAlert.dismiss(animated: true)
                if self.leadingSelection.constant == 24{
                    self.ref.child(nodeUserReports).child(model.reportU_Id).removeValue()
                    self.stopAnimating()
                }else{
                    self.ref.child(nodeListingReports).child(model.reportL_Id).removeValue()
                    self.stopAnimating()
                }
                self.stopAnimating()
                let alert = UIAlertController(title: "", message: "Report disregarded!", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                let when = DispatchTime.now() + 2.5
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                }
                
                self.arrListingData.removeObject(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
            custAlert.show(animated: true)
    
        }
        return [delete]
    }
    //MARK:- Report delete Delegate
    func reportDeleted(index: Int) {
        let indexPath:IndexPath = IndexPath(row: index, section: 0)
        self.arrListingData.removeObject(at: index)
        tblView.deleteRows(at: [indexPath], with: .left)
    }
    
}
