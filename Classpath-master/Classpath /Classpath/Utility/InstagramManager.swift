//
//  InstagramManager.swift
//  ClassPath
//
//  Created by Coldfin on 08/06/18.
//  Copyright © 2018 Coldfin. All rights reserved.
//

import UIKit
import Foundation

class InstagramManager: NSObject, UIDocumentInteractionControllerDelegate {
    
    private let kInstagramURL = "instagram://app"
    private let kUTI = "com.instagram.exclusivegram"
    private let kfileNameExtension = "instagram.igo"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Instagram application"
    
    var documentInteractionController = UIDocumentInteractionController()
    
    // singleton manager
    class var sharedManager: InstagramManager {
        struct Singleton {
            static let instance = InstagramManager()
        }
        return Singleton.instance
    }
    
    func postImageToInstagramWithCaption(imageInstagram: UIImage, instagramCaption: String, view: UIViewController) {
        // called to post image with caption to the instagram application
        
        let instagramURL = NSURL(string: kInstagramURL)
        
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {
            
            let jpgPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(kfileNameExtension)
            
            do {
                try imageInstagram.jpegData(compressionQuality: 1.0)?.write(to: URL(fileURLWithPath: jpgPath), options: .atomic)
                
            } catch {
                
                print(error)
            }
            
            let rect = CGRect(x: 0, y: 0, width: 612, height: 612)
            let fileURL = NSURL.fileURL(withPath: jpgPath)
            documentInteractionController.url = fileURL
            documentInteractionController.delegate = self
            documentInteractionController.uti = kUTI
            
            // adding caption for the image
            documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
            documentInteractionController.presentOpenInMenu(from: rect, in: view.view, animated: true)
        } else {
            
            let alert = UIAlertController(title: "", message: kAlertViewMessage, preferredStyle: UIAlertController.Style.alert)
            view.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                alert.dismiss(animated: true, completion: {() -> Void in
                })
            })
        }
    }
}
