//
//  Utills.swift
//  App
//
//  Created by Ved on 20/07/17.
//  Copyright © 2017 Coldfin. All rights reserved.
//

import Firebase
import FirebaseAuth
import Foundation
import CoreLocation
import AVFoundation


enum CardType: String {
    case Unknown, Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay
    
    static let allCards = [Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay]
    
    var regex : String {
        switch self {
        case .Amex:
            return "^3[47][0-9]{5,}$"
        case .Visa:
            return "^4[0-9]{6,}([0-9]{3})?$"
        case .MasterCard:
            return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
        case .Diners:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .Discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .JCB:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .UnionPay:
            return "^(62|88)[0-9]{5,}$"
        case .Hipercard:
            return "^(606282|3841)[0-9]{5,}$"
        case .Elo:
            return "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
        default:
            return ""
        }
    }
}

class Utills: NSObject{
    
    var home_category_select = "Social Sports League"//"Promoted Listings"
    var userForCategory = ""
    var userListingData = [String:Any]()
    
    var userCity = ""
    var listingCity = ""
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    
     var onSelectAddress: ((_ Value: String) -> Void)?
    //MARK: Card Type
    
    func fetchcardImagebyItsType(type:CardType) -> UIImage {
        switch type {
        case .Amex:
            return UIImage(named: "amex.png")!
        case .Visa:
            return UIImage(named: "visa.png")!
        case .MasterCard:
            return UIImage(named: "mastercard.png")!
        case .Diners:
            return UIImage(named: "diners.png")!
        case .Discover:
            return UIImage(named: "discover.png")!
        case .JCB:
            return UIImage(named: "jcb.png")!
        case .UnionPay:
            return UIImage(named: "unionpay.png")!
        case .Hipercard:
            return UIImage(named: "stp_card_unknown.png")!
        case .Elo:
            return UIImage(named: "stp_card_unknown.png")!
        default:
            return UIImage(named: "stp_card_error.png")!
        }
    }
    
