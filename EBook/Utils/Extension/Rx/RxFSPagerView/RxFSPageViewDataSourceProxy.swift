//
//  RxFSPageViewDataSourceProxy.swift
//  RabbitOptimization
//
//  Created by Daniel on 2019/8/27.
//  Copyright © 2019 Daniel. All rights reserved.
//

import RxSwift
import RxCocoa

extension FSPagerView: HasDataSource {
    public typealias DataSource = FSPagerViewDataSource
}

fileprivate let pagerViewDataSourceNotSet = FSPagerViewDataSourceNotSet()

fileprivate final class FSPagerViewDataSourceNotSet: NSObject, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        fatalError("DataSource not set", file: #file, line: #line)
    }
}

class RxFSPagerViewDataSourceProxy: DelegateProxy<FSPagerView, FSPagerViewDataSource>, DelegateProxyType, FSPagerViewDataSource {
    
    init(pageView: FSPagerView) {
        super.init(parentObject: pageView, delegateProxy: RxFSPagerViewDataSourceProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register {RxFSPagerViewDataSourceProxy(pageView: $0)}
    }
    
    private weak var _requiredMethodsDataSource: FSPagerViewDataSource? = pagerViewDataSourceNotSet
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return (_requiredMethodsDataSource ?? pagerViewDataSourceNotSet).numberOfItems(in: pagerView)
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        return (_requiredMethodsDataSource ?? pagerViewDataSourceNotSet).pagerView(pagerView, cellForItemAt: index)
    }
    
    override func setForwardToDelegate(_ delegate: FSPagerViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = delegate ?? pagerViewDataSourceNotSet
        super.setForwardToDelegate(delegate, retainDelegate: retainDelegate)
    }
}
