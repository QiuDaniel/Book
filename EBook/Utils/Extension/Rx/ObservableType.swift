//
//  ObservableType.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import Foundation
import RxSwift

extension ObservableType {
    func ignoreAll() -> Observable<Void> {
        return map { _ in }
    }
    
    func unwrap<T>() -> Observable<T> where Element == Optional<T> {
        return filter{ $0 != nil }.map{ $0! }
    }
    
    func merge(with other: Observable<Element>) -> Observable<Element> {
        return Observable.merge(self.asObservable(), other)
    }
}
