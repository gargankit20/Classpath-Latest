//
//  AutoCompleteTextField.swift
//  AutocompleteTextfieldSwift
//
//  Created by Mylene Bayan on 6/13/15.
//  Copyright (c) 2015 mnbayan. All rights reserved.
//

import Foundation
import UIKit

open class AutoCompleteTextField:UITextField {
    /// Manages the instance of tableview
    fileprivate var autoCompleteTableView:UITableView?
    /// Holds the collection of attributed strings
    fileprivate lazy var attributedAutoCompleteStrings = [NSAttributedString]()
    fileprivate lazy var attributedAutoCompleteIDs = [NSAttributedString]()
    /// Handles user selection action on autocomplete table view
    open var onSelect:(String, IndexPath)->() = {_,_ in}
    /// Handles textfield's textchanged
    open var onTextChange:(String)->() = {_ in}
    
    /// Font for the text suggestions
    open var autoCompleteTextFont = UIFont.systemFont(ofSize: 12)
    /// Color of the text suggestions
    open var autoCompleteTextColor = UIColor.white
    /// Used to set the height of cell for each suggestions
    open var autoCompleteCellHeight:CGFloat = 35.0
    /// The maximum visible suggestion
    open var maximumAutoCompleteCount = 3
    /// Used to set your own preferred separator inset
    open var autoCompleteSeparatorInset = UIEdgeInsets.zero
    /// Shows autocomplete text with formatting
    open var enableAttributedText = false
    /// User Defined Attributes
    open var autoCompleteAttributes:[NSAttributedString.Key : Any]?
    /// Hides autocomplete tableview after selecting a suggestion
    open var hidesWhenSelected = true
    /// Hides autocomplete tableview when the textfield is empty
    open var hidesWhenEmpty:Bool?{
        didSet{
            assert(hidesWhenEmpty != nil, "hideWhenEmpty cannot be set to nil")
            autoCompleteTableView?.isHidden = hidesWhenEmpty!
        }
    }
    /// The table view height
    open var autoCompleteTableHeight:CGFloat?{
        didSet{
            redrawTable()
        }
    }
    /// The strings to be shown on as suggestions, setting the value of this automatically reload the tableview
    open var autoCompleteStrings:[String]?{
        didSet{ reload() }
    }
    open var autoCompleteIDs:[String]?{
        didSet{ reloadIDs() }
    }
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setup()
        //(superview!)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        setupAutocompleteTable(superview!)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        commonInit()
        if newSuperview != nil {
            setupAutocompleteTable(newSuperview!)
        }
        
    }

    fileprivate func commonInit(){
        hidesWhenEmpty = true
        autoCompleteAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        autoCompleteAttributes![NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
        self.clearButtonMode = .always
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidEndEditing), for: .editingDidEnd)
    }


    fileprivate func setupAutocompleteTable(_ view:UIView){
        //let screenSize = UIScreen.mainScreen().bounds.size
        let tableView = UITableView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y - self.frame.height - 40, width: self.frame.width, height: 30.0))

        tableView.backgroundColor = UIColor(red: 115/255.0, green: 115/255.0, blue: 115/255.0, alpha: 1.0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = autoCompleteCellHeight
        tableView.isHidden = hidesWhenEmpty ?? true
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        view.addSubview(tableView)
        autoCompleteTableView = tableView
        
        autoCompleteTableHeight = 70.0
    }
    
    fileprivate func redrawTable(){
        if let autoCompleteTableView = autoCompleteTableView, let autoCompleteTableHeight = autoCompleteTableHeight {
            var newFrame = autoCompleteTableView.frame
            newFrame.size.width = self.frame.width
            newFrame.size.height = autoCompleteTableHeight
            autoCompleteTableView.frame = newFrame
        }
    }
    
    //MARK: - Private Methods
    fileprivate func reloadIDs(){
        if enableAttributedText{
            let attrs = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12.0)] as [NSAttributedString.Key : Any]

            if attributedAutoCompleteIDs.count > 0 {
                attributedAutoCompleteIDs.removeAll(keepingCapacity: false)
            }
            
            if let autoCompleteStrings = autoCompleteIDs, let autoCompleteAttributes = autoCompleteAttributes {
                for i in 0..<autoCompleteStrings.count{
                    let str = autoCompleteStrings[i] as NSString
                    let range = str.range(of: text!, options: .caseInsensitive)
                    let attString = NSMutableAttributedString(string: autoCompleteStrings[i], attributes: attrs)
                    attString.addAttributes(autoCompleteAttributes, range: range)
                    attributedAutoCompleteIDs.append(attString)
                }
            }
        }
    }
    
    
    fileprivate func reload(){
        if enableAttributedText{
            let attrs = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12.0)] as [NSAttributedString.Key : Any]
    
            if attributedAutoCompleteStrings.count > 0 {
                attributedAutoCompleteStrings.removeAll(keepingCapacity: false)
            }
            
            if let autoCompleteStrings = autoCompleteStrings, let autoCompleteAttributes = autoCompleteAttributes {
                for i in 0..<autoCompleteStrings.count{
                    let str = autoCompleteStrings[i] as NSString
                    let range = str.range(of: text!, options: .caseInsensitive)
                    let attString = NSMutableAttributedString(string: autoCompleteStrings[i], attributes: attrs)
                    attString.addAttributes(autoCompleteAttributes, range: range)
                    attributedAutoCompleteStrings.append(attString)
                }
            }
        }
        autoCompleteTableView?.reloadData()
    }
    
    @objc func textFieldDidChange(){
        guard let _ = text else {
            return
        }
        
        onTextChange(text!)
        if text!.isEmpty{ autoCompleteStrings = nil }
        DispatchQueue.main.async(execute: { () -> Void in
            self.autoCompleteTableView?.isHidden =  self.hidesWhenEmpty! ? self.text!.isEmpty : false
        })
    }
    
    @objc func textFieldDidEndEditing() {
        autoCompleteTableView?.isHidden = true
    }
    
    
    //Float Textfield
    let animationDuration = 0.3
    var title = UILabel()
    
    // MARK:- Properties
    override open var accessibilityLabel:String! {
        get {
            if text!.isEmpty {
                return title.text
            } else {
                return text
            }
        }
        set {
            self.accessibilityLabel = newValue
        }
    }
    
    override open var placeholder:String? {
        didSet {
           // title.text = placeholder
            title.textColor = UIColor.lightGray
            title.sizeToFit()
        }
    }
    
    override open var attributedPlaceholder:NSAttributedString? {
        didSet {
           // title.text = attributedPlaceholder?.string
            title.textColor = UIColor.lightGray
            title.sizeToFit()
        }
    }
    
    var titleFont:UIFont = UIFont(name: "SFProText-SemiBold",size: 15.0)! {
        didSet {
            title.font = titleFont
            title.sizeToFit()
        }
    }
    
    @IBInspectable var hintYPadding:CGFloat = 0.0
    
    @IBInspectable var titleYPadding:CGFloat = 0.0 {
        didSet {
//            var r = title.frame
//            r.origin.y = titleYPadding
//            title.frame = r
        }
    }
    
    @IBInspectable var titleTextColour:UIColor = UIColor.gray {
        didSet {
            if !isFirstResponder {
                title.textColor = titleTextColour
            }
        }
    }
    
    @IBInspectable var titleActiveTextColour:UIColor! {
        didSet {
            if isFirstResponder {
                title.textColor = titleActiveTextColour
            }
        }
    }

    // MARK:- Overrides
    override open func layoutSubviews() {
        super.layoutSubviews()
       // setTitlePositionForTextAlignment()
        let isResp = isFirstResponder
        if isResp && !text!.isEmpty {
            title.textColor = titleActiveTextColour
        } else {
            title.textColor = titleTextColour
        }
        // Should we show or hide the title label?
        if text!.isEmpty {
            // Hide
            hideTitle(isResp)
        } else {
            // Show
            showTitle(isResp)
        }
    }
    
    override open func textRect(forBounds bounds:CGRect) -> CGRect {
        let r = super.textRect(forBounds: bounds)
        if !text!.isEmpty {
//            var top = ceil(title.font.lineHeight + hintYPadding)
//            top = min(top, maxTopInset())
//            r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(top, 0.0, 0.0, 0.0))
        }
        return r.integral
    }
    
    override open func editingRect(forBounds bounds:CGRect) -> CGRect {
        let r = super.editingRect(forBounds: bounds)
        if !text!.isEmpty {
//            var top = ceil(title.font.lineHeight + hintYPadding)
//            top = min(top, maxTopInset())
//            r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(top, 0.0, 0.0, 0.0))
        }
        return r.integral
    }
    
    override open func clearButtonRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.clearButtonRect(forBounds: bounds)
        if !text!.isEmpty {
            var top = ceil(title.font.lineHeight + hintYPadding)
            top = min(top, maxTopInset())
            r = CGRect(x:r.origin.x, y:r.origin.y /*+ (top * 0.5)*/, width:r.size.width, height:r.size.height)
        }
        return r.integral
    }
    
    // MARK:- Public Methods

    // MARK:- Private Methods
    fileprivate func setup() {
        borderStyle = UITextField.BorderStyle.none
        titleActiveTextColour = tintColor
        //Set up title label
        title.alpha = 0.0
        title.font = titleFont
        title.textColor = titleTextColour
        if let str = placeholder {
            if !str.isEmpty {
               // title.text = str
                title.sizeToFit()
            }
        }
        self.addSubview(title)
    }
    
    
    fileprivate func maxTopInset()->CGFloat {
        return max(0, floor(bounds.size.height - font!.lineHeight - 4.0))
    }
    
    fileprivate func setTitlePositionForTextAlignment() {
        let r = textRect(forBounds: bounds)
        var x = r.origin.x
        if textAlignment == NSTextAlignment.center {
            x = r.origin.x + (r.size.width * 0.5) - title.frame.size.width
        } else if textAlignment == NSTextAlignment.right {
            x = r.origin.x + r.size.width - title.frame.size.width
        }
        title.frame = CGRect(x:x, y:title.frame.origin.y, width:title.frame.size.width, height:title.frame.size.height)
    }
    
    fileprivate func showTitle(_ animated:Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [.beginFromCurrentState,.curveEaseOut], animations:{
            // Animation
            self.title.alpha = 1.0
            var r = self.title.frame
            r.origin.y = self.titleYPadding
            self.title.frame = r
            }, completion:nil)
    }
    
    fileprivate func hideTitle(_ animated:Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [.beginFromCurrentState,.curveEaseIn], animations:{
            // Animation
            self.title.alpha = 0.0
            var r = self.title.frame
            r.origin.y = self.title.font.lineHeight + self.hintYPadding
            self.title.frame = r
            }, completion:nil)
    }
}

