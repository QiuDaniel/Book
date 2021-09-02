//
//  FSPagerView+Rx.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/2.
//

import Foundation
import RxSwift
import RxCocoa
import RxFSPagerView

extension Reactive where Base: FSPagerView  {
    
    public var automaticSlidingInterval: Binder<CGFloat> {
        return Binder(base) { view, interval in
            view.automaticSlidingInterval = interval
        }
    }
    
    public var isScrollEnabled: Binder<Bool> {
        return Binder(base) { view, enable in
            view.isScrollEnabled = enable
        }
    }
}
