//
//  FSPageControl+Rx.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/3.
//

import RxSwift
import RxCocoa

public extension Reactive where Base: FSPageControl {
    
    var numberOfPages: Binder<Int> {
        return Binder(base) { control, numberOfPages in
            control.numberOfPages = numberOfPages
        }
    }
    
    var currentPage: Binder<Int> {
        return Binder(base) { control, currentPage in
            control.currentPage = currentPage
        }
    }
}

