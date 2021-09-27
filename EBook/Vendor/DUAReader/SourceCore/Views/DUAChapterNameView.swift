//
//  DUAChapterNameView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/27.
//

import UIKit

class DUAChapterNameView: UIView {
    
    var title = "" {
        didSet {
            titleLabel.text = title
            titleLabel.textAlignment = .left
            titleLabel.textColor = .gray
            titleLabel.font = .systemFont(ofSize: 11)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.sizeToFit()
        }
    }
    
    
    var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.origin = CGPoint(x: 3, y: 3)
    }
    
}
