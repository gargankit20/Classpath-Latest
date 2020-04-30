//
//  customAlertView.swift
//  ClassPath
//
//  Created by coldfin_lb on 6/22/18.
//  Copyright © 2018 Coldfin. All rights reserved.
//

import UIKit

class customAlertView: UIView, customAlertModal {
    var backgroundView = UIView()
    var leftButton = UIButton()
    var okButton = UIButton()
    var dialogView = UIView()
    var bgButton = UIButton()
    
    var rightButton = UIButton()
    
    var onRightBtnSelected: ((_ Value: String) -> Void)?
    var onLeftBtnSelected: ((_ Value: String) -> Void)?
    var onBtnSelected: ((_ Value: String) -> Void)?
    var onBgBtnSelected: ((_ Value: String) -> Void)?
    
    convenience init(title:String, message:String, customView:UIView, leftBtnTitle:String, rightBtnTitle:String, image:UIImage) {
        self.init(frame: UIScreen.main.bounds)
        
        if leftBtnTitle != "" && rightBtnTitle != ""{
            initializeWithTwoButtons(title: title, message: message, customView:customView, leftBtnTitle:leftBtnTitle, rightBtnTitle:rightBtnTitle)
        }
    }
    convenience init(title:String, message:String, btnTitle:String) {
        self.init(frame: UIScreen.main.bounds)
        
       
        initializeWithOneButtons(title: title, message: message, buttonTitle:btnTitle )
    
        
    }
    convenience init(title:String, message:String, image:UIImage) {
        self.init(frame: UIScreen.main.bounds)
        initializeWithNoButtons(title: title, message: message, image:image)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initializeWithTwoButtons(title:String, message:String, customView:UIView, leftBtnTitle:String, rightBtnTitle:String){
        dialogView.clipsToBounds = true
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        addSubview(backgroundView)
        
        bgButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        bgButton.addTarget(self, action: #selector(onClick_bgButton(_:)), for: .touchUpInside)
        addSubview(bgButton)
        
        let dialogViewWidth:CGFloat = 310
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: dialogViewWidth, height: 40))
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.textColor = themeColor
        titleLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20)
        titleLabel.textAlignment = .center
        dialogView.addSubview(titleLabel)
        var titleHeight:CGFloat = (titleLabel.text?.heightWithConstrainedWidth(width: dialogViewWidth-40, font: titleLabel.font))!
        titleLabel.frame = CGRect(x: 20, y: 20, width: dialogViewWidth-40, height: titleHeight)
        titleHeight += 20
        if title == "" {
            titleHeight = 0
        }
        
