//
//  TutorialPopUp.swift
//  Classpath
//
//  Created by Coldfin on 12/10/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit

class TutorialCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblInfo: UILabel!
}

class TutorialPopUp: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

   @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClick_btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onClick_SkipTutorial(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: CollectionView delegate and datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorialCell", for: indexPath) as! TutorialCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = Float(scrollView.contentOffset.x / pageWidth)
        
        let page = Int(currentPage)
        pageControl.currentPage = page
    }
}
