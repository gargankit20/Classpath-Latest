//
//  PromoteVC.swift
//  Classpath
//
//  Created by Coldfin on 20/08/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import StoreKit
import Firebase

class PromoteTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDetails:UILabel!
    @IBOutlet weak var btnBuy:UIButton!
    @IBOutlet weak var view_shadow: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view_shadow.layer.shadowOpacity = 1
        view_shadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_shadow.layer.shadowRadius = 4.0
        view_shadow.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
    }
}

class PromoteVC: UIViewController,UITableViewDelegate,UITableViewDataSource,NVActivityIndicatorViewable {
    
    @IBOutlet weak var tblview : UITableView!
    var Expiration_Date = Date()
    var products: [SKProduct] = []
    var parameter = NSMutableDictionary()
    var SelectedPackage = String()
    var product: SKProduct? {
        didSet {
            guard product != nil else { return }
        }
    }
    
    struct promoteData {
        var heading = String()
        var description = String()
    }
    
    var promoteDatas = [promoteData(heading: "7 Days promotion for $5.99", description: "Your listing will be posted in the Promoted Listings category (or view all categories) for seven days."),promoteData(heading: "2 weeks promotion for $10.99", description: "Your listing will be posted in the Promoted Listings category (or view all categories) for two weeks.")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SubscribedProduct.store.restorePurchases()
        requestAllProducts()
        
        tblview.tableFooterView = UIView(frame: CGRect.zero)
        tblview.rowHeight = 150
    }
    
    //Get Product from itunes
    func requestAllProducts() {
         
        self.startAnimating(sizeProgress, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
        print(SubscribedProduct.store)
        SubscribedProduct.store.requestProducts { [unowned self] success, products in
       //     print( success, products)
            if success, let products = products {
                self.products = products
                self.stopAnimating()
            }
        }
    }

    //MARK: Tableview datasource and delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promoteDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "promoteCell", for: indexPath) as! PromoteTableViewCell
        cell.lblTitle.text = promoteDatas[indexPath.row].heading
        cell.lblDetails.text = promoteDatas[indexPath.row].description
        cell.btnBuy.tag = indexPath.row
        cell.btnBuy.addTarget(self, action:#selector(onclick_buy(sender:)), for: .touchUpInside)
        return cell
    }
    @objc func onclick_buy(sender: UIButton) {
        var tag = 0
        
        if sender.tag == 0{
            tag = 1
        }
        
        product = products[tag]
        
        let Subscription_type = product!.productIdentifier
        
        //get Expiration date
        if Subscription_type == "com.lifestyle.classpath.sevendays" {
            Expiration_Date = Date(timeInterval: 60 * 60 * 24 * 7 , since: Date())
        }else if Subscription_type == "com.lifestyle.classpath.2weeks"{
            Expiration_Date = Date(timeInterval: 60 * 60 * 24 * 14, since: Date())
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy HH:mm:ss"
        let Expire_Date = formatter.string(from: Expiration_Date)
        self.parameter.setValue(Expire_Date, forKey: "Expiration_Date")
        defaults.set(Expire_Date, forKey: "Expiration")
        list_id = defaults.value(forKey: "listingID") as! String
        defaults.set(self.parameter, forKey: "listvalue")
        SubscribedProduct.store.buyProduct(product!)
    }
}
