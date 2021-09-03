//
//  BookCitySectionBgView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/3.
//

import UIKit

@objc(BookCitySectionBgView)
class BookCitySectionBgView: UICollectionReusableView {
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.white_2c2c2c()
        view.cornerRadius = 10
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
        bgView.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)) }
    }
}
