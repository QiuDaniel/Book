//
//  Debouncer.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/7.
//

import Foundation

class Debouncer {
    public let label: String
    public let interval: DispatchTimeInterval
    fileprivate let queue: DispatchQueue
    fileprivate let semaphore: DispatchSemaphoreWrapper
    fileprivate var workItem: DispatchWorkItem?
    
    
    public init(label: String, interval: Float, qos: DispatchQoS = .userInteractive) {
        self.interval         = .milliseconds(Int(interval * 1000))
        self.label         = label
        self.queue = DispatchQueue(label: "com.farfetch.debouncer.internalqueue.\(label)", qos: qos)
        self.semaphore = DispatchSemaphoreWrapper(withValue: 1)
    }
    
    
    public func call(_ callback: @escaping (() -> ())) {
        
        self.semaphore.sync  { () -> () in
            self.workItem?.cancel()
            self.workItem = DispatchWorkItem {
                callback()
            }
            if let workItem = self.workItem {
                self.queue.asyncAfter(deadline: .now() + self.interval, execute: workItem)
            }
        }
    }
    
}
