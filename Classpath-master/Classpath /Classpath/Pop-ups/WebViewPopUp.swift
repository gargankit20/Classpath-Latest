//
//  WebViewPopUp.swift
//  Classpath
//
//  Created by Coldfin on 11/6/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import WebKit

class WebViewPopUp: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var viewHieght: NSLayoutConstraint!
    @IBOutlet weak var viewWeb: UIView!
    var webView: WKWebView!
    @IBOutlet weak var lbltitle: UILabel!
    var urlString = ""
    var activityView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenHeight >= 812{
            viewHieght.constant = 88
        }else{
            viewHieght.constant = 64
        }
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight-viewHieght.constant))
        viewWeb.addSubview(webView!)
        activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        
        activityView.startAnimating()
        webView.navigationDelegate=self
        if let url = URL(string: urlString) {
            print(url)
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.interstitial.isReady
        {
            appDelegate.interstitial.present(fromRootViewController:self)
        }
    }
        
    @IBAction func onClick_close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView:WKWebView, didFinish navigation:WKNavigation!)
    {
        lbltitle.text=webView.title
        activityView.stopAnimating()
    }
}
