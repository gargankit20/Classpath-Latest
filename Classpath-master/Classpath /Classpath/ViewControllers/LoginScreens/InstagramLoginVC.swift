//
//  InstagramLoginVC.swift
//  InstagramLogin-Swift
//

protocol InstaLogindelegate {
    func doneLogin(token : String)
}

import UIKit
import WebKit

class InstagramLoginVC: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var loginView: UIView!
    var loginWebView:WKWebView!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    var delegate : InstaLogindelegate!
    var token = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginWebView=WKWebView(frame:CGRect(x:0, y:0, width:loginView.frame.size.width, height:loginView.frame.size.height))
        loginView.addSubview(loginWebView)
        loginWebView.navigationDelegate=self
        unSignedRequest()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "SFProText-SemiBold", size: 20)!,NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    @IBAction func onClick_btnBack(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - unSignedRequest
    func unSignedRequest () {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_IDS.INSTAGRAM_AUTHURL,INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI, INSTAGRAM_IDS.INSTAGRAM_SCOPE ])
        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!)
        loginWebView.load(urlRequest)
    }

    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI) {
            print(requestURLString)
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
          //  print(requestURLString.substring(from: range.upperBound), String(requestURLString[range.upperBound...]))
            handleAuth(authToken:String(requestURLString[range.upperBound...]))
            return false;
        }
        return true
    }
    
    func handleAuth(authToken: String)  {
        
        self.dismiss(animated: true) {
            self.delegate.doneLogin(token : authToken)
        }
        print("Instagram authentication token ==", authToken)
        token = authToken
    }
    
    func webView(_ webView:WKWebView, decidePolicyFor navigationAction:WKNavigationAction, decisionHandler:(WKNavigationActionPolicy)->Void)
    {
        if navigationAction.request.url!.scheme=="instaplaces"
        {
            _=navigationAction.request.url?.absoluteString
            if token != ""
            {
                let url=URL(string:"httpshttps://instagram.com/accounts/logout")
                
                let logoutRequest=URLRequest(url:url!)
                webView.load(logoutRequest)
            }
        }
        else
        {
            _=checkRequestForCallbackURL(request:navigationAction.request)
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView:WKWebView, didStartProvisionalNavigation navigation:WKNavigation!)
    {
        loginIndicator.isHidden=false
        loginIndicator.startAnimating()
    }
    
    func webView(_ webView:WKWebView, didFinish navigation:WKNavigation!)
    {
        loginIndicator.isHidden=true
        loginIndicator.stopAnimating()
    }
    
    func webView(_ webView:WKWebView, didFail navigation:WKNavigation!, withError error:Error)
    {
        loginIndicator.isHidden=true
        loginIndicator.stopAnimating()
    }
}
