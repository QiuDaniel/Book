//
//  RxFSPagerViewSectionedReloadDataSource.swift
//  RabbitOptimization
//
//  Created by Daniel on 2019/8/27.
//  Copyright © 2019 Daniel. All rights reserved.
//

import Differentiator
import RxSwift
import RxCocoa

class RxFSPagerViewSectionedReloadDataSource<S: SectionModelType>: FSPagerViewSectionedDataSource<S>, RxFSPagerViewDataSourceType {
    typealias Element = [S]
    
    func pagerView(_ pagerView: FSPagerView, observedEvent: Event<[S]>) {
        Binder(self) { dataSource, element in
            dataSource.setSections(element)
            pagerView.reloadData()
        }.on(observedEvent)
    }
}
