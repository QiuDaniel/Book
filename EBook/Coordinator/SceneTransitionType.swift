//
//  SceneTransitionType.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import UIKit

enum SceneTransitionType {
    case root(UIViewController)
    case guide(UIViewController)
    case push(UIViewController, Bool)
    
    case tabBar(UITabBarController)
    case present(UIViewController)
    case show(UIView, CustomiseAtimationStyle)
    case alert(UIViewController)
}

enum CustomiseAtimationStyle {
    case drop
    case spring
    case slide
    case fade
}
