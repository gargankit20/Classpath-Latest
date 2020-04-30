//
//  FODVC.swift
//  Classpath
//
//  Created by Coldfin on 12/10/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit

class FODTableVewCell:UITableViewCell {
    
    @IBOutlet weak var lblRegisterUser: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var lblPlanCost: UILabel!
    @IBOutlet weak var lblPlanName: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var viewRatings: HCSStarRatingView!
}

class FODVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UISearchBarDelegate {

    @IBOutlet weak var viewDefault: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    var isClosed = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.tableFooterView = UIView()
        tblView.rowHeight = 180
        
        searchBar.delegate = self
        
        //Dismiss keyboard
        let tapTerm : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        tapTerm.delegate = self
        tapTerm.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTerm)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isClosed {
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showTutorialView), userInfo: nil, repeats: false)
            isClosed = false
        }
    }
    
    @objc func showTutorialView() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "TutorialPopUp") as! TutorialPopUp
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: nil)
    }
    
    @objc func tapView(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    //MARK: SearchBar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    //MARK: TableView Delegate and Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FODCell", for: indexPath) as! FODTableVewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "FODDetailVC") as! FODDetailVC
        self.navigationController?.pushViewController(nextPage, animated: true)
    }
}
