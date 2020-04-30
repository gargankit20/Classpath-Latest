//
//  Terms&ConditionVC.swift
//  HIITList
//
//  Created by coldfin_lb on 12/18/17.
//  Copyright © 2017 Coldfin. All rights reserved.
//

import UIKit

class Terms_ConditionVC: UIViewController {

    @IBOutlet weak var barHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenHeight >= 812{
            barHeight.constant = 88
        }else{
            barHeight.constant = 64
        }
    }

    @IBAction func onClick_btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Statusbar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
