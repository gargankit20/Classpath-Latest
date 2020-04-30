//
//  SettingsVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/8/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {

    @IBOutlet weak var lblRadius: UILabel!
    @IBOutlet weak var swt_notify: UISwitch!
    
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        swt_notify.setOn(snapUtils.currentUserModel.notificationState, animated: true)
        
        swt_notify.layer.cornerRadius = 16.0;
    }
    
    @IBAction func onValueChange_radius(_ sender: UISlider) {
        lblRadius.text = "\(Int(sender.value))"
    }

    @IBAction func onValueChange_noti(_ sender: UISwitch) {
        self.ref.child(nodeUsers).child(snapUtils.currentUserModel.userId).updateChildValues([keyNotificationState:sender.isOn])
    }
}
