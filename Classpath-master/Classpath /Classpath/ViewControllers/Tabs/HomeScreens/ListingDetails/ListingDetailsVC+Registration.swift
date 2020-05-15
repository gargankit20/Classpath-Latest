//
//  ListingDetailsVC+Registration.swift
//  Classpath
//
//  Created by Coldfin on 24/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import WebKit

extension ListingDetailsVC{
  
    func getAlreadyBooked()
    {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let _ = ref.child(nodeListingsRegistered).queryOrdered(byChild: keyUid).queryEqual(toValue: uid).observe(.value, with: { snapshot in
            if !snapshot.exists() {return}
            for child in snapshot.children {
                if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyListingId] as? String {
                    if(defaults == self.model.listingID){
                        if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keySelectedSlot] as? NSDictionary {
                            if let c = defaults.value(forKey: keyConfirmed) as? NSDictionary
                            {
                                if let c = c.value(forKey: self.result) as? NSArray
                                {
                                    let arr = c.mutableCopy() as! NSMutableArray
                                    for i in arr {
                                        self.alreadyBookedSlotsAprooved.add(i)
                                    }
                                    self.isRegistered = true
                                }
                            }
                            if let c = defaults.value(forKey: keyAprooved) as? NSDictionary
                            {
                                if let c = c.value(forKey: self.result) as? NSArray
                                {
                                    let arr = c.mutableCopy() as! NSMutableArray
                                    for i in arr {
                                        self.alreadyBookedSlotsAprooved.add(i)
                                    }
                                    self.isRegistered = true
                                }
                            }
                            if let c = defaults.value(forKey: keyPending) as? NSDictionary
                            {
                                if let c = c.value(forKey: self.result) as? NSArray
                                {
                                    let arr = c.mutableCopy() as! NSMutableArray
                                    for i in arr { 
                                        self.alreadyBookedSlotsPending.add(i)
                                    }
                                    self.isRegistered = true
                                }
                            }
                            if let c = defaults.value(forKey: keyRejected) as? NSDictionary
                            {
                                if let c = c.value(forKey: self.result) as? NSArray
                                {
                                    let arr = c.mutableCopy() as! NSMutableArray
                                    for i in arr {
                                        self.alreadyBookedSlotsRejected.add(i)
                                    }
                                    self.isRegistered = true
                                }
                            }
                            if let c = defaults.value(forKey: keyCancelled) as? NSDictionary
                            {
                                if let c = c.value(forKey: self.result) as? NSArray
                                {
                                    let arr = c.mutableCopy() as! NSMutableArray
                                    for i in arr {
                                        self.alreadyBookedSlotsCancelled.add(i)
                                    }
                                    self.isRegistered = true
                                }
                            }
                        }
                    }
                }
            }
        })
    }
  
    @IBAction func onClick_btnRegistar(_ sender: UIButton) {
       
        if sender.titleLabel?.text == "Instant Book"{
            isInstantBook = true
            createSlot4newUser(isListingURL:false)
        }else{
            if (model.listingURL.count == 0)
            {
                if validation() {
                    if arrSlotServices.count != 0{
                        let arrServices = arrSlotServices.object(at: slotIndex) as! NSMutableArray
                        if arrServices.count != 0 {
                            servicePopUp(arrServices:arrServices)
                        }
                        else{
                            self.registerfromSlot(isListingURL:false)
                        }
                    }else{
                        self.registerfromSlot(isListingURL:false)
                    }
                }
                
            }else{
                if validation(){
                    self.openURL()
                    if !isRegistered {
                  //      self.registerfromSlot(isListingURL:true)
                    }
                }
            }
        }
    }
    
    func servicePopUp(arrServices:NSMutableArray) {
        let viewCheckBox = UIView(frame: CGRect(x: 0, y: 0, width: 310, height: 0))
        var yFrame:CGFloat = 0
        var tag = 1
        for i in arrServices {
            let model = i as! ServiceModal
            let btnCheckBox = UIButton(frame: CGRect(x: 15, y: yFrame, width: 280, height: 40.0))
            btnCheckBox.setTitleColor(textThemeColor, for: .normal)
            btnCheckBox.setImage(#imageLiteral(resourceName: "ic_check_box"), for: .normal)
            btnCheckBox.setImage(#imageLiteral(resourceName: "ic_check_box_fill"), for: .selected)
            btnCheckBox.tag = tag
            btnCheckBox.contentHorizontalAlignment = .left
            if tag == 1{
                btnCheckBox.isSelected = true
                let modal = arrServices.object(at: 0) as! ServiceModal
                self.serviceId = modal.serviceID
            }else {
                btnCheckBox.isSelected = false
            }
            btnCheckBox.addTarget(self, action: #selector(onSelect_service(_:)), for: .touchUpInside)
            btnCheckBox.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 16)
            btnCheckBox.setTitle("  \(model.serviceName!) at \(model.serviceCost!)", for: .normal)
            viewCheckBox.addSubview(btnCheckBox)
            yFrame += 45
            tag += 1
        }
        
        var message = ""
        if arrServices.count == 1 {
            let modal = arrServices.object(at: 0) as! ServiceModal
            self.serviceId = modal.serviceID
            viewCheckBox.frame =  CGRect(x: 0, y: 0, width: 300, height: 0)
            viewCheckBox.isHidden = true
            message = "\(modal.serviceName!) at \(modal.serviceCost!)"
        }else {
            message = "Select the service to continue"
           viewCheckBox.frame =  CGRect(x: 0, y: 0, width: 300, height: yFrame)
        }
        
        let alert = customAlertView(title: "Service available", message: message, customView: viewCheckBox, leftBtnTitle: "Cancel", rightBtnTitle: "Submit", image: #imageLiteral(resourceName: "ic_done"))
        
        alert.onRightBtnSelected = { (Value: String) in
            // if btnCheckBox.isSelected == true{
            self.registerfromSlot(isListingURL:false)
            alert.dismiss(animated: true)
            //      self.isServiceSelected = true
            // }
        }
        alert.show(animated: true)
    }
    
    func validation() -> Bool
    {
        if model.listingURL.count == 0 {
            if(isToday)
            {
                if(model.availableslotsToday.count == 0)
                {
                    let alert = UIAlertController(title: "", message: "No timeframe available", preferredStyle: UIAlertController.Style.alert)
                    self.present(alert, animated: true, completion: nil)
                    // change to desired number of seconds (in this case 5 seconds)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        alert.dismiss(animated: true, completion: {() -> Void in
                        })
                    })
                    return false
                }
            }else
            {
                if(model.availableslotsTomorrow.count == 0)
                {
                    let alert = UIAlertController(title: "", message: "No timeframe available", preferredStyle: UIAlertController.Style.alert)
                    self.present(alert, animated: true, completion: nil)
                    // change to desired number of seconds (in this case 5 seconds)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        alert.dismiss(animated: true, completion: {() -> Void in
                        })
                    })
                    return false
                }
            }
        }
        
        guard let uid = Auth.auth().currentUser?.uid else{
            let alert = UIAlertController(title: "", message: "Oops! Something went wrong. Please try again", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            // change to desired number of seconds (in this case 5 seconds)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alert.dismiss(animated: true, completion: {() -> Void in
                })
            })
            
            return false
        }
        
        if !checkUserOwnListing(uid:uid) {
           return false
        }
        
        if !isAlreadySelected() {
            return false
        }
        
        if model.listingURL.count == 0 {
            if(self.slotSelected == "") //&& (!isRegistered)
            {
                let alert = UIAlertController(title: "", message: "Please select a timeframe to register", preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
                // change to desired number of seconds (in this case 5 seconds)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                    alert.dismiss(animated: true, completion: {() -> Void in
                    })
                })
                return false
                
            }
        }
        
        if model.listingURL.count == 0 {
            if snapUtils.currentUserModel.Verification != "true"{
                
                let v = UIView()
                let custAlert = customAlertView.init(title: "Message", message: "Phone verification required. Would you like to proceed?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
                custAlert.onRightBtnSelected = { (Value: String) in
                    custAlert.dismiss(animated: true)
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextPage = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                    let nav = UINavigationController(rootViewController: nextPage)
                    self.present(nav, animated: true, completion: nil)
                    // self.navigationController?.pushViewController(nextPage, animated: true)
                }
                custAlert.onLeftBtnSelected = { (Value: String) in
                    custAlert.dismiss(animated: true)
                    
                }
                custAlert.show(animated: true)
                
                return false
            }
        }
        return true
    }
    
    func checkUserOwnListing(uid:String) -> Bool {
        if(model.userid == uid)
        {
//            let alert = UIAlertController(title: "", message: "You can't register for your own listing", preferredStyle: UIAlertControllerStyle.alert)
//            self.present(alert, animated: true, completion: nil)
//            // change to desired number of seconds (in this case 5 seconds)
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
//                alert.dismiss(animated: true, completion: {() -> Void in
//                })
//            })
            
            btnRegister.isEnabled = false
            btnRegister.backgroundColor = textThemeColor
            
            return false
        }
        return true
    }
    
    func isAlreadySelected() -> Bool {
        
        print(alreadyBookedSlotsRejected)
        
        if(self.alreadyBookedSlotsAprooved.contains(self.slotSelected) || self.alreadyBookedSlotsPending.contains(self.slotSelected) || self.alreadyBookedSlotsRejected.contains(self.slotSelected) || self.alreadyBookedSlotsCancelled.contains(self.slotSelected))
        {
            if model.listingURL.count != 0 {
                isRegistered = true
                btnRegister.isEnabled = true
                btnRegister.backgroundColor = themeColor
            }else{
                isRegistered = false
                
                btnRegister.isEnabled = false
                btnRegister.backgroundColor = textThemeColor
                
                //                let alert = UIAlertController(title: "", message: "You've already submitted a request to register for this timeframe today. Please select a different one", preferredStyle: UIAlertControllerStyle.alert)
                //                self.present(alert, animated: true, completion: nil)
                //                // change to desired number of seconds (in this case 5 seconds)
                //                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                //                    alert.dismiss(animated: true, completion: {() -> Void in
                //                    })
                //                })
                return false
            }
        }
        
        btnRegister.isEnabled = true
        btnRegister.backgroundColor = themeColor
        
        return true
    }
    
    func openURL()
    {
        if(model.listingURL != "")
        {
            if (model.listingURL.hasPrefix("https://")) || (model.listingURL.hasPrefix("http://")){
                openUrl(urlString:model.listingURL)
            }else {
                let correctedURL = "http://\(model.listingURL ?? "")"
                openUrl(urlString:correctedURL)
            }
        }
    }

    func openUrl(urlString:String!) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "WebViewPopUp") as! WebViewPopUp
        modalViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.urlString = urlString
        self.present(modalViewController, animated: true, completion: nil)
        
        
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
    }
    
    @objc func onSelect_service(_ sender:UIButton){
        let arrServices = arrSlotServices.object(at: slotIndex) as! NSMutableArray
        let view = sender.superview
        for i in 0...arrServices.count-1 {
            if let btn = view?.viewWithTag(i+1) as? UIButton{
                btn.isSelected = false
            }
            
            if i == sender.tag-1 {
                let modal = arrServices.object(at: i) as! ServiceModal
                self.serviceId = modal.serviceID
            }
        }
        sender.isSelected = true
    }
    
    func registerfromSlot(isListingURL:Bool){
        if arrSlotServices.count != 0 {
            let arrServices = arrSlotServices.object(at: slotIndex) as! NSMutableArray
            for i in arrServices{
                let modal = i as! ServiceModal
                if modal.serviceID == self.serviceId{
                    if modal.instantBook {
                        btnRegister.setTitle("Instant Book", for: .normal)
                        return
                    }
                }
            }
        }
        if (model.distance > 30){
            let alert = UIAlertController(title: "", message: "You can only register for listings within a 30 mile radius of your current location", preferredStyle: .alert)
            
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
            
        }else{
            if(validation())
            {
                 
                self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                let _ = ref.child(nodeListingsRegistered).queryOrdered(byChild: keyUid).queryEqual(toValue: snapUtils.currentUserModel.userId).observe(.value, with: { snapshot in
                    self.ref.child(nodeListingsRegistered).removeAllObservers()
                   // if !snapshot.exists() {
                        
                        self.register4NewUserID(isListingURL:isListingURL)
               //     }else
//                    {
//                        self.stopAnimating()
//                        var isExist = false
//                        var childSnap = DataSnapshot()
//                        for child in snapshot.children {
//                            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyListingId] as? String {
//                                if(defaults == self.model.listingID){
//                                    isExist = true
//                                    childSnap = child as! DataSnapshot
//                                }
//                            }
//                        }
//                        if(isExist)
//                        {
//                            if isListingURL == false{
//
//                                let v = UIView()
//                                let custAlert = customAlertView.init(title: "", message: "You're about to send a registration request to this listing owner for the timeframe selected. Would you like to proceed?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
//                                custAlert.onRightBtnSelected = { (Value: String) in
//                                    custAlert.dismiss(animated: true)
//                                    self.createslot(childSnap: childSnap, isListingURL: isListingURL)
//                                }
//                                custAlert.onLeftBtnSelected = { (Value: String) in
//                                    custAlert.dismiss(animated: true)
//                                }
//                                custAlert.show(animated: true)
//                                return
//                            }else{
//                                self.createslot(childSnap: childSnap,isListingURL:isListingURL)
//                            }
//                        }else{
//                            self.register4NewUserID(isListingURL: isListingURL)
//                            return
//                        }
//                    }
                })
            }
        }
    }
    
    func createslot(childSnap:DataSnapshot,isListingURL:Bool) {
        
        let parameter = NSMutableDictionary()
        parameter.setValue(snapUtils.currentUserModel.userId, forKey:keyUid)
        parameter.setValue(self.model.listingID, forKey:keyListingId)
        parameter.setValue(self.serviceId, forKey: keyServiceId)
        parameter.setValue(String(self.ticketsCount), forKey: keyTicketsCount)
        if isListingURL == true{
            self.alreadyBookedSlotsAprooved.add(self.slotSelected.trimmingCharacters(in: .whitespaces))
        }else{
            self.alreadyBookedSlotsPending.add(self.slotSelected.trimmingCharacters(in: .whitespaces))
        }
        parameter.setValue(Date().localDateString(), forKey: keyRequestTime)
        let dic = NSMutableDictionary()
        dic.setValue([self.result: self.alreadyBookedSlotsPending], forKey: keyPending)
        dic.setValue([self.result: self.alreadyBookedSlotsAprooved], forKey: keyConfirmed)
        dic.setValue([self.result: self.alreadyBookedSlotsRejected], forKey: keyRejected)
        dic.setValue([self.result: self.alreadyBookedSlotsCancelled], forKey: keyRejected)
        parameter.setValue(dic, forKey:keySelectedSlot)
        
        
        let regInstance = self.ref.child(nodeListingsRegistered).child((childSnap).key)
        regInstance.setValue(parameter)
        if isListingURL == true{
            regInstance.child(keySelectedSlot).child(keyConfirmed).child(self.result).setValue(self.alreadyBookedSlotsAprooved)
        }else{
            regInstance.child(keySelectedSlot).child(keyPending).child(self.result).setValue(self.alreadyBookedSlotsPending)
            let alert = UIAlertController(title: "", message: "Registration request successfully sent. You’ll be notified once the listing owner has responded", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 2.5
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
        if isListingURL != true{
            var time = Double()
            time = NSDate().timeIntervalSince1970
//            var title = String()
//            title = self.model.title
            
            let day = isToday ? "today":"tomorrow"
            
            let msg = "Hey "+self.lblOwner.text!.trimmingCharacters(in:.whitespacesAndNewlines)+"! "+snapUtils.currentUserModel.userName.trimmingCharacters(in:.whitespacesAndNewlines)+" is requesting to join your session "+day+" from "+self.slotSelected.trimmingCharacters(in:.whitespacesAndNewlines)+"."
//            "Hi \(self.lblOwner.text!)! \(snapUtils.currentUserModel.userName) has sent request for listing :\(title)"
            var regID = String()
            var listingID = String()
            listingID = self.model.listingID
            regID = self.model.userid
            
            snapUtils.SendNotification(receiverId: regID, message: msg, timeStamp: time, listingId: listingID)
            self.updateCount(uid: self.model.userid)
            self.registerCount(isListingURL: isListingURL)
        }
    }
    
    func registerCount(isListingURL:Bool){
        
        let _ = ref.child(nodeUsers).child(self.model.userid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                //Exist
                var dic = NSMutableDictionary()
                if let defaults = (snapshot.value as! NSDictionary)[keyRegisterClick] as? NSDictionary {
                    dic = defaults.mutableCopy() as! NSMutableDictionary
                }
                var str:String = ""
                if dic.value(forKey: self.model.listingID) != nil{
                    str = dic.value(forKey: self.model.listingID) as! String
                }
                
                if str != Date().localDateStringOnlyDate(){
                    self.ref.child(nodeListings).child(self.model.listingID).child(keyNoofRegister).observeSingleEvent(of: .value, with: { snapshot in
                        self.ref.child(nodeListings).child(self.model.listingID).child(keyNoofRegister).removeAllObservers()
                        dic.setValue(Date().localDateStringOnlyDate(), forKey: self.model.listingID)
                        let userInstance = self.ref.child(nodeUsers).child(self.model.userid)
                        userInstance.updateChildValues([keyRegisterClick:dic])
                        
                        
                    })
                }else{
                    dic.setValue(Date().localDateStringOnlyDate(), forKey: self.model.listingID)
                    let userInstance = self.ref.child(nodeUsers).child(self.model.userid)
                    userInstance.updateChildValues([keyRegisterClick:dic])
                
                }
                
            }
        })
    }
    
    func updateCount(uid: String)
    {
        let _ = ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: uid).observe(.childAdded, with: { snapshot in
           // self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: uid).removeAllObservers()
            var count = 1
            if let defaults = (snapshot.value as! NSDictionary)[keyPendingNotificationCount] as? Int {
                count = defaults + 1
            }
            let userInstance = self.ref.child(nodeUsers).child(uid)
            userInstance.updateChildValues([keyPendingNotificationCount : count])
        })
    }
    
    func register4NewUserID(isListingURL:Bool)
    {
        self.stopAnimating()
        if isListingURL == true{
            
            self.createSlot4newUser(isListingURL:isListingURL)
        }else{
            let v = UIView()
            let custAlert = customAlertView.init(title: "", message: "Sending a registration request to the listing owner for the timeframe and service selected. Would you like to proceed?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
                self.createSlot4newUser(isListingURL:isListingURL)
            }
            custAlert.onLeftBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
            }
            custAlert.show(animated: true)
        }
        return
    }
    func  createSlot4newUser(isListingURL:Bool) {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        self.registerCount(isListingURL: isListingURL)
        
        let parameter = NSMutableDictionary()
        parameter.setValue(uid, forKey:keyUid)
        parameter.setValue(self.model.listingID, forKey:keyListingId)
        parameter.setValue(self.serviceId, forKey: keyServiceId)
        parameter.setValue(String(self.ticketsCount), forKey: keyTicketsCount)
        if isInstantBook{
            parameter.setValue(true, forKey: "isInstantBook")
        }
        
        parameter.setValue(Date().localDateString(), forKey: keyRequestTime)
        
        let dic=NSMutableDictionary()
        
        if isListingURL == true{
            self.alreadyBookedSlotsAprooved.add(self.slotSelected.trimmingCharacters(in: .whitespaces))
        }else{
            if isInstantBook
            {
                let arrApproved=NSMutableArray()
                arrApproved.add(self.slotSelected.trimmingCharacters(in: .whitespaces))
                dic.setValue([self.result:arrApproved], forKey:keyAprooved)
                //alreadyBookedSlotsAprooved.add(self.slotSelected.trimmingCharacters(in:.whitespaces))
            }
            else
            {
                let arrPending=NSMutableArray()
                arrPending.add(self.slotSelected.trimmingCharacters(in: .whitespaces))
                dic.setValue([self.result:arrPending], forKey:keyPending)
                //alreadyBookedSlotsPending.add(self.slotSelected.trimmingCharacters(in: .whitespaces))
            }
        }
        
        if isListingURL == true{
            dic.setValue([self.result: self.alreadyBookedSlotsAprooved], forKey: keyConfirmed)
        }else{
            //dic.setValue([self.result: self.alreadyBookedSlotsAprooved], forKey: keyAprooved)
        }
        //dic.setValue([self.result: self.alreadyBookedSlotsRejected], forKey: keyRejected)
        //dic.setValue([self.result: self.alreadyBookedSlotsCancelled], forKey: keyRejected)
        parameter.setValue(dic, forKey:keySelectedSlot)
        
        let userInstance = self.ref.child(nodeListingsRegistered).childByAutoId()
        userInstance.setValue(parameter)
        let listingRegisterID = userInstance.key
        
        if isInstantBook {
            self.getBookingData(param: parameter, listingRegisterID:listingRegisterID!)
        }else {
            if isListingURL == false{
                
                let alert = UIAlertController(title: "", message: "Registration request successfully sent. You’ll be notified once the listing owner has responded", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                let when = DispatchTime.now() + 2.5
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                }
                var time = Double()
//                var title = String()
//                title = self.model.title
                time = NSDate().timeIntervalSince1970
                
                let day = isToday ? "today":"tomorrow"
                
                let msg = "Hey "+self.lblOwner.text!.trimmingCharacters(in:.whitespacesAndNewlines)+"! "+snapUtils.currentUserModel.userName.trimmingCharacters(in:.whitespacesAndNewlines)+" is requesting to join your session "+day+" from "+self.slotSelected.trimmingCharacters(in:.whitespacesAndNewlines)+"."
//                "Hi \(self.lblOwner.text!)! \(snapUtils.currentUserModel.userName) has sent request for listing :\(title)"
                var regID = String()
                var listingID = String()
                listingID = self.model.listingID
                regID = self.model.userid
                
                snapUtils.SendNotification(receiverId: regID, message: msg, timeStamp: time, listingId: listingID)
                self.updateCount(uid: self.model.userid)
            }
        }
    }
    func getBookingData(param:NSMutableDictionary, listingRegisterID:String){
        
        if let slot = param.value(forKey: keySelectedSlot) as? NSDictionary {
            if let def = slot.value(forKey: keyAprooved) as? NSDictionary {
                let child2 = def.allKeys
                for i  in child2
                {
                    let d = def.value(forKey: i as! String) as! NSArray
                    for j in d
                    {
                        let strTime = j as! String
                        if(strTime == "") {
                        } else {
                            
                            bookingMod.slotArr = d
                            bookingMod.slot_selected = j as! String
                            bookingMod.slotDate = i as! String
                            bookingMod.listingRegister = listingRegisterID
                            let g = (j as! String).components(separatedBy: "-")
                            let start = g[0]
                            // let end = ""
                            let end = g[1]
                            
                            let k = utils.convertStringToDate(i as! String + " "  + start, dateFormat: "MM-dd-yyyy h:mm a")
                            
                            let m = utils.convertStringToDate(i as! String, dateFormat: "MM-dd-yyyy")
                            
                            bookingMod.weekDay = k.dayOfWeek() ?? ""
                            bookingMod.appoint_date = k
                            bookingMod.strDate = utils.convertDateToString(m, format: "E, MMM d") + " from \(start) to \(end)"
                            bookingMod.dateReminder = utils.convertDateToString(m, format: "MM-dd-yyyy")
                            bookingMod.listingStatus = "PENDING"
                            bookingMod.ticketsCount = self.ticketsCount
                            bookingMod.listingID = model.listingID
                            bookingMod.images = model.images
                            bookingMod.listing_description =  model.listing_description
                            bookingMod.title =  model.title
                            bookingMod.serviceId  = serviceId
                            bookingMod.userId = model.userid
                            bookingMod.listingAddress = model.address
                            bookingMod.listingURL = model.listingURL
                            
                        }
                    }
                }
            }
        }
        let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "InvoiceVC") as! InvoiceVC
        modalViewController.model =  bookingMod
        modalViewController.isInstantPay = true
        modalViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.modalTransitionStyle = .crossDissolve
        self.present(modalViewController, animated: true, completion: nil)
    }
    
    @objc func paymentDoneSuccess(_ notification: NSNotification){
        
        if let _ = notification.userInfo?["isCancel"] as? Bool {
            if self.bookingMod.listingRegister != "" {
                self.ref.child(nodeListingsRegistered).child(self.bookingMod.listingRegister).removeValue()
            }
        }else {
            var timer = Timer()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(payDone), userInfo: nil, repeats: false)

            if let modBook = notification.userInfo?["model"] as? BookingModel{
                
                ref.child(nodeListingsRegistered).child(modBook.listingRegister).child(keySelectedSlot).child(keyAprooved).child(modBook.slotDate).observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists(){
                        self.ref.child(nodeListingsRegistered).child(modBook.listingRegister).child(keySelectedSlot).child(keyAprooved).removeValue()
                        let arraySlice=modBook.slotArr.prefix(1)
                        let newArray=Array(arraySlice); self.ref.child(nodeListingsRegistered).child(modBook.listingRegister).child(keySelectedSlot).child(keyConfirmed).child(modBook.slotDate).setValue(newArray)
                        snapUtils.SendNotification(receiverId : modBook.userId, message : "Congratulation, you have a client booked", timeStamp : NSDate().timeIntervalSince1970,listingId: modBook.listingRegister)
                    }
                })
            }
        }
    }
    
    @objc func payDone(){
        btnRegister.setTitle("Request a session", for: .normal)
        let custAlert = customAlertView(title: "Payment successful", message: "You're all set. Tap the time slot to add the appointment to your calendar.", btnTitle: "OK")
        custAlert.onBtnSelected = { (Value: String) in
            custAlert.dismiss(animated: true)
            self.navigateToBookingTab()
        }
        custAlert.show(animated: true)
    }
}
