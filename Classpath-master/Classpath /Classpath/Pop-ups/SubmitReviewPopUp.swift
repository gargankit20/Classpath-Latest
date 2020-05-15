//
//  SubmitReviewPopUp.swift
//  Classpath
//
//  Created by Coldfin on 21/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase


class SubmitReviewPopUp: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate,NVActivityIndicatorViewable {
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var user_prompt: UIView!
    @IBOutlet weak var lbl_Ratelisting: UILabel!
    @IBOutlet weak var lbl_Recommendlisting: UILabel!
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var limitCount: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var Rate_Recommend: HCSStarRatingView!
    @IBOutlet weak var Rate_listing: HCSStarRatingView!
    
    var ShowPrompt = String()
    var listingid = String()
    var Clientid = String()
    var ref: DatabaseReference!
    var Deletetag = Int()
    var timeframe = ""
    var listName = ""
    var reviewID = ""
    
    var model = BookingModel()
    
    var arr:NSMutableArray = NSMutableArray()
    
    var isUserRating : Bool!
    
    var userName:String!
    
    var senderUserName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        getusername()
        txtComment.delegate = self
        
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = themeColor.cgColor

        
        user_prompt.layer.cornerRadius =  10
        user_prompt.layer.masksToBounds =  true
        
        //KeyBoard Observer
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillShow(_:)),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIResponder.keyboardWillHideNotification,object: nil)
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
    }
    
    //MARK: Textfiled Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text != "" {
            let newLength = textField.text!.count + string.count - range.length
            limitCount.text = "\(newLength)/250"
            return newLength < 250
        }
        return true
    }
    
    //MARK: - KeyBoard Observer Method
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = (keyboardFrame.height - 30) * (show ? 1 : 0)
        topConstraint.constant = -adjustmentHeight
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    @objc func tapView(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: data handling and manipulation methods
    func getusername()  {
        let _ = self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: snapUtils.currentUserModel.userId).observe(.childAdded, with: { snapshot1 in
            if !snapshot1.exists() {return}
            var name = ""
            
            if let defaults = (snapshot1.value as! NSDictionary)[keyUsername] as? String {
                name =  defaults
            }
            
            self.senderUserName = name
            
            self.user_prompt.isHidden = false
            self.getListingData()
            
            
        })
    }
    
    func getListingData() {
        self.ref.child("listings").child(sessionKey).observeSingleEvent(of : .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.Clientid = value![keyUserID] as! String
            let title = value![keyTitle] as! String
            self.lbl_Ratelisting.text = "Rate listing \(title)"
            self.lbl_Recommendlisting.text = "Do you recommend listing \(title)?"
        })
        
        
    }
    
//    func deleteList() {
//        
//        self.ref.child(nodeListingsRegistered).child(DellistingRegister).child(keySelectedSlot).child(keyConfirmed).observe(.value, with: { snapshot in
//            
//            let reviewInstance = self.ref.child(nodeListingsRegistered).child(self.model.listingRegister).child(keySelectedSlot)
//            if !snapshot.exists() {
//                let arr2 = NSMutableDictionary()
//                arr2.setValue([self.model.slot_selected], forKey: self.model.slotDate)
//                reviewInstance.child(keyReviewed).setValue(arr2)
//            }else{
//                var arr2 = NSMutableArray()
//                let arr3 = snapshot.value as! NSMutableDictionary
//                if let k = arr3.value(forKey: self.model.slotDate) as? NSMutableArray
//                {
//                    arr2 = k
//                }
//                arr2.add(self.model.slot_selected)
//                arr3.setValue(arr2, forKey: self.model.slotDate)
//                
//                reviewInstance.child(keyReviewed).setValue(arr3)
//                reviewInstance.child(keyConfirmed).child(self.model.slotDate).removeValue()
//            }
//            
//        })
//    }
    
    
    //MARK: Actions
    @IBAction func onClick_Cancel(_ sender:Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClick_btnSubmit(_ sender: UIButton) {
        if validation() {
             
            self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
            
            let key2 = self.ref.child(nodeReviews).childByAutoId().key
            
            let param1 = NSMutableDictionary()
            param1.setValue(snapUtils.currentUserModel.userId, forKey: keyUserID)
            param1.setValue(self.listingid, forKey: keyListingId)
            param1.setValue(txtComment.text, forKey: keyComment)
            param1.setValue(Rate_Recommend.value, forKey: keyrecommend)
            param1.setValue(Rate_listing.value, forKey: keyStars)
            param1.setValue(NSDate().timeIntervalSince1970, forKey: keyDate)
            
            let reviewInstance1 = self.ref.child(nodeReviews).child(key2!)
            reviewInstance1.updateChildValues(param1 as! [AnyHashable : Any])
            
            let _ = self.ref.child(nodeListings).queryOrderedByKey().queryEqual(toValue: self.listingid).observe(.childAdded, with: { snapshot in
                self.ref.child(nodeListings).queryOrderedByKey().queryEqual(toValue: self.listingid).removeAllObservers()
                var count = 1
                if let defaults = (snapshot.value as! NSDictionary)[keyNoofTimesReviewed] as? Int {
                    count = defaults + 1
                }
                count = 1
                if let defaults = (snapshot.value as! NSDictionary)[keyNoofTimesRecommended] as? Int {
                    count = defaults + 1
                }
                let userInstance = self.ref.child(nodeListings).child(self.listingid)
                userInstance.updateChildValues([keyNoofTimesReviewed : count])
                userInstance.updateChildValues([keyNoofTimesRecommended : count])
                
            })
            let _ = self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: self.Clientid).observe(.childAdded, with: { snapshot in
                self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: self.Clientid).removeAllObservers()
                
                var count = 1
                if let defaults = (snapshot.value as! NSDictionary)[keyNoofTimesUserReviewed] as? Int {
                    count = defaults + 1
                }
                let userInstance = self.ref.child(nodeUsers).child(self.Clientid)
                userInstance.updateChildValues([keyNoofTimesUserReviewed : count])
                
            })
//            snapUtils.SendNotification(receiverId: self.Clientid, message: "\(self.senderUserName) has reviewed your listing named \(listName)", timeStamp: NSDate().timeIntervalSince1970, listingId: "")
//            deleteList()
            self.stopAnimating()
            self.dismiss(animated: false, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name("submitReview"), object: nil)
        }
    }

    func validation() -> Bool
    {
        if(txtComment.text == "")
        {
            utils.emptyFieldValidation(txtComment, view: self.view, tag: txtComment.tag+11)
            let custAlert = customAlertView(title: "Message", message: "Empty required field!", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        if(Rate_listing.value == 0.0 || Rate_Recommend.value == 0.0)
        {
            let custAlert = customAlertView(title: "Message", message: "Minimum rating value is 1.", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        return true
    }
    
}
