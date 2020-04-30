//
//  PhoneVerficationPopUp.swift
//  Classpath
//
//  Created by Coldfin on 20/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PhoneVerficationPopUp: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate,NVActivityIndicatorViewable {

    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var viewCode: UIView!
    @IBOutlet weak var txtcode: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var btnSendCode: UIButton!
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    var contactNo:String!
    var ref: DatabaseReference!
    var verificationCode:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setDesign()
    }
   
    //MARK: Actions
    @IBAction func onClick_BgToDismiss(_ sender: Any) {
          self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onClick_btnSendCode(_ sender: Any) {
        
        
        defaults.set(txtPhone.text, forKey: "MobileNo")
        
        let contactNo:String = "+\(utils.countryCodes())\(txtPhone.text!)"
        
        let strurl = "\(BaseURl)/generalApi/genrateotp.php"
        let params = NSMutableDictionary()
        params.setValue(contactNo, forKey: "phone")
         
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html", "application/json"])
        manager.post(strurl, parameters: params, success: {(operation, responseObject) in
            let element : NSDictionary = responseObject as! NSDictionary
            let success:Int = element.object(forKey: "success") as! Int
            

            if success == 1{
                self.viewCode.isHidden = false
                self.verificationCode = "\(element.object(forKey: "otp") as! Int)"
                self.txtcode.isEnabled = true
                self.txtcode.becomeFirstResponder()
                print("your code is: ",self.verificationCode)
            }else{
                var message:String = element.object(forKey: "message") as! String
                if message.contains("is not a valid phone number."){
                    let arrString = message.components(separatedBy: "'To' number")
                    message = arrString[1]
                }
                let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                let when = DispatchTime.now() + 2.5
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            self.stopAnimating()
            
        }, failure: { (operation, error) in
            print(error as Any)
            self.stopAnimating()
            let alert = UIAlertController(title: "", message: "Something went wrong please try again", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 2.5
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
        })
    }
    @IBAction func onClick_btnSubmit(_ sender: Any) {
        
        defaults.set(txtPhone.text, forKey: "MobileNo")
        if self.verificationCode == self.txtcode.text!{
            self.ref?.child(nodeUsers).child(snapUtils.currentUserModel.userId).child(keyTerms).observeSingleEvent(of: .value, with: { (snapshot) in
                NotificationCenter.default.post(name: NSNotification.Name("numberVerified"), object: nil                    )
                 self.dismiss(animated: true, completion: nil)
            })
        }else{
            let alert = UIAlertController(title: "Error", message: "The code you have entered dosen't match the one we sent you.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 2.5
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: -  Set designs for different devices
    func setDesign()
    {        //Set delegate
        txtPhone.delegate = self
        txtcode.delegate = self
        txtPhone.text = contactNo
        
        if txtPhone.text != ""{
            btnSendCode.backgroundColor = themeColor
        }else{
             btnSendCode.backgroundColor  = textThemeColor
        }
        
        //KeyBoard Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
        
        self.view.setNeedsLayout()
    }
    //MARK: - UITextField Delegate Method
    @objc func tapView(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        btnSendCode.backgroundColor  = textThemeColor
    }
    
    //MARK: - KeyBoard Observer Method
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let _ = (keyboardFrame.height) * (show ? 1 : 0)
        //topViewConstraint.constant = -adjustmentHeight
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
}
