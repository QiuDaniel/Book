//
//  UserInterfaceViewModel.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/12.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa

protocol UserInterfaceViewModelInput {
    func reloadSection()
}

protocol UserInterfaceViewModelOutput {
    var sections: Observable<[SectionModel<Int, Int>]> { get }
}

protocol UserInterfaceViewModelType {
    var input: UserInterfaceViewModelInput { get }
    var output: UserInterfaceViewModelOutput { get }
}

class UserInterfaceViewModel: UserInterfaceViewModelType, UserInterfaceViewModelOutput, UserInterfaceViewModelInput {
    var input: UserInterfaceViewModelInput { return self }
    var output: UserInterfaceViewModelOutput { return self }
    
    // MARK: - Input
    func reloadSection() {
        reloadProperty.onNext(true)
    }
    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<Int, Int>]> = {
        reloadProperty.asObservable().flatMapLatest { refresh -> Observable<[SectionModel<Int, Int>]> in
            guard refresh else {
                return .empty()
            }
            var sectionArr = [SectionModel<Int, Int>]()
            sectionArr.append(SectionModel(model: 0, items: [0]))
            if UserinterfaceManager.shared.interfaceStyle != .system {
                sectionArr.append(SectionModel(model: 1, items: [0, 1]))
            }
            return .just(sectionArr)
        }
    }()
    
    // MARK: - Property
    
    private let reloadProperty = PublishSubject<Bool>()
    
    init() {
    }
}
