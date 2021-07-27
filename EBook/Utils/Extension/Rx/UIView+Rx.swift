//
//  UIView+Rx.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/25.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    var borderColor: Binder<UIColor?> {
        return Binder(base) { view, borderColor in
            view.borderColor = borderColor
        }
    }
}
