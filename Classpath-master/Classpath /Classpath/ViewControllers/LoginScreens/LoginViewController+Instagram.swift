//
//  File.swift
//  Classpath
//
//  Created by coldfin_lb on 8/1/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//
import UIKit
import FirebaseAuth
import Firebase

extension  LoginViewController : InstaLogindelegate
{
    func doneLogin(token: String)
    {
        startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        let urlString = "http://www.classpathonline.com/verifyToken"
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let ptoken = ["token": token] as [String: Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: ptoken, options: .prettyPrinted)
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
                                //    print(user?.user.uid)
                                    let parameter = NSMutableDictionary()
                                    parameter.setValue(user?.user.displayName, forKey: keyUsername)
                                    parameter.setValue(user?.user.uid, forKey: "InstaID")
                                    parameter.setValue(user?.user.photoURL?.absoluteString, forKey: keyProfilePic)
                                    parameter.setValue(true, forKey: keyNotificationState)
                                    
                                    let arr = NSMutableArray(array: ["Athlete"])
                                    parameter.setValue(arr, forKey: keyBadges)
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
                                            self.setUserData(param: parameter, uid: (user?.user.uid)!)
                                            self.stopAnimating()
                                            self.term = "true"
                                        }
                                        else
                                        {
                                            let userInstance=self.ref.child(nodeUsers).child(uid)
                                            userInstance.updateChildValues([keyDeviceToken:UserDefaults.standard.value(forKey:keyDeviceToken) as! String])
                                        }
                                    })
                                    
                                    self.myGroup.notify(queue: DispatchQueue.main, execute: {
                                        if self.term == "true"{
                                        }else{
                                            self.stopAnimating()
                                            //self.redirectToHome()
                                            self.redirectToTerms()
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
