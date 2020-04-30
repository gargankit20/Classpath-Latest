//
//  FilterVC.swift
//  ClassPath
//
//  Created by coldfin_lb on 4/11/18.
//  Copyright © 2018 Coldfin. All rights reserved.
//

import UIKit

class filterTableViewCell: UITableViewCell {
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var subTitle:UILabel!
    @IBOutlet weak var imgDone:UIImageView!
    override func awakeFromNib() {
        self.dropShadow(label: lblTitle)
        self.dropShadow(label: subTitle)
    }
    
    func dropShadow(label:UILabel){
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
    }
}

protocol  filterDelegate{
    func filterCategory(category:String, arrCategories:NSMutableArray)
}

class FilterVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var delegate:filterDelegate!
    var mainArray:NSMutableArray = NSMutableArray()
    var noOfListing = NSMutableDictionary()
    @IBOutlet weak var tblView:UITableView!
    var arrSelect:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainArray = (arrfilterCategory as NSArray).mutableCopy() as! NSMutableArray
        mainArray.removeObject(at: arrfilterCategory.count-1)
        for _ in mainArray{
            arrSelect.add(true)
        }
    }
    
    @IBAction func onClick_btnApply(_ sender: Any) {
        let arr:NSMutableArray = NSMutableArray()
        
        for i in 0...mainArray.count-1{
            var arrData = [String:UIImage]()
            arrData = mainArray.object(at: i) as! [String:UIImage]
            let ishide:Bool = arrSelect.object(at: i) as! Bool
            if !ishide{
                arr.add((arrData as NSDictionary).allKeys[0] as! NSString as String)
            }
        }
        delegate.filterCategory(category: "Promoted Listings", arrCategories:arr)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView Delegate & DatasSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:filterTableViewCell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! filterTableViewCell
        var arr = [String:UIImage]()
        arr = mainArray.object(at: indexPath.row) as! [String:UIImage]
        cell.lblTitle.text = (arr as NSDictionary).allKeys[0] as! NSString as String
        cell.imgView.image = (arr as NSDictionary).value(forKey: ((arr as NSDictionary).allKeys[0] as! NSString) as String) as? UIImage
        if let c = self.noOfListing.value(forKey: "\((arr as NSDictionary).allKeys[0] as! NSString)") as? Int
        {
            cell.subTitle.text = "\(c)" + " Listings"
        }else{
            cell.subTitle.text = "0 Listing"
        }
        let ishide:Bool = arrSelect.object(at: indexPath.row) as! Bool
        
        cell.imgDone.isHidden = ishide
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:filterTableViewCell  = tblView.cellForRow(at: indexPath) as! filterTableViewCell
        if cell.subTitle.text != "0 Listings" && cell.imgDone.isHidden == true {
            cell.imgDone.isHidden = false
            arrSelect.replaceObject(at: indexPath.row, with: false)
        }else{
            cell.imgDone.isHidden = true
            arrSelect.replaceObject(at: indexPath.row, with: true)
        }
        
    }
}

