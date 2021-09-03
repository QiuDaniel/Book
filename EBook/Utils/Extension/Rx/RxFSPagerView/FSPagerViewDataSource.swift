//
//  FSPagerViewDataSource.swift
//  RabbitOptimization
//
//  Created by Daniel on 2019/8/27.
//  Copyright © 2019 Daniel. All rights reserved.
//

import Differentiator

class FSPagerViewSectionedDataSource<S: SectionModelType>: NSObject, FSPagerViewDataSource, FSPagerViewSectionedDataSourceType {
    typealias I = S.Item
    typealias Section = S
    typealias ConfigureCell = (FSPagerViewSectionedDataSource<S>, FSPagerView, Int, I) -> FSPagerViewCell
    
    init(configureCell: @escaping ConfigureCell) {
        self.configureCell = configureCell
    }
    
    typealias SectionModelSnapshot = SectionModel<S, I>
    
    private var _sectionModels: [SectionModelSnapshot] = []
    
    var sectionModels: [S] {
        return _sectionModels.map { Section(original: $0.model, items: $0.items) }
    }
    
    subscript(index: Int) -> I {
        get {
            return _sectionModels[0].items[index]
        }
        set {
            var section = _sectionModels[0]
            section.items[index] = newValue
            _sectionModels[0] = section
        }
    }
    
    func model(at index: Int) throws -> Any {
        return self[index]
    }
    
    func setSections(_ sections: [S]) {
        _sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    var configureCell: ConfigureCell
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        if _sectionModels.count == 0 {
            return 0
        }
        return _sectionModels[0].items.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        return configureCell(self, pagerView, index, self[index])
    }
}
