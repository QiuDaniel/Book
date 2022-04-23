//
//  AlertViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/6/22.
//

import Foundation
import Action
import RxSwift
import RxCocoa

typealias CloseAction = () -> Observable<Void>

enum AlertType: Int {
    case addBookcase
}

protocol AlertViewModelInput {
    var leftAction: CocoaAction { get }
    var rightAction: CocoaAction { get }
    var closeAction: CocoaAction { get }
    var inputValue: BehaviorRelay<String> { get set }
}

protocol AlertViewModelOutput {
    var alertTitle: Observable<String?> { get }
    var alertMessage: Observable<String?> { get }
    var leftActionTitle: Observable<String> { get }
    var rightActionTitle: Observable<String> { get }
//    var error: Observable<String> { get }
//    var inputBgBorderColor: Observable<UIColor?> { get }
}

protocol AlertViewModelType {
    var input: AlertViewModelInput { get }
    var output: AlertViewModelOutput { get }
}

class AlertViewModel: AlertViewModelType, AlertViewModelInput, AlertViewModelOutput {
    
    var input: AlertViewModelInput { return self }
    var output: AlertViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var leftAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            return sceneCoordinator.hide {
                if let action = self.actions[0].action {
                    action()
                }
                self.actions[0].action = nil
            }
        }
    }()
    
    lazy var rightAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            if self.actions.count > 1 {
                if let action = self.actions[1].inputAction {
                    let input = self.inputValue.value.removeHeadAndTailSpacePro
                    if isEmpty(input) {
                        Toast.show(SPLocalizedString("toast_input_nil"))
                    } else {
                        if _error == "" {
                            action(input)
                            self.actions[1].inputAction = nil
                            return self.sceneCoordinator.hide()
                        }
                    }
                } else if let action = actions[1].action {
                    return sceneCoordinator.hide {
                        action()
                        self.actions[1].action = nil
                    }
                }
            }
            return .empty()
        }
    }()
    
    lazy var closeAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            if let close = self.close {
                return self.sceneCoordinator.hide().concat(close())
            }
            return self.sceneCoordinator.hide()
        }
    }()
    
    lazy var inputValue: BehaviorRelay<String> = BehaviorRelay(value: "")
    
//    lazy var error: Observable<String> = {
//        guard type == .observerAdd else {
//            return .just("")
//        }
//        return inputValue.asObservable().skip(1).throttle(.milliseconds(800), scheduler: MainScheduler.instance).map { [unowned self] value  in
//            if value.isEmailAddress {
//                if value == AppManager.shared.currentUser!.email {
//                    _error = SPLocalizedString("alert_error_addself")
//                } else {
//                    _error = ""
//                }
//            } else {
//                _error = SPLocalizedString("alert_error_email")
//            }
//            return _error
//        }
//    }()
//
//    lazy var inputBgBorderColor: Observable<UIColor?> = {
//        guard type == .observerAdd else {
//            return .just(R.color.f8f8f8())
//        }
//        return inputValue.asObservable().skip(1).throttle(.milliseconds(800), scheduler: MainScheduler.instance).map { value  in
//            if value.isEmailAddress {
//                if value == AppManager.shared.currentUser!.email {
//                    return R.color.ff4c42()
//                }
//                return R.color.f8f8f8()
//            }
//            return R.color.ff4c42()
//        }
//    }()
    
    // MARK: - Output
    
    lazy var alertTitle: Observable<String?> = {
        return .just(self.title)
    }()
    
    lazy var alertMessage: Observable<String?> = {
        return .just(self.message)
    }()
    
    lazy var leftActionTitle: Observable<String> = {
        var title = actions[0].title ?? ""
        return .just(title)
    }()
    
    lazy var rightActionTitle: Observable<String> = {
        var title = ""
        if actions.count > 1 {
            title = actions[1].title
        }
        return .just(title)
    }()
    
    private let title: String?
    private let message: String?
    private let sceneCoordinator: SceneCoordinatorType
    private let actions: [AlertAction]
    private let close: CloseAction?
    private let type: AlertType
    private var _error = ""
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, title: String? = nil, message: String? = nil, actions:[AlertAction], closeAction: CloseAction? = nil, type: AlertType = .addBookcase) {
        self.sceneCoordinator = sceneCoordinator
        self.title = title
        self.message = message
        self.type = type
        assert(actions.count >= 1, "Actions must contains 1 AlertAction")
        self.actions = actions
        self.close = closeAction
    }
}
