//
//  EULAVC.swift
//  HIITList
//
//  Created by Ved on 23/11/17.
//  Copyright © 2017 Coldfin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class EULAVC: UIViewController {
    @IBOutlet weak var viewPopUp: UIView!
    @IBOutlet weak var lblPrivacyTerm: UILabel!
    //@IBOutlet weak var lblMessage: TTTAttributedLabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnIAgree: UIButton!
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        setDesign()
        setData()
        // Do any additional setup after loading the view.
    }

    func setDesign()  {
        viewPopUp.layer.cornerRadius = 8
        viewPopUp.clipsToBounds = true
        
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = themeColor.cgColor
    }

    func setData()
    {
        ref = Database.database().reference()

        //lblPrivacyTerm.text = "By creating an account,you agree to the Classpath Terms of Use"
        let text = (lblPrivacyTerm.text)!
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms of Use")
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue,range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range1)
        lblPrivacyTerm.attributedText = underlineAttriString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
        lblPrivacyTerm.isUserInteractionEnabled = true
        lblPrivacyTerm.addGestureRecognizer(tapAction)
       
    }

    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (lblPrivacyTerm.text)!
        let termsRange = (text as NSString).range(of: "Terms of Use")
       // let privacyRange = (text as NSString).range(of: "Privacy policy")
        
        if gesture.didTapAttributedTextInLabel(label: lblPrivacyTerm, inRange: termsRange) {
            let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "Terms_ConditionVC") as! Terms_ConditionVC
            modalViewController.modalPresentationStyle = .overCurrentContext
            self.present(modalViewController, animated: true, completion: nil)
        }else {
            print("Tapped none")
        }
    }


    @IBAction func onClick_btnIAgree(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        self.ref.child(nodeUsers).child(uid).updateChildValues([keyTerms:true])
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "HomeTabbarController")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }

    @IBAction func onClick_btnCancel(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

//extension EULAVC : TTTAttributedLabelDelegate
//{
//    func attributedLabel(_ label: TTTAttributedLabel, didSelectLinkWith url: URL) {
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
//    }
//}


extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y:
            locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
