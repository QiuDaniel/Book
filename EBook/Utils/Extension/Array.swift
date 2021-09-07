//
//  Array.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/3.
//

import Foundation

extension Array {
    /// Picks `n` random elements (straightforward approach)
    subscript (randomPick n: Int) -> [Element] {
        if n >= self.count {
            return self
        }
        var indices = [Int](0..<count)
        var randoms = [Int]()
        for _ in 0..<n {
            randoms.append(indices.remove(at: Int(arc4random_uniform(UInt32(indices.count)))))
        }
        return randoms.map { self[$0] }
    }
}

extension Array where Element:Hashable {
    var unique:[Element] {
        var uniq = Set<Element>()
        uniq.reserveCapacity(self.count)
        return self.filter {
            return uniq.insert($0).inserted
        }
    }
}
