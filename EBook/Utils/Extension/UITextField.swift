//
//  UITextField.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/24.
//

import Foundation

private class UITextFieldMaxLengthObserver: NSObject {
    
    @objc func textChange(_ textField: UITextField) {
        if let destText = textField.text, let maxLength = textField.maxLength {
            let textInfo = getTextField(destText, maxLength: maxLength)
            let selectedRange = textField.markedTextRange
            if selectedRange == nil {
                if textInfo.0 > maxLength {
                    textField.text = limitInput(limit: textInfo.1, destText)
                }
            }
        }
    }
    
    //Private Method

    private func limitInput(limit: Int ,_ text: String) -> String {
        var tmp = text
        if tmp.count > limit {
            let index = tmp.index(tmp.startIndex, offsetBy: limit)
            tmp = String(tmp[..<index])
        }
        return tmp
    }
    
    private func getTextField(_ text: String, maxLength: Int) -> (Int, Int) {
        var length = 0
        var number = 0
        let textStr = text as NSString
        textStr.enumerateSubstrings(in: NSMakeRange(0, textStr.length), options: .byComposedCharacterSequences) { subString, subStringRange, enclosingRange, stop in
            if subString?.count == 1 {
                let ch = textStr.character(at: subStringRange.location)
                if isascii(Int32(ch)) == 1 {
                    length += 1
                } else {
                    length += 2
                }
                if length <= maxLength {
                    number += 1
                }
            } else {
                length += 4
                if length <= maxLength {
                    number += 2
                }
            }
        }
        return (length, number)
    }
}

private var maxLengthKey: Void?

extension UITextField {
    
    private static let obsever = UITextFieldMaxLengthObserver()
    
    var maxLength: Int? {
        get {
            return objc_getAssociatedObject(self, &maxLengthKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &maxLengthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue != nil {
                self.addTarget(UITextField.obsever, action: #selector(UITextField.obsever.textChange(_:)), for: .editingChanged)
            }
        }
    }
}
