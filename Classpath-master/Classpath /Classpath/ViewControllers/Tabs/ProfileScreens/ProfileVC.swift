//
//  ProfileVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/6/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var imgIcons: UIImageView!
    @IBOutlet weak var lblNames:UILabel!
    @IBOutlet weak var viewBg:UIView!
    @IBOutlet weak var badge: BadgeSwift!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBg.layer.shadowOpacity = 1
        viewBg.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewBg.layer.shadowRadius = 4
        viewBg.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
        badge.textColor = UIColor.white
        badge.font = UIFont(name: "SFProText-SemiBold", size: CGFloat(13))
        badge.borderWidth = 0
        badge.insets = CGSize(width: 0, height: 0)
    }
}

class ProfileVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var heightCollectionView: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConst: NSLayoutConstraint!
    @IBOutlet weak var collectionView:UICollectionView!
    
    var ref: DatabaseReference!
    
    var arrProfileOptions = [["Edit Profile":#imageLiteral(resourceName: "profile_edit_profile")], ["Add Listing":#imageLiteral(resourceName: "profile_add_listing")], ["My Services":#imageLiteral(resourceName: "profile_my_services")], ["Conversations":#imageLiteral(resourceName: "profile_conversations")], ["My Items":#imageLiteral(resourceName: "profile_my_listing")], ["Payment":#imageLiteral(resourceName: "profile-payment")], ["Requests":#imageLiteral(resourceName: "profile_registrations")], /*["History":#imageLiteral(resourceName: "profile_history")],*/ ["Favorites":#imageLiteral(resourceName: "profile_favorites")], /*["WorkoutVideo":#imageLiteral(resourceName: "profile_workout_video")], ["Meal Plan":#imageLiteral(resourceName: "profile_meal_plan")],*/ ["Settings":#imageLiteral(resourceName: "profile_settings")]]
    
    var VCOptions = ["EditProfileVC","AddListingVC","MyServiceVC","ConversationsVC","MyListingsVC","PaymentDetailsVC","RegistrationVC",/*"HistoryVC",*/"FavoritesVC",/*"WorkOutVC","MealPlanVC",*/"SettingsVC"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        if screenHeight >= 812 {
            collectionViewTopConst.constant = 45
        }
        snapUtils.currentUserDateFetchFromDB(completionHandler: { isCompleted in
            if snapUtils.currentUserModel.isAdmin {
                self.arrProfileOptions = [["Edit Profile":#imageLiteral(resourceName: "profile_edit_profile")], ["Add Listing":#imageLiteral(resourceName: "profile_add_listing")], ["My Services":#imageLiteral(resourceName: "profile_my_services")], ["Conversations":#imageLiteral(resourceName: "profile_conversations")], ["My Items":#imageLiteral(resourceName: "profile_my_listing")], ["Payment":#imageLiteral(resourceName: "profile-payment")], ["Requests":#imageLiteral(resourceName: "profile_registrations")],/* ["History":#imageLiteral(resourceName: "profile_history")],*/ ["Favorites":#imageLiteral(resourceName: "profile_favorites")], /*["WorkoutVideo":#imageLiteral(resourceName: "profile_workout_video")], ["Meal Plan":#imageLiteral(resourceName: "profile_meal_plan")],*/ ["Settings":#imageLiteral(resourceName: "profile_settings")], ["Manage Account":#imageLiteral(resourceName: "manage_account")]]
                
                self.VCOptions = ["EditProfileVC","AddListingVC","MyServiceVC","ConversationsVC","MyListingsVC","PaymentDetailsVC","RegistrationVC",/*"HistoryVC",*/"FavoritesVC",/*"WorkOutVC","MealPlanVC",*/"SettingsVC","ManageAccountVC"]
            }
            self.collectionView.reloadData()
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        utils.getProfileBadge()
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    @IBAction func onClick_logOut(_ sender: Any) {
        defaults.setValue(0, forKey: keyProfileBadge)
        defaults.setValue(0, forKey: keyPendingBadge)
        let uid = snapUtils.currentUserModel.userId
        snapUtils.currentUserModel = UserDataModel()
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                
                let userInstance = self.ref.child(nodeUsers).child(uid)
                userInstance.updateChildValues([keyFCMToken:""])
                userInstance.updateChildValues([keyDeviceToken:""])
                
                snapUtils.currentUserModel = UserDataModel()
                
                let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let root1ViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                appDelegate.window?.rootViewController = root1ViewController
                appDelegate.window?.makeKeyAndVisible()
                print("User signout successfully")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrProfileOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! ProfileCollectionViewCell
        var dic = [String:UIImage]()
        dic = arrProfileOptions[indexPath.row]
        cell.lblNames.text = ((dic as NSDictionary).allKeys[0] as! NSString) as String
        let imgIcons = (dic as NSDictionary).value(forKey: ((dic as NSDictionary).allKeys[0] as! NSString) as String) as? UIImage
        cell.imgIcons.image = imgIcons?.withRenderingMode(.alwaysTemplate)
//        if indexPath.row == 9 || indexPath.row == 10{
//            cell.imgIcons.tintColor = .lightGray
//        }else {
            cell.imgIcons.tintColor = themeColor
//        }
        cell.badge.isHidden = true
        switch (indexPath.row) {
        case 3:
            if let c = defaults.value(forKey: keyProfileBadge) as? Int {
                if(c > 0){
                    cell.badge.text = "\(c)"
                    cell.badge.isHidden = false
                }else{
                    cell.badge.isHidden = true
                }
            }
            break;
        case 6:
            if let c = defaults.value(forKey: keyPendingBadge) as? Int
            {
                if(c > 0){
                    cell.badge.text = "\(c)"
                    cell.badge.isHidden = false
                }else
                {
                    cell.badge.isHidden = true
                }
            }
            break;
        default:
            break;
        }
        heightCollectionView.constant = collectionView.contentSize.height
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // if indexPath.item != 9 && indexPath.item != 10{
            let storyBoardId = VCOptions[indexPath.row]
            let nextpage = self.storyboard?.instantiateViewController(withIdentifier: storyBoardId)
            self.navigationController?.pushViewController(nextpage!,animated: true)
      //  }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3 - 5, height: collectionView.frame.width/3-5)
    }
}
