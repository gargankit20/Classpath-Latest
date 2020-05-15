//
//  ViewController.swift
//  Classpath
//
//  Created by coldfin_lb on 8/8/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import Gallery
import AVFoundation
import FirebaseStorage

protocol addEditListdelegate {
    func reloadList()
    func deletedList(list: ListingModel)
}

class previewPhotoCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
}

class addPhotoCell: UICollectionViewCell {
    @IBOutlet weak var btnAddImage: UIButton!
}

class AddListingVC: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate,NVActivityIndicatorViewable{
    
    var delegate : addEditListdelegate!
    var isForEdit : Bool = false
    var ref: DatabaseReference!
    var editListModel = ListingModel()
    var arrServices = NSMutableArray()
    
    var sunSlotServices = NSMutableDictionary()
    var monSlotServices = NSMutableDictionary()
    var tueSlotServices = NSMutableDictionary()
    var wedSlotServices = NSMutableDictionary()
    var thuSlotServices = NSMutableDictionary()
    var friSlotServices = NSMutableDictionary()
    var satSlotServices = NSMutableDictionary()
    
    var paramOfferedServices = NSMutableDictionary()
    var parameter = NSMutableDictionary()
    @IBOutlet weak var txtSunday: TLTagsControl!
    @IBOutlet weak var txtMonday: TLTagsControl!
    @IBOutlet weak var txtTuesday: TLTagsControl!
    @IBOutlet weak var txtWednesday: TLTagsControl!
    @IBOutlet weak var txtThursday: TLTagsControl!
    @IBOutlet weak var txtFriday: TLTagsControl!
    @IBOutlet weak var txtSaturday: TLTagsControl!
    @IBOutlet weak var viewAddMedia:UIView!
    @IBOutlet weak var collViewImages:UICollectionView!
    
    @IBOutlet weak var txtListingURL: UITextField!
     @IBOutlet weak var txtAddress: AutoCompleteTextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtCertificates: UITextField!
    @IBOutlet weak var txtdescription: UITextField!
    @IBOutlet weak var txtBusinessWebsite: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
   // @IBOutlet weak var txtExpirationDate: UITextField!
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var lblcerti: UILabel!
    
    @IBOutlet weak var viewCertificateHeight: NSLayoutConstraint!
    @IBOutlet weak var viewCertificates: UIView!
    @IBOutlet weak var btn_certificateClose: UIButton!
    @IBOutlet weak var btn_certificateHeight: NSLayoutConstraint!

    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()
    