    func matchesRegex(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
    func luhnCheck(number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            guard let digit = Int(tuple.element) else { return false }
            let odd = tuple.offset % 2 == 1
            
            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
    //MARK:Upload image and video to firebase storage
    
    func uploadImages(userId: [String], view:UIViewController, imagesArray : [UIImage], completionHandler: @escaping ([String]) -> ()){
        
        print(imagesArray)
        let storage =  Storage.storage()
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = imagesArray.count
        var count = 0
        
        for image in imagesArray{
            
            let imageName =  String(arc4random()) + ((NSString(format: "%.0f.jpg", Date().timeIntervalSince1970) as NSString) as String) // Unique string to reference image
            
            //Create storage reference for image
            let storageRef = storage.reference().child("\(userId[count])").child(imageName)
            
            let myImage = image
            guard let uplodaData = myImage.pngData() else{
                return
            }
            
            // Upload image to firebase
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
            observeUploadTaskFailureCases(uploadTask : uploadTask, view: view)
            count += 1
        }
    }
    func observeUploadTaskFailureCases(uploadTask :  StorageUploadTask, view:UIViewController){
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
                let alert = UIAlertController(title: "", message:msg, preferredStyle: .alert)
                view.present(alert, animated: true, completion: nil)
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                    view.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    //MARK: Tag controll method
    
    func tagDesign(tagControl : UIScrollView, dataArray : NSMutableArray, backColor : NSArray,isActionable:Bool)
    {
        print(dataArray)
        var index = 0
        var x :CGFloat = 0.0
        for i in dataArray
        {
            let btn = UIButton(frame: CGRect(x: x, y: 0, width: 10 , height: tagControl.frame.height))
            if("\(i)".range(of: "Not available") == nil)
            {
                btn.setTitle("\(i)".replace(target: " ", withString: ""), for: .normal)
            }else{
                btn.setTitle("\(i)", for: .normal)
            }
            btn.titleLabel?.textAlignment = .center
            btn.layer.cornerRadius = 4
            btn.clipsToBounds = true
            btn.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 10)
            btn.sizeToFit()
            btn.frame = CGRect(x: x, y: 0, width: btn.frame.width+12, height: tagControl.frame.height)
            x = x + btn.frame.width + 5.0
            if ((backColor.object(at: index) as! Bool) == true)
            {
                btn.backgroundColor = UIColor.lightGray
                btn.setTitleColor(UIColor.white, for: .normal)
            }else
            {
                btn.backgroundColor = themeColor
                btn.setTitleColor(UIColor.white, for: .normal)
            }
            btn.tag = index
            if isActionable && btn.backgroundColor == themeColor{
                btn.addTarget(self, action:#selector(onClick_tagClick(_:)), for: .touchUpInside)
            }
            index += 1
            tagControl.addSubview(btn)
        }
        tagControl.contentSize = CGSize(width: x, height: tagControl.frame.height)
        tagControl.setNeedsDisplay()
    }
    
    @objc func onClick_tagClick(_ sender:UIButton) {
        let data:[String: UIButton] = ["btn": sender]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tagSlotClicked"), object: nil, userInfo: data)
    }
    
    //MARK: Create video Thumbnail
    func thumbnailForVideoAtURL(url: URL, completionHandler: @escaping (UIImage) -> ()) {
        
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMake(value: 0, timescale: 60)
            let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            if img != nil {
                let frameImg  = UIImage(cgImage: img!)
                DispatchQueue.main.async(execute: {
                    completionHandler(frameImg)
                })
            }
        }
    }
    
    //MARK: - country phone number code
    
    func countryCodes() -> String {
        let locale = Locale.current
        let code:String = locale.regionCode!
        return getCountryPhonceCode(code)
    }
    
    func getCountryPhonceCode (_ country : String) -> String
    {
        let countryDictionary  = ["AF":"93","AL":"355","DZ":"213","AS":"1","AD":"376","AO":"244","AI":"1","AG":"1","AR":"54","AM":"374","AW":"297","AU":"61","AT":"43","AZ":"994","BS":"1","BH":"973","BD":"880","BB":"1","BY":"375","BE":"32","BZ":"501","BJ":"229","BM":"1","BT":"975","BA":"387","BW":"267","BR":"55","IO":"246","BG":"359","BF":"226","BI":"257","KH":"855","CM":"237","CA":"1","CV":"238","KY":"345","CF":"236","TD":"235","CL":"56","CN":"86","CX":"61","CO":"57","KM":"269","CG":"242","CK":"682","CR":"506","HR":"385","CU":"53","CY":"537","CZ":"420","DK":"45","DJ":"253","DM":"1","DO":"1","EC":"593","EG":"20","SV":"503","GQ":"240","ER":"291","EE":"372","ET":"251","FO":"298","FJ":"679","FI":"358","FR":"33","GF":"594","PF":"689","GA":"241","GM":"220","GE":"995","DE":"49","GH":"233","GI":"350","GR":"30","GL":"299","GD":"1","GP":"590","GU":"1","GT":"502","GN":"224","GW":"245","GY":"595","HT":"509","HN":"504","HU":"36","IS":"354","IN":"91","ID":"62","IQ":"964","IE":"353","IL":"972","IT":"39","JM":"1","JP":"81","JO":"962","KZ":"77","KE":"254","KI":"686","KW":"965","KG":"996","LV":"371","LB":"961","LS":"266","LR":"231","LI":"423","LT":"370","LU":"352","MG":"261","MW":"265","MY":"60","MV":"960","ML":"223","MT":"356","MH":"692","MQ":"596","MR":"222","MU":"230","YT":"262","MX":"52","MC":"377","MN":"976","ME":"382","MS":"1","MA":"212","MM":"95","NA":"264","NR":"674","NP":"977","NL":"31","AN":"599","NC":"687","NZ":"64","NI":"505","NE":"227","NG":"234","NU":"683","NF":"672","MP":"1","NO":"47","OM":"968","PK":"92","PW":"680","PA":"507",                        "PG":"675","PY":"595","PE":"51","PH":"63","PL":"48","PT":"351","PR":"1","QA":"974","RO":"40","RW":"250","WS":"685","SM":"378","SA":"966","SN":"221","RS":"381","SC":"248","SL":"232","SG":"65","SK":"421","SI":"386","SB":"677","ZA":"27","GS":"500","ES":"34","LK":"94","SD":"249","SR":"597","SZ":"268","SE":"46","CH":"41","TJ":"992","TH":"66","TG":"228","TK":"690","TO":"676","TT":"1","TN":"216","TR":"90","TM":"993","TC":"1","TV":"688","UG":"256","UA":"380","AE":"971","GB":"44","US":"1","UY":"598","UZ":"998","VU":"678","WF":"681","YE":"967","ZM":"260","ZW":"263","BO":"591","BN":"673","CC":"61","CD":"243","CI":"225","FK":"500","GG":"44","VA":"379","HK":"852","IR":"98","IM":"44","JE":"44","KP":"850","KR":"82","LA":"856","LY":"218","MO":"853","MK":"389","FM":"691","MD":"373","MZ":"258","PS":"970","PN":"872","RE":"262","RU":"7","BL":"590","SH":"290","KN":"1","LC":"1","MF":"590","PM":"508","VC":"1","ST":"239","SO":"252","SJ":"47","SY":"963","TW":"886","TZ":"255","TL":"670","VE":"58","VN":"84","VG":"284","VI":"340"]
        if countryDictionary[country] != nil {
            return countryDictionary[country]!
        }
            
        else {
            return ""
        }
        
    }
    
    
    //MARK: - convert thousand into k
    
    func formatPoints(num: Double) ->String{
        var thousandNum = num/1000
        var millionNum = num/1000000
        if num >= 1000 && num < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Float(thousandNum))k")
            }
            return("\(thousandNum.roundToPlaces(places: 1))k")
        }
        if num > 1000000{
            if(floor(millionNum) == millionNum){
                return("\(Int(thousandNum))k")
            }
            return ("\(millionNum.roundToPlaces(places: 1))M")
        }
        else{
            var num1 = num
            if(floor(num) == num){
                return ("\(Float(num1))")
            }
            return ("\(num1.roundToPlaces(places: 1))")
            
        }
        
    }
    
    //MARK: - Validation functions
    func emptyFieldValidation(_ textField: UITextField, view:UIView, tag:Int)
    {
        if(textField.text == "")
        {
            textField.becomeFirstResponder()
            if let lbl = view.viewWithTag(tag) as? UILabel {
                lbl.backgroundColor = UIColor.red
            }
            
        }else
        {
            if let lbl = view.viewWithTag(tag) as? UILabel {
                lbl.backgroundColor = UIColor(hex: 0xE6E6E6)
            }
        }
    }
  
    func convertDateToString(_ dateToConvert : Date, format : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        let stringDate = dateFormatter.string(from: dateToConvert)
        return stringDate
    }

    func convertStringToDate(_ strToConvert : String, dateFormat : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.ISO8601)! as Calendar
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        let convertedDate = dateFormatter.date(from: strToConvert)
        return convertedDate!
    }

    //MARK: Date Utility
    func getPostTime(_ postDatetime : Date) -> (String,String) {
        let currentDAte = Date()
        print(currentDAte)
        let years = currentDAte.yearsFrom(postDatetime)
        let months = currentDAte.monthsFrom(postDatetime)
        let days = currentDAte.daysFrom(postDatetime)
        let hours = currentDAte.hoursFrom(postDatetime)
        let min = currentDAte.minutesFrom(postDatetime)
        let sec = currentDAte.secondsFrom(postDatetime)

        if years != 0 {
            return (String("\(years) year(s) ago"),"year")
            
        }else if months != 0 {
            return (String("\(months) month(s) ago"),"month")
            
        }else if days != 0 {
            return (String("\(days) day(s) ago"),"day")
            
        }else if hours != 0 {
            return (String("\(hours) hour(s) ago"),"hour")
            
        }else if min != 0 && min <= 60 {
            return (String("\(min) min(s) ago"),"min")
            
        }else if sec != 0 && sec <= 60{
            return (String("\(sec) sec(s) ago"),"sec")

        }else{
            return (String("just now"),"justnow")
        }
    }
  
    func updateBooking()
    {
        let ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        ref.child(nodeUsers).child(uid).observe(.value, with: { snapshot in
            defaults.setValue(0, forKey: keyPendingBadge)
            
            if snapshot.exists(){
                if let defaults2 = (snapshot.value as! NSDictionary)[keyNotificationCount] as? Int {
                    if(defaults2 == 0)
                    {
                        //defaults.setValue(0, forKey: keyPendingBadge)
                        let ap = UIApplication.shared.delegate as! AppDelegate
                        if let myTabBar = ap.window?.rootViewController as? UITabBarController
                        {
                            myTabBar.tabBar.items![1].badgeValue = nil
                            defaults.setValue(false, forKey: keyIsNewBooking)
                        }
                    }else{
                        //defaults.setValue(defaults2, forKey: keyPendingBadge)
                        let ap = UIApplication.shared.delegate as! AppDelegate
                        if let myTabBar = ap.window?.rootViewController as? UITabBarController
                        {
                            print(defaults2)
                            myTabBar.tabBar.items![1].badgeValue = "\(defaults2)"
                            myTabBar.tabBar.items![1].badgeColor = .red
                            defaults.setValue(true, forKey: keyIsNewBooking)
                        }
                    }
                }
                if let defaults2 = (snapshot.value as! NSDictionary)[keyPendingNotificationCount] as? Int {
                    if(defaults2 == 0)
                    {
                        defaults.setValue(0, forKey: keyPendingBadge)
                        let ap = UIApplication.shared.delegate as! AppDelegate
                        if let myTabBar = ap.window?.rootViewController as? UITabBarController
                        {
                            myTabBar.tabBar.items![3].badgeValue = nil
                            defaults.setValue(false, forKey: keyIsNewBooking)
                        }
                    }else{
                        defaults.setValue(defaults2, forKey: keyPendingBadge)
                        let ap = UIApplication.shared.delegate as! AppDelegate
                        if let myTabBar = ap.window?.rootViewController as? UITabBarController
                        {
                            print(defaults2)
                            myTabBar.tabBar.items![3].badgeValue = "\(defaults2)"
                            myTabBar.tabBar.items![3].badgeColor = .red
                            defaults.setValue(true, forKey: keyIsNewBooking)
                        }
                    }
                }
            }
        })
    }
    
    func updateData(c: Int)
    {
        var a = 0
        if let d = defaults.value(forKey: keyPendingBadge) as? Int
        {
            a = d
        }
        if((c+a) == 0)
        {
            let ap = UIApplication.shared.delegate as! AppDelegate
            if let myTabBar = ap.window?.rootViewController as? UITabBarController
            {
                myTabBar.tabBar.items![3].badgeValue = nil
            }
        }else
        {
            let ap = UIApplication.shared.delegate as! AppDelegate
            if let myTabBar = ap.window?.rootViewController as? UITabBarController
            {
                myTabBar.tabBar.items![3].badgeValue = "\((a + c))"
                myTabBar.tabBar.items![3].badgeColor = .red
            }
        }
    }

    func getProfileBadge()
    {
        self.updateBooking()
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let myGroup = DispatchGroup()
        var c = 0
        let ref = Database.database().reference()
        ref.child(nodeUserChats).child(uid).observe(.value, with: { (snapshot) in
           // ref.child(nodeUserChats).child(uid).removeAllObservers()
            if !(snapshot.exists())
            {
                return
            }
            var chatIds = NSArray()
            if let defaults = (snapshot.value as! NSDictionary)[keyChatID] as? NSArray {
                chatIds = defaults
            }
            for i  in chatIds{
               myGroup.enter()
                let oponent_id = ((i as! String).replace(target: uid, withString: "")).replace(target: "-", withString: "")
                  self.updateData(c: c)
                let _ = ref.child(nodeChatMessages).child(i as! String).queryOrdered(byChild: keyViewFlag).queryEqual(toValue: false).observe(.value, with: { snapshot2 in
                    ref.child(nodeChatMessages).child(i as! String).removeAllObservers()
                    for j in snapshot2.children
                    {
                        if let defaults2 = ((j as! DataSnapshot).value as! NSDictionary)[keySentBy] as? String {
                            if(defaults2 == oponent_id)
                            {
                                c += 1
                                defaults.setValue(c, forKey: keyProfileBadge)
                                let ap = UIApplication.shared.delegate as! AppDelegate
                                if let myTabBar = ap.window?.rootViewController as? UITabBarController
                                {
                                    myTabBar.tabBar.items![3].badgeValue = "\(c)"
                                    myTabBar.tabBar.items![3].badgeColor = .red
                                }
                                self.updateData(c: c)
                            }
                        }
                    }
                    myGroup.leave()
                })
            }
        })
        myGroup.notify(queue: .main) {
          
        }
    }
    
    
    
    func getNotificationBadge()
    {
        var c = 0
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let partnersReference = ref.child(nodeNotifications).child(uid)
        
        partnersReference.observe(.value, with: { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
            if !snapshot.exists() {
                
            }
            else
            {
                for item in children {
                    let Flag = (item.childSnapshot(forPath: "ViewFlag").value as? Bool)!
                    print(Flag)
                    if Flag == false{
                        let ap = UIApplication.shared.delegate as! AppDelegate
                        if let myTabBar = ap.window?.rootViewController as? UITabBarController
                        {
                            c += 1
                            defaults.setValue(c, forKey: keyNotificationBadge)
                            myTabBar.tabBar.items![3].badgeValue = "\(c)"
                            myTabBar.tabBar.items![3].badgeColor = .red
                        }
                    }
                }
            }
        })
    }
    
    
    func getUserSnaprShot()
    {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let ref = Database.database().reference()
        let _ = ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: uid).observe(.childAdded, with: { snapshot in
            if !snapshot.exists() {return}
            userSnapShot = (snapshot.value as! NSDictionary)
            print(userSnapShot)
        })
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    //MARK: Address Fetch AutoComplete
    func configureTextField(_ textfield:AutoCompleteTextField){
        textfield.autoCompleteTextColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        textfield.autoCompleteTextFont = UIFont(name: "SFProText-Regular", size: 13.0)!
        textfield.autoCompleteCellHeight = 35.0
        textfield.maximumAutoCompleteCount = 20
        textfield.hidesWhenSelected = true
        textfield.hidesWhenEmpty = true
        textfield.enableAttributedText = true
        var attributes = [NSAttributedString.Key:AnyObject]()
        attributes[NSAttributedString.Key.foregroundColor] = UIColor.black
        attributes[NSAttributedString.Key.font] = UIFont(name: "SFProText-Regular", size: 13.0)
        textfield.autoCompleteAttributes = attributes
    }
    
    func handleTextFieldInterfaces(_ textfield:AutoCompleteTextField){
        textfield.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text, textfield: textfield)
            }
        }
        
        textfield.onSelect = {text, indexpath in
            if let block = utils.onSelectAddress {
                block(text)
            }
        }
    }
        
    func getCoordinates(text:String, completionHandler:@escaping (CLLocationCoordinate2D)->()) {

        let urlString = "\(GOOGLE_PLACES_DETAILS_API)?key=\(GOOGLE_MAPS_KEY)&placeid=\(text)"
        NSLog("urlstring : \(urlString)")
        
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = NSURL(string: encodedString) {
                let request = NSURLRequest(url: url as URL)
                self.dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let status = (result as AnyObject)["status"] as? String{
                                if status == "OK"{
                                    if let result2 = (result as AnyObject)["result"] as? NSDictionary{
                                        if let geometry = (result2 as AnyObject)["geometry"] as? NSDictionary{
                                            if let location = geometry.value(forKey: "location") as? NSDictionary
                                            {
                                                let lat = location.value(forKey: "lat") as! Double
                                                let lng = location.value(forKey: "lng") as! Double
                                                let coordinate = CLLocationCoordinate2DMake(lat, lng)
                                                completionHandler(coordinate)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        catch{
                        }
                    }
                })
                self.dataTask?.resume()
            }
        }
    }
    
    
    
    func fetchAutocompletePlaces(_ keyword:String, textfield:AutoCompleteTextField) {
        let urlString = "\(GOOGLE_PLACES_API)?key=\(GOOGLE_MAPS_KEY)&input=\(keyword)"
        NSLog("urlstring : \(urlString)")
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let status = (result as AnyObject).value(forKey: "status") as? String{
                                if status == "OK"{
                                    if let predictions = (result as AnyObject).value(forKey: "predictions") as? NSArray{
                                        var locations = [String]()
                                        var ids = [String]()
                                        for dict in predictions as! [NSDictionary]{
                                            locations.append(dict["description"] as! String)
                                            ids.append(dict["place_id"] as! String)
                                        }
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            textfield.autoCompleteStrings = locations
                                            textfield.autoCompleteIDs = ids
                                        })
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                textfield.autoCompleteIDs = nil
                                textfield.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError{
                            NSLog(error.localizedDescription)
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
}
extension Collection {
    public func chunk(n: Int) -> [SubSequence] {
        var res: [SubSequence] = []
        var i = startIndex
        var j: Index
        while i != endIndex {
            j = index(i, offsetBy: n, limitedBy: endIndex) ?? endIndex
            res.append(self[i..<j])
            i = j
        }
        return res
    }
}
extension Date {
    @nonobjc static var localFormatter: DateFormatter = {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "MM.dd.yyyy h:mm a"
        return dateStringFormatter
    }()
    
    func localDateString() -> String
    {
        return Date.localFormatter.string(from: self)
    }
    
    @nonobjc static var localFormatterDate: DateFormatter = {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "MM-dd-yyyy"
        return dateStringFormatter
    }()
    
    func localDateStringOnlyDate() -> String
    {
        return Date.localFormatterDate.string(from: self)
    }
    
    @nonobjc static var localFormatterFullDate: DateFormatter = {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "MM.dd.yyyy HH:mm:ss"
        return dateStringFormatter
    }()
    
    func localDateStringFullDate() -> String
    {
        return Date.localFormatterFullDate.string(from: self)
    }
}
extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}

extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}

extension UINavigationController
{
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if let lastVC = self.viewControllers.last
        {
            return lastVC.preferredStatusBarStyle
        }
        return .default
    }
}


