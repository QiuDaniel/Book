//
//  CATransaction.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import Foundation

extension CATransaction {
    class func withDisabledActions< T >(_ body: () throws -> T) rethrows -> T {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer {
            CATransaction.commit()
        }
        return try body()
    }
}
