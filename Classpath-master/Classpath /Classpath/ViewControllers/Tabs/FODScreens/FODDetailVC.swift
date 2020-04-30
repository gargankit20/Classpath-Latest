//
//  FODDetailVC.swift
//  Classpath
//
//  Created by coldfin on 07/01/19.
//  Copyright © 2019 coldfin_lb. All rights reserved.
//

import UIKit

class FODDetailTableViewCell:UITableViewCell {
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var imageTbl: UIImageView!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblDayType: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBg.layer.shadowOpacity = 0.8
        viewBg.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewBg.layer.shadowRadius = 4.0
        viewBg.layer.shadowColor = UIColor(red:0.48, green:0.53, blue:0.57, alpha:0.2).cgColor
    }
}

class FODDetailCollectionViewCell:UICollectionViewCell {
    
    @IBOutlet weak var imageColl: UIImageView!
}

class FODDetailVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var constTableHeight: NSLayoutConstraint!
    @IBOutlet weak var lblWeeks: UILabel!
    @IBOutlet weak var lblVideos: UILabel!
    @IBOutlet weak var lblLoca: UILabel!
    @IBOutlet weak var lblSuitedFor: UILabel!
    @IBOutlet weak var lblDisclaimer: UILabel!
    @IBOutlet weak var lblDeitType: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblProgramName: UILabel!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var btnPurchase: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        tblView.rowHeight = 115
        tblView.tableFooterView = UIView()
        
    }
    
    @IBAction func onClickBtnPurchase(_ sender: Any) {
        
    }
    
    //MARK: TableView Delegate and Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateViewConstraint()
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! FODDetailTableViewCell

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "PlanDetailVC") as! PlanDetailVC
        self.navigationController?.pushViewController(nextPage, animated: true)
    }
    
    func updateViewConstraint(){
        constTableHeight.constant = CGFloat(10*115) // multiple tableview row count
    }
    
    //MARK: CollectionView Delegate and Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FODImageCell", for: indexPath) as! FODDetailCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let width: CGFloat = scrollView.frame.size.width
            let page = Int((scrollView.contentOffset.x + (0.5 * width)) / width)
            self.pageControl.currentPage = page
        }
    }
}
