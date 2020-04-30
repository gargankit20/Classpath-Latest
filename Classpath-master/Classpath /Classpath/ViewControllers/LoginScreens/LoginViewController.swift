//
//  ViewController.swift
//  Classpath
//
//  Created by coldfin_lb on 8/1/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit

class LoginViewController: UIViewController,NVActivityIndicatorViewable,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageIconHeight: NSLayoutConstraint!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var scrView: UIScrollView!
    
    var ref: DatabaseReference!
    var myGroup = DispatchGroup()
    var term = String()
    
    //MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        let signIn = GIDSignIn.sharedInstance()!
        signIn.scopes = ["profile"]
        signIn.uiDelegate = self
        signIn.delegate = self
        signIn.clientID = FirebaseApp.app()?.options.clientID
        
        if screenHeight == 812{
            imageIconHeight.constant = 220
        }else if screenHeight == 812 || screenHeight > 667{
            imageIconHeight.constant = 165
        }else if screenHeight < 667 {
            imageIconHeight.constant = 0
        }
        
        //KeyBoard Observer
        NotificationCenter.default.addObserver(self,selector:#selector(self.keyboardWillShow(_:)),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHide(_:)),name: UIResponder.keyboardWillHideNotification,object: nil)
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
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
    @objc func tapView(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: self declared functions
    func setUserData(param: NSMutableDictionary, uid : String)
    {
        self.ref?.child(nodeUsers).child(uid).child(keyTerms).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let flag =  snapshot.value as? Bool
            {
                if(flag == true){
                    param.setValue(true, forKey: keyTerms)
                    let userInstance = self.ref.child(nodeUsers).child(uid)
                    userInstance.updateChildValues([keyTerms:true])
                    self.redirectToHome()
                }else
                {
                    param.setValue(false, forKey: keyTerms)
                    let userInstance = self.ref.child(nodeUsers).child(uid)
                    userInstance.updateChildValues([keyTerms:true])
                    self.redirectToTerms()
                }
            }else
            {
                param.setValue(false, forKey: keyTerms)
                let userInstance = self.ref.child(nodeUsers).child(uid)
                userInstance.setValue(param)
                self.redirectToTerms()
            }
        })
    }
    
    func redirectToTerms()
    {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "EULAVC") as! EULAVC
        
        modalViewController.modalPresentationStyle = .overCurrentContext
        self.present(modalViewController, animated: true, completion: nil)
    }
    
    func redirectToHome()
    {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "HomeTabbarController")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    func redirectToHomeORterms()
    {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        self.ref?.child(nodeUsers).child(uid).child(keyTerms).observeSingleEvent(of: .value, with: { (snapshot) in
            self.stopAnimating()
            if let flag =  snapshot.value as? Bool
            {
                if (flag == true)
                {
                    self.redirectToHome()
                }else
                {
                    self.redirectToTerms()
                }
            }else
            {
                self.redirectToTerms()
            }
        })
    }
    
    func ValidateTextField() -> Bool
    {
        if(txtEmailAddress.text == "" || txtPassword.text == "" )
        {
            utils.emptyFieldValidation(txtEmailAddress, view: self.view, tag: txtEmailAddress.tag + 2)
            utils.emptyFieldValidation(txtPassword, view: self.view, tag: txtPassword.tag + 2)
            return false
        }
        return true
    }
    
    func TwitterLogin(){
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                var twitter = String()
                twitter = (session?.userID)!
                
                self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                let parameter = NSMutableDictionary()
          //      print(session?.userName)
                parameter.setValue(session?.userName, forKey: keyUsername)
                let twitterClient = TWTRAPIClient(userID: session?.userID)
                twitterClient.loadUser(withID: (session?.userID)!) { (user, error) in
                    parameter.setValue(user?.profileImageURL, forKey: keyProfilePic)
                    parameter.setValue(twitter, forKey: "twitterID")
                    parameter.setValue(true, forKey: keyNotificationState)
                    //let currentDate = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM/yyyy")
                    let timestamp = NSDate().timeIntervalSince1970
                    let myTimeInterval = TimeInterval(timestamp)
                    let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/yyyy"
                    let JoinDate = formatter.string(from: time as Date)
                    
                    
                    //                              let currentDate = NSDate().timeIntervalSince1970
                    //                              let formatter = DateFormatter()
                    //                              formatter.dateFormat = "MM/yyyy"
                    
                    
                    let arr = NSMutableArray(array: ["Athlete"])
                    parameter.setValue(arr, forKey: keyBadges)
                    
                    
                    parameter.setValue(JoinDate, forKey: keyJoinDate)
                    parameter.setValue("Twitter", forKey: keyConnectedBy)
                    if let deviceToken = UserDefaults.standard.value(forKey: keyDeviceToken) as? String
                    {
                        parameter.setValue(deviceToken, forKey: keyDeviceToken)
                    }
                    else{
                        parameter.setValue("", forKey: keyDeviceToken)
                    }
                    
                    let credential = TwitterAuthProvider.credential(withToken: (session?.authToken)!, secret: (session?.authTokenSecret)!)
                    Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
                        self.stopAnimating()
                        
                        if error==nil
                        {
                            guard let uid=Auth.auth().currentUser?.uid else{
                                return
                            }
                            
                            let ref=Database.database().reference()
                            let _=ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue:uid).observeSingleEvent(of:.value, with:{snapshot in
                                if !snapshot.exists()
                                {
                                    self.setUserData(param:parameter, uid:(user?.user.uid)!)
                                    self.redirectToTerms()
                                }
                                else
                                {
                                    let userInstance=self.ref.child(nodeUsers).child(uid)
                                    userInstance.updateChildValues([keyDeviceToken:UserDefaults.standard.value(forKey:keyDeviceToken) as! String])
                                    
                                    let appDelegate=UIApplication.shared.delegate! as! AppDelegate
                                    let initialViewController=self.storyboard!.instantiateViewController(withIdentifier:"HomeTabbarController")
                                    appDelegate.window?.rootViewController=initialViewController
                                    appDelegate.window?.makeKeyAndVisible()
                                }
                            })
                        }
                        else
                        {
                            let custAlert=customAlertView(title:"Error", message:(error?.localizedDescription)!, btnTitle:"OK")
                            custAlert.show(animated:true)
                        }
                    }
                }
            }
        })
        
    }
    
    func openFB()
    {
        let login: FBSDKLoginManager = FBSDKLoginManager()
        
        
        let permission: [AnyObject] = ["public_profile" as AnyObject, "email" as AnyObject]
       // login.logOut()
        login.logIn(withReadPermissions: permission, from: self, handler: { (result, error) -> Void in
            if error != nil {
                
                NSLog("error in login")
                NSLog("Error: %@ \(error as Any)")
                
            }
            else if (result?.isCancelled)! {
                NSLog("Press Cancel Button")
            }
            else
            {
                print("No errors logging in")
                if((FBSDKAccessToken.current()) != nil)
                {
                    print("We got a Facebook Token")
                    self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender, interested_in, birthday, hometown, location"]).start(completionHandler: { (connection, result, error) -> Void in
                        self.stopAnimating()
                        if (error == nil)
                        {
                            let accessToken = FBSDKAccessToken.current().tokenString
                            NSLog("accessToken: %@ \((result as! NSDictionary))")
                            if (accessToken != nil) {
                                
                                var FacebookID:String = ""
                                if let userData = (result as! NSDictionary).value(forKey: "id") as? String
                                {
                                    FacebookID = userData
                                }
                                
                                var username:String = ""
                                if let userData = (result as! NSDictionary).value(forKey: "name") as? String
                                {
                                    username = userData
                                }
                                
                                var email:String = ""
                                if let userData = (result as! NSDictionary).value(forKey: "email") as? String
                                {
                                    email = userData
                                }
                                
                                let picture = (result as! NSDictionary).value(forKey: "picture") as! NSDictionary
                                let data = picture.value(forKey: "data") as! NSDictionary
                                
                                
                                let parameter = NSMutableDictionary()
                                parameter.setValue(username, forKey: keyUsername)
                                parameter.setValue(FacebookID, forKey: "FacebookID")
                                parameter.setValue(email, forKey: keyEmail)
                                parameter.setValue(data.value(forKey: "url") as! NSString, forKey: keyProfilePic)
                                parameter.setValue(true, forKey: keyNotificationState)
                                //let currentDate = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM/yyyy")
                                let timestamp = NSDate().timeIntervalSince1970
                                let myTimeInterval = TimeInterval(timestamp)
                                let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MM/yyyy"
                                let JoinDate = formatter.string(from: time as Date)
                                
                                let arr = NSMutableArray(array: ["Athlete"])
                                parameter.setValue(arr, forKey: keyBadges)
        
                                parameter.setValue(JoinDate, forKey: keyJoinDate)
                                parameter.setValue("Facebook", forKey: keyConnectedBy)
                                if let deviceToken = UserDefaults.standard.value(forKey: keyDeviceToken) as? String
                                {
                                    parameter.setValue(deviceToken, forKey: keyDeviceToken)
                                }
                                else{
                                    parameter.setValue("", forKey: keyDeviceToken)
                                }
                                
                                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                                
                                self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                                Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
                                    self.stopAnimating()
                                    
                                    if error==nil
                                    {
                                        guard let uid=Auth.auth().currentUser?.uid else{
                                            return
                                        }
                                        
                                        let ref=Database.database().reference()
                                        let _=ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue:uid).observeSingleEvent(of:.value, with:{snapshot in
                                            
                                            if !snapshot.exists()
                                            {
                                                self.setUserData(param:parameter, uid:(user?.user.uid)!)
                                                self.redirectToTerms()
                                            }
                                            else
                                            {
                                                let userInstance=self.ref.child(nodeUsers).child(uid)
                                                userInstance.updateChildValues([keyDeviceToken:UserDefaults.standard.value(forKey:keyDeviceToken) as! String])
                                                
                                                let appDelegate=UIApplication.shared.delegate! as! AppDelegate
                                                let initialViewController=self.storyboard!.instantiateViewController(withIdentifier:"HomeTabbarController")
                                                appDelegate.window?.rootViewController=initialViewController
                                                appDelegate.window?.makeKeyAndVisible()
                                            }
                                        })
                                    }
                                    else
                                    {
                                        let custAlert=customAlertView(title:"Error", message:(error?.localizedDescription)!, btnTitle:"OK")
                                        custAlert.show(animated:true)
                                    }
                                }
                            }
                        }
                        else{
                            NSLog("Error: %@\(error!)")
                        }
                    })
                }else{
                    NSLog("current access token is nil ")
                }
            }
        })
    }
    
    //MARK: Action methods
    @IBAction func onClick_loignButton(_ sender: Any) {
        self.view.endEditing(true)
        if(ValidateTextField())
        {
            if(txtEmailAddress.text?.isValidEmail())!
            {
                
                startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                
                
                Auth.auth().signIn(withEmail: txtEmailAddress.text!, password: txtPassword.text!, completion: { (user, error) in
                    self.stopAnimating()
                    if error == nil {
                        self.redirectToHomeORterms()
                        var deviceToken = ""
                        if let Token = UserDefaults.standard.value(forKey: keyDeviceToken) as? String
                        {
                            deviceToken = Token
                        }
                        self.ref.child(nodeUsers).child((user?.user.uid)!).updateChildValues([keyDeviceToken:deviceToken])
                    }else
                    {
                        let custAlert = customAlertView(title: "Error", message: (error?.localizedDescription)!, btnTitle: "OK")
                        custAlert.show(animated: true)
                    }
                })
                
            }else{
                let custAlert = customAlertView(title: "Error", message: "Please enter valid email.", btnTitle: "OK")
                custAlert.show(animated: true)
            }
        }else
        {
            let custAlert = customAlertView(title: "Error", message: "Required field(s) empty", btnTitle: "OK")
            custAlert.show(animated: true)
        }
    }
    
    @IBAction func onClick_forgotPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Forgot Password", message: "Please enter the email address registered for your account", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Email"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            Auth.auth().sendPasswordReset(withEmail: (textField?.text!)!) { error in
                if error != nil
                {
                    let custAlert = customAlertView(title: "Error", message: (error?.localizedDescription)!, btnTitle: "OK")
                    custAlert.show(animated: true)
                }
                else
                {
                    let custAlert = customAlertView(title: "Message", message: "Password recovery mail is sent.", btnTitle: "OK")
                    custAlert.show(animated: true)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClick_otherLoginButton(_ sender: UIButton) {
        if sender.tag == 1{
            openFB()
        }else if sender.tag == 2{
            TwitterLogin()
        }else if sender.tag == 3{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "InstagramLoginVC") as! InstagramLoginVC
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }else if sender.tag == 4{
            GIDSignIn.sharedInstance().signOut()
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    @IBAction func onClick_signUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onClick_TermsButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Terms_ConditionVC") as! Terms_ConditionVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: Statusbar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
extension LoginViewController: GIDSignInUIDelegate,GIDSignInDelegate
{
    // MARK: - Google Signin
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if (error == nil) {
        }
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true) {
            //nothing
        }
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true) {
            //nothing
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError : Error!)
    {
        if withError==nil
        {
            self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
            let parameter = NSMutableDictionary()
            parameter.setValue(user.profile.givenName, forKey: keyUsername)
            
            let arr = NSMutableArray(array: ["Athlete"])
            parameter.setValue(arr, forKey: keyBadges)
            //let currentDate = utils.convertStringToDate(Date().localDateString(), dateFormat: "MM/yyyy")
            let timestamp = NSDate().timeIntervalSince1970
            let myTimeInterval = TimeInterval(timestamp)
            let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yyyy"
            let JoinDate = formatter.string(from: time as Date)
            
            parameter.setValue(JoinDate, forKey: keyJoinDate)
            parameter.setValue("Google", forKey: keyConnectedBy)
            parameter.setValue(user.profile.email, forKey: keyEmail)
            parameter.setValue(user.profile.imageURL(withDimension: 100).absoluteString, forKey: keyProfilePic)
            parameter.setValue(true, forKey: keyNotificationState)
            if let deviceToken = UserDefaults.standard.value(forKey: keyDeviceToken) as? String
            {
                parameter.setValue(deviceToken, forKey: keyDeviceToken)
            }
            else{
                parameter.setValue("", forKey: keyDeviceToken)
            }
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
                self.stopAnimating()
                
                if error==nil
                {
                    guard let uid=Auth.auth().currentUser?.uid else{
                        return
                    }
                    
                    let ref=Database.database().reference()
                    let _=ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue:uid).observeSingleEvent(of:.value, with:{snapshot in
                        if !snapshot.exists()
                        {
                            self.setUserData(param:parameter, uid:(user?.user.uid)!)
                            self.redirectToTerms()
                        }
                        else
                        {
                            let userInstance=self.ref.child(nodeUsers).child(uid)
                            userInstance.updateChildValues([keyDeviceToken:UserDefaults.standard.value(forKey:keyDeviceToken) as! String])
                            
                            let appDelegate=UIApplication.shared.delegate! as! AppDelegate
                            let initialViewController=self.storyboard!.instantiateViewController(withIdentifier:"HomeTabbarController")
                            appDelegate.window?.rootViewController=initialViewController
                            appDelegate.window?.makeKeyAndVisible()
                        }
                    })
                }
                else
                {
                  let custAlert=customAlertView(title:"Error", message:(error?.localizedDescription)!, btnTitle:"OK")
                  custAlert.show(animated:true)
                }
            }
        }
    }
}