    var arrPhotos = NSMutableArray()
    var videoIndex = 10
    var videoURLString = ""
    var videoURL : URL!
    var videoImage = UIImage()
    var monServiceNotSelected=false
    var tueServiceNotSelected=false
    var wedServiceNotSelected=false
    var thuServiceNotSelected=false
    var friServiceNotSelected=false
    var satServiceNotSelected=false
    var sunServiceNotSelected=false
    let CategotyKeyboardview = KeyboardPicker()
    var locationCoordinate : CLLocationCoordinate2D!
    
    
    //MARK: View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Gallery.Config.VideoEditor.maximumDuration = 30
        if(arrPhotos.count == 0){
            collViewImages.isHidden = true
            viewAddMedia.isHidden = false
        }else
        {
            viewAddMedia.isHidden = true
            collViewImages.isHidden = false
        }
        ref = Database.database().reference()
        setDesign()
        if(isForEdit)
        {
            setData()
        }
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        getServicesData()
    }
    
    func setDesign()
    {
        utils.configureTextField(txtAddress)
        utils.handleTextFieldInterfaces(txtAddress)
        
        utils.onSelectAddress = { (Value) in
            self.txtListingURL.becomeFirstResponder()
            utils.getCoordinates(text: Value, completionHandler: {(locCoordinate) in
                self.locationCoordinate = locCoordinate
            })
        }
        
        //Set delegate
        txtCertificates.delegate = self
        txtCategory.delegate = self
        txtTitle.delegate = self
        txtAddress.delegate = self
        txtListingURL.delegate = self
        txtdescription.delegate = self
        txtBusinessWebsite.delegate = self
        
        //KeyBoard Observer
        NotificationCenter.default.addObserver(self,selector:#selector(self.keyboardWillShow(_:)),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIResponder.keyboardWillHideNotification,object: nil)
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
        
        let keyboardNextButtonView2 : UIToolbar = UIToolbar()
        keyboardNextButtonView2.sizeToFit()
        let nextButton2 : UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.textFieldShouldReturn(_:)))
        keyboardNextButtonView2.isTranslucent = false
        nextButton2.tintColor = UIColor.white
        nextButton2.tag = txtCategory.tag
        keyboardNextButtonView2.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),nextButton2], animated: true)
        keyboardNextButtonView2.barTintColor = themeColor
        
        txtCategory.inputAccessoryView = keyboardNextButtonView2
        
        txtCategory.text = arrCategory2[0]
        self.CategotyKeyboardview.Values = arrCategory2
        self.CategotyKeyboardview.Font = UIFont(name: "SFProText-Regular", size: 20)
        self.CategotyKeyboardview.onDateSelected = { (Value: String) in
            self.txtCategory.text = Value
        }
        self.txtCategory.inputView = self.CategotyKeyboardview
    }
    
    func setData()
    {
        //        guard let uid = Auth.auth().currentUser?.uid else{
        //            return
        //        }
        // nav = "forupdate"
        self.title = "Edit Listing"
         
        startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        var c = 0
        print(editListModel.images)
        for img in editListModel.images {
            print(img)
            let storageRef = Storage.storage().reference(forURL: "\(img)")
            storageRef.downloadURL(completion: { (url, error) in

                do{
                    let data = try Data(contentsOf: url!)
                    let image:UIImage = UIImage(data: data as Data)!
                    
                    self.arrPhotos.add(image)
                    self.collViewImages.reloadData()
                    self.scrView.bringSubviewToFront(self.collViewImages)
                    self.collViewImages.isHidden = false
                    c += 1
                    if(c == self.editListModel.images.count)
                    {
                        self.stopAnimating()
                        if self.editListModel.Video != ""{
                            self.videoURLString = self.editListModel.Video
                            self.videoURL = URL(string: self.videoURLString)!
                            self.videoIndex = self.arrPhotos.count
                            print(self.videoIndex)
                            utils.thumbnailForVideoAtURL(url: self.videoURL, completionHandler: {
                                image in
                                self.videoIndex = self.arrPhotos.count
                                self.videoImage = image
                                self.arrPhotos.add(image)
                                self.collViewImages.reloadData()
                            })
                        }
                    }
                    
                }catch let error {
                    print(error.localizedDescription)
                    self.stopAnimating()
                    c += 1
                    if(c == self.editListModel.images.count)
                    {
                        self.stopAnimating()
                    }
                }
            })
        }
        
        self.txtdescription.text = editListModel.listing_description
        self.txtCategory.text = editListModel.category
        self.lblcerti.text = editListModel.certificates
        print(editListModel.certificates)
        let height = utils.heightForView(text: lblcerti.text!, font: lblcerti.font, width: lblcerti.frame.width)
        viewCertificateHeight.constant = height+55
        self.txtTitle.text = editListModel.title
        self.txtAddress.text = editListModel.address
        self.txtListingURL.text = editListModel.listingURL
        
        if(editListModel.businessURL == "" || editListModel.businessURL == "N/A")
        {
            self.txtBusinessWebsite.text = ""
        }else{
            self.txtBusinessWebsite.text = editListModel.businessURL
        }
        
        paramOfferedServices = editListModel.services
        
        if let defaults =  paramOfferedServices.value(forKey: "Sunday") as? NSMutableDictionary{
            sunSlotServices = defaults
            
            sunServiceNotSelected=checkServiceSelected(sunSlotServices)
            
        }
        if let defaults =  paramOfferedServices.value(forKey: "Monday") as? NSMutableDictionary{
            monSlotServices = defaults
            
            monServiceNotSelected=checkServiceSelected(monSlotServices)
            
        }
        if let defaults =  paramOfferedServices.value(forKey: "Tuesday") as? NSMutableDictionary{
            tueSlotServices = defaults
            
            tueServiceNotSelected=checkServiceSelected(tueSlotServices)
            
        }
        if let defaults =  paramOfferedServices.value(forKey: "Wednesday") as? NSMutableDictionary{
            wedSlotServices = defaults
            
            wedServiceNotSelected=checkServiceSelected(wedSlotServices)
            
        }
        if let defaults =  paramOfferedServices.value(forKey: "Thursday") as? NSMutableDictionary{
            thuSlotServices = defaults
            
            thuServiceNotSelected=checkServiceSelected(thuSlotServices)
            
        }
        if let defaults =  paramOfferedServices.value(forKey: "Friday") as? NSMutableDictionary{
            friSlotServices = defaults
            
            friServiceNotSelected=checkServiceSelected(friSlotServices)
            
        }
        if let defaults =  paramOfferedServices.value(forKey: "Saturday") as? NSMutableDictionary{
            satSlotServices = defaults
            
            satServiceNotSelected=checkServiceSelected(satSlotServices)
            
        }
        
        
        for val in editListModel.serviceHours.Sunday
        {
            let str = "\(val) "
            self.txtSunday.addTag(str)
            self.txtSunday.tapDelegate = self
        }
        for val in editListModel.serviceHours.Monday
        {
            let str = "\(val) "
            self.txtMonday.addTag(str)
            self.txtMonday.tapDelegate = self
        }
        for val in editListModel.serviceHours.Tuesday
        {
            let str  = "\(val) "
            self.txtTuesday.addTag(str)
            self.txtTuesday.tapDelegate = self
        }
        for val in editListModel.serviceHours.Wednesday
        {
            let str = "\(val) "
            self.txtWednesday.addTag(str)
            self.txtWednesday.tapDelegate = self
        }
        for val in editListModel.serviceHours.Thursday
        {
            let str = "\(val) "
            self.txtThursday.addTag(str)
            self.txtThursday.tapDelegate = self
        }
        for val in editListModel.serviceHours.Friday
        {
            let str = "\(val) "
            self.txtFriday.addTag(str)
            self.txtFriday.tapDelegate = self
        }
        for val in editListModel.serviceHours.Saturday
        {
            let str = "\(val) "
            self.txtSaturday.addTag(str)
            self.txtSaturday.tapDelegate = self
        }
    }
    
    func checkServiceSelected(_ slotServices:NSMutableDictionary)->Bool
    {
        var serviceNotSelected=false
        
        let allTimeSlots=slotServices.allKeys
        
        for val in allTimeSlots
        {
            if !(val as! String).contains("Not available on")
            {
                let serviceIDs=slotServices.value(forKey:val as! String) as! String
                
                if serviceIDs.count==0
                {
                    serviceNotSelected=true
                }
            }
        }
        
        return serviceNotSelected
    }
    
    @objc func tapView(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    //MARK: UITextField delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtAddress {
            lblError.isHidden = true
            if textField.text != "" {
                let newLength = textField.text!.count + string.count - range.length
                return newLength <= 65
            }
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtCertificates{
            
            let str:String = lblcerti.text!
            if ((str.range(of: "\(txtCertificates.text!)")) == nil){
                if lblcerti.text == "" || lblcerti.text == "None"{
                    lblcerti.text = (txtCertificates.text!)
                }else{
                    lblcerti.text = "\(str),\((txtCertificates.text!))"
                }
            }
            let height = utils.heightForView(text: lblcerti.text!, font: lblcerti.font, width: lblcerti.frame.width)
            viewCertificateHeight.constant = height+55
            txtCertificates.text = ""
        }else{
            let nextTag = textField.tag + 1;
            let nextResponder = self.view.viewWithTag(nextTag) as? UITextField
            if (nextResponder != nil)   {
                nextResponder?.becomeFirstResponder()
            }else{
                self.view.endEditing(true)
            }
            
        }
        return false
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
    
    //MARK:  Fetch location
    func getLocation(address:String){
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            self.stopAnimating()
            guard let placemarks = placemarks else{
                self.lblError.isHidden = false
                self.txtAddress.becomeFirstResponder()
                self.txtAddress.addBorder(color: UIColor.red, thickness: 1.0)
                self.scrView.setContentOffset(CGPoint(x: 0, y: self.txtAddress.frame.origin.y-50), animated: true)
                return
            }
            self.lblError.isHidden = true
            let location = placemarks.first?.location
            
            self.fetchCity(location:location!){city in
                utils.listingCity=city
            }
            
            let coordinate = location?.coordinate
            self.locationCoordinate = coordinate
            
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onClick_Submit), userInfo: nil, repeats: false)
            // Use your location
        }
    }
    
    func fetchCity(location:CLLocation, completion:@escaping(String)->())
    {
        CLGeocoder().reverseGeocodeLocation(location){placemarks, error in
            if let error=error
            {
                print(error)
            }
            else if let city=placemarks?.first?.locality
            {
                completion(city)
            }
        }
    }

    func showServicesPopup()
    {
        let v=UIView()
        let custAlert=customAlertView.init(title:"Service missing", message:"A listing without a registration page requires at least one service. Would you like to create one now?", customView:v, leftBtnTitle:"No", rightBtnTitle:"Yes", image: #imageLiteral(resourceName: "ic_done"))
        custAlert.onRightBtnSelected={(Value:String) in
            custAlert.dismiss(animated:true)
            let storyboard:UIStoryboard=UIStoryboard(name:"Main", bundle:nil)
            let nextPage=storyboard.instantiateViewController(withIdentifier:"MyServiceVC") as! MyServiceVC
            self.navigationController?.pushViewController(nextPage, animated:true)
        }
        custAlert.onLeftBtnSelected={(Value:String) in
            custAlert.dismiss(animated:true)
        }
        custAlert.show(animated: true)
    }
    
    func getServicesData()
    {
        guard let uid=Auth.auth().currentUser?.uid else{
            return
        }
        
        let _=ref.child(nodeService).child(uid).observe(.value, with:{snapshot in
            self.arrServices=NSMutableArray()
            if snapshot.exists()
            {
                for child in snapshot.children
                {
                    let model = ServiceModal()
                    model.serviceID=(child as! DataSnapshot).key
                    if let defaults=((child as! DataSnapshot).value as! NSDictionary)[keyServiceName] as? String
                    {
                        model.serviceName=defaults
                    }
                    
                    self.arrServices.add(model)
                }
            }
        })
    }

    //MARK: Actions
    
    @IBAction func btn_CancelCertificates(_ sender: UIButton) {
        txtCertificates.becomeFirstResponder()
        lblcerti.text = ""
        txtCertificates.text = ""
        btn_certificateHeight.constant = 0
        viewCertificateHeight.constant = 65
    }
    
    @IBAction func btn_AddCertificates(_ sender: UIButton) {
        txtCertificates.becomeFirstResponder()
        let temp = lblcerti.text!
        print(temp)
        
        if temp != ""{
            let str = temp + "," + txtCertificates.text!
            lblcerti.text = str
            txtCertificates.text = ""
            let height = utils.heightForView(text: lblcerti.text!, font: lblcerti.font, width: lblcerti.frame.width)
            btn_certificateHeight.constant = 30
            viewCertificateHeight.constant = height+55
        }else{
            lblcerti.text = txtCertificates.text!
            txtCertificates.text = ""
            if lblcerti.text != ""{
                let height = utils.heightForView(text: lblcerti.text!, font: lblcerti.font, width: lblcerti.frame.width)
                btn_certificateHeight.constant = 30
                viewCertificateHeight.constant = height+55
            }
        }
    }
    
    @IBAction func onClick_Browse(_ sender: Any) {
        
        gallery = GalleryController()
        gallery.delegate = self
        
        present(gallery, animated: true, completion: nil)
    }
    
    @IBAction func onClick_addHours(_ sender: UIButton)
    {
        if arrServices.count==0 && txtListingURL.text==""
        {
            showServicesPopup()
            return
        }
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "AddHoursPopUp") as! AddHoursPopUp
        modalViewController.arrServices = arrServices
        modalViewController.delegate = self
        modalViewController.registrationURL=txtListingURL.text!
        switch sender.tag {
        case 15:
            print(paramOfferedServices)
            var serviceId = ""
            if let defaults =  paramOfferedServices.value(forKey: "Sunday") as? String{
                serviceId = defaults
            }
            for i in arrServices {
                if ((i as! ServiceModal).serviceID == serviceId){
                    modalViewController.strOffer = (i as! ServiceModal).serviceName
                    break
                }else if serviceId == ""{
                    modalViewController.strOffer = (arrServices.object(at: 0) as! ServiceModal).serviceName
                    break
                }
            }
            modalViewController.dayName = "Sunday"
            break;
        case 16:
            var serviceId = ""
            if let defaults =  paramOfferedServices.value(forKey: "Monday") as? String{
                serviceId = defaults
            }
            for i in arrServices {
                if ((i as! ServiceModal).serviceID == serviceId){
                    modalViewController.strOffer = (i as! ServiceModal).serviceName
                    break
                }else if serviceId == ""{
                    modalViewController.strOffer = (arrServices.object(at: 0) as! ServiceModal).serviceName
                    break
                }
            }
            modalViewController.dayName = "Monday"
            break;
        case 17:
            var serviceId = ""
            if let defaults =  paramOfferedServices.value(forKey: "Tuesday") as? String{
                serviceId = defaults
            }
            for i in arrServices {
                if ((i as! ServiceModal).serviceID == serviceId){
                    modalViewController.strOffer = (i as! ServiceModal).serviceName
                    break
                }else if serviceId == ""{
                    modalViewController.strOffer = (arrServices.object(at: 0) as! ServiceModal).serviceName
                    break
                }
            }
            modalViewController.dayName = "Tuesday"
            break;
        case 18:
            var serviceId = ""
            if let defaults =  paramOfferedServices.value(forKey: "Wednesday") as? String{
                serviceId = defaults
            }
            for i in arrServices {
                if ((i as! ServiceModal).serviceID == serviceId){
                    modalViewController.strOffer = (i as! ServiceModal).serviceName
                    break
                }else if serviceId == ""{
                    modalViewController.strOffer = (arrServices.object(at: 0) as! ServiceModal).serviceName
                    break
                }
            }
            modalViewController.dayName = "Wednesday"
            break;
        case 19:
            var serviceId = ""
            if let defaults =  paramOfferedServices.value(forKey: "Thursday") as? String{
                serviceId = defaults
            }
            for i in arrServices {
                if ((i as! ServiceModal).serviceID == serviceId){
                    modalViewController.strOffer = (i as! ServiceModal).serviceName
                    break
                }else if serviceId == ""{
                    modalViewController.strOffer = (arrServices.object(at: 0) as! ServiceModal).serviceName
                    break
                }
            }
            modalViewController.dayName = "Thursday"
            break;
        case 20:
            var serviceId = ""
            if let defaults =  paramOfferedServices.value(forKey: "Friday") as? String {
                serviceId = defaults
            }
            for i in arrServices {
                if ((i as! ServiceModal).serviceID == serviceId){
                    modalViewController.strOffer = (i as! ServiceModal).serviceName
                    break
                }else if serviceId == ""{
                    modalViewController.strOffer = (arrServices.object(at: 0) as! ServiceModal).serviceName
                    break
                }
            }
            modalViewController.dayName = "Friday"
            break;
        case 21:
            var serviceId = ""
            if let defaults =  paramOfferedServices.value(forKey: "Saturday") as? String {
                serviceId = defaults
            }
            for i in arrServices {
                if ((i as! ServiceModal).serviceID == serviceId){
                    modalViewController.strOffer = (i as! ServiceModal).serviceName
                    break
                }else if serviceId == ""{
                    modalViewController.strOffer = (arrServices.object(at: 0) as! ServiceModal).serviceName
                    break
                }
            }
            modalViewController.dayName = "Saturday"
            break;
        default:
            modalViewController.strOffer =  ""
            modalViewController.dayName = ""
        }
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func onClick_Submit(_ sender: UIButton)
    {
        if ValidateTextField()
        {
            if txtListingURL.text==""
            {
                if arrServices.count>0
                {
                    txtTitle.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                    txtCategory.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                    txtListingURL.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                    txtAddress.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                    txtBusinessWebsite.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                    
                    startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                    
                    if(locationCoordinate == nil)
                    {
                        getLocation(address:txtAddress.text!)
                        return
                    }
                    
                    createVideoStorageURL()
                }
                else
                {
                    showServicesPopup()
                }
            }
            else
            {
                txtTitle.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                txtCategory.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                txtListingURL.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                txtAddress.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                txtBusinessWebsite.addBorder(color:  UIColor.lightGray.withAlphaComponent(0.2), thickness: 1.0)
                
                startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                
                if(locationCoordinate == nil)
                {
                    getLocation(address:txtAddress.text!)
                    return
                }
                
                createVideoStorageURL()
            }
        }
    }
    func furtherSubmitRequest() {
        if videoIndex != 10 {
            if videoIndex <= arrPhotos.count-1 {
                arrPhotos.removeObject(at: videoIndex)
            }
        }
        uploadImages(userId: snapUtils.currentUserModel.userId,imagesArray : arrPhotos as! [UIImage]){ (uploadedImageUrlsArray) in
            self.stopAnimating()
            let parameterServices = NSMutableDictionary()
            
            var str = self.getSlotDays(str: self.txtSunday.tags)
            parameterServices.setValue(str, forKey:"Sunday" )
            
            str = self.getSlotDays(str: self.txtMonday.tags)
            parameterServices.setValue(str, forKey: "Monday")
            
            str = self.getSlotDays(str: self.txtTuesday.tags)
            parameterServices.setValue(str, forKey: "Tuesday")
            
            str = self.getSlotDays(str: self.txtWednesday.tags)
            parameterServices.setValue(str, forKey: "Wednesday")
            
            str = self.getSlotDays(str: self.txtThursday.tags)
            parameterServices.setValue(str, forKey: "Thursday")
            
            str = self.getSlotDays(str: self.txtFriday.tags)
            parameterServices.setValue(str, forKey: "Friday")
            
            str = self.getSlotDays(str: self.txtSaturday.tags)
            parameterServices.setValue(str, forKey: "Saturday")
            
            
            self.parameter.setValue(self.txtTitle.text, forKey:keyTitle)
            self.parameter.setValue(self.txtCategory.text, forKey:keyCategory)
            self.parameter.setValue(self.lblcerti.text, forKey:keyCertificates)
            if self.lblcerti.text! == ""{
                self.parameter.setValue("Not applicable", forKey:keyCertificates)
            }
            self.parameter.setValue(self.txtdescription.text, forKey: keyDescription)
            self.parameter.setValue(uploadedImageUrlsArray, forKey: keyImages)
            self.parameter.setValue(self.locationCoordinate.latitude, forKey: keyLat)
            self.parameter.setValue(self.locationCoordinate.longitude, forKey: keyLong)
            self.parameter.setValue(self.txtAddress.text!, forKey: KeyListingAddress)
            self.parameter.setValue(self.txtListingURL.text!, forKey: keyURL)
            
            
            self.parameter.setValue(self.txtBusinessWebsite.text!, forKey: keyBusinessWebsite)
            self.parameter.setValue(parameterServices, forKey: keyServiceHour)
            self.parameter.setValue(self.paramOfferedServices, forKey: keyServices)
            self.parameter.setValue(true, forKey: keyIsOpen)
            self.parameter.setValue(snapUtils.currentUserModel.userId, forKey: keyUserID)
            self.parameter.setValue(self.videoURLString, forKey: keyVideo)
            self.parameter.setValue(self.editListModel.Expiration_Date, forKey: keyExpirationDate)
            self.parameter.setValue(self.editListModel.noofRegister, forKey: keyNoofRegister)
            self.parameter.setValue(self.editListModel.views, forKey: keyViews)
            self.parameter.setValue(self.editListModel.NoofTimesReviewed, forKey: keyNoofTimesReviewed)
            self.parameter.setValue(self.editListModel.NoofTimesRecommended, forKey: keyNoofTimesRecommended)
            
            if(self.isForEdit)
            {
                
                self.ref.child(nodeListings).child(self.editListModel.listingID)
                
                // Remove the image from storage
                let storage =  Storage.storage()
                let imgs = self.editListModel.images
                
                for i in imgs!
                {
                    let imageRef = storage.reference(forURL: i as! String)
                    imageRef.delete { error in
                        if error != nil {
                            print("Uh-oh, an error occurred!")
                        } else {
                            print("File deleted successfully")
                        }
                    }
                }
                self.editListModel.images = uploadedImageUrlsArray as NSArray
                self.editListModel.title = self.txtTitle.text
                self.editListModel.category = self.txtCategory.text
                self.editListModel.certificates = self.lblcerti.text
                self.editListModel.listing_description = self.txtdescription.text
                self.editListModel.latitude = self.locationCoordinate.latitude
                self.editListModel.longitude = self.locationCoordinate.longitude
                self.editListModel.address = self.txtAddress.text!
                self.editListModel.listingURL = self.txtListingURL.text!
                self.editListModel.Video = self.videoURLString
                
                self.editListModel.businessURL = self.txtBusinessWebsite.text!
                let slotModel2 = SlotSelectionModel()
                
                let defaults = parameterServices
                if let default2 = defaults.value(forKey: "Sunday") as? NSArray {
                    slotModel2.Sunday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Monday") as? NSArray {
                    slotModel2.Monday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Tuesday") as? NSArray {
                    slotModel2.Tuesday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Wednesday") as? NSArray {
                    slotModel2.Wednesday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Thursday") as? NSArray {
                    slotModel2.Thursday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Friday") as? NSArray {
                    slotModel2.Friday = default2.mutableCopy() as! NSMutableArray
                }
                
                if let default2 = defaults.value(forKey: "Saturday") as? NSArray {
                    slotModel2.Saturday = default2.mutableCopy() as! NSMutableArray
                }
                self.editListModel.serviceHours = slotModel2
                self.delegate.reloadList()
                print(self.parameter)
                let childUpdates = ["/\(nodeListings)/\(self.editListModel.listingID)": self.parameter]
                
                self.ref.updateChildValues(childUpdates)
                
            }else{
               
                let key = self.ref.child(nodeListings).childByAutoId().key
                let childUpdates = ["/\(nodeListings)/\(key ?? "")": self.parameter]
                self.ref.updateChildValues(childUpdates)
                snapUtils.sendMultipleNotifications(listingName:self.txtTitle.text!, listingId: key!)
                self.updateOwnerBadge()
            }
            
            let alert = UIAlertController(title: "", message: (self.isForEdit) ? "Listing edited successfully." : "Listing added successfully.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    func updateOwnerBadge() {
        let userRef = self.ref.child(nodeUsers).child(snapUtils.currentUserModel.userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            var badges = NSArray()
            if let defaults = (snapshot.value as! NSDictionary)[keyBadges] as? NSArray{
                badges = defaults
            }
            if badges.count == 1{
                let arr = ["Athlete","Pro Trainer"]
                userRef.updateChildValues([keyBadges:arr])
            }
            var count = 1
            if let defaults = (snapshot.value as! NSDictionary)[keyListingCount] as? Int {
                count += defaults
            }
            userRef.updateChildValues([keyListingCount:count])
        }
        
    }
    
    
    //MARK: Slot data
    func getSlotDays(str: NSMutableArray) ->(NSMutableArray)
    {
        let strArr = NSMutableArray()
        for i in str
        {
            strArr.add("\(i)".trimmingCharacters(in: .whitespaces))
        }
        return (strArr)
    }
    //MARK: Image Storage
    func uploadImages(userId: String, imagesArray : [UIImage], completionHandler: @escaping ([String]) -> ()){
        let storage =  Storage.storage()
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = imagesArray.count
        
        for image in imagesArray{
            
            let imageName =  String(arc4random()) + ((NSString(format: "%.0f.jpg", Date().timeIntervalSince1970) as NSString) as String)
            let storageRef = storage.reference().child("\(userId)").child(imageName)
            let myImage = image
            guard let uplodaData = myImage.pngData() else{
                return
            }
            let uploadTask = storageRef.putData(uplodaData, metadata: nil, completion: { (metadata, error) in
                if error != nil, metadata != nil {
                    print(error ?? "")
                    return
                }
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    if let imageUrl = url?.absoluteString {
                        uploadedImageUrlsArray.append(imageUrl)
                        uploadCount += 1
                        if uploadCount == imagesCount{
                            completionHandler(uploadedImageUrlsArray)
                        }
                    }
                })
                
            })
            observeUploadTaskFailureCases(uploadTask : uploadTask)
        }
    }
    
    func observeUploadTaskFailureCases(uploadTask :  StorageUploadTask ){
        uploadTask.observe(.failure) { snapshot in
            
            if let error = snapshot.error as NSError? {
                var msg = ""
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    msg = "File doesn't exist"
                    break
                    
                case .unauthorized:
                    msg = "User doesn't have permission to access file"
                    break
                    
                case .cancelled:
                    msg = "User canceled the upload"
                    break
                    
                case .unknown:
                    msg = "Unknown error occurred, please try again"
                    break
                    
                default:
                    msg = "Something went wrong while uploading images please try again."
                    break
                    
                }
                self.stopAnimating()
                let alert = UIAlertController(title: "", message:msg, preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    //MARK: Video Storage
    func createVideoStorageURL(){
        if videoURL != nil {
            let storage =  Storage.storage()
            let videoName = getName()
            let VideoPathRef = storage.reference().child("Videos").child(snapUtils.currentUserModel.userId).child(videoName)
            let metadata = StorageMetadata()
            metadata.contentType = "video"
            do {
                let data = try Data.init(contentsOf: videoURL)
                let _ = VideoPathRef.putData(data, metadata: metadata, completion: { (metadata, error) in
                    if error != nil, metadata != nil {
                        print(error ?? "")
                        return
                    }
                    
                    VideoPathRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            return
                        }
                        if let video_URL = url?.absoluteString {
                            self.videoURLString = video_URL
                            print(self.videoURL)
                        }
                    })
                    
                    // "Video is successfully uploaded"
                    self.furtherSubmitRequest()
                })
            } catch {
            }
        }else{
            furtherSubmitRequest()
        }
    }
    func getName() -> String {
        let dateFormatter = DateFormatter()
        let dateFormat = "yyyyMMddHHmmss"
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.string(from: Date())
        let name = date.appending(".mp4")
        return name
    }
    //MARK: Validation Methods
    func ValidateTextField() -> Bool
    {
        if(txtCategory.text == "" || txtAddress.text == "" || txtdescription.text == "" || txtTitle.text == "")
        {
            utils.emptyFieldValidation(txtCategory, view: self.view, tag: txtCategory.tag+21)
            utils.emptyFieldValidation(txtdescription, view: self.view, tag: txtdescription.tag+21)
            utils.emptyFieldValidation(txtAddress, view: self.view, tag: txtAddress.tag+21)
            utils.emptyFieldValidation(txtTitle, view: self.view, tag: txtTitle.tag+21)
            return false
        }
        
        if(arrPhotos.count == 0)
        {
            
            let custAlert = customAlertView(title: "Error", message: "Please select at least one photo for your listing", btnTitle: "OK")
            custAlert.show(animated: true)
            return false

        }
        
        if(txtListingURL.text!.count > 0)
        {
            let urlstring = txtListingURL.text?.removingPercentEncoding
            if(!validateUrl(urlString: urlstring! as NSString))
            {
                let custAlert = customAlertView(title: "Error", message: "Please enter valid registration URL", btnTitle: "OK")
                custAlert.show(animated: true)
                return false
            }
        }
        
        if(txtSunday.tags.count == 0 || txtMonday.tags.count == 0  || txtTuesday.tags.count == 0  || txtWednesday.tags.count == 0  || txtThursday.tags.count == 0  || txtFriday.tags.count == 0  || txtSaturday.tags.count == 0  )
        {
            let custAlert = customAlertView(title: "Service Missing", message: "Be sure to add at least one service to each timeframe or check the N/A box.", btnTitle: "OK")
            custAlert.show(animated: true)
            return false
        }
        
        if txtListingURL.text==""
        {
            if monServiceNotSelected || tueServiceNotSelected || wedServiceNotSelected || thuServiceNotSelected || friServiceNotSelected || satServiceNotSelected || sunServiceNotSelected
            {
                let custAlert=customAlertView(title:"Service Missing", message: "Be sure to add at least one service to each timeframe or check the N/A box.", btnTitle:"OK")
                custAlert.show(animated:true)
                return false
            }
        }
        
        if snapUtils.currentUserModel.Verification != "true"
        {
            let v = UIView()
            let custAlert = customAlertView.init(title: "Message", message: "Phone verification required. Would you like to proceed?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextPage = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                self.navigationController?.pushViewController(nextPage, animated: true)
            }
            custAlert.onLeftBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
            }
            custAlert.show(animated: true)
            return false
        }
        
        if txtListingURL.text==""
        {
            if snapUtils.currentUserModel.merchantId==""
            {
                let v = UIView()
                let custAlert = customAlertView.init(title: "Message", message: "Business and banking info required for payout. Add information to proceed?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
                custAlert.onRightBtnSelected = { (Value: String) in
                    custAlert.dismiss(animated: true)
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextPage = storyboard.instantiateViewController(withIdentifier: "PaymentDetailsVC") as! PaymentDetailsVC
                    self.navigationController?.pushViewController(nextPage, animated: true)
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
    
    func validateUrl (urlString: NSString) -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
    
}
extension AddListingVC:GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
         
        startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        print(videoIndex,arrPhotos.count)
        arrPhotos.removeAllObjects()
            Image.resolve(images: images, completion: { [weak self] resolvedImages in
                for image in resolvedImages {
                    self?.arrPhotos.add(image!)
                }
                if self?.videoIndex != 10 {
                    self?.arrPhotos.add(self?.videoImage as Any)
                    self?.videoIndex = (self?.arrPhotos.count)!-1
                }
                self?.stopAnimating()
                self?.collViewImages.reloadData()
                if(self?.arrPhotos.count == 0){
                    self?.collViewImages.isHidden = true
                    self?.viewAddMedia.isHidden = false
                }else
                {
                    self?.viewAddMedia.isHidden = true
                    self?.collViewImages.isHidden = false
                }
            })
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
         
        startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
        if videoIndex != 10 {
            arrPhotos.removeObject(at: videoIndex)
        }
        
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
                    self.stopAnimating()
                    
                    self.videoIndex = self.arrPhotos.count
                    
                    utils.thumbnailForVideoAtURL(url: tempPath,completionHandler: {
                        image in
                        self.videoImage = image
                        self.arrPhotos.add(image)
                        self.videoURL = tempPath
                        self.collViewImages.reloadData()
                        if(self.arrPhotos.count == 0){
                            self.collViewImages.isHidden = true
                            self.viewAddMedia.isHidden = false
                        }else
                        {
                            self.viewAddMedia.isHidden = true
                            self.collViewImages.isHidden = false
                        }
                    }) 
                }
            }
        }
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
}
extension AddListingVC:UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if((arrPhotos.count + 1)>5)
        {
            return arrPhotos.count
        }else
        {
            return arrPhotos.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.row == arrPhotos.count && arrPhotos.count < 5)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPhotoCell", for: indexPath) as! addPhotoCell
            cell.btnAddImage.addTarget(self, action: #selector(self.onAdd(_:)), for: .touchUpInside)
            return cell
        }else
        {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewPhotoCell", for: indexPath) as! previewPhotoCell
            cell.imgView.image = arrPhotos.object(at: indexPath.row) as? UIImage
            cell.btnClose.tag = indexPath.row
            cell.btnClose.addTarget(self, action: #selector(self.onDelete(_:)), for: .touchUpInside)
            if videoIndex == indexPath.row {
                cell.btnVideo.isHidden = false
            }else{
                 cell.btnVideo.isHidden = true
            }
            return cell
        }
    }
    @objc func onAdd(_ sender:UIButton)
    {
        gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
    }
    @objc func onDelete(_ sender:UIButton)
    {
        let btn =  sender as UIButton
        self.arrPhotos.removeObject(at: btn.tag)
        if btn.tag == videoIndex {
            videoIndex = 10
            self.videoURLString = ""
        }
        print(btn.tag, videoIndex)
        if videoIndex != 10 && btn.tag < videoIndex && btn.tag != videoIndex{
            videoIndex -= 1
        }
        
        self.collViewImages.reloadData()
        if(arrPhotos.count == 0){
            collViewImages.isHidden = true
            viewAddMedia.isHidden = false
        }else
        {
            viewAddMedia.isHidden = true
            collViewImages.isHidden = false
        }
    }
}
extension AddListingVC:addHoursPopUpsDelegate,TLTagsControlDelegate{
    
