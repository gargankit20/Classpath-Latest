//
//  ReportViewPopUp.swift
//  Classpath
//
//  Created by Coldfin on 21/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase

class ReportViewPopUp: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate,NVActivityIndicatorViewable {
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var txttype: UITextField!
    @IBOutlet weak var txtDesc: UITextField!
    let Keyboardview = KeyboardPicker()
    var ref: DatabaseReference!
    var type = ""
    var model = ListingModel()
    var user_model = UserDataModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setDesign()
    }
    
    //MARK: Design and delegate assigning function
    func setDesign()
    {
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = themeColor.cgColor
        
        //Tool bar over End Time
        let keyboardNextButtonView2 : UIToolbar = UIToolbar()
        keyboardNextButtonView2.sizeToFit()
        let nextButton2 : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.txtfieldNumberPadShouldReturnTime(_:)))
        keyboardNextButtonView2.isTranslucent = false
        nextButton2.tintColor = UIColor.white
        keyboardNextButtonView2.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),nextButton2], animated: true)
        keyboardNextButtonView2.barTintColor = themeColor
        txttype.inputAccessoryView = keyboardNextButtonView2
        
        Keyboardview.Values = ["Spam","Abuse","Inappropriate Content","Licensed Material","Other"]
        txttype.text = "Spam"
        Keyboardview.RowSelected = 0
        txttype.inputView = Keyboardview
        Keyboardview.onDateSelected = { (Value: String) in
            self.txttype.text = Value
        }
        txttype.readonly = true
        
        txtDesc.delegate = self
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView2(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
    }
    
    // gesture tap function
    @objc func tapView2(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: Textfield Validation
    @objc func txtfieldNumberPadShouldReturnTime(_ textField : UITextField) -> Bool {
        txtDesc.becomeFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtDesc {
            if textField.text != "" {
                let newLength = textField.text!.count + string.count - range.length
                return newLength <= 250
            }
        }
        return true
    }
    
    //MARK: Actions
    @IBAction func onClick_Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClick_Submit(_ sender: Any) {
        
        if valdiateListing(){
            self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
            callAPI()
            let param = NSMutableDictionary()
            param.setValue(self.txttype.text, forKey: keyReportType)
            param.setValue(self.txtDesc.text, forKey: keyReportDesc)
            param.setValue(utils.convertDateToString(Date(), format: "MM-dd-yyyy HH:mm"), forKey: keyReportDate)
            if type == "Listing" {
                param.setValue(snapUtils.currentUserModel.userId, forKey: keyUserID)
                param.setValue(self.model.userid, forKey: keyReportedTo)
                param.setValue(self.model.listingID, forKey: keyListingId)
                param.setValue(snapUtils.currentUserModel.userName, forKey: keyRBUsername)
                param.setValue(snapUtils.currentUserModel.email, forKey: keyRBEmail)
                param.setValue(self.model.title, forKey: keyRLTitle)
                param.setValue(self.model.email_id, forKey: keyRLEmail)
                param.setValue(self.model.userName, forKey: keyRLUsername)
                param.setValue(self.model.images, forKey: keyImages)
             
                let _ = self.ref.child(nodeListingReports).childByAutoId().setValue(param)
                
                let _ = self.ref.child(nodeListings).child(self.model.listingID).observe(.value, with: { snapshot in
                    self.ref.child(nodeListings).child(self.model.listingID).removeAllObservers()
                    var count = 1
                    if let defaults = (snapshot.value as! NSDictionary)[keyNoofTimesReported] as? Int {
                        count = defaults + 1
                    }
                    let userInstance = self.ref.child(nodeListings).child(self.model.listingID)
                    userInstance.updateChildValues([keyNoofTimesReported : count])
                })
            }else {
                param.setValue(snapUtils.currentUserModel.userId, forKey: keyReportedBy)
                param.setValue(self.user_model.userId, forKey: keyReportedTo)
                param.setValue(snapUtils.currentUserModel.userName, forKey: keyRBUsername)
                param.setValue(snapUtils.currentUserModel.email, forKey: keyRBEmail)
                param.setValue(self.user_model.email, forKey: keyRLEmail)
                param.setValue(self.user_model.userName, forKey: keyRLUsername)
                param.setValue(self.user_model.profilePic, forKey: keyProfilePic)
            
                let _ = self.ref.child(nodeUserReports).childByAutoId().setValue(param)
                
            }
        }
    }
    
    //MARK: Validation function
    func valdiateListing() -> Bool
    {
        if(txttype.text == "")
        {
            let alert = UIAlertController(title: "", message: " Please select report type", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            // change to desired number of seconds (in this case 5 seconds)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alert.dismiss(animated: true, completion: {() -> Void in
                })
            })
            
            return false
        }else if(txtDesc.text == ""){
            
            let alert = UIAlertController(title: "", message: "Describe the issue in more detail", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            // change to desired number of seconds (in this case 5 seconds)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alert.dismiss(animated: true, completion: {() -> Void in
                })
            })
            
            return false
        }else if snapUtils.currentUserModel.Verification != "true"{
            let v = UIView()
            let custAlert = customAlertView(title: "Message", message: "Phone verification required. Would you like to proceed?", customView: v, leftBtnTitle: "NO", rightBtnTitle: "YES", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = {(Value:String) in
                custAlert.dismiss(animated: true)
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextPage = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                self.navigationController?.pushViewController(nextPage, animated: true)
            }
            custAlert.show(animated: true)
            return false
        }
        else
        {
            return true
        }
    }
    
    //MARK: API call for report request
    func callAPI()
    {
        
        let params = NSMutableDictionary()
        params.setValue(txtDesc.text, forKey: "description")
        params.setValue(utils.convertDateToString(Date(), format: "MM-dd-yyyy HH:mm"), forKey: "date")
        params.setValue(type, forKey: "type")
        params.setValue(txtDesc.text, forKey: "description")
        params.setValue(txttype.text, forKey: "report_type")
        params.setValue(self.model.listingID, forKey: "lid_reported")
        params.setValue(snapUtils.currentUserModel.userId, forKey: "uid_reporting")
        params.setValue(snapUtils.currentUserModel.userId, forKey: "uid_list_owner")
        if self.model.userid != snapUtils.currentUserModel.userId{
            params.setValue(self.model.userid, forKey: "uid_list_owner")
        }
        params.setValue(snapUtils.currentUserModel.email, forKey: "reportedby_email")
        let strurl = "\(BaseURl)/generalApi/sendemail.php"
        
        print(params)
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html", "application/json"])
        manager.post(strurl, parameters: params, success: {(operation, responseObject) in
            
            let alert = UIAlertController(title: "", message: "Report submitted successfully", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            // change to desired number of seconds (in this case 5 seconds)
            
            self.stopAnimating()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alert.dismiss(animated: true, completion: {() -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
            })
            
        }, failure: { (operation, error) in
            print(error as Any)
        })
        
    }
}
