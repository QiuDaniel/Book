//
//  HistoryCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import Foundation
import RxSwift
import Kingfisher

protocol HistoryCellViewModelOutput {
    var cover: Observable<Resource?> { get }
    var title: Observable<String> { get }
    var time: Observable<String> { get }
}

protocol HistoryCellViewModelType {
    var output: HistoryCellViewModelOutput { get }
}

class HistoryCellViewModel: HistoryCellViewModelType, HistoryCellViewModelOutput {
    
    var output: HistoryCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: record.picture)).share()
    }()
    
    lazy var title: Observable<String> = {
        return .just(record.bookName).share()
    }()
    
    lazy var time: Observable<String> = {
        let date = Date(timeIntervalSince1970: record.timestamp)
        return .just(Date.bookHistoryTimeSinceDate(date)).share()
    }()
    
    // MARK: - Property
    
    private let record: BookRecord
    
    init(record: BookRecord) {
        self.record = record
    }
}
