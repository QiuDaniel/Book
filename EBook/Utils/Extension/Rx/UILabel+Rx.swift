//
//  UILabel+Rx.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/8.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UILabel {
    public var textColor: Binder<UIColor?> {
        return Binder(base) { label, color in
            label.textColor = color
        }
    }
}
