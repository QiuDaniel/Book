//
//  AboutViewModel.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/13.
//

import Foundation
import RxSwift
import RxDataSources

protocol AboutViewModelOutput {
    var sections: Observable<[SectionModel<String, JSONObject>]> { get }
    var backImage: Observable<UIImage?> { get }
}

protocol AboutViewModelType {
    var output: AboutViewModelOutput { get }
}

class AboutViewModel: AboutViewModelType, AboutViewModelOutput {
    var output: AboutViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<String, JSONObject>]> = {
        var sectionArr:[SectionModel<String, JSONObject>] = []
        sectionArr.append(SectionModel(model: "0", items: [["name": "about_wechat", "style": false, "content": SPLocalizedString("about_content_wechat")],
                                                           ["name": "about_mail", "style": false, "content": "about_content_email"],
                                                           ["name":"about_team", "line": true]]))
        sectionArr.append(SectionModel(model: "1", items: [["name": "about_privacy"],
                                                            ["name": "about_agreement"],
                                                            ["name": "about_version", "style": false, "content": ("v" + App.appVersion), "line": true]]))
        return .just(sectionArr)
    }()
    
    lazy var backImage: Observable<UIImage?> = {
        return .just(R.image.nav_back_white())
    }()
    
    init() {
        
    }
}
