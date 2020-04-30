//
//  EditProfileVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/6/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation
import FirebaseStorage
import FirebaseUI

class EditProfileVC: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate,NVActivityIndicatorViewable,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var cover_image: UIImageView!
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtAddress: AutoCompleteTextField!
    @IBOutlet weak var txtPhoneNo: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblJoinDate: UILabel!
    @IBOutlet weak var lblConnectedBy: UILabel!
    @IBOutlet weak var imgConnectedBy: UIImageView!
    @IBOutlet weak var viewProfile:UIView!
    @IBOutlet weak var btnProfileEdit:UIButton!
    @IBOutlet weak var srView:UIScrollView!
    @IBOutlet weak var constDeleteAccount: NSLayoutConstraint!
    //@IBOutlet weak var btnDeleteAccount: UIButton!
    
    let picker = UIImagePickerController()
    var popOver: UIPopoverController!
    var isProfilePic = true
    
    var locationCoordinate : CLLocationCoordinate2D!
    
    var dateSelected = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    
     var ref: DatabaseReference!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        NotificationCenter.default.addObserver(self, selector: #selector(self.contactNumberVerified), name: NSNotification.Name(rawValue: "numberVerified"), object: nil)
        
        //        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        //        snapUtils.currentUserDateFetchFromDB(completionHandler: { isCompleted in
        //            self.stopAnimating()
        if snapUtils.currentUserModel.isAdmin {
            self.constDeleteAccount.constant = 0
            //self.btnDeleteAccount.isHidden = true
        }else {
            self.constDeleteAccount.constant = 30
            //self.btnDeleteAccount.isHidden = false
        }
        
        self.setDesign()
        self.setData()
        
        if self == navigationController?.viewControllers[0]  {
            let button =  UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
            button.setTitleColor(themeColor, for: .normal)
            button.titleLabel?.font =  UIFont(name: "SFProText-SemiBold", size: 17)
            button.backgroundColor = .clear
            button.setTitle("Edit Profile", for: .normal)
            self.navigationItem.titleView = button
            
            let backBarButton = UIBarButtonItem(image: UIImage(named: "ic_back_white"), style: .plain, target: self, action: #selector(self.clickonBack))
            backBarButton.tintColor = themeColor
            self.navigationItem.leftBarButtonItem = backBarButton
            self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "SFProText-SemiBold", size: 17)!,NSAttributedString.Key.foregroundColor: themeColor]
            self.navigationController?.navigationBar.tintColor = UIColor(hex: 0xF8F8F8)
            self.navigationController?.navigationBar.isTranslucent = false
        }
        //        })
    }
    
    @objc func clickonBack(button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Value and design updating function
    func setDesign() {
        btnProfileEdit.layer.shadowOffset = CGSize(width: 0, height: 2)
        btnProfileEdit.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.15).cgColor
        btnProfileEdit.layer.shadowOpacity = 1
        btnProfileEdit.layer.shadowRadius = 5
        
        viewProfile.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewProfile.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.15).cgColor
        viewProfile.layer.shadowOpacity = 1
        viewProfile.layer.shadowRadius = 5
        
        viewProfile.layer.borderWidth = 4
        viewProfile.layer.borderColor = UIColor.white.cgColor
        
        picker.delegate = self
        
        //KeyBoard Observer
        NotificationCenter.default.addObserver(self,selector:#selector(self.keyboardWillShow(_:)),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIResponder.keyboardWillHideNotification,object: nil)
        
        // Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
        
        self.view.setNeedsLayout()
    }
    
    func setData() {
        utils.configureTextField(txtAddress)
        utils.handleTextFieldInterfaces(txtAddress)
        
        utils.onSelectAddress = { (Value) in
            utils.getCoordinates(text: Value, completionHandler: {(locCoordinate) in
                self.locationCoordinate = locCoordinate
            })
        }

        if(snapUtils.currentUserModel.profilePic != "")
        {
            profile_image.sd_setImage(with:URL(string:snapUtils.currentUserModel.profilePic), placeholderImage:#imageLiteral(resourceName: "ic_profile_default"))
        }
        if(snapUtils.currentUserModel.coverPic != "")
        {
            cover_image.sd_setImage(with:URL(string:snapUtils.currentUserModel.coverPic), placeholderImage:#imageLiteral(resourceName: "ic_cover_default"))
        }
        if snapUtils.currentUserModel.Verification != ""{
       //     self.lbl_verify.text = "Verified"
        }
        
        self.txtUserName.text = snapUtils.currentUserModel.userName
        self.txtPhoneNo.text = snapUtils.currentUserModel.mobileNo
        self.txtEmail.text = snapUtils.currentUserModel.email
        self.txtAddress.text = snapUtils.currentUserModel.address
        let arrDate = snapUtils.currentUserModel.joinDate.components(separatedBy: " ")
        self.lblJoinDate.text = "Joined on \(arrDate[0])"
        
        self.lblConnectedBy.text = "Connected by \(snapUtils.currentUserModel.connectedBy)"
        
        if snapUtils.currentUserModel.connectedBy == "Twitter"{
            self.imgConnectedBy.image = #imageLiteral(resourceName: "ic_tw_share")
        }else if snapUtils.currentUserModel.connectedBy == "Facebook"{
            self.imgConnectedBy.image = #imageLiteral(resourceName: "ic_fb_share")
        }else if snapUtils.currentUserModel.connectedBy == "Google"{
            self.imgConnectedBy.image =  #imageLiteral(resourceName: "ic_google")
        }else if snapUtils.currentUserModel.connectedBy == "Instagram"{
            self.imgConnectedBy.image = #imageLiteral(resourceName: "ic_ig_share")
        }else{
            self.imgConnectedBy.image = #imageLiteral(resourceName: "ic_logo")
            self.lblConnectedBy.text = "Classpath Registered"
        }
    }
    // Save profile Data
    @objc func contactNumberVerified() {
       submitEditedInfo(isNumberVerified: true)
    }
    
    func submitEditedInfo(isNumberVerified: Bool) {
        if let mobile = defaults.value(forKey: "MobileNo") as? String {
            self.txtPhoneNo.text = mobile
        }
        if(txtEmail.text?.isValidEmail())!
        {
            
            self.removeImageFromDataBaseStorage(imageString: snapUtils.currentUserModel.profilePic)
            self.removeImageFromDataBaseStorage(imageString: snapUtils.currentUserModel.coverPic)
            
            
            self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
            utils.uploadImages(userId: ["ProfilePic","CoverPic"], view: self,imagesArray : [self.profile_image.image!,self.cover_image.image!]){ (uploadedImageUrlsArray) in
                snapUtils.currentUserModel.userName = self.txtUserName.text!
                snapUtils.currentUserModel.mobileNo = self.txtPhoneNo.text!
                snapUtils.currentUserModel.email = self.txtEmail.text!
                snapUtils.currentUserModel.coverPic = uploadedImageUrlsArray[1]
                snapUtils.currentUserModel.address = self.txtAddress.text!
                
                if isNumberVerified == true {
                    snapUtils.currentUserModel.Verification = "true" 
                }
                
                if self.locationCoordinate != nil {
                    snapUtils.currentUserModel.lat = self.locationCoordinate.latitude
                    snapUtils.currentUserModel.long = self.locationCoordinate.longitude
                }
                
                if uploadedImageUrlsArray[0].range(of: "CoverPic") != nil{
                    snapUtils.currentUserModel.coverPic = uploadedImageUrlsArray[0]
                    snapUtils.currentUserModel.profilePic = uploadedImageUrlsArray[1]
                }else{
                    snapUtils.currentUserModel.coverPic = uploadedImageUrlsArray[1]
                    snapUtils.currentUserModel.profilePic = uploadedImageUrlsArray[0]
                }
               print(snapUtils.currentUserModel.encodeToJSON())
                self.ref.child(nodeUsers).child(snapUtils.currentUserModel.userId).updateChildValues(snapUtils.currentUserModel.encodeToJSON())
                
                let alert = UIAlertController(title: "", message: "Profile updated successfully.", preferredStyle: .alert)
                self.stopAnimating()
                self.present(alert, animated: true, completion: nil)
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }else{
            let custAlert = customAlertView.init(title: "Message", message: "Please enter valid email.", btnTitle: "OK")
            custAlert.show(animated: true)
        }
    }
    
    func removeImageFromDataBaseStorage(imageString:String){
        if(imageString != ""  && imageString.range(of: "firebasestorage") != nil)
        {
            let storage =  Storage.storage()
            let imageRef = storage.reference(forURL: imageString)
            imageRef.delete { error in
                if error != nil {
                    print("Uh-oh, an error occurred!")
                } else {
                    print("File deleted successfully")
                }
            }
        }
    }
   
    //MARK: Actions
    @IBAction func onClick_btnSave(_ sender: Any)  {
        if(ValidateTextField()) {
            if txtPhoneNo.text != snapUtils.currentUserModel.mobileNo {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let modalViewController = storyboard.instantiateViewController(withIdentifier: "PhoneVerficationPopUp") as! PhoneVerficationPopUp
            modalViewController.modalPresentationStyle = .overCurrentContext
            modalViewController.modalTransitionStyle = .crossDissolve
                modalViewController.contactNo = self.txtPhoneNo.text!
            self.present(modalViewController, animated: true, completion: nil)
                
            }else {
                self.submitEditedInfo(isNumberVerified: false)
            }
        }else
        {
            let custAlert = customAlertView.init(title: "Message", message: "Required field(s) empty", btnTitle: "OK")
            custAlert.show(animated: true)

        }
    }
    
    @IBAction func onClick_EditData(_ sender: UIButton) {
        if sender.tag != 7 && sender.tag != 8{
            if let txt = self.view.viewWithTag(sender.tag-6) as? UITextField {
                txt.isEnabled = true
                txt.becomeFirstResponder()
            }
        }else {
            isProfilePic = true
            if sender.tag == 7{
                isProfilePic = false
            }
            let alertController = UIAlertController(title: "Upload Profile picture", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            let pickfromgallery = UIAlertAction(title: "Pick from Gallery", style: .default, handler: { (action) -> Void in
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
                    self.picker.allowsEditing = false
                    self.picker.sourceType = .photoLibrary
                    self.picker.modalPresentationStyle = .popover
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        let popover = UIPopoverController(contentViewController: self.picker)
                        popover.present(from: self.view.bounds, in: self.view, permittedArrowDirections: .any, animated: true)
                        self.popOver = popover
                    }
                    else {
                        self.present(self.picker, animated: true, completion: nil)
                    }
                    self.picker.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView:sender)
                }
            })
            let takeaphoto = UIAlertAction(title: "Take a Photo", style: .default, handler: { (action) -> Void in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.picker.allowsEditing = false
                    self.picker.sourceType = UIImagePickerController.SourceType.camera
                    self.picker.cameraCaptureMode = .photo
                    self.picker.modalPresentationStyle = .fullScreen
                    self.present(self.picker, animated: true, completion: nil)
                }else {
                    self.noCamera()
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            })
            alertController.addAction(pickfromgallery)
            alertController.addAction(takeaphoto)
            alertController.addAction(cancel)
            if let popoverPresentationController = alertController.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = (sender as AnyObject).bounds
            }
            present(alertController, animated: false, completion: nil)
        }
    }
    
    @IBAction func onClick_btnDelete(_ sender: Any) {
        handleDelete()
    }
    
    func handleDelete()  {
        let v = UIView()
        let custAlert = customAlertView.init(title: "Message", message: "Deleting your account would permanently get rid of ALL your data with no chance of recovery. Would you like to proceed?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
        custAlert.onRightBtnSelected = { (Value: String) in
            custAlert.dismiss(animated: true)
            self.DeleteAccount()
        }
        custAlert.onLeftBtnSelected = { (Value: String) in
            custAlert.dismiss(animated: true)
        }
        custAlert.show(animated: true)
    }
    
    func DeleteAccount(){
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        //remove listing
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                // An error happened.
                print(error)
                // Create the alert controller
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                // Create the actions
                let NoAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    self.dismiss(animated: false, completion: nil)
                }
                // Add the actions
                alertController.addAction(NoAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let LisingList = self.ref.child(nodeListings)
                LisingList.observeSingleEvent(of :.value ,with: { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for item in children {
                        let GetId = (item.childSnapshot(forPath: keyUserID).value as? String)!
                        if GetId == uid{
                            LisingList.child(item.key).removeValue()
                        }
                    }
                })
                
                //remove ListingReports
                let ListReport = self.ref.child(nodeListingReports)
                ListReport.observeSingleEvent(of :.value ,with: { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for item in children {
                        print(item.key)
                        let GetId = (item.childSnapshot(forPath: keyUserID).value as? String)!
                        if GetId == uid{
                            ListReport.child(item.key).removeValue()
                        }
                    }
                })
                
                //remove ListingReview
                let ListReview = self.ref.child(nodeReviews)
                ListReview.observeSingleEvent(of :.value ,with: { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for item in children {
                        let GetId = (item.childSnapshot(forPath: keyUserID).value as? String)!
                        if GetId == uid{
                            ListReview.child(item.key).removeValue()
                        }
                    }
                })
                
                //remove listingRegister
                let ListRegister = self.ref.child(nodeListingsRegistered)
                ListRegister.observeSingleEvent(of :.value ,with: { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for item in children {
                        if let GetId = item.childSnapshot(forPath: keyUid).value as? String {
                            if GetId == uid{
                                ListRegister.child(item.key).removeValue()
                            }
                        }
                    }
                })
                
                //remove Notifications
                let ListNotifications = self.ref.child(nodeNotifications)
                ListNotifications.observeSingleEvent(of :.value ,with: { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for item in children {
                        var key4 = String()
                        key4 = item.key
                        ListNotifications.child(key4).observeSingleEvent(of :.value ,with: { snapshot3 in
                            guard let children = snapshot3.children.allObjects as? [DataSnapshot] else { return }
                            for item3 in children {
                                let val1 = item3.value as! NSDictionary
                                var GetID1 = ""
                                if let defaults = val1[keyToUid] as? String {
                                    GetID1 = defaults
                                }
                                var GetID12 = ""
                                if let defaults = val1[keyFromUid] as? String {
                                    GetID12 = defaults
                                }
                                if GetID1 == uid{
                                    ListNotifications.child(key4).child(item3.key).removeValue()
                                }else if GetID12 == uid{
                                    ListNotifications.child(key4).child(item3.key).removeValue()
                                }
                            }
                        })
                    }
                })
                
                //remove chatMessages
                let ListchatMessages = self.ref.child(nodeChatMessages)
                ListchatMessages.observeSingleEvent(of :.value ,with: { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for item in children {
                        let string = item.key
                        if string.range(of:uid) != nil {
                            ListchatMessages.child(item.key).removeValue()
                        }
                    }
                })
                
                //remove chats
                let Listchats = self.ref.child(nodeChats)
                Listchats.observeSingleEvent(of :.value ,with: { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for item in children {
                        let string = item.key
                        if string.range(of:uid) != nil {
                            Listchats.child(item.key).removeValue()
                        }
                    }
                })
                
                //remove chats
                let ListuserChats = self.ref.child(nodeUserChats).child(uid)
                ListuserChats.observeSingleEvent(of :.value ,with: { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for item in children {
                        ListuserChats.child(item.key).removeValue()
                    }
                })
                
                //remove userChats
                let ListuserChatsChild = self.ref.child(nodeUserChats)
                ListuserChatsChild.observeSingleEvent(of :.value ,with: { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for item in children {
                        var key1 = String()
                        key1 = item.key
                        ListuserChatsChild.child(key1).child(keyChatID).observeSingleEvent(of :.value ,with: { snapshot1 in
                            var value1 = NSMutableArray()
                            if !snapshot1.exists(){return}
                            value1 = snapshot1.value as! NSMutableArray
                            for i in 0..<value1.count{
                                let temp = value1.object(at: i) as! String
                                let myString = String(i)
                                
                                if temp.range(of:uid) != nil {
                                    ListuserChatsChild.child(key1).child(keyChatID).child(myString).removeValue()
                                }
                            }
                        })
                    }
                })
                
                let UserList = self.ref.child(nodeUsers).child(uid)
                UserList.observeSingleEvent(of :.value ,with: { snapshot in
                    UserList.removeValue()
                    let alert = UIAlertController(title: "", message: "Your account was deleted successfully", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    let when = DispatchTime.now() + 2.5
                    DispatchQueue.main.asyncAfter(deadline: when){
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let root1ViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    appDelegate.window?.rootViewController = root1ViewController
                    appDelegate.window?.makeKeyAndVisible()
                })
                
            }
        }
    }
    
    //MARK: - Image Picker functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if  let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        {
            if isProfilePic {
                self.profile_image.image = chosenImage
            }else{
                self.cover_image.image = chosenImage
            }
            self.dismiss(animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func noCamera(){
        let custAlert = customAlertView(title: "No Camera", message: "Sorry, this device has no camera", image: #imageLiteral(resourceName: "ic_info"))
        custAlert.show(animated: true)
    }
    
    //MARK: Helper methods
    func ValidateTextField() -> Bool
    {
        if(txtUserName.text == "" || txtPhoneNo.text == "" || txtEmail.text == "")
        {
            utils.emptyFieldValidation(txtPhoneNo, view: self.view, tag: txtPhoneNo.tag+9)
            utils.emptyFieldValidation(txtEmail, view: self.view, tag: txtEmail.tag+9)
            return false
        }
        
        if self.locationCoordinate ==  nil {
             utils.emptyFieldValidation(txtAddress, view: self.view, tag: txtAddress.tag+9)
        }
        return true
    }
    //MARK: - UITextField Delegate Method
    @objc func tapView(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - KeyBoard Observer Method
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = (keyboardFrame.height - 150) * (show ? 1 : 0)
        srView.contentInset.bottom = adjustmentHeight
        srView.scrollIndicatorInsets.bottom = adjustmentHeight
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
