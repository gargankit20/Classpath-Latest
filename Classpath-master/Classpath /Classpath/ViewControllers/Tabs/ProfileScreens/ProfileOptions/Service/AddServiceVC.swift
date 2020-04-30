//
//  AddServiceVC.swift
//  Classpath
//
//  Created by Coldfin on 27/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase

class AddServiceVC: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate,NVActivityIndicatorViewable {

    @IBOutlet weak var txtServiceName: UITextField!
    @IBOutlet weak var txtServiceDesc: UITextField!
    @IBOutlet weak var txtServiceDeal: UITextField!
    @IBOutlet weak var txtServiceCost: UITextField!
    @IBOutlet weak var txtServicePolicy: UITextField!
    var ref: DatabaseReference!
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var lblDescLimit: UILabel!
    @IBOutlet weak var lblDealLimit: UILabel!
    @IBOutlet weak var btnInstantBook: UIButton!
    var isInstantBook = false
    var isForEdit = false
    var model = ServiceModal()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        txtServiceDesc.delegate = self
        txtServiceDeal.delegate = self
        txtServiceName.delegate = self
        txtServiceCost.delegate = self
        
        btnInstantBook.setImage(#imageLiteral(resourceName: "ic_check_box_fill"), for: .selected)
        btnInstantBook.setImage(#imageLiteral(resourceName: "ic_check_box"), for: .normal)
        
        setData()
        
        //KeyBoard Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
    }
    
    func setData() {
        txtServiceName.text = model.serviceName
        txtServiceDesc.text = model.serviceDesc
        txtServiceDeal.text = model.serviceDeal
        txtServiceCost.text = model.serviceCost
        txtServicePolicy.text = model.servicePolicy
        btnInstantBook.isSelected = model.instantBook
    }
    
    //MARK: - UITextField Delegate Method
    @objc func tapView(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    //MARK: - KeyBoard Observer Method
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : 0)
        scrView.contentInset.bottom = adjustmentHeight
        scrView.scrollIndicatorInsets.bottom = adjustmentHeight
        print(adjustmentHeight)
    }
    //MARK: - UITextField Delegate Methods

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtServiceCost {
            txtServiceCost.text! = txtServiceCost.text!.trimmingCharacters(in: .whitespaces)
            txtServiceCost.text! = txtServiceCost.text!.replace(target: " ", withString: "")
            if txtServiceCost.text!.range(of:".") != nil{
                let newLength = textField.text!.count + string.count - range.length
                let arrText = txtServiceCost.text!.components(separatedBy: ".")
                let textLength:String = arrText[0]
                return newLength < textLength.count+4
            }
        }
        if textField == txtServiceDesc {
            if textField.text != "" {
                let newLength = textField.text!.count + string.count - range.length
                lblDescLimit.text = "\(newLength)/200"
                return newLength < 200
            }
        }
        if textField == txtServiceDeal {
            if textField.text != "" {
                let newLength = textField.text!.count + string.count - range.length
                lblDealLimit.text = "\(newLength)/200"
                return newLength < 200
            }
        }
        if textField == txtServiceName {
            if textField.text != "" {
                let newLength = textField.text!.count + string.count - range.length
                return newLength < 23
            }
        }
        return true
    }
    //MARK: - Textfield Validation
    func ValidateTextField() -> Bool
    {
        if(txtServiceName.text == "" || txtServiceDesc.text == "" || txtServiceDeal.text == "" || txtServicePolicy.text == "" || txtServiceCost.text == "")
        {
            utils.emptyFieldValidation(txtServiceName, view: self.view, tag: txtServiceName.tag + 5)
            utils.emptyFieldValidation(txtServiceDesc, view: self.view, tag: txtServiceDesc.tag + 5)
            utils.emptyFieldValidation(txtServiceDeal, view: self.view, tag: txtServiceDeal.tag + 5)
            utils.emptyFieldValidation(txtServicePolicy, view: self.view, tag: txtServicePolicy.tag + 5)
            utils.emptyFieldValidation(txtServiceCost, view: self.view, tag: txtServiceCost.tag + 5)
            let custAlert = customAlertView.init(title: "Message", message: "Required field(s) empty", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        
        if currencyInputFormatting(string: txtServiceCost.text!) == "" {
            utils.emptyFieldValidation(txtServiceCost, view: self.view, tag: txtServiceCost.tag + 5)
            let custAlert = customAlertView.init(title: "Message", message: "Cost invalidate", btnTitle: "OK")
            custAlert.show(animated: true)
            
            return false
        }

        
        var strAmt = txtServiceCost.text!.trimmingCharacters(in: .whitespaces)
        strAmt = strAmt.replace(target: " ", withString: "")
        strAmt = strAmt.replace(target: "$", withString: "")

        if (Double(strAmt)) != nil {
            if !amountShouldBeGreater(amt: Double(strAmt)!) {
                utils.emptyFieldValidation(txtServiceCost, view: self.view, tag: txtServiceCost.tag + 5)
                let custAlert = customAlertView.init(title: "Message", message: "Minimum service cost is $ 10.0", btnTitle: "OK")
                custAlert.show(animated: true)
                
                return false
            }
        }else {
            utils.emptyFieldValidation(txtServiceCost, view: self.view, tag: txtServiceCost.tag + 5)
            let custAlert = customAlertView.init(title: "Message", message: "Cost invalidate", btnTitle: "OK")
            custAlert.show(animated: true)
            
            return false
        }
        
        return true
    }
    
    func amountShouldBeGreater(amt:Double) -> Bool {
        if amt < 10.0 {
            return false
        }
        return true
    }
    
    // formatting text for currency textField
    func currencyInputFormatting(string:String) -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = string
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
    //MARK: Actions
    @IBAction func onClick_instantBook(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            isInstantBook = false
        }else {
            sender.isSelected = true
            isInstantBook = true
        }
    }
    @IBAction func onClick_addServices(_ sender: Any) {
        
        if ValidateTextField(){
            if txtServiceCost.text!.range(of:".") == nil{
                txtServiceCost.text = "\(txtServiceCost.text!).00"
            }
            
            if txtServiceCost.text!.range(of:"$") == nil{
                txtServiceCost.text = "$\(txtServiceCost.text!)"
            }
            var message = "Service successfully added!"
            var key = self.ref.child(nodeService).child(snapUtils.currentUserModel.userId).childByAutoId().key
            if isForEdit {
                key = model.serviceID
                message = "Service successfully edited!"
            }
            
            let Note: [String : Any] = [keyServiceName: txtServiceName.text!,
                                        keyServiceDesc: txtServiceDesc.text!,
                                        keyServiceCost: txtServiceCost.text!,
                                        keyServiceDeal: txtServiceDeal.text!,
                                        keyServicePolicy: txtServicePolicy.text!,
                                        keyInstantBook: isInstantBook]
            print(Note)
            let childUpdates = ["/\(nodeService)/\(snapUtils.currentUserModel.userId)/\(key)": Note]
            
            self.ref.updateChildValues(childUpdates)
            
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 2.5
            DispatchQueue.main.asyncAfter(deadline: when){
                self.navigationController?.popViewController(animated: true)
                alert.dismiss(animated: true, completion: nil)
            }
          
        }
    }
}