        let messageLabel = UILabel(frame: CGRect(x: 30, y: titleHeight+20, width: dialogViewWidth-60, height: 30))
        messageLabel.text = message
        messageLabel.textColor = textThemeColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "SFProDisplay-Regular", size: 17)
        dialogView.addSubview(messageLabel)
        
        var messageHeight:CGFloat = (messageLabel.text?.heightWithConstrainedWidth(width: dialogViewWidth-60, font: messageLabel.font))!
        messageLabel.frame = CGRect(x: 20, y: titleHeight+10, width: dialogViewWidth-40, height: messageHeight)
        
        messageHeight += 20
        
        let custView = UIView(frame: CGRect(x: 0, y: titleHeight+messageHeight, width: dialogViewWidth, height: customView.frame.height+5))
        custView.addSubview(customView)
        dialogView.addSubview(custView)
        
        let dialogViewHeight = titleHeight + messageHeight + 55 + customView.frame.height+10
        
        leftButton = UIButton(frame: CGRect(x: 13, y: dialogViewHeight-55, width: dialogViewWidth/2-15, height: 44))
        leftButton.setTitle(leftBtnTitle, for: .normal)
        leftButton.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 17)!
        leftButton.setTitleColor(themeColor, for: .normal)
        leftButton.addTarget(self, action: #selector(onClick_leftButton(_:)), for: .touchUpInside)
        leftButton.layer.cornerRadius = 5
        leftButton.layer.borderWidth = 1
        leftButton.layer.borderColor = UIColor(red:0.32, green:0.71, blue:0.72, alpha:1).cgColor
        leftButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        leftButton.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1).cgColor
        leftButton.layer.shadowOpacity = 1
        leftButton.layer.shadowRadius = 2
        dialogView.addSubview(leftButton)

        rightButton = UIButton(frame: CGRect(x: dialogViewWidth/2+2, y: dialogViewHeight-55, width:  dialogViewWidth/2-15, height: 44))
        rightButton.setTitle(rightBtnTitle, for: .normal)
        rightButton.setTitleColor(UIColor.white, for: .normal)
        rightButton.addTarget(self, action: #selector(onClick_rightButton(_:)), for: .touchUpInside)
        rightButton.layer.cornerRadius = 5
        rightButton.backgroundColor = themeColor
        rightButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        rightButton.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1).cgColor
        rightButton.layer.shadowOpacity = 1
        rightButton.layer.shadowRadius = 2
        dialogView.addSubview(rightButton)
        
        dialogView.frame.origin = CGPoint(x: frame.width/2 - 150, y: frame.height)
        dialogView.frame.size = CGSize(width: dialogViewWidth, height: dialogViewHeight)
        dialogView.alpha = 0.95
        dialogView.layer.cornerRadius = 10
        dialogView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.95)
        dialogView.layer.shadowOffset = CGSize(width: 0, height: 2)
        dialogView.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        dialogView.layer.shadowOpacity = 1
        dialogView.layer.shadowRadius = 4
        dialogView.bringSubviewToFront(custView)
        addSubview(dialogView)
        
    }
    
    func initializeWithOneButtons(title:String, message:String, buttonTitle:String){
        dialogView.clipsToBounds = true
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        addSubview(backgroundView)
        
        let dialogViewWidth:CGFloat = 310
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: dialogViewWidth, height: 40))
        titleLabel.text = title
        titleLabel.textColor = themeColor
        titleLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20)
        titleLabel.textAlignment = .center
        dialogView.addSubview(titleLabel)
        
        var titleHeight = 60
        if title == "" {
            titleHeight = 20
        }
        
        let messageLabel = UILabel(frame: CGRect(x: 20, y: titleHeight, width: Int(dialogViewWidth-40), height: 30))
        messageLabel.text = message
        messageLabel.textColor = textThemeColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        dialogView.addSubview(messageLabel)
        
        let messageHeight:CGFloat = (messageLabel.text?.heightWithConstrainedWidth(width: dialogViewWidth-20, font: messageLabel.font))!
        messageLabel.frame = CGRect(x: 10, y: CGFloat(titleHeight), width: dialogViewWidth-20, height: messageHeight)
        
        let dialogViewHeight = titleLabel.frame.height + messageHeight + 100
        
        okButton = UIButton(frame: CGRect(x: 13, y: dialogViewHeight-65, width: dialogViewWidth-26, height: 44))
        okButton.setTitle(buttonTitle, for: .normal)
        okButton.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 17)!
        okButton.setTitleColor(UIColor.white, for: .normal)
        okButton.addTarget(self, action: #selector(onClick_Button(_:)), for: .touchUpInside)
        okButton.backgroundColor = themeColor
        okButton.layer.cornerRadius = 5
        okButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        okButton.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1).cgColor
        okButton.layer.shadowOpacity = 1
        okButton.layer.shadowRadius = 2
        dialogView.addSubview(okButton)
    
        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
        dialogView.frame.size = CGSize(width: dialogViewWidth, height: dialogViewHeight)
        dialogView.alpha = 0.95
        dialogView.layer.cornerRadius = 10
        dialogView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.95)
        dialogView.layer.shadowOffset = CGSize(width: 0, height: 2)
        dialogView.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        dialogView.layer.shadowOpacity = 1
        dialogView.layer.shadowRadius = 4
        addSubview(dialogView)
        
    }
    
    func initializeWithNoButtons(title:String, message:String, image:UIImage){
        dialogView.clipsToBounds = true
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        addSubview(backgroundView)
        
        let dialogViewWidth:CGFloat = 310
        var headerHeight:CGFloat = 0.0
        if title == ""{
            let imageHolder = UIImageView(frame: CGRect(x: dialogViewWidth/2-37.5, y: 20, width: 75, height: 75))
            imageHolder.image = image
            dialogView.addSubview(imageHolder)
            headerHeight = 75
            
            
        }else {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: dialogViewWidth, height: 40))
            titleLabel.text = title
            titleLabel.numberOfLines = 0
            titleLabel.textColor = themeColor
            titleLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20)
            titleLabel.textAlignment = .center
            dialogView.addSubview(titleLabel)
            headerHeight = 40
        }
        
        let btnClose = UIButton(frame: CGRect(x: dialogViewWidth-47, y: 15, width: 30, height: 30))
        btnClose.setTitle("X", for: .normal)
        btnClose.addTarget(self, action: #selector(onClick_Button(_:)), for: .touchUpInside)
        btnClose.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 15)
        btnClose.setTitleColor(textThemeColor, for: .normal)
        dialogView.addSubview(btnClose)
        
        let messageLabel = UILabel(frame: CGRect(x: 30, y: headerHeight+35, width: dialogViewWidth-60, height: 30))
        messageLabel.text = message
        messageLabel.textColor = textThemeColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        dialogView.addSubview(messageLabel)
        
        let messageHeight:CGFloat = (messageLabel.text?.heightWithConstrainedWidth(width: dialogViewWidth-20, font: messageLabel.font))!
        messageLabel.frame = CGRect(x: 20, y: headerHeight+35, width: dialogViewWidth-40, height: messageHeight)
        
        let dialogViewHeight = headerHeight + messageHeight + 75
        
        dialogView.frame.origin = CGPoint(x: 25, y: frame.height)
        dialogView.frame.size = CGSize(width: dialogViewWidth, height: dialogViewHeight)
        dialogView.alpha = 0.95
        dialogView.layer.cornerRadius = 10
        dialogView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.95)
        dialogView.layer.shadowOffset = CGSize(width: 0, height: 2)
        dialogView.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        dialogView.layer.shadowOpacity = 1
        dialogView.layer.shadowRadius = 4
        addSubview(dialogView)
        
    }
    @objc func onClick_bgButton(_ sender:UIButton) {
        if let block = onBgBtnSelected {
            block("hi")
            dismiss(animated: true)
        }
        
    }
    
    @objc func onClick_leftButton(_ sender:UIButton) {
        if let block = onLeftBtnSelected {
            block("hi")
        }
        dismiss(animated: true)
    }
    
    @objc func onClick_rightButton(_ sender:UIButton) {
        if let block = onRightBtnSelected {
            block("hi")
        }
    }
    @objc func onClick_Button(_ sender:UIButton) {
        if let block = onBtnSelected {
            block("hi")
        }
        dismiss(animated: true)
    }
    
}
extension String {
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
}
