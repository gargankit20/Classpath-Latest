//
//  MyServiceVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/8/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MyServiceTableViewCell: UITableViewCell {
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var lblServiceDeal: UILabel!
    @IBOutlet weak var lblServiceCost: UILabel!
    @IBOutlet weak var lblServicePolicy: UILabel!
    @IBOutlet weak var view_shadow: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view_shadow.layer.shadowOpacity = 1
        view_shadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_shadow.layer.shadowRadius = 4.0
        view_shadow.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
    }
}
class MyServiceVC: UIViewController,UITableViewDelegate,UITableViewDataSource,NVActivityIndicatorViewable{

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    var arrServices = NSMutableArray()
    @IBOutlet weak var viewDefault: UIView!
    
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        ref = Database.database().reference()
        
        tblView.estimatedRowHeight = 100
        tblView.rowHeight = UITableView.automaticDimension
        tblView.tableFooterView = UIView(frame: CGRect.zero)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.btnAdd.isEnabled = true
        self.btnAdd.tintColor = themeColor
        callServicesApi()
    }
    
    func callServicesApi() {
         
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let _ = ref.child(nodeService).child(uid).observe(.value, with: { snapshot in
            self.ref.child(nodeService).child(uid).removeAllObservers()
            self.arrServices = NSMutableArray()
//            if snapshot.childrenCount == 3 {
//                self.btnAdd.isEnabled = false
//                self.btnAdd.tintColor = UIColor(hex: 0xF8F8F8)
//            }else{
//                self.btnAdd.isEnabled = true
//                self.btnAdd.tintColor = themeColor
//            }
            if !snapshot.exists() {
                // self.tblView.isHidden = true
                self.tblView.reloadData()
                self.stopAnimating()
                return
            }
            self.parseSnapShotForNoti(snapshotNoti: snapshot)
            
        })
        
    }
    func parseSnapShotForNoti(snapshotNoti: DataSnapshot){
        for child in snapshotNoti.children {
            let model =  ServiceModal()
            
            model.serviceID = (child as! DataSnapshot).key
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceName] as? String {
                model.serviceName = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceDesc] as? String {
                model.serviceDesc = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceDeal] as? String {
                model.serviceDeal = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceCost] as? String {
                model.serviceCost = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServicePolicy] as? String {
                model.servicePolicy = defaults
            }
            
            if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyInstantBook] as? Bool {
                model.instantBook = defaults
            }
            self.arrServices.add(model)
        }
        
        self.tblView.reloadData()
        self.stopAnimating()
    }
    
    //MARK: - UITableView Delegate & DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrServices.count == 0{
            viewDefault.isHidden = false
        }else {
            viewDefault.isHidden = true
        }
       return self.arrServices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "myServiceCell", for: indexPath) as! MyServiceTableViewCell
        
        var model : ServiceModal = ServiceModal()
        model = arrServices.object(at: indexPath.row) as! ServiceModal
        
        cell.lblServiceName.text = model.serviceName!
        cell.lblServiceDesc.text = model.serviceDesc!
        cell.lblServiceDeal.text = model.serviceDeal!
        cell.lblServiceCost.text = model.serviceCost!
        cell.lblServicePolicy.text = model.servicePolicy!
        
        cell.btnEdit.tag = indexPath.row
        cell.btnEdit.addTarget(self, action:#selector(editService(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action:#selector(handleServiceDelete(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { action, indexPath in
//            self.handleServiceDelete(indexPath: indexPath)
//        }
//        let edit = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { action, indexPath in
//            self.editService(indexPath: indexPath)
//        }
//        return [edit,delete]
//    }
    
    @objc func editService(sender: UIButton) {
        var model : ServiceModal = ServiceModal()
        model = arrServices.object(at: sender.tag) as! ServiceModal
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "AddServiceVC") as! AddServiceVC
        nextpage.isForEdit = true
        nextpage.model = model
        self.navigationController?.pushViewController(nextpage,animated: true)
    }
    
    @objc func handleServiceDelete(sender: UIButton) {
        let v = UIView()
        let custAlert = customAlertView.init(title: "Message", message: "Are you sure you want to delete this service?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
        custAlert.onRightBtnSelected = { (Value: String) in
            custAlert.dismiss(animated: true)
            self.deleteTimeFrameRelatedToService(tag: sender.tag)
        }
        custAlert.onLeftBtnSelected = { (Value: String) in
            custAlert.dismiss(animated: true)
        }
        custAlert.show(animated: true)
    }
    
    
    func deleteTimeFrameRelatedToService(tag: Int) {
        guard let uid = Auth.auth().currentUser?.uid else{return}
        var model : ServiceModal = ServiceModal()
        model = self.arrServices.object(at: tag) as! ServiceModal
        self.ref.child(nodeListings).queryOrdered(byChild: keyUserID).queryEqual(toValue: snapUtils.currentUserModel.userId).observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let listingId = (child as! DataSnapshot).key
                var services = NSMutableDictionary()
                if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServices] as? NSMutableDictionary {
                    services = defaults
                    if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyServiceHour] as? NSDictionary
                    {
                        for i in 1...7{
                            let nextDay = Calendar.current.date(byAdding: .day, value: i, to: Date())!
                            let keyDay = "\(nextDay.dayOfWeek()!)"
                            if let def = defaults.value(forKey: keyDay) as? NSMutableArray {
                                if let ser = services.value(forKey: keyDay) as? NSMutableDictionary {
                                    let defHours = def
                                    let defValue = def
                                    for i in defValue{
                                        if("\(i)".range(of: "Not available") == nil)
                                        {
                                            if let strSer = ser.object(forKey: i) as? String {
                                                var updateSer = strSer.replacingOccurrences(of: model.serviceID, with: "")
                                                updateSer = updateSer.trimmingCharacters(in: .whitespaces)
                                                let arrSer = strSer.components(separatedBy: " ")
                                                for j in arrSer {
                                                    if j == model.serviceID {
                                                        if updateSer == "" {
                                                            defHours.remove(i)
                                                            if defHours.count == 0 {
                                                                defHours.add("Not available on \(keyDay)")
                                                            }
                                                        }
                                                        let refInstance = self.ref.child(nodeListings).child(listingId)
                                                        refInstance.child(keyServiceHour).child(keyDay).setValue(defHours)
                                                        if updateSer == "" {
                                                            refInstance.child(keyServices).child(keyDay).removeValue()
                                                        }else{
                                                            refInstance.child(keyServices).child(keyDay).updateChildValues(["\(i)":updateSer])
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            let userInstance = self.ref.child(nodeService).child(uid)
            userInstance.child(model.serviceID).removeValue()
            
            let alert = UIAlertController(title: "", message: "Service successfully deleted!", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 2.5
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
            self.arrServices.removeObject(at: tag)
            self.tblView.reloadData()
        })
    }
}
