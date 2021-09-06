//
//  NovelSearchServiceType.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import Foundation
import RxSwift

protocol NovelSearchServiceType {
    
    func searchHeat(withAppId id: String) -> Observable<[SearchHeat]>
    
    func searchNovel(withKeyword keyword: String, pageIndex: Int, pageSize: Int, reader: ReaderType) -> Observable<SearchResult>
}
