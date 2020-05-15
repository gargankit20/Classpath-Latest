//
//  PayViewController.swift
//  Classpath
//
//  Created by Coldfin on 04/09/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Stripe
import Firebase

class PayViewController: UIViewController,addCardSet,NVActivityIndicatorViewable {

    @IBOutlet weak var barHeight: NSLayoutConstraint!
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var lblUsingCard: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    
    var totalCost = ""
    var serviceName = ""
    var purchaseDescription = ""
    var numberOfTickets = ""
    var cardInfo = NSDictionary()
    var merchantId = ""
    var listingRegisterId = ""
    var model = BookingModel()
    var isInstantPay = false
    
    var ref: DatabaseReference!
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProText-SemiBold", size: 20)!,NSAttributedString.Key.foregroundColor: themeColor]
        setDesign()
    }
    
    
    
    //MARK: Set Design
    func setDesign(){
        if screenHeight >= 812{
            barHeight.constant = 88
        }else{
            barHeight.constant = 64
        }
        if cardInfo.count == 0{
            lblUsingCard.text = "Add Card"
        }else{
            let cardName = self.cardInfo.value(forKey: keyCardName)
            //do{
                //let cardNumber = try crypUtils.decryptMessage(encryptedMessage: self.cardInfo.value(forKey: keyCardNumber) as! String)
                lblUsingCard.text = "using \(cardName!) \(self.cardInfo.value(forKey: keyCardNumber) as! String)"
            //}catch{}
        }
        lblServiceName.text = "Service Name: \(serviceName)"
        lblTotalAmount.text = self.totalCost
    }
    
    //MARK: Actions
    @IBAction func OnClick_AddInfo(_ sender: Any) {
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "PaymentDetailsVC") as! PaymentDetailsVC
        nextPage.isFromProfile = false
        nextPage.delegate = self
        let navigationController = UINavigationController(rootViewController: nextPage)
        self.present(navigationController, animated: true)
    }
    @IBAction func onClickBuy(_ sender: Any) {
        
        startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        self.ref.child(nodeListingsRegistered).child(model.listingRegister).child(keySelectedSlot).child(keyAprooved).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                
                if self.lblUsingCard.text != "Add Card"{
                    print(self.totalCost)
                    var cost = self.totalCost.replace(target: "$", withString: "")
                    cost = cost.trimmingCharacters(in: .whitespaces)
                    print(cost)
                    //cost = String(cost).replace(target: ".", withString: "")
                    cost = cost.trimmingCharacters(in: .whitespaces)
                    let customerId = self.cardInfo.value(forKey: keyCustomerId) as! String
                    self.completeCharge(amount: Double(cost)!,merchantId: self.merchantId, customer: customerId)
                }else{
                    self.stopAnimating()
                    let custAlert = customAlertView(title: "Message", message: "Payment method missing. Add card to proceed?", btnTitle: "OK")
                    custAlert.show(animated: true)
                }
                
            }else {
                let custAlert = customAlertView(title: "Message", message: "Something went wrong. Sorry, you can't proceed further. ", btnTitle: "OK")
                custAlert.show(animated: true)
                
                self.stopAnimating()
            }
        })
    }
    
    @IBAction func backTapped(_ sender: Any) {
        let userInfo:[String: Bool] = ["isCancel": true]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "instantBook"), object: nil, userInfo: userInfo)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Charge complete
    func completeCharge(amount: Double,merchantId: String, customer: String) {
       // let url = ""
        
        let allCents = (amount * 100);
        
        let charges = (allCents*96.5)/100
        let stripefee = ((allCents*2.9)/100)+30
        
        let ownerPayment = charges-stripefee
        
        print(amount, ownerPayment, stripefee, charges)
        
        let currentDate=Date()
        let formatter=DateFormatter()
        formatter.dateFormat="MM-dd-yyyy"
        let someDate=formatter.string(from:currentDate)
        
        let strUrl = "\(BaseURl)/stripe/create_charge.php"
        let params: [String: Any] = ["customer": customer,
                                     "amount": allCents,
                                     "amountInUSD":String(format:"%.2f", amount),
                                     "description":purchaseDescription,
                                     "tickets":numberOfTickets,
                                     "name":snapUtils.currentUserModel.userName,
                                     "date":someDate,
                                     "merchant_account" : merchantId,
                                     "merchant_pay_amount" : Int(ownerPayment),
                                     "currency": "usd",
                                     "receipt_email": snapUtils.currentUserModel.email,
                                     "statement_descriptor": "Payment to Classpath"]
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
              //  print(responseObject as Any)
                let response = (responseObject as! NSDictionary).value(forKey: "response") as! NSDictionary
                let id = response.value(forKey: "id") as! String
                print("here--->id",id)
                self.ref.child("\(nodeListingsRegistered)/\(self.listingRegisterId)").updateChildValues([keyTransactionId: id])
                if self.isInstantPay {
                    let userInfo:[String:BookingModel] = ["model":self.model]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "instantBook"), object: nil, userInfo: userInfo)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ServiceBought"), object: nil, userInfo: nil)
                }
                let alert = UIAlertController(title: "", message: "You're transaction completed succesfully!", preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                    alert.dismiss(animated: true, completion: {() -> Void in
                    })
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }, failure: { (operation, error) in
            print(error as Any)
        })
    }
    
    //MARK: Delegate set method
    func setCardData(cardInfo:NSDictionary) {
        self.cardInfo = cardInfo
        setDesign()
    }
}
