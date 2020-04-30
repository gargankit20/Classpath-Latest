//
//  RegistrationVC.swift
//  Classpath
//
//  Created by coldfin_lb on 8/4/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpVC: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtPostCode: UITextField!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    //MARK: Action methods
    @IBAction func onClick_SignUp(_ sender: Any) {
        if validateTextfield(){
            if(txtEmail.text?.isValidEmail())!
            {
                if (txtPassword.text!.utf16).count >= 6{
                    let size = CGSize(width: 30, height:30)
                    self.startAnimating(size, message: nil, type: NVActivityIndicatorType(rawValue: 22)!)
                    let parameter = NSMutableDictionary()
                    parameter.setValue(self.txtUserName.text, forKey: keyUsername)
                    parameter.setValue(self.txtMobileNumber.text!, forKey: keyMobileno)
                    parameter.setValue(self.txtEmail.text!, forKey: keyEmail)
                    parameter.setValue(self.txtAddress.text!, forKey: keyAddress)
                    parameter.setValue(false, forKey: keyTerms)
                    
                    let timestamp = NSDate().timeIntervalSince1970
                    let myTimeInterval = TimeInterval(timestamp)
                    let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/yyyy"
                    let JoinDate = formatter.string(from: time as Date)
                    parameter.setValue(JoinDate, forKey: keyJoinDate)
                    if let deviceToken = UserDefaults.standard.value(forKey: keyDeviceToken) as? String
                    {
                        parameter.setValue(deviceToken, forKey: keyDeviceToken)
                    }
                    else{
                        parameter.setValue("", forKey: keyDeviceToken)
                    }
                    
                    
                    Auth.auth().createUser(withEmail: self.txtEmail.text!, password: self.txtPassword.text!, completion: { (user, error) in
                        self.stopAnimating()
                        if error == nil {
                            let userInstance = self.ref.child(nodeUsers).child((user?.user.uid)!)
                            userInstance.setValue(parameter)
                            self.redirectToTerms()
                        }else
                        {
                           // utils.showAlertWithTitle((error?.localizedDescription)!, strTitle: AlertTitle)
                        }
                    })
                }
                else
                {
                    //"Password must be at least 6 characters long."
                }
            }
        }
    }
    
    func redirectToTerms()
    {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "EULAVC") as! EULAVC
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: nil)
    }
    
    @IBAction func onClick_Login(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: Self defined functions
    func validateTextfield() -> Bool {
        if txtUserName.text == "" || txtPassword.text == "" || txtMobileNumber.text == "" || txtEmail.text == "" {
            utils.emptyFieldValidation(txtUserName)
            utils.emptyFieldValidation(txtPassword)
            utils.emptyFieldValidation(txtMobileNumber)
            utils.emptyFieldValidation(txtEmail)
            return false
        }
        return true
    }
    
    //MARK: Statusbar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
