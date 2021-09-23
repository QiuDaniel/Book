//
//  AlertAction.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/6/22.
//

import UIKit
import Action

typealias ActionBlock = () -> Void
typealias InputAction = (String) -> Void

class AlertAction: NSObject {
    
    private(set) var title: String!
    var action: ActionBlock?
    var inputAction: InputAction?
    
    static func action(withTitle title: String, action: ActionBlock? = nil) -> AlertAction {
        let alertAction = AlertAction()
        alertAction.title = title
        alertAction.action = action
        return alertAction
    }
    
    static func action(withTitle title: String, inputAction: InputAction?) -> AlertAction {
        let alertAction = AlertAction()
        alertAction.title = title
        alertAction.inputAction = inputAction
        return alertAction
    }
    
}
