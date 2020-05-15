//
//  ChattingsVC.swift
//  Classpath
//
//  Created by Coldfin on 14/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseUI

class ChatCellSend: BaseCell {
    @IBOutlet weak var imgProfileView: UIImageView!
    @IBOutlet weak var lblChatMessage: UILabel!
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var lblTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBg.layer.shadowOpacity = 1
        viewBg.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewBg.layer.shadowRadius = 4
        viewBg.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
    }
}

class ChatCellRecieved: BaseCell {
    @IBOutlet weak var lblChatMessage: UILabel!
    @IBOutlet weak var imgProfileView: UIImageView!
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var lblTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBg.layer.shadowOpacity = 1
        viewBg.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewBg.layer.shadowRadius = 4
        viewBg.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
    }
}

class ChattingsVC: UIViewController,NVActivityIndicatorViewable,UIGestureRecognizerDelegate, UITextViewDelegate {

    @IBOutlet weak var viewDisable: UIView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    var txtfld = UITextView()
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var rightBarbuttonItem: UIBarButtonItem!
    var isScrolledOnce = false
    
    var Chat_messages = NSMutableArray()
    var isfromConversatin = false
    var limitQuery = 200
    var offsetQuery = 0
    var is4FirstTime = true
    var UserName = ""
    var UserImage = ""
    var OponentImage = ""
    var ReceiverUserid = ""
    var ref: DatabaseReference!
    var CurrentchatID = ""
    var lastID = ""
    var fcmReceiverToken = ""
    var senderUserName = ""
    var userObj : conversationModel = conversationModel()
    var index1 : Int = 0
    
