//
//  PayentDetailsVC+BankInfo.swift
//  Classpath
//
//  Created by Coldfin on 31/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit

extension PaymentDetailsVC {
    
    @IBAction func onClickViewMyId(_ sender: UIButton) {
        let message = "You have successful created a merchant account. Your ID is "
        if  (self.lblMerchantMessage.text?.contains("XXXXXXXXXXXX"))! {
            self.lblMerchantMessage.text = "\(message)\(snapUtils.currentUserModel.merchantId)"
            sender.setTitle("  Hide ID", for: .normal)
        }else {
            self.lblMerchantMessage.text = "\(message)XXXXXXXXXXXX"
            sender.setTitle("  Show ID", for: .normal)
        }
                
    }
    @IBAction func onClickUpdateBankInfo(_ sender: UIButton) {
        //secureView.isHidden = true
        connectWithStripe()
    }
    
    @IBAction func onClickHideBankInfo(_ sender: Any) {
        secureView.isHidden = false
    }
    
    func layoutUpdateAccordingToCountry(){
        if countryCode == "US"{
            heightSSN.constant = 78
            heightRoutingNumber.constant = 78
            viewSSN.isHidden = false
            viewRouting.isHidden = false
        }
        if countryCode == "JP"{
            viewKanaAddress.isHidden = false
            heightKanaAddress.constant = 377
            lblAddress.text = "ADDRESS IN KANAJI"
        }
    }
    
