//
//  BookcaseMoreViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/26.
//

import Foundation
import RxSwift
import Kingfisher
import Action

protocol BookcaseMoreViewModelInput {
    var dismissAction: CocoaAction { get }
    var detailAction: CocoaAction { get }
    var deleteAction: CocoaAction { get }
}

protocol BookcaseMoreViewModelOutput {
    var cover: Observable<Resource?> { get }
    var bookName: Observable<String> { get }
    var author: Observable<String> { get }
}

protocol BookcaseMoreViewModelType {
    var input: BookcaseMoreViewModelInput { get }
    var output: BookcaseMoreViewModelOutput { get }
}

class BookcaseMoreViewModel: BookcaseMoreViewModelType, BookcaseMoreViewModelOutput, BookcaseMoreViewModelInput {
    var input: BookcaseMoreViewModelInput { return self }
    var output: BookcaseMoreViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var dismissAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            NotificationCenter.default.post(name: SPNotification.dragDismiss.name, object: nil)
            return sceneCoordinator.dismiss(animated: true)
        }
    }()
    
    lazy var detailAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            NotificationCenter.default.post(name: SPNotification.dragDismiss.name, object: nil)
            return sceneCoordinator.dismiss(animated: true) {
                if self.completionHandler != nil {
                    self.completionHandler!(.detail)
                }
            }
        }
    }()
    
    lazy var deleteAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            NotificationCenter.default.post(name: SPNotification.dragDismiss.name, object: nil)
            return sceneCoordinator.dismiss(animated: true) {
                if self.completionHandler != nil {
                    self.completionHandler!(.delete)
                }
            }
        }
    }()
    
    // MARK: - Output
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: book.picture))
    }()
    
    lazy var bookName: Observable<String> = {
        return .just(book.bookName)
    }()
    
    lazy var author: Observable<String> = {
        return .just(book.author)
    }()
    
    private let sceneCoordinator: SceneCoordinatorType
    private let book: BookRecord
    private let completionHandler:((BookcaseMoreAction) -> Void)?
#if DEBUG
    deinit {
        printLog("==deinit====\(self)")
    }
#endif
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, book: BookRecord, completionHandler:((BookcaseMoreAction) -> Void)? = nil) {
        self.sceneCoordinator = sceneCoordinator
        self.book = book
        self.completionHandler = completionHandler
    }
}