    var isBlocked = false
    var blockedBy = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let _ = self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: uid).observe(.childAdded, with: { snapshot in
            if !snapshot.exists() {return}
            
            if let defaults = (snapshot.value as! NSDictionary)[keyProfilePic] as? String {
                self.UserImage = defaults
            }
        })
        let _ = self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: ReceiverUserid).observe(.childAdded, with: { snapshot in
            if !snapshot.exists() {return}
            
            if let defaults = (snapshot.value as! NSDictionary)[keyProfilePic] as? String {
                self.OponentImage = defaults
            }
        })
        
        self.rightBarbuttonItem.image = #imageLiteral(resourceName: "ic_delete_user")
        
        setDesigning()
        setData()
        tblView.delegate = self
        tblView.dataSource = self
        
        
        tblView.addPullToRefresh(actionHandler: {() -> Void in
            if(self.CurrentchatID != "")
            {
                self.fetchChatMessages(chatId: self.CurrentchatID)
            }else
            {
                self.tblView.pullToRefreshView.stopAnimating()
            }
        })
        getAllMessagesFetchChatID()
        backGroundRequestForGetReceiverToken()
        getLoginUsername()
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitleColor(themeColor, for: .normal)
        button.titleLabel?.font =  UIFont(name: "SFProText-SemiBold", size: 17)
        button.backgroundColor = .clear
        button.setTitle(UserName, for: .normal)
        button.addTarget(self, action: #selector(self.clickOnButton), for: .touchUpInside)
        self.navigationItem.titleView = button
        
        if self == navigationController?.viewControllers[0]  {
            let backBarButton = UIBarButtonItem(image: UIImage(named: "ic_back_white"), style: .plain, target: self, action: #selector(self.clickonBack))
            backBarButton.tintColor = themeColor
            self.navigationItem.leftBarButtonItem = backBarButton
            self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "SFProText-SemiBold", size: 17)!,NSAttributedString.Key.foregroundColor: themeColor]
            self.navigationController?.navigationBar.tintColor = UIColor(hex: 0xF8F8F8)
            self.navigationController?.navigationBar.isTranslucent = false
        }
        
        self.title = ""
    }
    
    
    @objc func clickonBack(button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func CheckBlocked(chatID : String)
    {
        let _ = ref.child(nodeChats).child(chatID).observe(.value, with: { snapshot in
            if !snapshot.exists()
            {
            }else{
                if let defaults = (snapshot.value as! NSDictionary)[keyIsBlocked] as? Bool
                {
                    self.isBlocked = defaults
                    if(defaults == true)
                    {
                        if let defaults2 = (snapshot.value as! NSDictionary)[keyBlockedBy] as? String
                        {
                            self.blockedBy = defaults2
                            guard let uid = Auth.auth().currentUser?.uid else{
                                return
                            }
                            if(self.blockedBy == uid)
                            {
                                self.rightBarbuttonItem.tintColor = textThemeColor
                                self.rightBarbuttonItem.isEnabled = true
                                self.rightBarbuttonItem.image = #imageLiteral(resourceName: "ic_delete_user")
                                self.viewDisable.isHidden = true
                            }else{
                                self.rightBarbuttonItem.tintColor = UIColor.clear
                                self.rightBarbuttonItem.isEnabled = false
                                self.viewDisable.isHidden = false
                            }
                        }
                    }else{
                        
                        self.rightBarbuttonItem.tintColor = textThemeColor
                        self.rightBarbuttonItem.isEnabled = true
                        self.rightBarbuttonItem.image = #imageLiteral(resourceName: "ic_delete_user")
                        self.viewDisable.isHidden = true
                    }
                }else{
                    self.isBlocked = false
                    self.rightBarbuttonItem.tintColor = textThemeColor
                    self.rightBarbuttonItem.isEnabled = true
                    self.rightBarbuttonItem.image = #imageLiteral(resourceName: "ic_delete_user")
                    self.viewDisable.isHidden = true
                }
            }
        })
    }
    
    @objc func clickOnButton(button: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextpage = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        nextpage.userID = ReceiverUserid
        nextpage.isShowBar = true
        self.present(nextpage, animated: true, completion: nil)
    }
    
    func backGroundRequestForGetReceiverToken()
    {
        let _ = ref.child(nodeUsers).child(ReceiverUserid).observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists()
            {
            }else{
                if let fcmToken = (snapshot.value as! NSDictionary)[keyDeviceToken] as? String {
                    self.fcmReceiverToken = fcmToken
                }
            }
        })
    }
    
    func getLoginUsername(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let _ = self.ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: uid).observe(.childAdded, with: { snapshot in
            if !snapshot.exists() {return}
            var name = ""
            
            if let defaults = (snapshot.value as! NSDictionary)[keyUsername] as? String {
                name =  name + defaults
            }
            
            self.senderUserName = name
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(self.CurrentchatID != "" )
        {
            self.ref.child(nodeChatMessages).child(self.CurrentchatID).removeAllObservers()
        }
    }
    
    deinit {
        if(self.CurrentchatID != "" )
        {
            self.ref.child(nodeChatMessages).child(self.CurrentchatID).removeAllObservers()
        }
    }
    
    func sendFCMNotification(token: String, message: String, userName: String) {
        let strUrl = NSString(format: "https://fcm.googleapis.com/fcm/send") as String
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json","text/html") as Set<NSObject>
        
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("key=AAAA2reorDM:APA91bE1mH4hlBZgBBz_PI8cnlrxbfSbhQyPOlY2svW1ZIIxknA1tPgCWnzc4L2UnUPLBphp3_dQbNoEApQViv-Nhzs0do6teLaODA6myUkU8FtP_HyWg2t0--EOVsM0JEDA2-mCHXNl", forHTTPHeaderField: "Authorization")
        
        let param: [String: Any] = ["to": token,
                                    "notification": [
                                        "body": message,
                                        "title": userName,
                                        "badge": "1",
                                        "sound": "default"],]
        manager.post(strUrl, parameters: param, success: { (operation,responseObject) in
            let _ : NSDictionary = responseObject as! NSDictionary
        },failure: { (operation,error) in
            print(error as Any)
        })
    }
    //MARK: - Get Messages
    func getAllMessagesFetchChatID()
    {
        if(CurrentchatID == "")
        {
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            let chatID = uid + "-" + ReceiverUserid
            let reversedchatID = ReceiverUserid + "-" + uid
            let _ = ref.child(nodeUserChats).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                //self.ref.child(nodeUserChats).child(uid).removeAllObservers()
                if !snapshot.exists()
                {
                }else{
                    if let defaults = (snapshot.value as! NSDictionary)[keyChatID] as? NSArray {
                        if(defaults.contains(chatID))
                        {
                            self.CurrentchatID = chatID
                            self.CheckBlocked(chatID : self.CurrentchatID)
                            self.fetchChatMessages(chatId : self.CurrentchatID)
                        }else if(defaults.contains(reversedchatID))
                        {
                            self.CurrentchatID = reversedchatID
                            self.CheckBlocked(chatID : self.CurrentchatID)
                            self.fetchChatMessages(chatId : self.CurrentchatID)
                        }
                    }
                }
            })
        }else
        {
            self.CheckBlocked(chatID : self.CurrentchatID)
            self.fetchChatMessages(chatId : self.CurrentchatID)
        }
    }
    func addOverserForGettingNewMsgs(chatID : String)
    {
        let _  = ref.child(nodeChatMessages).child(chatID).queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
            let model = ChatMessagesModel()
            model.messageId = snapshot.key
            
            if let defaults = (snapshot.value as! NSDictionary)[keyTimeStamp] as? Double
            {
                model.timeStamp = defaults
            }else
            {
                model.timeStamp = 0.0
            }
            
            if let defaults = (snapshot.value as! NSDictionary)[keySentBy] as? String {
                model.sendby = defaults
            }
            
            if let defaults = (snapshot.value as! NSDictionary)[keyMessage] as? String {
                model.message = defaults
            }
            
            if let defaults = (snapshot.value as! NSDictionary)[keyViewFlag] as? Bool {
                if(model.sendby == self.ReceiverUserid)
                {
                    model.SendRcvFlag = "recieve"
                    self.ref.child(nodeChatMessages).child(chatID).child(model.messageId).updateChildValues([keyViewFlag:true])
                }else
                {
                    model.SendRcvFlag = "sent"
                }
                model.ViewFlag = defaults
            }
            
            if (self.Chat_messages.first(where: {($0 as! ChatMessagesModel).messageId == model.messageId}) != nil) {
            } else {
                if ((self.Chat_messages.lastObject as! ChatMessagesModel).timeStamp < model.timeStamp )
                {
                    self.Chat_messages.add(model)
                    self.tblView.reloadData()
                    self.go_To_End(withAnimation: false)
                }
            }
        })
    }
    func fetchChatMessages(chatId : String)
    {
        var q = ref.child(nodeChatMessages).child(chatId).queryOrderedByKey()
        if(self.lastID != "")
        {
            q = q.queryEnding(atValue: self.lastID)
        }
        q.queryLimited(toLast: UInt(self.limitQuery)).observeSingleEvent(of: .value, with: { (snapshot) in
            //self.ref.child(nodeChatMessages).child(chatId).removeAllObservers()
            self.self.tblView.pullToRefreshView.stopAnimating()
            var k = 0
            let arrmsgs = NSMutableArray()
            for child in snapshot.children{
                let model = ChatMessagesModel()
                model.messageId = (child as! DataSnapshot).key
                if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyTimeStamp] as? Double{
                    model.timeStamp = defaults
                }else{
                    model.timeStamp = 0.0
                }
                if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keySentBy] as? String{
                    model.sendby = defaults
                }
                if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyMessage] as?String{
                    model.message = defaults
                }
                if let defaults = ((child as! DataSnapshot).value as! NSDictionary)[keyViewFlag] as? Bool{
                    if(model.sendby == self.ReceiverUserid){
                        model.SendRcvFlag = "recieve"
                        self.ref.child(nodeChatMessages).child(chatId).child(model.messageId).updateChildValues([keyViewFlag:true])
                    }else{
                        model.SendRcvFlag = "sent"
                    }
                    model.ViewFlag = defaults
                }
                if(k==0){
                    self.lastID = model.messageId
                    if (self.Chat_messages.first(where: {($0 as! ChatMessagesModel).messageId == model.messageId}) != nil) {
                    } else {
                        if(snapshot.childrenCount == 1 || snapshot.childrenCount < self.limitQuery ){
                            arrmsgs.add(model)
                        }
                    }
                }else{
                    arrmsgs.add(model)
                }
                k+=1
            }
            self.Chat_messages = (arrmsgs.addingObjects(from: self.Chat_messages.mutableCopy() as! [Any]) as NSArray).mutableCopy() as! NSMutableArray
            self.tblView.reloadData()
            if(!self.isScrolledOnce)
            {
                self.isScrolledOnce = true
                self.go_To_End(withAnimation: false)
            }
            self.addOverserForGettingNewMsgs(chatID : self.CurrentchatID)
        })
    }
    //MARK: -  Send Message
    func SendMessageAPI()
    {
        let trimmedString: String = txtMessage.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !(trimmedString == "") {
            if !(txtMessage.text == "Type a message") {
                guard let uid = Auth.auth().currentUser?.uid else{
                    return
                }
                let chatID = uid + "-" + ReceiverUserid
                let reversedchatID = ReceiverUserid + "-" + uid
                 
                self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                let _ = ref.child(nodeChats).observeSingleEvent(of: .value, with: { (snapshot) in
                    //  self.ref.child(nodeChats).removeAllObservers()
                    if !snapshot.exists()
                    {
                        //Not exist
                        self.SendMsgToAnewChat(chatId : chatID,receiverId : self.ReceiverUserid, message : trimmedString, timeStamp : NSDate().timeIntervalSince1970)
                    }else if (snapshot.hasChild("\(chatID)"))
                    {
                        //exists
                        self.SendMsgToAoldChat(snapshot: snapshot, chatId : chatID, message: trimmedString,timeStamp:  NSDate().timeIntervalSince1970)
                    }else if (snapshot.hasChild("\(reversedchatID)"))
                    {
                        //exists
                        self.SendMsgToAoldChat(snapshot: snapshot, chatId : reversedchatID, message: trimmedString,timeStamp:  NSDate().timeIntervalSince1970)
                    }else
                    {
                        //Not exist
                        self.SendMsgToAnewChat(chatId : chatID,receiverId : self.ReceiverUserid, message : trimmedString, timeStamp : NSDate().timeIntervalSince1970)
                    }
                })
            }
        }
    }
    
    func setUsrChatsNode(uid : String, chatId : String, receiverId : String, message : String, timeStamp : Double)
    {
        //UserChats Node
        let _ = ref.child(nodeUserChats).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // self.ref.child(nodeUserChats).child(uid).removeAllObservers()
            if !snapshot.exists()
            {
                //Not exist
                let parameterUserChats = NSMutableDictionary()
                let arr = NSMutableArray()
                arr.add(chatId)
                parameterUserChats.setValue(arr, forKey:keyChatID)
                let userChatsInstance = self.ref.child(nodeUserChats).child(uid)
                print(parameterUserChats)
                
                userChatsInstance.setValue(parameterUserChats)
            }else
            {
                //Exist
                var arr = NSMutableArray()
                if let defaults = (snapshot.value as! NSDictionary)[keyChatID] as? NSArray {
                    arr = defaults.mutableCopy() as! NSMutableArray
                }
                if !(arr.contains(chatId) || arr.contains(self.ReceiverUserid + "-" + uid)){
                    arr.add(chatId)
                }
                let parameterUserChats = NSMutableDictionary()
                parameterUserChats.setValue(arr, forKey:keyChatID)
                let userChatsInstance = self.ref.child(nodeUserChats).child(uid)
                userChatsInstance.setValue(parameterUserChats)
            }
        })
        
        //UserChats Node
        let _ = ref.child(nodeUserChats).child(receiverId).observeSingleEvent(of: .value, with: { (snapshot) in
            // self.ref.child(nodeUserChats).child(receiverId).removeAllObservers()
            if !snapshot.exists(){
                //Not exist
                let parameterUserChats = NSMutableDictionary()
                let arr = NSMutableArray()
                arr.add(chatId)
                parameterUserChats.setValue(arr, forKey:keyChatID)
                let userChatsInstance = self.ref.child(nodeUserChats).child(receiverId)
                print(parameterUserChats)
                userChatsInstance.setValue(parameterUserChats)
            }else{
                //Exist
                var arr = NSMutableArray()
                if let defaults = (snapshot.value as! NSDictionary)[keyChatID] as? NSArray {
                    arr = defaults.mutableCopy() as! NSMutableArray
                }
                if !(arr.contains(chatId) || arr.contains(self.ReceiverUserid + "-" + uid)){
                    arr.add(chatId)
                }
                let parameterUserChats = NSMutableDictionary()
                parameterUserChats.setValue(arr, forKey:keyChatID)
                let userChatsInstance = self.ref.child(nodeUserChats).child(receiverId)
                userChatsInstance.setValue(parameterUserChats)
            }
        })
    }
    
    func SendMsgToAnewChat(chatId : String, receiverId : String, message : String, timeStamp : Double)
    {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        self.setUsrChatsNode(uid: uid, chatId: chatId, receiverId: receiverId, message: message, timeStamp: timeStamp)
        //chatsMessages Node
        let paramchatsMessages = NSMutableDictionary()
        paramchatsMessages.setValue(uid, forKey:keySentBy)
        paramchatsMessages.setValue(message, forKey:keyMessage)
        paramchatsMessages.setValue(timeStamp, forKey:keyTimeStamp)
        paramchatsMessages.setValue(false, forKey:keyViewFlag)
        
        let chatsMessagesInstance = self.ref.child(nodeChatMessages).child(chatId).childByAutoId()
        chatsMessagesInstance.setValue(paramchatsMessages)
        addOverserForGettingNewMsgs(chatID : chatId)
        let model = ChatMessagesModel()
        model.messageId = chatsMessagesInstance.key!
        model.sendby = uid
        model.message = message
        model.timeStamp = timeStamp
        model.ViewFlag = false
        model.SendRcvFlag = "sent"
        self.Chat_messages.add(model)
        self.tblView.reloadData()
        self.txtfld.text = ""
        self.txtMessage.text = "Type a message"
        self.view.endEditing(true)
        self.go_To_End(withAnimation: true)
        
        //Chats Node
        let paramChats = NSMutableDictionary()
        paramChats.setValue([uid,receiverId], forKey: keyMembers)
        paramChats.setValue(chatsMessagesInstance.key, forKey: keyLastMessage)
        paramChats.setValue(timeStamp, forKey: keyTimeStamp)
        
        let chatsInstance = self.ref.child(nodeChats).child(chatId)
        chatsInstance.setValue(paramChats)
        self.CurrentchatID = chatId
        self.sendFCMNotification(token: self.fcmReceiverToken, message: message, userName: senderUserName)
        self.stopAnimating()
    }
    
    func SendMsgToAoldChat(snapshot : DataSnapshot,chatId : String,message : String, timeStamp : Double)
    {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        //chatsMessages Node
        let paramchatsMessages = NSMutableDictionary()
        paramchatsMessages.setValue(uid, forKey:keySentBy)
        paramchatsMessages.setValue(message, forKey:keyMessage)
        paramchatsMessages.setValue(timeStamp, forKey:keyTimeStamp)
        paramchatsMessages.setValue(false, forKey:keyViewFlag)
        let chatsMessagesInstance = self.ref.child(nodeChatMessages).child(chatId).childByAutoId()
        chatsMessagesInstance.setValue(paramchatsMessages)
        
        let model = ChatMessagesModel()
        model.messageId = chatsMessagesInstance.key!
        model.sendby = uid
        model.message = message
        model.timeStamp = timeStamp
        model.ViewFlag = false
        model.SendRcvFlag = "sent"
        
        self.Chat_messages.add(model)
        self.tblView.reloadData()
        self.txtfld.text = ""
        self.txtMessage.text = "Type a message"
        self.view.endEditing(true)
        self.go_To_End(withAnimation: true)
        
        //Chats Node
        let paramChats = NSMutableDictionary()
        paramChats.setValue(chatsMessagesInstance.key, forKey: keyLastMessage)
        paramChats.setValue(timeStamp, forKey: keyTimeStamp)
        
        self.ref.child(nodeChats).child(chatId).updateChildValues(paramChats as! [AnyHashable : Any])
        
        self.CurrentchatID = chatId
        print("token:\(fcmReceiverToken)")
        self.sendFCMNotification(token: self.fcmReceiverToken, message: message, userName: senderUserName)
        self.stopAnimating()
    }
    
    func setData()
    {
        //self.navigationItem.title = UserName
    }
    
    func setDesigning()
    {
        let tapTerm1 : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(sender:)))
        tapTerm1.delegate = self
        tapTerm1.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm1)
        //Set keyboard toolbar
        var inputAccView : UIView = UIView()
        inputAccView = UIView(frame: CGRect(x:0, y:0, width: tblView.frame.size.width, height: viewMessage.frame.height))
        inputAccView.backgroundColor = UIColor.lightGray
        inputAccView.alpha = 0.8
        var btnKeyboard : UIButton = UIButton()
        btnKeyboard = UIButton(type: .custom)
        btnKeyboard.frame = CGRect(x:tblView.frame.size.width-50,y: inputAccView.center.y, width: 75, height: 37)
        btnKeyboard.setTitle("Send", for: .normal)
        btnKeyboard.titleLabel?.font = btnSend.titleLabel?.font//UIFont(name: "Helvetica-Medium", size: 17)
        btnKeyboard.setTitleColor(themeColor, for: .normal)
        //btnKeyboard.setImage(UIImage(named: "send-hover.png"), for: .normal)
        btnKeyboard.addTarget(self, action: #selector(self.onClick_btnSend(_:)), for: .touchUpInside)
        txtfld = UITextView(frame: CGRect(x:8, y: 6, width: btnKeyboard.frame.origin.x - 60, height: 37))
        txtfld.backgroundColor = UIColor.clear
        txtfld.isEditable = true
        txtfld.textColor = txtMessage.textColor
        txtfld.font = txtMessage.font
        txtfld.delegate = self
        txtfld.textColor = UIColor.darkGray
        txtfld.text = "Type a message"
        txtMessage.delegate = self
        let keyboardNextButtonView1 : UIToolbar = UIToolbar()
        keyboardNextButtonView1.frame = inputAccView.frame
        let  Button1 : UIBarButtonItem = UIBarButtonItem()
        Button1.customView  = btnKeyboard
        let  Button3 : UIBarButtonItem = UIBarButtonItem()
        Button3.customView  = txtfld
        keyboardNextButtonView1.setItems([Button3,Button1], animated: true)
        keyboardNextButtonView1.backgroundColor = viewMessage.backgroundColor
        txtMessage.inputAccessoryView = keyboardNextButtonView1
        configureTableView()
        //Show navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //KeyBoard Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - KeyBoard Observer Method
    @objc func keyboardWillShow(_ notification:Notification){
        //ScrView.isScrollEnabled = true
        let userInfo = (notification as NSNotification).userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = tblView.contentInset
        contentInset.bottom = keyboardFrame.size.height+10
        tblView.contentInset = contentInset
        go_To_End(withAnimation: true)
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        tblView.contentInset = contentInset
        go_To_End(withAnimation: true)
    }
    
    @IBAction func onClick_btnSend(_ sender: AnyObject) {
        print(self.isBlocked)
        if(self.isBlocked == true)
        {
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            self.view.endEditing(true)
            if(self.blockedBy == uid)
            {
                let v = UIView()
                let custAlert = customAlertView.init(title: "Message", message: "Are you sure you want to unblock this user?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
                custAlert.onRightBtnSelected = { (Value: String) in
                    custAlert.dismiss(animated: true)
                     self.unBlockUser()
                }
                custAlert.onLeftBtnSelected = { (Value: String) in
                    custAlert.dismiss(animated: true)
                }
                custAlert.show(animated: true)
                
            }
        }
        else{
            SendMessageAPI()
        }
    }
    
    func go_To_End(withAnimation: Bool)
    {
        if(self.tblView.numberOfRows(inSection: 0) == self.Chat_messages.count && self.Chat_messages.count > 1)
        {
            let indexPath = IndexPath(row: self.Chat_messages.count-1, section: 0)
            self.tblView.scrollToRow(at: indexPath, at: .top, animated: withAnimation)
            self.userObj.lastMessage = (self.Chat_messages.lastObject as! ChatMessagesModel).message
            self.userObj.lastmsgTime = (self.Chat_messages.lastObject as! ChatMessagesModel).timeStamp
        }
    }
    
    @objc func tapView(sender:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // MARK: Custom Methods
    func configureTableView() {
        tblView.delegate = self
        tblView.dataSource = self
        tblView.estimatedRowHeight = 78
        tblView.rowHeight = UITableView.automaticDimension
        tblView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtMessage.text == "Type a message"{
            txtMessage.textColor = UIColor.darkGray
            txtMessage.text = ""
        }
        if txtfld.text == "Type a message"{
            txtfld.textColor = UIColor.darkGray
            txtfld.text = ""
        }
        txtMessage.textColor = UIColor.darkGray
        txtfld.textColor = UIColor.darkGray
        txtfld.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        txtMessage.text = txtfld.text
    }
    
    func blockThisUser()
    {
        if(CurrentchatID != "")
        {
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            self.blockedBy = uid
            self.isBlocked = true
            self.rightBarbuttonItem.image = #imageLiteral(resourceName: "ic_delete_user")
            let userInstance = ref.child(nodeChats).child(CurrentchatID)
            userInstance.updateChildValues([keyBlockedBy:uid,keyIsBlocked:true])
            
            let custAlert = customAlertView(title: "Message", message: "User blocked successfully.", btnTitle: "OK")
            custAlert.show(animated: true)
    
        }else
        {
            let custAlert = customAlertView(title: "Message", message: "Something went wrong. Please try again.", btnTitle: "OK")
            custAlert.show(animated: true)
            
        }
        //viewDidLoad()
    }
    
    func unBlockUser()
    {
        if(CurrentchatID != "")
        {
            let userInstance = ref.child(nodeChats).child(CurrentchatID)
            userInstance.child(keyBlockedBy).removeValue()
            userInstance.child(keyIsBlocked).removeValue()
            self.rightBarbuttonItem.image = #imageLiteral(resourceName: "ic_delete_user")
            
            self.isBlocked = false
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            self.blockedBy = uid
            
            let custAlert = customAlertView(title: "Message", message: "User unblocked successfully.", btnTitle: "OK")
            custAlert.show(animated: true)
            
            
            
            // self.blockedBy = ""
        }else
        {
            let custAlert = customAlertView(title: "Message", message: "Something went wrong. Please try again.", btnTitle: "OK")
            custAlert.show(animated: true)
        }
        // viewDidLoad()
    }
    
    @IBAction func onClick_btnBlockUser(_ sender: Any) {
        
        print(self.blockedBy)
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        print(uid)
        if(self.isBlocked == true && self.blockedBy == uid)
        {
            let v = UIView()
            let custAlert = customAlertView.init(title: "Message", message: "Unblock user?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
                 self.unBlockUser()
            }
            custAlert.show(animated: true)
            
        }else
        {
            let v = UIView()
            let custAlert = customAlertView.init(title: "Message", message: "Block user?", customView: v, leftBtnTitle: "No", rightBtnTitle: "Yes", image: #imageLiteral(resourceName: "ic_done"))
            custAlert.onRightBtnSelected = { (Value: String) in
                custAlert.dismiss(animated: true)
                 self.blockThisUser()
            }
            custAlert.show(animated: true)           
        }
        self.view.endEditing(true)
    }
    
//    @IBAction func onClick_btnBack(sender: AnyObject) {
//        if (isfromConversatin == false)
//        {
//            self.navigationController?.setNavigationBarHidden(true, animated: false)
//        }
//        let _ = navigationController?.popViewController(animated: true)
//    }
}

extension ChattingsVC :  UITableViewDelegate, UITableViewDataSource
{
    //MARK: UITableView Delegate & Data Source
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Chat_messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userObj : ChatMessagesModel = ChatMessagesModel()
        userObj = Chat_messages.object(at: indexPath.row) as! ChatMessagesModel
        let flag = userObj.SendRcvFlag
        if(flag == "sent")
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "idCellChat", for: indexPath) as! ChatCellSend
            cell.lblChatMessage.text = userObj.message
            
            if UserImage != ""{
                let storageRef=Storage.storage().reference(forURL:UserImage as String)
                cell.imgProfileView.sd_setImage(with:storageRef, placeholderImage:#imageLiteral(resourceName: "ic_profile_default"))
            }else{
                cell.imgProfileView.image = #imageLiteral(resourceName: "ic_profile_default")
            }
            var lblTimeText = ""
            let date : NSDate = NSDate(timeIntervalSince1970: TimeInterval(userObj.timeStamp))
            let str1 = utils.getPostTime(date as Date).0
            let str2 = utils.getPostTime(date as Date).1
            if str2 == "year" || str2 == "month" || str2 == "day" {
                if str2 == "day" {
                    let arr = str1.components(separatedBy: " ")
                    if Int(arr[0])! > 7 {
                        lblTimeText = "\(utils.convertDateToString(date as Date, format: "dd MMM yy"))"
                    }else{
                        lblTimeText = "\(str1)"
                    }
                }else{
                    lblTimeText = "\(utils.convertDateToString(date as Date, format: "dd MMM yy"))"
                }
            }
            else{
                lblTimeText = utils.getPostTime(date as Date).0
            }
            cell.lblTime.text = lblTimeText
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "idCellChatRecieved", for: indexPath) as! ChatCellRecieved
            cell.lblChatMessage.text = userObj.message
            
            if OponentImage != ""{
                let storageRef=Storage.storage().reference(forURL:self.OponentImage as String)
                cell.imgProfileView.sd_setImage(with:storageRef, placeholderImage:#imageLiteral(resourceName: "ic_profile_default"))
            }else{
                cell.imgProfileView.image = #imageLiteral(resourceName: "ic_profile_default")
            }
            var lblTimeText = ""
            let date : NSDate = NSDate(timeIntervalSince1970: TimeInterval(userObj.timeStamp))
            let str1 = utils.getPostTime(date as Date).0
            let str2 = utils.getPostTime(date as Date).1
            if str2 == "year" || str2 == "month" || str2 == "day" {
                if str2 == "day" {
                    let arr = str1.components(separatedBy: " ")
                    if Int(arr[0])! > 7 {
                        lblTimeText = "\(utils.convertDateToString(date as Date, format: "dd MMM yy"))"
                    }else{
                        lblTimeText = "\(str1)"
                    }
                }else{
                    lblTimeText = "\(utils.convertDateToString(date as Date, format: "dd MMM yy"))"
                }
            }
            else{
                lblTimeText = utils.getPostTime(date as Date).0
            }
            cell.lblTime.text = lblTimeText
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtfld.text != "" && txtfld.text != "Type a message" {
            txtMessage.text = txtfld.text
        }else{
            txtfld.text = "Type a message"
        }
        txtMessage.text = txtfld.text
}
}