var key: Void?

class UITextFieldAdditions: NSObject {
    var readonly: Bool = false
}

extension UITextField {
    var readonly: Bool {
        get {
            return self.getAdditions().readonly
        } set {
            self.getAdditions().readonly = newValue
        }
    }
    
    private func getAdditions() -> UITextFieldAdditions {
        var additions = objc_getAssociatedObject(self, &key) as? UITextFieldAdditions
        if additions == nil {
            additions = UITextFieldAdditions()
            objc_setAssociatedObject(self, &key, additions!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        return additions!
    }

    open override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        if ((action == #selector(UIResponderStandardEditActions.paste(_:)) || (action == #selector(UIResponderStandardEditActions.cut(_:)))) && self.readonly) {
            return nil
        }
        return super.target(forAction: action, withSender: sender)
    }
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

extension UITextField {
    func addBorder(color: UIColor, thickness: CGFloat) {
        self.layer.cornerRadius = 3.0
        self.layer.borderWidth = thickness
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
        let paddingView = UIView(frame: CGRect(x:0, y:0,width: 10,height: self.frame.width))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

//extension UITextView {
//    func addBorder(color: UIColor, thickness: CGFloat) {
//        self.layer.borderColor = color.cgColor
//        self.layer.borderWidth = thickness
//    }
//}

extension UIView {
    func setRadiusWithShadow(_ radius: CGFloat? = nil) { // this method adds shadow to right and bottom side of button
        self.layer.cornerRadius = radius ?? self.frame.width / 2
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.8
        self.layer.masksToBounds = false
    }
}

extension UIView {
    func addBorderToView(color: UIColor, thickness: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = thickness
    }
}

