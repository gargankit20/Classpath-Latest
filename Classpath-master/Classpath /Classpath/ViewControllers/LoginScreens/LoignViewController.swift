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

class LoignViewController: UIViewController,InstaLogindelegate {
    
    

    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
     var ref: DatabaseReference!
    
    //MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    //MARK: Action methods
    @IBAction func onClick_loignButton(_ sender: Any) {
        
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
                    // Error
                }
                else
                {
                    //Mail sent
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClick_otherLoginButton(_ sender: UIButton) {
        if sender.tag == 3{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "InstagramLoginVC") as! InstagramLoginVC
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClick_signUp(_ sender: Any) {
    }
    
    @IBAction func onClick_TermsButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Terms_ConditionVC") as! Terms_ConditionVC
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: Statusbar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension  LoginViewController : InstaLogindelegate
{
    func doneLogin(token: String) {
        
        let size = CGSize(width: 30, height:30)
        startAnimating(size, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        
        let urlString = "http://13.58.33.217:3000/verifyToken"//"http://localhost:8000/verifyToken"
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let token = ["token": token] as [String: Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: token, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        self.stopAnimating()
                        NSLog("Received data:\n\(jsonDataDict))")
                        let element = jsonDataDict as NSDictionary
                        let token = element.value(forKey: "firebase_token") as? String
                        
                        if((token) != nil){
                            Auth.auth().signIn(withCustomToken: token ?? "") { (user, error) in
                                if user != nil {
                                    print(user?.uid)
                                    var Instagramid = String()
                                    Instagramid = (user?.uid)!
                                    let parameter = NSMutableDictionary()
                                    parameter.setValue(user?.displayName, forKey: keyUsername)
                                    parameter.setValue(user?.uid, forKey: "InstaID")
                                    parameter.setValue(user?.photoURL?.absoluteString, forKey: keyProfilePic)
                                    let timestamp = NSDate().timeIntervalSince1970
                                    let myTimeInterval = TimeInterval(timestamp)
                                    let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "MM/yyyy"
                                    let JoinDate = formatter.string(from: time as Date)
                                    
                                    parameter.setValue(JoinDate, forKey: keyJoinDate)
                                    parameter.setValue("Instagram", forKey: keyConnectedBy)
                                    if let deviceToken = UserDefaults.standard.value(forKey: keyDeviceToken) as? String
                                    {
                                        parameter.setValue(deviceToken, forKey: keyDeviceToken)
                                    }
                                    else{
                                        parameter.setValue("", forKey: keyDeviceToken)
                                    }
                                    
                                    guard let uid = Auth.auth().currentUser?.uid else{
                                        return
                                    }
                                    
                                    let ref = Database.database().reference()
                                    let _ = ref.child(nodeUsers).queryOrderedByKey().queryEqual(toValue: uid).observe(.value, with: { snapshot in
                                        self.myGroup.enter()
                                        if !snapshot.exists() {
                                            defer { self.myGroup.leave()}
                                            self.setUserData(param: parameter, uid: (user?.uid)!)
                                            self.stopAnimating()
                                            //                                             self.redirectToHomeORterms()
                                            self.term = "true"
                                        }
                                    })
                                    
                                    self.myGroup.notify(queue: DispatchQueue.main, execute: {
                                        if self.term == "true"{
                                        }else{
                                            self.stopAnimating()
                                            self.redirectToHome()
                                        }
                                    })
                                    
                                    
                                } else {
                                    print(error!)
                                }
                            }
                        }
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
                self.stopAnimating()
            }
        }
        task.resume()
    }
}


