//
//  SceneCoordinatorType.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import Foundation
import RxSwift

protocol SceneCoordinatorType {
    init(window: UIWindow)
    
    @discardableResult
    func transition(to scene: TargetScene) -> Observable<Void>
    
    @discardableResult
    func pop(animated: Bool) -> Observable<Void>
    
    @discardableResult
    func pop(to viewController: AnyClass, animated: Bool) -> Observable<Void>
    
    @discardableResult
    func dismiss(animated: Bool) -> Observable<Void>
    
    @discardableResult
    func dismiss(animated: Bool, completion:@escaping(() -> Void)) -> Observable<Void>
    
    @discardableResult
    func hide() -> Observable<Void>
    
    @discardableResult
    func hide(completion:@escaping(() -> Void)) -> Observable<Void>
    
    @discardableResult
    func tabBarSelected(_ index: Int) -> Observable<Void>
    
    @discardableResult
    func resetTabBar(language: Bool, insertController: UIViewController?) -> Observable<Void>
}
