//
//  RxFSPagerViewDataSourceType.swift
//  RabbitOptimization
//
//  Created by Daniel on 2019/8/27.
//  Copyright © 2019 Daniel. All rights reserved.
//

import RxSwift

protocol RxFSPagerViewDataSourceType {
    associatedtype Element
    
    func pagerView(_ pagerView: FSPagerView, observedEvent: Event<Element>)
}
