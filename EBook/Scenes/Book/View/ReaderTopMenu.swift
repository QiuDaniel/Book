//
//  ReaderTopMenu.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/16.
//

import UIKit

class ReaderTopMenu: UIView {
    
    private lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(R.image.nav_back(), for: .normal)
        btn.tag = 100
//        btn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        return btn
    }()
    
    
    private (set)var moreBtn: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addShadow(.black.withAlphaComponent(0.5), offset: CGSize(width: 0, height: 4), radius: 16, opacity: 1)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

/**
// MARK: - ResponseEvent

private extension ReaderTopMenu {
    
    @objc
    func backBtnAction(_ sender: UIButton) {
        eventNotificationName(UIResponderEvent.back.rawValue)
    }
    
    @objc
    func moreBtnAction(_ sender: UIButton ) {
        eventNotificationName(UIResponderEvent.more.rawValue)
    }
    
}
 */
// MARK: - Init

private extension ReaderTopMenu {
    func setup() {
        moreBtn = UIButton(type: .custom)
        moreBtn.setImage(R.image.gengduo(), for: .normal)
//        moreBtn.addTarget(self, action: #selector(moreBtnAction), for: .touchUpInside)
        moreBtn.tag = 101
        layer.backgroundColor = R.color.white_2c2c2c()?.cgColor
        let containerView = UIView()
        containerView.backgroundColor = .clear
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        containerView.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        containerView.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
}
