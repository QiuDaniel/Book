//
//  BookIntroTagBgView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import UIKit

@objc(BookIntroTagBgView)
class BookIntroTagBgView: UICollectionReusableView {
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.windowBgColor()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(bgView)
        bgView.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) }
    }
}
