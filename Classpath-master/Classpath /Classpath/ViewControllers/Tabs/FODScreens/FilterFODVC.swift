//
//  FilterVC.swift
//  Classpath
//
//  Created by coldfin on 11/01/19.
//  Copyright © 2019 coldfin_lb. All rights reserved.
//

import UIKit

class FilterFODVC: UIViewController {

    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func onSlider_level(_ sender: UISlider) {
        lblLevel.text = "\(Int(sender.value))/10"
    }
    
    @IBAction func onSlider_duration(_ sender: UISlider) {
        lblDays.text = "\(Int(sender.value))"
    }
    
    @IBAction func onSlider_price(_ sender: UISlider) {
        lblPrice.text = "$\(Int(sender.value))"
    }
}
