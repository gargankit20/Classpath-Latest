//
//  ShareOptionsVC.swift
//  ClassPath
//
//  Created by coldfin_lb on 6/6/18.
//  Copyright © 2018 Coldfin. All rights reserved.
//

import UIKit
import TwitterKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import MessageUI


class ShareOptionsVC: UIViewController,TWTRComposerViewControllerDelegate,FBSDKSharingDelegate,NVActivityIndicatorViewable,MFMessageComposeViewControllerDelegate {
    
    
    @IBOutlet weak var leadingFb: NSLayoutConstraint!
    @IBOutlet weak var bottomFb: NSLayoutConstraint!
    
    @IBOutlet weak var trailingInsta: NSLayoutConstraint!
    @IBOutlet weak var bottomInsta: NSLayoutConstraint!
    
    @IBOutlet weak var topTwitter: NSLayoutConstraint!
    @IBOutlet weak var leadingTwitter: NSLayoutConstraint!
    
    @IBOutlet weak var topTextMsg: NSLayoutConstraint!
    @IBOutlet weak var trailingTextMsg: NSLayoutConstraint!
    
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnTextMessage: UIButton!
    
    var image:UIImage!
    var caption = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(animateButton), userInfo: nil, repeats: false)
        
    }

    @objc func animateButton(){
        
        self.topTwitter.constant = 5
        self.trailingTextMsg.constant = 5
        self.topTextMsg.constant = 5
        self.leadingFb.constant = 5
        self.bottomFb.constant = 5
        self.trailingInsta.constant = 5
        self.bottomInsta.constant = 5
        self.leadingTwitter.constant = 5
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            self.btnFacebook.alpha = 0.5
            self.btnInstagram.alpha = 0.5
            self.btnTwitter.alpha = 0.5
            self.btnTextMessage.alpha = 0.5
            
            self.btnFacebook.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.btnInstagram.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.btnTwitter.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.btnTextMessage.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
        }, completion: {(finished: Bool) in
            UIView.animate(withDuration: 0.5, animations: {
                self.btnFacebook.alpha = 1
                self.btnInstagram.alpha = 1
                self.btnTwitter.alpha = 1
                self.btnTextMessage.alpha = 1
                
                self.btnFacebook.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.btnInstagram.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.btnTwitter.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.btnTextMessage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        })
    }
    
    @IBAction func onClick_Close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onClick_btnShareAction(_ sender: UIButton) {
      
        if sender.tag == 1{
            instaShare()
        }else if sender.tag == 3 {
            twitterShare()
        }else{
            fbShare()
        }
    }
    
    func instaShare() {
        InstagramManager.sharedManager.postImageToInstagramWithCaption(imageInstagram: image, instagramCaption: caption, view: self)
    }
    
    func twitterShare() {
        if (TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
            
            let composer = TWTRComposerViewController(initialText: caption, image: image, videoURL:nil)
            composer.delegate = self
            present(composer, animated: true, completion: nil)
        } else{
            TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                if (session != nil) {
                    print("signed in as \(String(describing: session?.userName))");
                } else {
                    print("error: \(String(describing: error?.localizedDescription))");
                }
            })
        }
        
    }
    
    
    
    func fbShare() {
           //  
          //  self.startAnimating(size, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
//            let login: FBSDKLoginManager = FBSDKLoginManager()
//            login.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
//                if (error != nil) {
//                    print(error!)
//                    self.stopAnimating()
//                } else if (result?.isCancelled)! {
//                    self.stopAnimating()
//                    print("Canceled")
//                } else if (result?.grantedPermissions.contains("publish_actions"))! {

                    
                    let photoToShare = FBSDKSharePhoto()
                    photoToShare.isUserGenerated = true
                    photoToShare.caption = self.caption
                    photoToShare.image = self.image
                    
                    let content = FBSDKSharePhotoContent()
                    content.photos = [photoToShare]
                    
                    let dialog = FBSDKShareDialog()
                    dialog.fromViewController = self
                    dialog.shareContent = content
                    dialog.mode = .automatic
                    dialog.show()
                    
                    
//                    let content  = FBSDKSharePhotoContent()
//                    content.photos = [photoToShare]
//                    FBSDKShareAPI.share(with: content, delegate: self)
 //               }
//            }
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        self.stopAnimating()
        let alert = UIAlertController(title: "", message: "Your appointment is successfully posted!", preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            alert.dismiss(animated: true, completion: {() -> Void in
            })
        })
    }
    
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        self.stopAnimating()
        let alert = UIAlertController(title: "", message: "Something went wrong you cannot share this appointment right now!", preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            alert.dismiss(animated: true, completion: {() -> Void in
            })
        })
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
    }

    
    func composerDidCancel(_ controller: TWTRComposerViewController) {
        
    }
    
    func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
        self.stopAnimating()
        let alert = UIAlertController(title: "", message: "Something went wrong you cannot share this appointment right now!", preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            alert.dismiss(animated: true, completion: {() -> Void in
            })
        })
    }
    
    func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
        self.stopAnimating()
        let alert = UIAlertController(title: "", message: "Your appointment is successfully twitted!", preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            alert.dismiss(animated: true, completion: {() -> Void in
            })
        })
    }
    
    @IBAction func onClick_SendSms(_ sender: Any) {
        
//        if MFMessageComposeViewController.canSendText() && MFMessageComposeViewController.canSendAttachments() && MFMessageComposeViewController.isSupportedAttachmentUTI(kUTTypePNG as String) {
//            let vc = MFMessageComposeViewController()
//            vc.messageComposeDelegate = self
//            vc.recipients = ["8733985641"]
//            let myImage = self.image
//            let attached: Bool = vc.addAttachmentData(UIImagePNGRepresentation(myImage!)!, typeIdentifier: kUTTypePNG as String, filename: "image.png")
//            if attached {
//                print("Attached (:")
//            } else {
//                print("Not attached ):")
//            }
//            present(vc, animated: true)
//        }
        
        
        // Make sure the device can send text messages
        if (self.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = self.configuredMessageComposeViewController()
            // Present the configured MFMessageComposeViewController instance
            self.present(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let custAlert = customAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", btnTitle: "OK")
            custAlert.show(animated: true)
    
        }
    }
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = []
        messageComposeVC.body =  self.caption
        
        let myImage = self.image
        let attached: Bool = messageComposeVC.addAttachmentData(myImage!.pngData()!, typeIdentifier: kUTTypePNG as String, filename: "image.png")
        if attached {
            print("Attached (:")
        } else {
            print("Not attached ):")
        }
        
        return messageComposeVC
        
//        let vc = MFMessageComposeViewController()
//        vc.messageComposeDelegate = self
//        vc.recipients = ["8733985641"]
//        vc.body = self.caption
//        let myImage = self.image
//
//        let attached: Bool = vc.addAttachmentData(UIImagePNGRepresentation(myImage!)!, typeIdentifier: kUTTypePNG as String, filename: "image.png")
//        if attached {
//            print("Attached (:")
//        } else {
//            print("Not attached ):")
//        }
//        return vc
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }

}
