//
//  UIButton+Rx.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/17.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    public func titleColor(for controlState: UIControl.State = []) -> Binder<UIColor?> {
        return Binder(base) { button, color in
            button.setTitleColor(color, for: controlState)
        }
    }
}