    func getUserAccountDetail(){
        if snapUtils.currentUserModel.merchantId != "" {
            
            secureView.isHidden = false
            btnHideInfo.isHidden = false
            
            isForEdit = true
            //txtName.text = snapUtils.currentUserModel.accountInfo[keyFull_name]
            //txtDOB.text = snapUtils.currentUserModel.accountInfo[keyDob]
            //txtAdd_line_1.text = snapUtils.currentUserModel.accountInfo[keyAdd_line1]
            //txtAdd_line_2.text = snapUtils.currentUserModel.accountInfo[keyAdd_line2]
            //txtCity.text = snapUtils.currentUserModel.accountInfo[keyCity]
            //txtState.text = snapUtils.currentUserModel.accountInfo[keyState]
            //txtCountry.text = snapUtils.currentUserModel.accountInfo[keyCountry]
            //txtPostal_code.text = snapUtils.currentUserModel.accountInfo[keyPostal_code]
            //txtBusinessName.text = snapUtils.currentUserModel.accountInfo[keyBusiness_name]
            //txtBusinessType.text = snapUtils.currentUserModel.accountInfo[keyBusinessType]
            //txtKanaAddLine1.text = snapUtils.currentUserModel.accountInfo[keyKanaAdd_line1]
            //txtKanaAddLine2.text = snapUtils.currentUserModel.accountInfo[keyKanaAdd_line2]
            //txtKanaCity.text = snapUtils.currentUserModel.accountInfo[keyKanaCity]
            //txtKanaState.text = snapUtils.currentUserModel.accountInfo[keyKanaState]
            //txtKanaCountry.text = snapUtils.currentUserModel.accountInfo[keyKanaCountry]
            //txtKanaPostalCode.text = snapUtils.currentUserModel.accountInfo[keyKanaPostal_code]
            //txtPersonalId.text = snapUtils.currentUserModel.accountInfo[keyPersonal_id]!
            //txtBusinessTaxId.text = snapUtils.currentUserModel.accountInfo[keyBusinessTax]!
            //txtSSN.text = snapUtils.currentUserModel.accountInfo[keyssn]!
            //txtAccountRouting.text = snapUtils.currentUserModel.accountInfo[keyAc_routing]!
            //txtAccountNumber.text = snapUtils.currentUserModel.accountInfo[keyAc_no]!
            
//            do {
//                var taxid = ""
//                var routing = ""
//                var ssn = ""
//                let personalid = try crypUtils.decryptMessage(encryptedMessage: snapUtils.currentUserModel.accountInfo[keyPersonal_id]!)
//                if txtBusinessType.text == "company"{
//                    taxid = try crypUtils.decryptMessage(encryptedMessage: snapUtils.currentUserModel.accountInfo[keyBusinessTax]!)
//                }
//                let ac_no = try crypUtils.decryptMessage(encryptedMessage: snapUtils.currentUserModel.accountInfo[keyAc_no]!)
//                if countryCode == "US"{
//                    routing = try crypUtils.decryptMessage(encryptedMessage: snapUtils.currentUserModel.accountInfo[keyAc_routing]!)
//                    ssn = try crypUtils.decryptMessage(encryptedMessage: c)
//                }
//                txtPersonalId.text = personalid
//                txtBusinessTaxId.text = taxid
//                accountNumber = ac_no
//                routingNumber = routing
//                txtSSN.text = ssn
//            }catch{}
//
//            var hashPassword = ""
//            for i in 0..<routingNumber.count {
//                if i < 5{
//                    hashPassword += "X"
//                }else{
//                    let strIndex = routingNumber[i]
//                    hashPassword += String(strIndex)
//                }
//            }
//            txtAccountRouting.text = hashPassword
//
//            hashPassword = ""
//            for i in 0..<accountNumber.count {
//                if i < 8{
//                    hashPassword += "X"
//                }else{
//                    hashPassword += String(accountNumber[i])
//                }
//            }
//            txtAccountNumber.text = hashPassword
        }else {
            
            secureView.isHidden = true
            btnHideInfo.isHidden = true
            
            isForEdit = false
            txtName.becomeFirstResponder()
            txtName.isEnabled = true
            txtDOB.isEnabled = true
            txtAdd_line_1.isEnabled = true
            txtAdd_line_2.isEnabled = true
            txtCity.isEnabled = true
            txtState.isEnabled = true
            txtCountry.isEnabled = true
            txtPostal_code.isEnabled = true
            txtBusinessName.isEnabled = true
            txtBusinessType.isEnabled = true
            txtKanaAddLine1.isEnabled = true
            txtKanaAddLine2.isEnabled = true
            txtKanaCity.isEnabled = true
            txtKanaState.isEnabled = true
            txtKanaCountry.isEnabled = true
            txtKanaPostalCode.isEnabled = true
            txtPersonalId.isEnabled = true
            txtBusinessTaxId.isEnabled = true
            txtSSN.isEnabled = true
            txtAccountRouting.isEnabled = true
            txtAccountNumber.isEnabled = true
            
            self.hideEditButtons(txtName.tag)
            self.hideEditButtons(txtName.tag)
            self.hideEditButtons(txtDOB.tag)
            self.hideEditButtons(txtAdd_line_1.tag)
            self.hideEditButtons(txtAdd_line_2.tag)
            self.hideEditButtons(txtCity.tag)
            self.hideEditButtons(txtState.tag)
            self.hideEditButtons(txtCountry.tag)
            self.hideEditButtons(txtPostal_code.tag)
            self.hideEditButtons(txtBusinessName.tag)
            self.hideEditButtons(txtBusinessType.tag)
            self.hideEditButtons(txtKanaAddLine1.tag)
            self.hideEditButtons(txtKanaAddLine2.tag)
            self.hideEditButtons(txtKanaCity.tag)
            self.hideEditButtons(txtKanaState.tag)
            self.hideEditButtons(txtKanaCountry.tag)
            self.hideEditButtons(txtKanaPostalCode.tag)
            self.hideEditButtons(txtPersonalId.tag)
            self.hideEditButtons(txtBusinessTaxId.tag)
            self.hideEditButtons(txtSSN.tag)
            self.hideEditButtons(txtAccountRouting.tag)
            self.hideEditButtons(txtAccountNumber.tag)
        }
    }
    
