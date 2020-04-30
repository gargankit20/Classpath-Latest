//
//  AddHoursPopUp.swift
//  Classpath
//
//  Created by Coldfin on 20/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit

protocol  addHoursPopUpsDelegate{
    func setData(day : String, str : String, serviceId: String)
}

class AddHoursPopUp: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    //   @IBOutlet weak var txtOfferedService: UITextField!
    @IBOutlet weak var lblPopUpTitle: UILabel!
    @IBOutlet weak var txtTOHours: UITextField!
    @IBOutlet weak var txtFromHOurs: UITextField!
    @IBOutlet weak var btnNotAvailable: UIButton!
    @IBOutlet weak var optionViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var popupHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var optionView: UIView!
    
    var NotAvailableCheckBoxSelected = false
    var toDate = Date()
    var fromDate = Date()
    let serviceKeyboardview = KeyboardPicker()
    var delegate : addHoursPopUpsDelegate!
    var arrServices = NSMutableArray()
    var registrationURL=""
    var dayName = ""
    var strOffer = ""
    var serviceIds = ""
    
    let scrView = UIScrollView()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = themeColor.cgColor
        
        
        
        
        setData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    func setData() {
        let arrSer = NSMutableArray()
        for i in arrServices {
            arrSer.add((i as! ServiceModal).serviceName)
        }
        
        lblPopUpTitle.text = "Set Hours for \(dayName)"
        btnNotAvailable.setTitle(" Not available on \(dayName)", for: .normal)
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
        
        btnNotAvailable.setImage(#imageLiteral(resourceName: "ic_check_box"), for: .normal)
        btnNotAvailable.setImage(#imageLiteral(resourceName: "ic_check_box_fill"), for: .selected)
        
        btnNotAvailable.isSelected = false
        
        txtFromHOurs.delegate = self
        txtTOHours.delegate = self
        txtFromHOurs.readonly = true
        txtTOHours.readonly = true
        
        //Tool bar for phone
        let keyboardNextButtonView : UIToolbar = UIToolbar()
        keyboardNextButtonView.sizeToFit()
        let nextButton : UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.textFieldShouldReturn(_:)))
        keyboardNextButtonView.isTranslucent = false
        nextButton.tintColor = UIColor.white
        nextButton.tag = txtTOHours.tag
        keyboardNextButtonView.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),nextButton], animated: true)
        keyboardNextButtonView.barTintColor = themeColor
        txtTOHours.inputAccessoryView = keyboardNextButtonView
        
        let keyboardNextButtonView2 : UIToolbar = UIToolbar()
        keyboardNextButtonView2.sizeToFit()
        let nextButton2 : UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.textFieldShouldReturn(_:)))
        keyboardNextButtonView2.isTranslucent = false
        nextButton2.tintColor = UIColor.white
        nextButton2.tag = txtFromHOurs.tag
        keyboardNextButtonView2.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),nextButton2], animated: true)
        keyboardNextButtonView2.barTintColor = themeColor
        txtFromHOurs.inputAccessoryView = keyboardNextButtonView2
        txtFromHOurs.becomeFirstResponder()
        
        txtFromHOurs.text = UserDefaults.standard.value(forKey: "from") as? String
        txtTOHours.text = UserDefaults.standard.value(forKey: "to") as? String
        if let c = UserDefaults.standard.value(forKey: "toDate") as? Date
        {
            toDate = c
            fromDate = (UserDefaults.standard.value(forKey: "fromDate") as? Date)!
        }
        
        if arrSer.count != 0 {
            //            let keyboardNextButtonView3 : UIToolbar = UIToolbar()
            //            keyboardNextButtonView3.sizeToFit()
            //            let nextButton3 : UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.textFieldShouldReturn(_:)))
            //            keyboardNextButtonView3.isTranslucent = false
            //            nextButton3.tintColor = UIColor.white
            //            nextButton3.tag = txtOfferedService.tag
            //            keyboardNextButtonView3.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),nextButton3], animated: true)
            //            keyboardNextButtonView3.barTintColor = themeColor
            //
            //            txtOfferedService.inputAccessoryView = keyboardNextButtonView3
            //
            //            txtOfferedService.text = strOffer
            //            self.serviceKeyboardview.Values = arrSer as! [String]
            //            self.serviceKeyboardview.Font = UIFont(name: "SFProText-Regular", size: 20)
            //            self.serviceKeyboardview.onDateSelected = { (Value: String) in
            //                self.txtOfferedService.text = Value
            //            }
            //            self.txtOfferedService.inputView = self.serviceKeyboardview
            
            var yFrame:CGFloat = 0
            var tag = 1
            
            for i in arrSer {
                let btnCheckBox = UIButton(frame: CGRect(x: 10, y: yFrame, width: optionView.frame.width-20, height: 30.0))
                btnCheckBox.setTitleColor(textThemeColor, for: .normal)
                btnCheckBox.setImage(#imageLiteral(resourceName: "ic_check_box"), for: .normal)
                btnCheckBox.setImage(#imageLiteral(resourceName: "ic_check_box_fill"), for: .selected)
                btnCheckBox.tag = tag
                btnCheckBox.contentHorizontalAlignment = .left
                if tag == 1{
                    btnCheckBox.isSelected = true
                    let modal = arrServices.object(at: tag-1) as! ServiceModal
                    self.serviceIds = modal.serviceID
                }else {
                    btnCheckBox.isSelected = false
                }
                btnCheckBox.addTarget(self, action: #selector(onSelect_service(_:)), for: .touchUpInside)
                btnCheckBox.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 16)
                btnCheckBox.setTitle("  \(i as! String)", for: .normal)
                scrView.addSubview(btnCheckBox)
                yFrame += 35
                tag += 1
            }
            scrView.contentSize = CGSize(width: optionView.frame.width, height: yFrame)
            var heightOption:CGFloat = 105
            if yFrame < 105 {
                heightOption = yFrame
            }
            scrView.frame = CGRect(x: 0, y: 0, width: optionView.frame.width, height: heightOption)
            optionView.addSubview(scrView)
            scrView.flashScrollIndicators()
            optionViewHeightConstant.constant = heightOption
            popupHeightConstant.constant += heightOption
            
            if yFrame > 105 {
                timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(scrollIndicator), userInfo: nil, repeats: true)
            }
        }else
        {
            
        }
        print(self.serviceIds)
    }
    
    @objc func scrollIndicator(){
        scrView.flashScrollIndicators()
    }
    
    @objc func onSelect_service(_ sender:UIButton) {
        if sender.isSelected == true {
            let modal = arrServices.object(at: sender.tag-1) as! ServiceModal
            self.serviceIds = self.serviceIds.replacingOccurrences(of: modal.serviceID, with: "")
            sender.isSelected = false
        }else{
            let modal = arrServices.object(at: sender.tag-1) as! ServiceModal
            self.serviceIds = "\(self.serviceIds) \(modal.serviceID)"
            sender.isSelected = true
        }
        self.serviceIds = self.serviceIds.trimmingCharacters(in: .whitespaces)
        print(self.serviceIds)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1;
        let nextResponder = self.view.viewWithTag(nextTag) as? UITextField
        if (nextResponder != nil)   {
            nextResponder?.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == txtTOHours){
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.tag = 1
            datePickerView.backgroundColor = UIColor.white
            datePickerView.datePickerMode = UIDatePicker.Mode.time
            datePickerView.date = toDate as Date
            textField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(self.EndDatedatePickerValueChanged), for: UIControl.Event.valueChanged)
        }else if(textField == txtFromHOurs){
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.tag = 2
            datePickerView.backgroundColor = UIColor.white
            datePickerView.datePickerMode = UIDatePicker.Mode.time
            datePickerView.date = fromDate as Date
            textField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(self.EndDatedatePickerValueChanged), for: UIControl.Event.valueChanged)
        }
    }
    
    @objc func EndDatedatePickerValueChanged(_ sender:UIDatePicker) {
        if(sender.tag == 1)
        {
            let dateFormatter = DateFormatter()
            toDate = sender.date
            dateFormatter.dateStyle = DateFormatter.Style.none
            dateFormatter.timeStyle = DateFormatter.Style.short
            txtTOHours.text = dateFormatter.string(from: sender.date)
        }else if(sender.tag == 2)
        {
            let dateFormatter = DateFormatter()
            fromDate = sender.date
            dateFormatter.dateStyle = DateFormatter.Style.none
            dateFormatter.timeStyle = DateFormatter.Style.short
            txtFromHOurs.text = dateFormatter.string(from: sender.date)
        }
    }
    
    //MARK: - UITextField Delegate Method
    @objc func tapView(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func onClick_btnNotAvailable(_ sender: Any) {
        NotAvailableCheckBoxSelected = !NotAvailableCheckBoxSelected
        btnNotAvailable.isSelected = NotAvailableCheckBoxSelected
        
        txtFromHOurs.isEnabled = !NotAvailableCheckBoxSelected
        txtTOHours.isEnabled = !NotAvailableCheckBoxSelected
    }
    
    func validateTextfields() -> Bool
    {
        if(txtFromHOurs.text == "" || txtTOHours.text == "")
        {
            let custAlert = customAlertView(title: "Message", message: "Required field(s) empty", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        if(fromDate > toDate)
        {
            let custAlert = customAlertView(title: "Message", message: "Please enter proper service time.", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        
        if registrationURL == ""
        {
            if self.serviceIds == ""
            {
                let custAlert = customAlertView(title: "Message", message: "Please select at least one service or Not Available", btnTitle: "OK")
                custAlert.show(animated: true)
                return false
            }
        }
        
        return true
    }
    
    @IBAction func onClick_btnSubmit(_ sender: Any) {
        
        
        if(NotAvailableCheckBoxSelected){
            self.dismiss(animated: true) {
                let str = "Not available on \(self.dayName)"
                self.delegate.setData(day: self.dayName, str : str, serviceId:self.serviceIds)
            }
            return
        }
        if(validateTextfields())
        {
            self.dismiss(animated: true) {
                let str = "\(self.txtFromHOurs.text!)-\(self.txtTOHours.text!)"
                self.delegate.setData(day: self.dayName, str : str, serviceId:self.serviceIds)
                UserDefaults.standard.setValue(self.txtTOHours.text, forKey: "to")
                UserDefaults.standard.setValue(self.txtFromHOurs.text, forKey: "from")
                UserDefaults.standard.setValue(self.toDate, forKey: "toDate")
                UserDefaults.standard.setValue(self.fromDate, forKey: "fromDate")
            }
        }
    }
    
    @IBAction func onClick_Cancel(_ sender:Any){
        self.dismiss(animated: true, completion: nil)
    }
}