    func setData(day: String, str: String, serviceId: String) {
        
        switch  day {
        case "Sunday":
            sunSlotServices.setValue(serviceId, forKey: str)
            setTagSLots(tagControls: txtSunday, str: str)
            paramOfferedServices.setValue(sunSlotServices, forKey:"Sunday" )
            sunServiceNotSelected=checkServiceSelected(sunSlotServices)
            break;
        case "Monday":
            monSlotServices.setValue(serviceId, forKey: str)
            setTagSLots(tagControls: txtMonday, str: str)
            paramOfferedServices.setValue(monSlotServices, forKey:"Monday" )
            monServiceNotSelected=checkServiceSelected(monSlotServices)
            break;
        case "Tuesday":
            tueSlotServices.setValue(serviceId, forKey: str)
            setTagSLots(tagControls: txtTuesday, str: str)
            paramOfferedServices.setValue(tueSlotServices, forKey:"Tuesday" )
            tueServiceNotSelected=checkServiceSelected(tueSlotServices)
            break;
        case "Wednesday":
            wedSlotServices.setValue(serviceId, forKey: str)
            setTagSLots(tagControls: txtWednesday, str: str)
            paramOfferedServices.setValue(wedSlotServices, forKey:"Wednesday" )
            wedServiceNotSelected=checkServiceSelected(wedSlotServices)
            break;
        case "Thursday":
            thuSlotServices.setValue(serviceId, forKey: str)
            setTagSLots(tagControls: txtThursday, str: str)
            paramOfferedServices.setValue(thuSlotServices, forKey:"Thursday" )
            thuServiceNotSelected=checkServiceSelected(thuSlotServices)
            break;
        case "Friday":
            friSlotServices.setValue(serviceId, forKey: str)
            setTagSLots(tagControls: txtFriday, str: str)
            paramOfferedServices.setValue(friSlotServices, forKey:"Friday" )
            friServiceNotSelected=checkServiceSelected(friSlotServices)
            break;
        case "Saturday":
            satSlotServices.setValue(serviceId, forKey: str)
            setTagSLots(tagControls: txtSaturday, str: str)
            paramOfferedServices.setValue(satSlotServices, forKey:"Saturday" )
            satServiceNotSelected=checkServiceSelected(satSlotServices)
            break;
        default:
            print("t")
        }
    }
    
