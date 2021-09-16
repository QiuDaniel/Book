//
//  DUATopMenu.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/16.
//

import UIKit

class DUATopMenu: UIView {
    
    var backImage: UIImage? {
        didSet {
            if let image = oldValue {
                backBtn.setImage(image, for: .normal)
            }
        }
        
        willSet {
            if let image = newValue {
                backBtn.setImage(image, for: .normal)
            }
        }
    }
    
    private lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension DUATopMenu {
    func setup() {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: DUAUtils.screenStatusBarHeight)
        addSubview(backBtn)
    }
}
