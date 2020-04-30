//
//  ConversationsVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/8/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseUI

class ConversationTableViewCell:UITableViewCell {
    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLastMessage: UILabel!
    @IBOutlet weak var badge: BadgeSwift!
    override func awakeFromNib() {
        badge.textColor = UIColor.white
        badge.font = UIFont(name: "SFProText-SemiBold", size: CGFloat(13))
        badge.borderWidth = 0
        badge.insets = CGSize(width: 0, height: 0)
        imgProfilePic.layer.cornerRadius = imgProfilePic.frame.height/2
        imgProfilePic.layer.masksToBounds = true
        // Initialization code
    }
}

class ConversationsVC: UIViewController,NVActivityIndicatorViewable {
    
    @IBOutlet weak var tblView: UITableView!
    var mainArray = NSMutableArray()
    var ref: DatabaseReference!
    @IBOutlet weak var viewDefault: UIView!
    var custAlert = customAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.tableFooterView = UIView(frame: CGRect.zero)
        if snapUtils.currentUserModel.Verification != "true"{
            let v = UIView()
            custAlert = customAlertView.init(title: "Message", message: "Phone verification required. Would you like to proceed?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = { (Value: String) in
                
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextpage = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                let nav = UINavigationController(rootViewController: nextpage)
                self.present(nav, animated: true, completion: nil)
            }
            custAlert.onLeftBtnSelected = { (Value: String) in
                self.custAlert.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
            custAlert.show(animated: true)
            return
        }
        
        ref = Database.database().reference()
        tblView.delegate = self
        tblView.dataSource = self
        tblView.rowHeight = UITableView.automaticDimension
        tblView.tableFooterView = UIView(frame: CGRect.zero)
        getConversations()
        defaults.setValue(0, forKey: keyProfileBadge)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if snapUtils.currentUserModel.Verification == "true"{
            custAlert.dismiss(animated: true)
        }
        if( self.mainArray.count > 0)
        {
            self.sortingDateinDescendingOrder()
        }
    }
    
    func getConversations(){
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
         
        startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        ref.child(nodeUserChats).child(uid).observe(.value, with: { (snapshot) in
            if !(snapshot.exists()){
                self.stopAnimating()
                self.viewDefault.isHidden = false
                return
            }
            self.viewDefault.isHidden = true
            var chatIds = NSArray()
            if let defaults = (snapshot.value as! NSDictionary)[keyChatID] as? NSArray {
                chatIds = defaults
            }
            var count:Int = 0
            self.mainArray.removeAllObjects()
            for i  in chatIds{
                let oponent_id = ((i as! String).replace(target: uid, withString: "")).replace(target: "-", withString: "")
                let model = conversationModel()
                model.chatID  = "\(i)"
                
                let _ = self.ref.child(nodeChatMessages).child(i as! String).observe(.value, with: { snapshot2 in
                    var count = 0
                    for j in snapshot2.children{
                        if let defaults = ((j as! DataSnapshot).value as! NSDictionary)[keyMessage] as? String{
                            model.lastMessage = defaults
                            
                        }
                        
                        if let defaults = ((j as! DataSnapshot).value as! NSDictionary)[keyTimeStamp] as? Double{
                            model.lastmsgTime = defaults
                            let date : NSDate = NSDate(timeIntervalSince1970: TimeInterval(defaults))
                            model.date_Time = utils.convertDateToString(date as Date, format: "yyyy-MM-dd HH:mm:ss")
                            if count  == snapshot2.childrenCount-1{
                                print(model.lastMessage,model.date_Time)
                            }
                            count += 1
                        }
                        if let defaults = ((j as! DataSnapshot).value as! NSDictionary)[keyListingId] as? String
                        {
                            model.listingId = defaults
                            
                        }
                        if( self.mainArray.count > 0)
                        {
                            self.sortingDateinDescendingOrder()
                        }
                    }
                })
                
                let _ = self.ref.child(nodeChatMessages).child(i as! String).queryOrdered(byChild: keyViewFlag).queryEqual(toValue: false).observe(.value, with: { snapshot2 in
                    var c = 0
                    for j in snapshot2.children
                    {
                        if let defaults = ((j as! DataSnapshot).value as! NSDictionary)[keySentBy] as? String {
                            if(defaults == oponent_id)
                            {
                                c += 1
                            }
                        }
                    }
                    
                    if let foo = self.mainArray.first(where: {($0 as! conversationModel).UserId == oponent_id}) {
                        (foo as! conversationModel).Unread = "\(c)"
                        
                        if( self.mainArray.count > 0)
                        {
                            self.sortingDateinDescendingOrder()
                        }
                    }else
                    {
                        model.Unread = "\(c)"
                        if( self.mainArray.count > 0)
                        {
                            self.sortingDateinDescendingOrder()
                        }
                    }
                })
                
                model.UserId = oponent_id
                let _ = self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: oponent_id).observe(.childAdded, with: { snapshot in
                    if !snapshot.exists() {return}
                    var name = ""
                    
                    if let defaults = (snapshot.value as! NSDictionary)[keyUsername] as? String {
                        name =   defaults
                    }
                    
                    if let defaults = (snapshot.value as! NSDictionary)[keyProfilePic] as? String {
                        model.oponentPic = defaults
                    }
                    
                    model.UserName = name
                    self.mainArray.add(model)
                    
                    
                    if count == chatIds.count-1 {
                        // self.tblView.reloadData()
                        self.sortingDateinDescendingOrder()
                        self.stopAnimating()
                    }
                    count += 1
                })
            }
        })
    }
    
    func sortingDateinDescendingOrder() {
        let sortedArray = self.mainArray.sorted{ ($0 as! conversationModel).date_Time.compare(($1 as! conversationModel).date_Time) == .orderedDescending}
        
        let arr : NSArray = sortedArray as NSArray
        self.mainArray = arr.mutableCopy() as! NSMutableArray
        
        self.tblView.reloadData()
        
    }
}
extension  ConversationsVC : UITableViewDelegate, UITableViewDataSource
{
    //MARK: UITableView Delegate & Data Source
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationTableViewCell
        var userObj : conversationModel = conversationModel()
        userObj = mainArray.object(at: indexPath.row) as! conversationModel
        
