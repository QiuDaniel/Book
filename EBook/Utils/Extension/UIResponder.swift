//
//  UIResponder.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/30.
//

import Foundation

extension UIResponder {
    @objc
    func eventNotificationName(_ name: String, userInfo:[String: Any]? = nil) {
        if let next = next, next.responds(to: #selector(eventNotificationName(_:userInfo:))) {
            next.eventNotificationName(name, userInfo: userInfo)
        }
    }
}