    func setTagSLots(tagControls : TLTagsControl,str : String)
    {
        if((str.range(of: "Not available")) != nil)
        {
            tagControls.tags = [str]
            tagControls.reloadTagSubviews()
            return
        }
        
        if((tagControls.tags.componentsJoined(by: ",").range(of: "Not available")) != nil)
        {
            tagControls.tags = []
        }
        
        if(tagControls.tags.count < 3 )
        {
            tagControls.addTag(str)
            let tags = tagControls.tags
            var convertedArray: [Date] = []
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            
            for dat in tags! {
                let dat = (dat as AnyObject).components(separatedBy: "-")
                let date = dateFormatter.date(from: dat[0])
                if let date = date {
                    convertedArray.append(date)
                }
            }
            let ready = convertedArray.sorted(by: { $0.compare($1) == .orderedAscending })
            print(ready)
            let arrFinal = NSMutableArray()
            for dat in ready
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                let d = dateFormatter.string(from: dat)
                arrFinal.addObjects(from: filterContentForSearchText(searchText: d,formArr: tags! as! [String],inArray: arrFinal))
            }
            tagControls.tags = arrFinal
            tagControls.tapDelegate = self
            tagControls.reloadTagSubviews()
        }else
        {
            let custAlert = customAlertView(title: "Message", message: "Maximum 3 time slots are allowed. Please remove any one to add new slot", btnTitle: "OK")
            custAlert.show(animated: true)
        }
    }
    
    func filterContentForSearchText(searchText: String,formArr: [String],inArray : NSMutableArray) -> [String] {
        let filterdItemsArray = formArr.filter { item in
            print("item--->",item)
            if (inArray.contains(item))
            {
                return false
            }else
            {
                return item.lowercased().contains(searchText.lowercased())
            }
        }
        return filterdItemsArray
    }
    
    func delete(_ tagsControl: TLTagsControl!, tappedAt index: Int, deleteTagText tagText: String!) {
        let tagText=tagText.trimmingCharacters(in:.whitespacesAndNewlines)
        if tagsControl.tag == 8{
            sunSlotServices.removeObject(forKey: tagText)
        }else if tagsControl.tag == 9{
            monSlotServices.removeObject(forKey: tagText)
        }else if tagsControl.tag == 10{
            tueSlotServices.removeObject(forKey: tagText)
        }else if tagsControl.tag == 11{
            wedSlotServices.removeObject(forKey: tagText)
        }else if tagsControl.tag == 12{
            thuSlotServices.removeObject(forKey: tagText)
        }else if tagsControl.tag == 13{
            friSlotServices.removeObject(forKey: tagText)
        }else if tagsControl.tag == 14{
            satSlotServices.removeObject(forKey: tagText)
        }
    }
    
    func tagsControl(_ tagsControl: TLTagsControl!, tappedAt index: Int) {
        
    }
}