    func hideEditButtons(_ tag:Int)  {
        let btnTag = tag*100
        if let btn = self.view.viewWithTag(btnTag) as? UIButton {
            btn.isHidden = true
        }
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtDOB.inputAccessoryView = toolbar
        txtDOB.inputView = datePicker
        
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        txtDOB.text = formatter.string(from: sender.date)
        //self.view.endEditing(true)
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        txtDOB.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtCardNumber || textField == txtCVV || textField == txtExpiryDate{
//            if textField == txtCardNumber {
//                var hashPassword = String()
//                let newChar = string.first
//                let offsetToUpdate = cardNumber.index(routingNumber.startIndex, offsetBy: range.location)
//
//                if string == "" {
//                    cardNumber.remove(at: offsetToUpdate)
//                    return true
//                }
//                else {
//                    if cardNumber.count < 16 {
//                        cardNumber.insert(newChar!, at: offsetToUpdate)
//                    }
//                }
//
//                if (textField.text?.count)! < 12{
//                    for _ in 0..<cardNumber.count {  hashPassword += "X" }
//                    textField.text = hashPassword
//                }else if (textField.text?.count)! > 15{
//                    return false
//                }else
//                {
//                    textField.text!.insert(newChar!, at: offsetToUpdate)
//                }
//                return false
//            }
            return cardTextfieldShouldChange(textfield:textField, range:range, string:string)
        }
        
       
        
//        if textField == txtAccountRouting {
//            var hashPassword = String()
//            let newChar = string.first
//            let offsetToUpdate = routingNumber.index(routingNumber.startIndex, offsetBy: range.location)
//
//            if string == "" {
//                routingNumber.remove(at: offsetToUpdate)
//                return true
//            }
//            else {
//                if routingNumber.count < 9 {
//                    routingNumber.insert(newChar!, at: offsetToUpdate)
//                }
//            }
//
//            if (textField.text?.count)! < 5{
//                for _ in 0..<routingNumber.count {  hashPassword += "X" }
//                textField.text = hashPassword
//            }else if (textField.text?.count)! > 8{
//                return false
//            }else
//            {
//                textField.text!.insert(newChar!, at: offsetToUpdate)
//            }
//            return false
//        }
//        if textField == txtAccountNumber {
//            var hashPassword = String()
//            let newChar = string.first
//            let offsetToUpdate = accountNumber.index(accountNumber.startIndex, offsetBy: range.location)
//
//            if string == "" {
//                accountNumber.remove(at: offsetToUpdate)
//                return true
//            }
//            else {
//                if accountNumber.count < 12 {
//                    accountNumber.insert(newChar!, at: offsetToUpdate)
//                }
//            }
//            if (textField.text?.count)! < 8{
//                for _ in 0..<accountNumber.count {  hashPassword += "X" }
//                textField.text = hashPassword
//            }else if (textField.text?.count)! > 11{
//                return false
//            }else
//            {
//                textField.text!.insert(newChar!, at: offsetToUpdate)
//            }
//            return false
//        }
        if textField == txtAccountRouting {
            if textField.text != "" {
                let newLength = textField.text!.count + string.count - range.length
                return newLength <= 9
            }
        }
        if textField == txtAccountNumber {
            if textField.text != "" {
                let newLength = textField.text!.count + string.count - range.length
                return newLength <= 12
            }
        }
        if textField == txtSSN {
            if textField.text != "" {
                let newLength = textField.text!.count + string.count - range.length
                return newLength <= 4
            }
        }
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtAccountRouting  || textField == txtAccountNumber{
            textField.text = ""
        }
        if textField == txtCardNumber {
            if textField.text!.count == 4 {
                textField.text = ""
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtAccountRouting  {
            if textField.text != "" && textField.text!.count >= 9 {
                if !(textField.text!.contains("X")) {
                    routingNumber = txtAccountRouting.text!
                }
              //  txtAccountRouting.text = (textField.text! as NSString).replacingCharacters(in: NSMakeRange(0,5), with: "XXXXX")
            }
        }
        if textField == txtAccountNumber {
            if textField.text != "" && textField.text!.count >= 12 {
                if !(textField.text!.contains("X")) {
                    accountNumber  = txtAccountNumber.text!
                }
             //   txtAccountNumber.text = (textField.text! as NSString).replacingCharacters(in: NSMakeRange(0,8), with: "XXXXXXXX")
            }
        }
        if textField == txtCardNumber {
            let (type, _, valid, image) = checkCardNumber(input: cardNumber)
            cardImage.image = image
            cardName = type.rawValue
            if !valid {
                textField.becomeFirstResponder()
            }
        }
    }
    @IBAction func onClick_Edit(_ sender: UIButton){
        let textFeildTag = sender.tag/100
        
        if let txt = self.view.viewWithTag(textFeildTag) as? UITextField {
            txt.isEnabled = true
            txt.becomeFirstResponder()
            txt.text = ""
        }
        
    
    }
    @IBAction func onClick_Type(_ sender: UIButton){
        self.view.endEditing(true)
        
        let actionSheetController: UIAlertController = UIAlertController(title: "TAX TYPE", message: "Choose an option from below", preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = themeColor
        let individualActionButton = UIAlertAction(title: "individual", style: .default) { _ in
            self.txtBusinessType.text = "individual"
            self.heightCompanyInfo.constant = 0
            self.viewCompanyInfo.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
            }, completion: nil)
            actionSheetController.dismiss(animated: true, completion: nil)
        }
        actionSheetController.addAction(individualActionButton)
        
        let companyActionButton = UIAlertAction(title: "company", style: .default)
        { _ in
            self.txtBusinessType.text = "company"
            self.heightCompanyInfo.constant = 233
            self.viewCompanyInfo.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            actionSheetController.dismiss(animated: true, completion: nil)
        }
        actionSheetController.addAction(companyActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    @IBAction func onClick_Agreement(_ sender: Any) {
        if btnAgreement.isSelected {
            btnAgreement.isSelected = false
            btnSubmit.backgroundColor = textThemeColor
        }else{
            btnAgreement.isSelected = true
            btnSubmit.backgroundColor = themeColor
        }
        
        isAgreed = btnAgreement.isSelected
        btnSubmit.isEnabled = isAgreed
        
    }
    @IBAction func onClick_submitAction(_ sender : Any){
        
        if(ValidateTextField())
        {
             
            startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
            
            let arrDOB = txtDOB.text!.components(separatedBy: "-")
            birth_month = arrDOB[0]
            birth_day = arrDOB[1]
            birth_year = arrDOB[2]
            
            let arrName = txtName.text!.components(separatedBy: " ")
            first_name = arrName[0]
            last_name = arrName[1]
            
            self.postAccountInfotoServer()
        }
    }
    
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (lblAgreement.text)!
        let privacyRange = (text as NSString).range(of: "Stripe Connected Account Agreement")
        
        if gesture.didTapAttributedTextInLabel(label: lblAgreement, inRange: privacyRange) {
            if let url = URL(string: "https://stripe.com/us/connect-account/legal") {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        } else {
            print("Tapped none")
        }
    }
    
    
    func retriveCurrency(){
        let strUrl = "\(BaseURl)/stripe/retrieve_country_spec.php"
        let params: [String: Any] = ["country":countryCode]
        
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html", "application/json"])
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.securityPolicy.allowInvalidCertificates = true;
        manager.securityPolicy.validatesDomainName = false;
        manager.post(strUrl, parameters: params, success: {(operation, responseObject) in
            
            self.currency = (responseObject as! NSDictionary).value(forKey: "default_currency") as! String
            print(self.currency)
            
        }, failure: { (operation, error) in
            print(error?.localizedDescription as Any)
        })
    }
    
    func encryptUserBankInfo_Save(params:[String: Any])  {
       // do {
            var routing = ""
            var ssn = ""
            var taxid = ""
        
        let personalId = String((txtPersonalId.text?.suffix(4))!)
        let accountNo = String((txtAccountNumber.text?.suffix(4))!)
//            let personalId = try crypUtils.encryptMessage(message: params[keyPersonal_id] as! String)
//            let accountNo = try crypUtils.encryptMessage(message: params[keyAc_no] as! String)
            if txtBusinessType.text == "company"{
//                taxid = try crypUtils.encryptMessage(message: params[keyBusinessTax] as! String)
                taxid = String((txtBusinessTaxId.text?.suffix(4))!)
            }
            if countryCode == "US"{
//                routing = try crypUtils.encryptMessage(message: params[keyAc_routing] as! String)
//                ssn = try crypUtils.encryptMessage(message: params[keyssn] as! String)
                routing = String((txtAccountRouting.text?.suffix(4))!)
                    ssn = txtSSN.text!
            }
            let parameters:[String:Any] = [keyFull_name: txtName.text!,
                                           keyDob: txtDOB.text!,
                                           keyAdd_line1 : txtAdd_line_1.text!,
                                           keyAdd_line2 : txtAdd_line_2.text!,
                                           keyCity: txtCity.text!,
                                           keyState : txtState.text!,
                                           keyCountry : txtCountry.text!,
                                           keyPostal_code: txtPostal_code.text!,
                                           keyPersonal_id : personalId,
                                           keyBusiness_name : txtBusinessName.text!,
                                           keyBusinessType: txtBusinessType.text!,
                                           keyBusinessTax: taxid,
                                           keyAc_no: accountNo,
                                           keyAc_routing : routing,
                                           keyssn:ssn,
                                           keyKanaCity:txtKanaCity.text!,
                                           keyKanaState:txtKanaState.text!,
                                           keyKanaCountry:txtKanaCountry.text!,
                                           keyKanaAdd_line1:txtKanaAddLine1.text!,
                                           keyKanaAdd_line2:txtKanaAddLine2.text!,
                                           keyKanaPostal_code:txtKanaPostalCode.text!]
            
            let childUpdates = ["/\(nodeUsers)/\(snapUtils.currentUserModel.userId)/\(keyMerchantAccountInfo)": parameters]
            self.ref.updateChildValues(childUpdates)
//        }catch{}
    }
    
    func postAccountInfotoServer() {
        let strUrl = "\(BaseURl)/stripe/merchant_create.php"
        var params: [String: Any] = ["email":snapUtils.currentUserModel.email, "ex_ac_country":txtCountry.text!, "ex_ac_currency":self.currency, "ex_ac_account_no":accountNumber, "le_city":txtCity.text!, "le_country":txtCountry.text!, "le_add_one":txtAdd_line_1.text!, "le_add_two" : txtAdd_line_2.text!, "le_post_code":txtPostal_code.text!, "le_state":txtState.text!, "le_dob_day":birth_day, "le_dob_month":birth_month, "le_dob_year":birth_year, "le_first_name":first_name, "le_last_name":last_name, "le_pa_city":txtCity.text!, "le_pa_country":txtCountry.text!, "le_pa_line1":txtAdd_line_1.text!, "postal_code":txtPostal_code, "le_personal_id_number":txtPersonalId.text!, "le_type":txtBusinessType.text!,"tos_ip_address":getWiFiAddress()!,]
        
        if txtBusinessType.text! == "company"{
            params["additional_owners"] = txtAdditionalOwner.text!
            params["business_name"] = txtBusinessName.text!
            params["business_tax_id"] = txtBusinessTaxId.text!
        }
        if countryCode == "US"{
            params["ex_ac_routing_no"] = routingNumber
            params["ssn_last_4"] = txtSSN.text!
        }
        if countryCode == "JP"{
            params["kana_city"] = txtKanaCity.text!
            params["kana_country"] = txtKanaCountry.text!
            params["kana_add_one"] = txtKanaAddLine1.text!
            params["kana_add_two"] = txtKanaAddLine2.text!
            params["kana_post_code"] = txtKanaPostalCode.text!
            params["kana_state"] = txtKanaState.text!
            params["kanji_city"] = txtCity.text!
            params["kanji_country"] = txtCountry.text!
            params["kanji_add_one"] = txtAdd_line_1.text!
            params["kanji_add_two"] = txtAdd_line_2.text!
            params["kanji_post_code"] = txtPostal_code.text!
            params["kanji_state"] = txtState.text!
        }
        
        var id = ""
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html", "application/json"])
        manager.requestSerializer.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        manager.securityPolicy.allowInvalidCertificates = true;
        manager.securityPolicy.validatesDomainName = false;
        manager.post(strUrl, parameters: params, success: {(operation, responseObject) in
            
            let success = (responseObject as! NSDictionary).value(forKey: "succcess") as! Bool
            if success {
                let response = (responseObject as! NSDictionary).value(forKey: "response")
                
                let element:NSDictionary = response as! NSDictionary
                id = element.value(forKey: "id") as! String
                
                let childUpdates = ["/\(nodeUsers)/\(snapUtils.currentUserModel.userId)/\(keyMerchantId)":id]
                self.ref.updateChildValues(childUpdates)
                self.ref.updateChildValues(childUpdates)
                self.encryptUserBankInfo_Save(params: params)
                if id != ""{
                    snapUtils.currentUserDateFetchFromDB(completionHandler: { _ in })
                    var message = "Merchant account created successfully!"
                    if self.isForEdit {
                        message = "Merchant account updated successfully!"
                    }
                    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when){
                        alert.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }else{
                let response = (responseObject as! NSDictionary).value(forKey: "response") as! NSDictionary
                
                let message = response.value(forKey: "message") as! String

                
                let custAlert = customAlertView(title: "Message", message: message, btnTitle: "OK")
                custAlert.show(animated: true)
                
            }
            self.stopAnimating()
        }, failure: { (operation, error) in
            self.stopAnimating()
            print(error!)
            let custAlert = customAlertView(title: "Message", message: "Something went wrong!", btnTitle: "OK")
            custAlert.onBtnSelected = {(Value: String) in
                _ = self.navigationController?.popViewController(animated: true)
            }
            custAlert.show(animated: true)
        })
    }
    
    func getAccountID(_ code:String)
    {
        let strUrl="\(BaseURl)/stripe/get_account_id.php"
        let params=["grant_type":"authorization_code", "code":code]
        var id=""
        let manager=AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes=Set(["text/html", "application/json"])
        manager.requestSerializer.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField:"Content-Type")
        manager.securityPolicy.allowInvalidCertificates=true;
        manager.securityPolicy.validatesDomainName=false;
        manager.post(strUrl, parameters:params, success:{(operation, responseObject) in
            
            let success=(responseObject as! NSDictionary).value(forKey:"success") as! Bool
            
            if success
            {
                let response=(responseObject as! NSDictionary).value(forKey:"response") as! NSDictionary
                id=response.value(forKey:"stripe_user_id") as! String
                
                let childUpdates =
                    ["/\(nodeUsers)/\(snapUtils.currentUserModel.userId)/\(keyMerchantId)":id]
                self.ref.updateChildValues(childUpdates)
                self.ref.updateChildValues(childUpdates)
                
                if id != ""
                {
                    var message="Merchant account created successfully!"
                    if self.isForEdit
                    {
                        message="Merchant account updated successfully!"
                    }
                    let alert=UIAlertController(title:"", message:message, preferredStyle:.alert)
                    self.present(alert, animated:true, completion:nil)
                    let when=DispatchTime.now()+3
                    DispatchQueue.main.asyncAfter(deadline:when)
                    {
                        alert.dismiss(animated:true, completion:nil)
                        self.navigationController?.popViewController(animated:
                            true)
                    }
                }
            }
            else
            {
                let response=(responseObject as! NSDictionary).value(forKey:"response") as! String
                
                let custAlert=customAlertView(title:"Message", message:response, btnTitle:"OK")
                custAlert.show(animated:true)
            }
            self.stopAnimating()
        }, failure:{(operation, error) in
            self.stopAnimating()
            let custAlert=customAlertView(title:"Message", message:"Something went wrong!", btnTitle:"OK")
            custAlert.onBtnSelected={(Value:String) in _=self.navigationController?.popViewController(animated:true)
            }
            custAlert.show(animated:true)
        })
    }

    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" || name == "pdp_ip0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    func ValidateTextField() -> Bool
    {
        if(txtName.text == "" || txtDOB.text == "" || txtAdd_line_1.text == "" || txtCity.text == "" || txtState.text == "" || txtCountry.text == "" || txtPostal_code.text == "" ||  txtBusinessType.text == "" ||  txtAccountNumber.text == "" || txtPersonalId.text == "" )
        {
            utils.emptyFieldValidation(txtName, view: self.view, tag: txtName.tag+1)
            utils.emptyFieldValidation(txtDOB, view: self.view, tag: txtDOB.tag+1)
            utils.emptyFieldValidation(txtAdd_line_1, view: self.view, tag: txtAdd_line_1.tag+1)
            utils.emptyFieldValidation(txtCity, view: self.view, tag: txtCity.tag+1)
            utils.emptyFieldValidation(txtState, view: self.view, tag: txtState.tag+1)
            utils.emptyFieldValidation(txtCountry, view: self.view, tag: txtCountry.tag+1)
            utils.emptyFieldValidation(txtPostal_code, view: self.view, tag: txtPostal_code.tag+1)
            utils.emptyFieldValidation(txtBusinessType, view: self.view, tag: txtBusinessType.tag+1)
            utils.emptyFieldValidation(txtAccountNumber, view: self.view, tag: txtAccountNumber.tag+1)
            utils.emptyFieldValidation(txtPersonalId, view: self.view, tag: txtPersonalId.tag+1)
            
            let custAlert = customAlertView(title: "Error", message: "Some required field(s) empty.", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        if countryCode == "JP"{
            if(txtKanaAddLine1.text == "" || txtKanaCity.text == "" || txtKanaState.text == "" || txtKanaCountry.text == "" || txtKanaCountry.text == ""){
                utils.emptyFieldValidation(txtKanaAddLine1, view: self.view, tag: txtKanaAddLine1.tag+1)
                utils.emptyFieldValidation(txtKanaCity, view: self.view, tag: txtKanaCity.tag+1)
                utils.emptyFieldValidation(txtKanaState, view: self.view, tag: txtKanaState.tag+1)
                utils.emptyFieldValidation(txtKanaCountry, view: self.view, tag: txtKanaCountry.tag+1)
                utils.emptyFieldValidation(txtKanaPostalCode, view: self.view, tag: txtKanaCountry.tag+1)
                let custAlert = customAlertView(title: "Error", message: "Some required field(s) empty.", btnTitle: "OK")
                custAlert.show(animated: true)
                return false
            }
        }
        if txtBusinessType.text == "company"{
            if(txtBusinessName.text == "" || txtBusinessTaxId.text == "" || txtAdditionalOwner.text == ""){
                utils.emptyFieldValidation(txtBusinessName, view: self.view, tag: txtBusinessName.tag+1)
                utils.emptyFieldValidation(txtBusinessTaxId, view: self.view, tag: txtBusinessTaxId.tag+1)
                utils.emptyFieldValidation(txtAdditionalOwner, view: self.view, tag: txtAdditionalOwner.tag+1)
                let custAlert = customAlertView(title: "Error", message: "Some required field(s) empty.", btnTitle: "OK")
                custAlert.show(animated: true)
                return false
            }
        }
        if countryCode == "US"{
            if(txtAccountRouting.text == "" || txtSSN.text == ""){
                utils.emptyFieldValidation(txtAccountRouting, view: self.view, tag: txtAccountRouting.tag+1)
                utils.emptyFieldValidation(txtSSN, view: self.view, tag: txtSSN.tag+1)
                let custAlert = customAlertView(title: "Error", message: "Some required field(s) empty.", btnTitle: "OK")
                custAlert.show(animated: true)
                return false
            }
        }
        
        var fields = ""
        var isNotUpdate = false
        if txtAccountNumber.text!.count == 4 || txtPersonalId.text!.count == 4 {
            isNotUpdate = true
        }
        if txtBusinessType.text == "company" {
            if txtBusinessTaxId.text!.count == 4{
                fields = ", Tax Id"
            }
        }
        if countryCode == "US"{
            if(txtAccountRouting.text!.count == 4){
                fields = "\(fields), Routing Number "
            }
        }
        
        if fields != "" || isNotUpdate {
            let custAlert = customAlertView(title: "Error", message: "If you want to update your account information.You have enter Acount Number, Personal Id\(fields) again!", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        
        txtName.text = txtName.text!.trimmingCharacters(in: .whitespaces)
        
        if txtName.text!.range(of:" ") == nil{
            let custAlert = customAlertView(title: "Message", message: "Please enter your full name, your first name and last name both are required", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        
        if snapUtils.currentUserModel.email=="" || snapUtils.currentUserModel.mobileNo==""
        {
            let custAlert=customAlertView(title:"Profile", message:"Email or phone missing", btnTitle:"OK")
            custAlert.show(animated:true)
            return false
        }

        return true
    }
    
    func validateUrl (urlString: NSString) -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }    
}
extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
