//
//  RegistrationVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/4/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation

class SignUpVC: UIViewController,NVActivityIndicatorViewable,UIGestureRecognizerDelegate,UITextFieldDelegate {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var scrView: UIScrollView!
    var ref: DatabaseReference!
    var locationCoordinate : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        //KeyBoard Observer
        NotificationCenter.default.addObserver(self,selector:#selector(self.keyboardWillShow(_:)),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIResponder.keyboardWillHideNotification,object: nil)
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
    }
    
    //MARK: Action methods
    @IBAction func onClick_SignUp(_ sender: Any) {
        if validateTextfield(){
            if(txtEmail.text?.isValidEmail())!
            {
                if (txtPassword.text!.utf16).count >= 6{
                    self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                    let parameter = NSMutableDictionary()
                    parameter.setValue(self.txtUserName.text, forKey: keyUsername)
                    parameter.setValue(self.txtMobileNumber.text!, forKey: keyMobileno)
                    parameter.setValue(self.txtEmail.text!, forKey: keyEmail)
                    parameter.setValue(false, forKey: keyTerms)
                    if(locationCoordinate != nil)
                    {
                        parameter.setValue(self.locationCoordinate.latitude, forKey: keyLat)
                        parameter.setValue(self.locationCoordinate.longitude, forKey: keyLong)
                    }
                    parameter.setValue(true, forKey: keyNotificationState)
                    
                    let arr = NSMutableArray(array: ["Athlete"])
                    parameter.setValue(arr, forKey: keyBadges)
                    
                    
                    let timestamp = NSDate().timeIntervalSince1970
                    let myTimeInterval = TimeInterval(timestamp)
                    let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/yyyy"
                    let JoinDate = formatter.string(from: time as Date)
                    parameter.setValue(JoinDate, forKey: keyJoinDate)
                    if let deviceToken = UserDefaults.standard.value(forKey: keyDeviceToken) as? String
                    {
                        parameter.setValue(deviceToken, forKey: keyDeviceToken)
                    }
                    else{
                        parameter.setValue("", forKey: keyDeviceToken)
                    }
                    
                    
                    Auth.auth().createUser(withEmail: self.txtEmail.text!, password: self.txtPassword.text!, completion: { (user, error) in
                        self.stopAnimating()
                        if error == nil {
//                            do {
//                                let encryptionKey = try crypUtils.generateEncryptionKey(withPassword: (user?.user.uid)!)
//                                parameter.setValue(encryptionKey, forKey: keyEncryptionKey)
//                            }catch{}
                            let userInstance = self.ref.child(nodeUsers).child((user?.user.uid)!)
                            userInstance.setValue(parameter)
                            self.redirectToTerms()
                        }else
                        {
                            let custAlert = customAlertView(title: "", message: (error?.localizedDescription)!, image: #imageLiteral(resourceName: "ic_info"))
                            custAlert.show(animated: true)
                        }
                    })
                }
                else
                {
                    let custAlert = customAlertView(title: "Message", message: "Password must be at least 6 characters long.", btnTitle: "OK")
                    custAlert.show(animated: true)
                }
            }
        }
    }
    
    func redirectToTerms()
    {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "EULAVC") as! EULAVC
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: nil)
    }
    
    @IBAction func onClick_Login(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: Self defined functions
    func validateTextfield() -> Bool {
        if txtUserName.text == "" || txtPassword.text == "" || txtMobileNumber.text == "" || txtEmail.text == "" {
            utils.emptyFieldValidation(txtUserName, view: self.view, tag: txtUserName.tag + 8)
            utils.emptyFieldValidation(txtPassword, view:self.view, tag: txtPassword.tag + 8)
            utils.emptyFieldValidation(txtMobileNumber, view: self.view, tag: txtMobileNumber.tag + 8)
            utils.emptyFieldValidation(txtEmail, view: self.view, tag: txtEmail.tag + 8)
            let custAlert = customAlertView.init(title: "Message", message: "Required field(s) empty", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        return true
    }
    
    //MARK: - KeyBoard Observer Method
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : 0)
        scrView.contentInset.bottom = adjustmentHeight
        scrView.scrollIndicatorInsets.bottom = adjustmentHeight
        print(scrView)
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
    //MARK: Statusbar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
