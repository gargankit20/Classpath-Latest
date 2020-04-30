//
//  KeyboardPicker.Swift
//
//  Created by Bhavesh Patel on 15/04/2016.
//

import UIKit
class KeyboardPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    var Values : [String]!
    var Font : UIFont!
    var RowSelected: Int = 0 {
        didSet {
            print(RowSelected)
            selectRow(RowSelected-1, inComponent: 0, animated: false)
            let Val = Values[self.selectedRow(inComponent: 0)]
            if let block = onDateSelected {
                block(Val)
            }
        }
    }
    var onDateSelected: ((_ Value: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        RowSelected = 0
        self.backgroundColor = UIColor.white

        self.delegate = self
        self.dataSource = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Values[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Values.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if Values.count > 0
        {
            let Val = Values[self.selectedRow(inComponent: 0)]
            RowSelected = self.selectedRow(inComponent: 0)+1
            if let block = onDateSelected {
                block(Val)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = Font
            pickerLabel?.textAlignment = .center
            pickerLabel?.numberOfLines = 0
        }
        pickerLabel?.text = Values[row]
        pickerLabel?.textColor = themeColor
        return pickerLabel!
    }
       

    
    deinit
    {
        
    }
}

