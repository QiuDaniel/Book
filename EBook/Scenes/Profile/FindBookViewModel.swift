//
//  FindBookViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/8.
//

import Foundation
import RxSwift
import RxCocoa
import Action

protocol FindBookViewModelInput {
    var nameValue: BehaviorRelay<String> { get set }
    var keywordValue: BehaviorRelay<String> { get set }
    var submitAction: CocoaAction { get }
}

protocol FindBookViewModelOutput {
    var count: Observable<NSAttributedString> { get }
    var submitBtnEnabled: Observable<Bool> { get }
    var nameError: Observable<String> { get }
    var hudLoading: Observable<Bool> { get }
    var hideKeyboard: Observable<Void> { get }
}

protocol FindBookViewModelType {
    var input: FindBookViewModelInput { get }
    var output: FindBookViewModelOutput { get }
}


class FindBookViewModel: FindBookViewModelType, FindBookViewModelOutput, FindBookViewModelInput {
    var input: FindBookViewModelInput { return self }
    var output: FindBookViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var nameValue: BehaviorRelay<String> = BehaviorRelay(value: "")
    lazy var keywordValue: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    lazy var submitAction: CocoaAction = {
        return CocoaAction(enabledIf: submitBtnEnabled) { [unowned self] in
            keyboardHidePublisher.onNext(())
            return submitBook().flatMap { success -> Observable<Void> in
                self.loadingProperty.accept(false)
                if success {
                    Toast.show("提交成功")
                    return self.sceneCoordinator.pop(animated: true)
                }
                return .empty()
            }
        }
    }()
    
    // MARK: - Output
    
    lazy var count: Observable<NSAttributedString> = {
        return getBookCount()
    }()
    
    lazy var submitBtnEnabled: Observable<Bool> = {
        return checkAccountName()
    }()
    
    let nameError: Observable<String>
    let hudLoading: Observable<Bool>
    let hideKeyboard: Observable<Void>
    
    // MARK: - Property
    
    private let nameErrorProperty = BehaviorRelay<String>(value: "")
    private let loadingProperty = BehaviorRelay<Bool>(value: false)
    private let keyboardHidePublisher = PublishSubject<Void>()
    private let sceneCoordinator: SceneCoordinatorType
    private let service: ProfileServiceType
    
#if DEBUG
    deinit {
        printLog("====dealloc===\(self)")
    }
#endif
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: ProfileService = ProfileService()) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        nameError = nameErrorProperty.asObservable()
        hudLoading = loadingProperty.asObservable()
        hideKeyboard = keyboardHidePublisher.asObservable()
    }
}

private extension FindBookViewModel {
    
    func getBookCount() -> Observable<NSAttributedString> {
        service.getBookFoundCount().map { count in
            let str = "我们已累计帮助\(count)位书友\n找到想看的书籍"
            let attriStr = NSMutableAttributedString(string: str)
            let countRange = NSString(string:str).range(of: "\(count)")
            attriStr.addAttribute(.foregroundColor, value: R.color.ff7828()!, range: countRange)
            return attriStr
        }.share()
    }
    
    func checkAccountName() -> Observable<Bool> {
        return nameValue.asObservable().skip(1).debounce(.seconds(1), scheduler: MainScheduler.instance).flatMap { [unowned self] name -> Observable<Bool> in
            if name.removeHeadAndTailSpacePro.count <= 0 {
                self.nameErrorProperty.accept(String(format: "* %@", "书名不能为空"))
                return .just(false)
            }
            return .just(true)
        }.share()
    }
    
    func submitBook() -> Observable<Bool> {
        loadingProperty.accept(true)
        return service.findBook(byBookName: nameValue.value, keyword: isEmpty(keywordValue.value) ? nil : keywordValue.value)
    }
}