        var lblTimeText = ""
        let date : NSDate = NSDate(timeIntervalSince1970: TimeInterval(userObj.lastmsgTime))
        let str1 = utils.getPostTime(date as Date).0
        let str2 = utils.getPostTime(date as Date).1
        if str2 == "year" || str2 == "month" || str2 == "day" {
            if str2 == "day" {
                let arr = str1.components(separatedBy: " ")
                if Int(arr[0])! > 7 {
                    lblTimeText = "\(utils.convertDateToString(date as Date, format: "dd MMM yy"))"
                }else{
                    lblTimeText = "\(str1)"
                }
            }else{
                lblTimeText = "\(utils.convertDateToString(date as Date, format: "dd MMM yy"))"
            }
        }
        else{
            lblTimeText = utils.getPostTime(date as Date).0
        }
        
        if(userObj.oponentPic != "")
        {
            cell.imgProfilePic.sd_setImage(with:URL(string:userObj.oponentPic), placeholderImage:#imageLiteral(resourceName: "ic_profile_default"))
        }else{
            cell.imgProfilePic.image = #imageLiteral(resourceName: "ic_profile_default")
        }
        cell.lblTime.text = lblTimeText
        cell.lblName.text = "\(userObj.UserName!)"
        cell.lblLastMessage.text = "\(userObj.lastMessage)"
        if(userObj.Unread != "0")
        {
            cell.badge.isHidden = false
            cell.badge.text = userObj.Unread
            cell.backgroundColor = UIColor(red:0.32, green:0.71, blue:0.72, alpha:0.05)
        }else{
            cell.badge.isHidden = true
            cell.backgroundColor = .white
        }
        cell.btnUserProfile.tag = indexPath.row
        cell.btnUserProfile.addTarget(self, action: #selector(onClick_UserProfile(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var userObj : conversationModel = conversationModel()
        userObj = mainArray.object(at: indexPath.row) as! conversationModel
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "ChattingsVC") as! ChattingsVC
        nextpage.UserName = userObj.UserName
        nextpage.ReceiverUserid = userObj.UserId
        nextpage.OponentImage = userObj.oponentPic
        nextpage.isfromConversatin = true
        nextpage.CurrentchatID = userObj.chatID
        nextpage.userObj = userObj
        nextpage.index1 = indexPath.row
        self.navigationController?.pushViewController(nextpage,animated: true)
    }
    
    @objc func onClick_UserProfile(sender:UIButton){
        var userObj : conversationModel = conversationModel()
        userObj = mainArray.object(at: sender.tag) as! conversationModel
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        nextpage.userID = userObj.UserId
        nextpage.isShowBar = true
        self.present(nextpage, animated: true, completion: nil)
    }
    
    
}
