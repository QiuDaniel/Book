//
//  UITextField+Rx.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/1.
//

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UITextField {
    var attributedPlaceholder: Binder<NSAttributedString> {
        return Binder(self.base) { textField, attributedPlaceholder in
            textField.attributedPlaceholder = attributedPlaceholder
        }
    }
    
    var keyboardType: Binder<UIKeyboardType> {
        return Binder(self.base) { textField, keyboardType in
            textField.keyboardType = keyboardType
        }
    }
}
