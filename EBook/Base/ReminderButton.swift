//
//  ReminderButton.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/8.
//

import UIKit

class ReminderButton: UIButton {

    private weak var iconImageView: UIImageView!
    
    override var isSelected: Bool {
        willSet(newValue) {
            super.isSelected = newValue
            iconImageView.isHidden = !newValue
            borderColor = newValue ? R.color.ff7828() : R.color.c_848fad()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
}

private extension ReminderButton {
    func setup() {
        let imageView = UIImageView(image: R.image.btn_selected())
        imageView.isHidden = true
        iconImageView = imageView
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
        }
    }
}