//MARK: - UITableViewDataSource - UITableViewDelegate
extension AutoCompleteTextField: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var newFrame = tableView.frame
        newFrame.size.width = self.frame.width
        newFrame.size.height = autoCompleteTableHeight!
        tableView.frame = newFrame
        return autoCompleteStrings != nil ? (autoCompleteStrings!.count > maximumAutoCompleteCount ? maximumAutoCompleteCount : autoCompleteStrings!.count) : 0
    }


    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "autocompleteCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        tableView.backgroundColor = UIColor(red: 115/255.0, green: 115/255.0, blue: 115/255.0, alpha: 1.0)
        cell?.backgroundColor = UIColor.clear
        
        if enableAttributedText{
            cell?.textLabel?.attributedText = attributedAutoCompleteStrings[(indexPath as NSIndexPath).row]
        }
        else{
            cell?.textLabel?.font = autoCompleteTextFont
            cell?.textLabel?.textColor = autoCompleteTextColor
            cell?.textLabel?.text = autoCompleteStrings![(indexPath as NSIndexPath).row]
        }

        cell?.contentView.gestureRecognizers = nil
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let selectedText = cell?.textLabel?.text {
            self.text = selectedText
            //onSelect(autoCompleteIDs![indexPath.row], indexPath))
            onSelect(autoCompleteIDs![(indexPath as NSIndexPath).row], indexPath)
        }
        DispatchQueue.main.async(execute: { () -> Void in
            tableView.isHidden = self.hidesWhenSelected
        })
    }
    

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = autoCompleteSeparatorInset
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = autoCompleteSeparatorInset
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return autoCompleteCellHeight
    }
}
