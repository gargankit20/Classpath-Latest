
//
//  AppDelegate.swift
//  Classpath
//
//  Created by coldfin_lb on 8/1/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit
import UserNotifications
import FirebaseMessaging
import StoreKit
import Stripe
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate,UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    var restrictRotation:UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        STPPaymentConfiguration.shared().publishableKey = STRIPE_PUBLISHABLE_KEY

        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        TWTRTwitter.sharedInstance().start(withConsumerKey:"637O7lUOT3CKozPFEwlmWjuFi", consumerSecret:"62a9GJWfDeYZpjB6q3Cr5Z9brJ0vfNTqwURVhXkCWnAAD4dtUH")
        
        FirebaseApp.configure()
        //Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                           categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        //UIApplication.shared.registerForRemoteNotifications()
        //FirebaseApp.configure()
        Messaging.messaging().delegate=self
        UIApplication.shared.applicationIconBadgeNumber = 0
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        
        return true
    }
   
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
         print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: keyDeviceToken)
        UserDefaults.standard.synchronize()
  
    }
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data )
    {
        Messaging.messaging().apnsToken=deviceToken
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Device Token :\(deviceTokenString) :")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
        //Called when a notification is delivered to a foreground app.
        print("didReceiveRemoteNotification Userinfo %@",userInfo)
        let _ : NSDictionary = userInfo as NSDictionary
        //  print(dict)
        //    if let notification:NSDictionary = dict.object(forKey: "aps") as? NSDictionary
        //   {}
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        // Process notification content
        print("\(content.userInfo)")
        completionHandler([.alert, .sound]) // Display notification as
        
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            _ = user.userID                  // For client-side use only!
            _ = user.authentication.idToken // Safe to send to the server
            _ = user.profile.name
            _ = user.profile.givenName
            _ = user.profile.familyName
            _ = user.profile.email
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
        FBSDKAppEvents.activateApp()
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let appId = url.absoluteString.components(separatedBy: "/").first
        if(appId == "fb498894970525874:")
        {
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }else if( appId == "939384155187-2bcbrhag6mrhtckqvfuu0vir9de0dhce.apps.googleusercontent.com:")
        {
            return GIDSignIn.sharedInstance().handle(url as URL,
                                                     sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }else
        {
            return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        }
        
        
    }
    
    
    // This method is where you handle URL opens if you are using univeral link URLs (eg "https://example.com/stripe_ios_callback")
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let stripeHandled = Stripe.handleURLCallback(with: url)
                
                if (stripeHandled) {
                    return true
                }
                else {
                    // This was not a stripe url, do whatever url handling your app
                    // normally does, if any.
                }
            }
            
        }
        return false
    }

    //orientation
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }
}





