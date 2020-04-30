//
//  InvoiceVC.swift
//  ClassPath
//
//  Created by coldfin_lb on 6/27/18.
//  Copyright © 2018 Coldfin. All rights reserved.
//

import UIKit
import Stripe
import Firebase

class InvoiceVC: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var lblListingName: UILabel!
    @IBOutlet weak var lblOwnerName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserNumber: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var lblAppointmentDate: UILabel!
    @IBOutlet weak var lblAppointmentTime: UILabel!
    @IBOutlet weak var lblServiceCosts: UILabel!
    @IBOutlet weak var lblRefundPolicy: UILabel!
    @IBOutlet weak var lblTickets: UILabel!
    @IBOutlet weak var lblTotalCost: UILabel!
    @IBOutlet weak var lblDeals: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    
    var merchantId = ""
    var ref: DatabaseReference!
    
    var serviceName = ""
    var serviceCost = ""
    var servicePolicy = ""
    var serviceDeal = ""
    var serviceDesc = ""
    
    var userNumber = ""
    var userEmail = ""
    var cardInfo = NSMutableDictionary()
    var isPayment = false
    var isInstantPay = false
    
    var model = BookingModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = themeColor.cgColor
        
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        ref = Database.database().reference()
        fetchInvoiceData()

    }
    override func viewWillAppear(_ animated: Bool) {
        if isPayment {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func fetchInvoiceData() {
        guard let uid = Auth.auth().currentUser?.uid else{return}
      
        
        self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: uid).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            
            if let defaults = (snapshot.value as! NSDictionary)[keyUsername] as? String {
                self.model.userName = "\(defaults)"
            }
            if let defaults = (snapshot.value as! NSDictionary)[keyMobileno] as? String {
                self.userNumber = "\(defaults)"
            }
            if let defaults = (snapshot.value as! NSDictionary)[keyEmail] as? String {
                self.userEmail = defaults
            }
            if let defaults = (snapshot.value as! NSDictionary)[keyCardInfo] as? NSMutableDictionary {
                self.cardInfo = defaults
            }
            
            print(self.model.userId)
            self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: self.model.userId).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                
                if let defaults = (snapshot.value as! NSDictionary)[keyUsername] as? String {
                    self.model.listingOwnerName = "\(defaults)"
                }
    
                
                if let defaults = (snapshot.value as! NSDictionary)[keyMerchantId] as? String {
                    self.merchantId = defaults
                }
                self.ref.child(nodeService).child(self.model.userId).child( self.model.serviceId).observeSingleEvent(of: .value, with: { snapshot in
                    
                        if let defaults = (snapshot.value as! NSDictionary)[keyServiceName] as? String {
                            self.serviceName = defaults
                        }
                        
                        if let defaults = (snapshot.value as! NSDictionary)[keyServiceDesc] as? String {
                            self.serviceDesc = defaults
                        }
                        
                        if let defaults = (snapshot.value as! NSDictionary)[keyServiceDeal] as? String {
                            self.serviceDeal = defaults
                        }
                        
                        if let defaults = (snapshot.value as! NSDictionary)[keyServiceCost] as? String {
                            self.serviceCost = defaults
                        }
                        
                        if let defaults = (snapshot.value as! NSDictionary)[keyServicePolicy] as? String {
                            self.servicePolicy = defaults
                        }
                        self.setData()
                        self.stopAnimating()
                        self.scrView.isHidden = false

                })
            })
        })
    }
    
    func setData() {
        lblListingName.text = model.title
        lblOwnerName.text = model.listingOwnerName
        lblLocation.text = model.listingAddress
        lblDescription.text = model.listing_description
        lblUsername.text = model.userName
        lblUserNumber.text = userNumber
        lblUserEmail.text = userEmail
        lblService.text = serviceName
        lblServiceDesc.text = serviceDesc
        
        lblServiceCosts.text = serviceCost
        lblRefundPolicy.text = servicePolicy
        lblDeals.text = serviceDeal
        
        lblTickets.text = String(model.ticketsCount)
        var cost = serviceCost.replace(target: "$", withString: "")
        cost = cost.trimmingCharacters(in: .whitespaces)
        
        lblTotalCost.text = String(format: "$%.2f", arguments: [Double(cost)! * Double(model.ticketsCount)])
        
        let dateArr = model.strDate.components(separatedBy: " at")
        var bookingTime:String = dateArr[1]
        bookingTime = bookingTime.trimmingCharacters(in: .whitespaces)
        lblAppointmentTime.text = bookingTime
        
        let dateAsString = utils.convertStringToDate(model.dateReminder, dateFormat: "MM-dd-yyyy")
        let bookingDate = utils.convertDateToString(dateAsString, format: "EEEE,MMMM d,yyyy")

        lblAppointmentDate.text = bookingDate 
    }
    
    @IBAction func onClick_Payment(_ sender: Any) {
       // var cost = self.serviceCost.replace(target: "$", withString: "")
    //cost = cost.replace(target: ".", withString: "")
        
        self.serviceCost = self.serviceCost.trimmingCharacters(in: .whitespaces)
        isPayment = true
        let payViewController = self.storyboard?.instantiateViewController(withIdentifier: "PayViewController") as! PayViewController
        payViewController.totalCost = self.lblTotalCost.text!
        payViewController.serviceName = self.serviceName
        payViewController.cardInfo =  self.cardInfo
        payViewController.isInstantPay = self.isInstantPay
        payViewController.merchantId = self.merchantId
        payViewController.listingRegisterId = model.listingRegister
        payViewController.model = model
        let navigationController = UINavigationController(rootViewController: payViewController)
        self.present(navigationController, animated: true)
        
    }
    
    @IBAction func onClick_Cancel(_ sender: Any) {
        let userInfo:[String: Bool] = ["isCancel": true]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "instantBook"), object: nil, userInfo: userInfo)
        self.dismiss(animated: true, completion: nil)
    }
  
   

}
