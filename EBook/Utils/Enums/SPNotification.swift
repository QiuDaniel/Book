//
//  Notification.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import Foundation

protocol SPNotificationType {
    var name: Notification.Name { get }
}

enum SPNotification {
    case loginSuccess
    case dragDismiss
    case languageChanged
    case interfaceChanged
}

extension SPNotification: SPNotificationType {
    var name: Notification.Name {
        switch self {
        case .loginSuccess:
            return Notification.Name(rawValue: "LoginSuccess")
        case .dragDismiss:
            return Notification.Name(rawValue: "DragDismiss")
        case .languageChanged:
            return Notification.Name(rawValue: "LanguageChanged")
        case .interfaceChanged:
            return Notification.Name(rawValue: "InterfaceChanged")
        }
    }
}
