//
//  ObservableConvertibleType.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/30.
//

import Foundation
import RxSwift

extension ObservableConvertibleType where Element: Equatable {
    func isEqualOriginValue() -> Observable<(value: Element, isEqualOriginValue:Bool)> {
        return asObservable().scan(nil) { acum, x -> (origin: Element, current: Element)? in
            if let acum = acum {
                return (origin: acum.origin, current: x)
            } else {
                return (origin: x, current: x)
            }
        }.map { ($0!.current, isEqualOriginValue: $0!.origin == $0!.current) }
    }
    
    func isEqual(_ value: Element) -> Observable<Bool> {
        return asObservable().scan(nil) { acum, x -> (origin: Element, current: Element)? in
            return (origin: value, current: x)
        }.map { $0!.origin == $0!.current }
    }
}
