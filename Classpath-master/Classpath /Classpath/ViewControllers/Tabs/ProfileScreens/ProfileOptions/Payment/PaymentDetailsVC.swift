//
//  PaymentDetailsVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/8/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import Stripe
import STKWebKitViewController

protocol  addCardSet{
    func setCardData(cardInfo:NSDictionary)
}

class PaymentDetailsVC: UIViewController,NVActivityIndicatorViewable,UITextFieldDelegate,UIGestureRecognizerDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var btnCreditCard:UIButton!
    @IBOutlet weak var btnBankInfo:UIButton!
    @IBOutlet weak var leadingSelection: NSLayoutConstraint!
    @IBOutlet weak var leadingView: NSLayoutConstraint!
    
    //MARK: CARD INFO
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtCVV: UITextField!
    @IBOutlet weak var txtExpiryDate: UITextField!
    @IBOutlet weak var btnAddCard: UIButton!
    @IBOutlet weak var viewCardInfo: UIView!
    var isForEdit = false
    
    @IBOutlet weak var lblMerchantMessage: UILabel!
    @IBOutlet weak var secureView: UIView!
    @IBOutlet weak var btnHideInfo: UIButton!
    
    var cardName = ""
    var ex_month = ""
    var ex_year = ""
    var delegate : addCardSet!
    var isFromPay = false
    
    //MARK: BANK INFO
    @IBOutlet weak var heightKanaAddress: NSLayoutConstraint!
    @IBOutlet weak var heightCompanyInfo: NSLayoutConstraint!
    @IBOutlet weak var heightSSN: NSLayoutConstraint!
    @IBOutlet weak var heightRoutingNumber: NSLayoutConstraint!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var txtAdd_line_1: UITextField!
    @IBOutlet weak var txtAdd_line_2: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtPostal_code: UITextField!
    @IBOutlet weak var txtBusinessType: UITextField!
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var txtPersonalId: UITextField!
    @IBOutlet weak var txtBusinessTaxId: UITextField!
    @IBOutlet weak var txtAccountRouting: UITextField!
    @IBOutlet weak var lblAgreement: UILabel!
    @IBOutlet weak var txtBusinessName: UITextField!
    @IBOutlet weak var txtAdditionalOwner: UITextField!
    @IBOutlet weak var txtSSN: UITextField!
    @IBOutlet weak var btnAgreement: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnConnectWithStripe: UIButton!
    @IBOutlet weak var scrView:UIScrollView!
    @IBOutlet weak var viewSSN: UIView!
    @IBOutlet weak var viewCompanyInfo: UIView!
    @IBOutlet weak var viewRouting: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var viewKanaAddress: UIView!
    @IBOutlet weak var txtKanaAddLine1: UITextField!
    @IBOutlet weak var txtKanaAddLine2: UITextField!
    @IBOutlet weak var txtKanaCity: UITextField!
    @IBOutlet weak var txtKanaState: UITextField!
    @IBOutlet weak var txtKanaCountry: UITextField!
    @IBOutlet weak var txtKanaPostalCode: UITextField!
    @IBOutlet weak var cardImage: UIImageView!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var constCVVWidth: NSLayoutConstraint!
    var isFromProfile = true
    @IBOutlet weak var btnBack: UIBarButtonItem!
    var isAgreed = false
    
    var birth_day = ""
    var birth_month = ""
    var birth_year = ""
    
    var first_name = ""
    var last_name = ""
    let datePicker = UIDatePicker()
    
    var cardNumber = String()
    var routingNumber = String()
    var accountNumber = String()
    var currency = ""
    var countryCode = ""
    
    var ref: DatabaseReference!
    
    //MARK: View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnSave.isEnabled = true
        leadingView.constant = 1000
        let locale = Locale.current
        countryCode = locale.regionCode!
        retriveCurrency()
        ref = Database.database().reference()
        setDesign()
        showDatePicker()
        getUserAccountDetail()
        getUserCardDetail()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "SFProText-SemiBold", size: 20)!,NSAttributedString.Key.foregroundColor: themeColor]
    
    }
    
    func getUserCardDetail(){
        if snapUtils.currentUserModel.cardInfo.count != 0{
//            do{
                let cardInfo = snapUtils.currentUserModel.cardInfo
                cardNumber = cardInfo.value(forKey: keyCardNumber) as! String
//                cardNumber = try crypUtils.decryptMessage(encryptedMessage: cardInfo.value(forKey: keyCardNumber) as! String)
//                var Password = ""
//                for i in 0..<cardNumber.count {
//                    if i < 12{
//                        Password += "X"
//                    }else{
//                        let strIndex = cardNumber[i]
//                        Password += String(strIndex)
//                    }
//                }
//                txtCardNumber.text = Password
                txtCardNumber.text = cardNumber
                constCVVWidth.constant = 45
                txtCVV.isHidden = false
                txtCVV.becomeFirstResponder()
                txtExpiryDate.text = "\(cardInfo.value(forKey: keyCardMonth)!)/\(cardInfo.value(forKey: keyCardYear)!)"
            let type = cardInfo.value(forKey: keyCardName) as! String
            if let image = UIImage(named: "\(type.lowercased()).png") {
                cardImage.image = image
            }else {
                cardImage.image = UIImage(named: "stp_card_unknown.png")
            }
//            }catch{}
        }
    }
    @IBAction func onClick_back(_ sender: Any) {
        if isFromProfile{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func onClick_addCard(_ sender: Any) {
        
        if validation() {
        //    cardNumber = txtCardNumber.text!
            
            startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
            let cardParams = STPCardParams()
            cardParams.number = cardNumber
            cardParams.expYear = UInt(ex_year)!
            cardParams.expMonth = UInt(ex_month)!
            cardParams.cvc = txtCVV.text!
            
            STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
                guard let token = token, error == nil else {
                    print(error as Any)
                    let custView = customAlertView(title: "Error", message: (error?.localizedDescription)!, btnTitle: "OK")
                    custView.show(animated: true)
                    self.stopAnimating()
                    return
                }
                self.updateCustomer(token: token.tokenId)
            }
        }
    }

    func updateCustomer(token: String) {
        // let url = ""
        let strUrl = "\(BaseURl)/stripe/create_customer.php"
        let params: [String: Any] = [
            "email": snapUtils.currentUserModel.email,
            "phone":snapUtils.currentUserModel.mobileNo,
            "token" : token
        ]
        print(params)
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html", "application/json"])
        manager.requestSerializer.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        manager.securityPolicy.allowInvalidCertificates = true;
        manager.securityPolicy.validatesDomainName = false;
        manager.post(strUrl, parameters: params, success: {(operation, responseObject) in
            print(responseObject as Any)
            self.stopAnimating()
            let success = (responseObject as! NSDictionary).value(forKey: "succcess") as! Bool
            if success {
                let response = (responseObject as! NSDictionary).value(forKey: "response") as! NSDictionary
                let id = response.value(forKey: "id") as! String
                self.saveDataOnServer(id: id,token:token)
                if id != ""{
                    
                    let alert = UIAlertController(title: "", message: "Your card is successfully added!", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when){
                        alert.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }else{
                let response = (responseObject as! NSDictionary).value(forKey: "response") as! NSDictionary
                let error = response.value(forKey: "message") as! String
                let custView = customAlertView(title: "Error", message: error, btnTitle: "OK")
                custView.show(animated: true)
            }
        }, failure: { (operation, error) in
            print(error as Any)
        })
    }
    func saveDataOnServer(id:String,token:String){
        do{
            let cardNo = txtCardNumber.text?.suffix(4)
            let parameters:NSDictionary = [keyCardNumber: cardNo!,
                                           keyCardName: cardName,
                                           keyCardYear: ex_year,
                                           keyCardMonth: ex_month,
                                           keyCustomerId: id]
            let childUpdates = ["/\(nodeUsers)/\(snapUtils.currentUserModel.userId)/\(keyCardInfo)": parameters]
            self.ref.updateChildValues(childUpdates)
            if !isFromProfile{
                self.delegate.setCardData(cardInfo:parameters)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    func validation() -> Bool {
        if txtCardNumber.text == "" || txtCVV.text == "" || txtExpiryDate.text == ""{
            utils.emptyFieldValidation(txtCardNumber, view: self.view, tag: txtCardNumber.tag + 1)
            utils.emptyFieldValidation(txtCVV, view: self.view, tag: txtCVV.tag + 1)
            utils.emptyFieldValidation(txtExpiryDate, view: self.view, tag: txtExpiryDate.tag + 1)
            let custView = customAlertView(title: "Error", message: "All fileds are requireds.", btnTitle: "OK")
            custView.show(animated: true)
            return false
        }
        
        if expirationRegEx(dateString: txtExpiryDate.text!){
            let custView = customAlertView(title: "Error", message: "Invalid date. Please enter date in \"MM/YY\" format", btnTitle: "OK")
            custView.show(animated: true)
            return false
        }else{
            let arr = txtExpiryDate.text?.components(separatedBy: "/")
            ex_month = arr![0]
            ex_year = arr![1]
        }
        
        print(cardNumber)
        let (type, _, valid, image) = checkCardNumber(input: cardNumber)
        cardImage.image = image
        cardName = type.rawValue
        if !valid {
            let custView = customAlertView(title: "Error", message: "Invalid Card Data.", btnTitle: "OK")
            custView.show(animated: true)
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
    func expirationRegEx(dateString:String) -> Bool {
        let urlRegEx = "/^(0[1-9]|1[0-2])\\/?([0-9]{4}|[0-9]{2})$/"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: dateString)
    }

    func checkCardNumber(input: String) -> (type: CardType, formatted: String, valid: Bool, cardImage:UIImage) {
        // Get only numbers from the input string
        let numberOnly = input.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
        
        var type: CardType = .Unknown
        var formatted = ""
        var valid = false
        
        // detect card type
        for card in CardType.allCards {
            if (utils.matchesRegex(regex: card.regex, text: numberOnly)) {
                type = card
                break
            }
        }
        
        let image = utils.fetchcardImagebyItsType(type: type)
        
        // check validity
        valid = utils.luhnCheck(number: numberOnly)
        
        // format
        var formatted4 = ""
        for character in numberOnly {
            if formatted4.count == 4 {
                formatted += formatted4 + " "
                formatted4 = ""
            }
            formatted4.append(character)
        }
        
        formatted += formatted4 // the rest
        
        // return the tuple
        return (type, formatted, valid, image)
    }
    
    @IBAction func connectWithStripe()
    {
        let OAUTH_LINK="https://connect.stripe.com/express/oauth/authorize?client_id=\(STRIPE_CLIENT_ID)&state=Ankit89"
        let OAUTH_URL=URL(string:OAUTH_LINK)!
        
        let controller=STKWebKitModalViewController(url:OAUTH_URL)!
        controller.modalPresentationStyle = .fullScreen
        controller.webKitViewController.webView.navigationDelegate=self
        let navBarColor=UIColor(red:248/255, green:248/255, blue:248/255, alpha:1)
        let navigationController =
            controller.webKitViewController.navigationController!
        navigationController.navigationBar.isTranslucent=false
        navigationController.navigationBar.barTintColor=navBarColor
        present(controller, animated:true)
    }
    
    func webView(_ webView:WKWebView, decidePolicyFor navigationAction:WKNavigationAction, decisionHandler:@escaping(WKNavigationActionPolicy)->Void)
    {
        let url=navigationAction.request.url!
        
        if url.host=="www.classpath.co"
        {
            let urlComponents=url.query!.components(separatedBy:"&")
            let codeComponents=urlComponents[0].components(separatedBy:"=")
            getAccountID(codeComponents[1])
            btnConnectWithStripe.isHidden=true
            dismiss(animated:true)
        }
        
        decisionHandler(.allow)
    }
        
    func setDesign(){
        layoutUpdateAccordingToCountry()
        btnAgreement.setImage(#imageLiteral(resourceName: "ic_check_box"), for: .normal)
        btnAgreement.setImage(#imageLiteral(resourceName: "ic_check_box_fill"), for: .selected)
        txtCardNumber.delegate = self
        txtCVV.delegate = self
        txtExpiryDate.delegate = self
        txtAccountRouting.delegate = self
        txtAccountNumber.delegate = self
        txtBusinessType.delegate = self
        txtSSN.delegate = self
        
        btnSubmit.isEnabled = false
        
   //     btnAddCard.backgroundColor = themeColor
     //   btnAddCard.isEnabled = true
        
        let text = (lblAgreement.text)!
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Stripe Connected Account Agreement")
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        lblAgreement.attributedText = underlineAttriString
        
        let tapLabel : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
        tapLabel.delegate = self
        lblAgreement.isUserInteractionEnabled = true
        lblAgreement.addGestureRecognizer(tapLabel)
        
        //KeyBoard Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
        
    }

    func cardTextfieldShouldChange(textfield: UITextField, range: NSRange, string: String)-> Bool{
        if textfield.text != "" && textfield == txtCardNumber{
            let newLength = textfield.text!.count + string.count - range.length
            let isReturn = (newLength <= 15)
            if !isReturn{
                if txtCardNumber.text!.count == 15 {
                    txtCardNumber.text = "\(txtCardNumber.text!)\(string)"
                    cardNumber = txtCardNumber.text!
                    let (type, _, valid, image) = checkCardNumber(input: cardNumber)
                    cardImage.image = image
                    cardName = type.rawValue
                    if valid {
                        txtCardNumber.text = String(txtCardNumber.text!.suffix(4))
                        constCVVWidth.constant = 45
                        txtCVV.isHidden = false
                        txtExpiryDate.becomeFirstResponder()
                    }
                }
            }
            return isReturn
        }
        if textfield.text != "" && textfield == txtCVV {
            let newLength = textfield.text!.count + string.count - range.length
            let isReturn = (newLength <= 3)
            
            return isReturn
        }
        if textfield.text != "" && textfield == txtExpiryDate {
            let newLength = textfield.text!.count + string.count - range.length
            let isReturn = (newLength <= 5)
            if newLength == 3 && !((textfield.text?.contains("/"))!){
                textfield.text = "\(textfield.text!)/"
            }
            if !isReturn{
                txtCVV.becomeFirstResponder()
            }
            return isReturn
        }
        return true
    }

    //MARK: - Keyboard hide/show Method
    
    
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
        print(scrView)
    }
    @IBAction func onClick_btnPaymentInfo(_ sender: UIButton) {
        btnBankInfo.setTitleColor(textThemeColor, for: .normal)
        btnCreditCard.setTitleColor(textThemeColor, for: .normal)
        UIView.animate(withDuration: 1.0, animations: {
            if sender == self.btnCreditCard{
                self.leadingView.constant = 1000
                self.btnSave.isEnabled = true
            }else {
                self.leadingView.constant = 21
                self.btnSave.isEnabled = false
            }
        }, completion: nil)
        sender.setTitleColor(themeColor, for: .normal)
        leadingSelection.constant = sender.frame.origin.x
    }
    

}
