//
//  UserProfileVC.swift
//  Classpath
//
//  Created by Coldfin on 22/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

class BagdeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bagde_image: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
}

class UserProfileVC: UIViewController {

    @IBOutlet weak var cover_image: UIImageView!
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var lblName: UITextField!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblJoinedDate: UILabel!
    @IBOutlet weak var lblConnected: UILabel!
    @IBOutlet weak var imgConnectedBy: UIImageView!
    @IBOutlet weak var constBarSize: NSLayoutConstraint!
    @IBOutlet weak var btnListingCount: UIButton!
    @IBOutlet weak var btnWorkoutCount: UIButton!
    @IBOutlet weak var levelIndicator: UIView!
    @IBOutlet weak var constLevelFill: NSLayoutConstraint!
    @IBOutlet weak var level1: UIView!
    @IBOutlet weak var collView:UICollectionView!
    
    var ref : DatabaseReference!
    var isShowBar = false
    var isReported = false
    var userID = ""
    
    let arrBagde = ["Athlete":#imageLiteral(resourceName: "001-runner"),"Pro Trainer":#imageLiteral(resourceName: "002-trophy"),"Master Trainer":#imageLiteral(resourceName: "004-music-and-multimedia"),"World Class Trainer":#imageLiteral(resourceName: "medal")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        if isShowBar {
            if screenHeight >= 812{
                constBarSize.constant = 88
            }else{
                constBarSize.constant = 64
            }
        }else{
            constBarSize.constant = 0
        }
        
        btnListingCount.setRadiusWithShadow()
        btnWorkoutCount.setRadiusWithShadow()
    
        
        levelIndicator.layer.shadowOffset = CGSize(width: 0, height: 2)
        levelIndicator.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
        levelIndicator.layer.shadowOpacity = 1
        levelIndicator.layer.shadowRadius = 4
        levelIndicator.layer.masksToBounds = false
        
        profile_image.addBorderToView(color: .white, thickness: 3.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setData(_:)), name: NSNotification.Name(rawValue: "userDataFetch"), object: nil)
        
        
        updateOwnerBadge(userid:userID)
       
    }
    
    func updateOwnerBadge(userid:String) {
        let userRef = self.ref.child(nodeListings).queryOrdered(byChild: keyUserID).queryEqual(toValue: userid)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists(){
                var noOfReg = 0
                for child in snapshot.children {
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyNoofRegister] as? Int{
                        noOfReg += defaults
                    }
                }
                if noOfReg >= 1500{
                    let arr = ["Athlete","Pro Trainer","Master Trainer","World Class Trainer"]
                    self.ref.child(nodeUsers).child(userid).updateChildValues([keyBadges:arr])
                }else if noOfReg >= 1000{
                    let arr = ["Athlete","Pro Trainer","Master Trainer"]
                    self.ref.child(nodeUsers).child(userid).updateChildValues([keyBadges:arr])
                }
            }
            snapUtils.userDateFetchFromDB(userid: self.userID, notiName:"userDataFetch")
        }
    }
    
    @objc func setData(_ notification: NSNotification){
        
        self.view.layoutIfNeeded()
        if(snapUtils.userModel.profilePic != "")
        {
            profile_image.sd_setImage(with:URL(string:snapUtils.userModel.profilePic), placeholderImage:#imageLiteral(resourceName: "ic_profile_default"))
        }
        if(snapUtils.userModel.coverPic != "")
        {
            cover_image.sd_setImage(with:URL(string:snapUtils.userModel.coverPic), placeholderImage:#imageLiteral(resourceName: "ic_cover_default"))
        }
        if snapUtils.userModel.Verification != ""{
               self.lblPhone.text = "Phone Verified"
        }else {
            self.lblPhone.text = "Phone Unverified"
        }
        
        self.btnListingCount.setTitle("\(snapUtils.userModel.listingCount)", for: .normal)
        self.btnWorkoutCount.setTitle("\(snapUtils.userModel.workoutPlanCount)", for: .normal)
        
        self.btnListingCount.isEnabled = snapUtils.userModel.listingCount == 0 ? false : true
        self.btnWorkoutCount.isEnabled = snapUtils.userModel.workoutPlanCount == 0 ? false : true
        
        
        let badgeCount = snapUtils.userModel.badges.count
        constLevelFill.constant = (level1.frame.width * CGFloat(badgeCount)) + 3
        
        self.lblName.text = snapUtils.userModel.userName
       
        let arrDate = snapUtils.userModel.joinDate.components(separatedBy: " ")
        self.lblJoinedDate.text = "Joined on \(arrDate[0])"
        
        self.lblConnected.text = "Connected by \(snapUtils.userModel.connectedBy)"
        
        if snapUtils.userModel.connectedBy == "Twitter"{
            self.imgConnectedBy.image = #imageLiteral(resourceName: "ic_tw_share")
        }else if snapUtils.userModel.connectedBy == "Facebook"{
            self.imgConnectedBy.image = #imageLiteral(resourceName: "ic_fb_share")
        }else if snapUtils.userModel.connectedBy == "Google"{
            self.imgConnectedBy.image = #imageLiteral(resourceName: "ic_google")
        }else if snapUtils.userModel.connectedBy == "Instagram"{
            self.imgConnectedBy.image = #imageLiteral(resourceName: "ic_ig_share")
        }else{
            self.imgConnectedBy.image = #imageLiteral(resourceName: "ic_logo")
            self.lblConnected.text = "Classpath Registered"
        }
        checkThisListingisReported()
        
        collView.reloadData()
    }
    
    func checkThisListingisReported(){
        ref.child(nodeUserReports).queryOrdered(byChild: keyReportedBy).queryEqual(toValue: snapUtils.currentUserModel.userId).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children {
                    if let userid = ((child as! DataSnapshot).value as! NSDictionary)[keyReportedTo] as? String{
                        if userid  == snapUtils.userModel.userId {
                            self.isReported = true
                            return
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func onClick_btnReport(_ sender: Any) {
        var message = ""
        if(self.userID == snapUtils.currentUserModel.userId) {
            message = "You can't report yourself"
        }else if self.isReported {
            message = "You've already reported this user"
        }else {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let modalViewController = storyboard.instantiateViewController(withIdentifier: "ReportViewPopUp") as! ReportViewPopUp
            modalViewController.modalPresentationStyle = .overCurrentContext
            modalViewController.modalTransitionStyle = .crossDissolve
            modalViewController.type = "User"
            modalViewController.user_model = snapUtils.userModel
            self.present(modalViewController, animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            alert.dismiss(animated: true, completion: {() -> Void in
            })
        })
    }
    
    @IBAction func onClick_btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClick_btnListingCount(_ sender: Any) {
        if let tabBarController = self.view.window?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 0
        }
        utils.userListingData["username"] = snapUtils.userModel.userName
        utils.userListingData["profilePic"] = self.profile_image.image
        
        utils.userForCategory = self.userID
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClick_btnWorkoutCount(_ sender: Any) {
        if let tabBarController = self.view.window?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 1
        }
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

extension UserProfileVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snapUtils.userModel.badges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "badgeCell", for: indexPath) as! BagdeCollectionViewCell
        
        let keyBadgeName = snapUtils.userModel.badges[indexPath.row] as! String
        cell.bagde_image.image = arrBagde[keyBadgeName]
        cell.lblTitle.text = keyBadgeName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
}
