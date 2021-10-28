//
//  AboutViewModel.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/13.
//

import Foundation
import RxSwift
import RxDataSources
import Action

protocol AboutViewModelInput {
    var itemAction: Action<JSONObject, Void> { get }
}

protocol AboutViewModelOutput {
    var sections: Observable<[SectionModel<String, JSONObject>]> { get }
    var backImage: Observable<UIImage?> { get }
}

protocol AboutViewModelType {
    var input: AboutViewModelInput { get }
    var output: AboutViewModelOutput { get }
}

class AboutViewModel: AboutViewModelType, AboutViewModelOutput, AboutViewModelInput {
    var input: AboutViewModelInput { return self }
    var output: AboutViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var itemAction: Action<JSONObject, Void> = {
        return Action<JSONObject, Void> { [unowned self] item in
            guard let name = item["name"] as? String else {
                return .empty()
            }
            if name == "用户协议" {
                return sceneCoordinator.transition(to: Scene.h5(H5ViewModel(url: "agreement.txt", title:name)))
            } else if name == "隐私政策" {
                return sceneCoordinator.transition(to: Scene.h5(H5ViewModel(url: "privacy.txt", title:name)))
            } else if name == "免责声明" {
                return sceneCoordinator.transition(to: Scene.h5(H5ViewModel(url: "statement.txt", title:name)))
            }
            return .empty()
        }
    }()
    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<String, JSONObject>]> = {
        var sectionArr:[SectionModel<String, JSONObject>] = []
        sectionArr.append(SectionModel(model: "0", items: [["name": "用户协议"],
                                                            ["name": "隐私政策"],
                                                            ["name": "免责声明"]]))
        return .just(sectionArr)
    }()
    
    lazy var backImage: Observable<UIImage?> = {
        return .just(R.image.nav_back_white())
    }()
    
    private let sceneCoordinator: SceneCoordinatorType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinator
    }
}
