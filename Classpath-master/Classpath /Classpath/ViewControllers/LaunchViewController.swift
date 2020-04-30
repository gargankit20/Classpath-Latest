//
//  LaunchViewController.swift
//  Classpath
//
//  Created by coldfin_lb on 8/13/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import FirebaseAuth

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        var storyBoardId = "LoginViewController"
        if Auth.auth().currentUser != nil {
            storyBoardId = "HomeTabbarController"
        }
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: storyBoardId)
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
