//
//  BookIntroBottomMenu.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/18.
//

import UIKit

class BookIntroBottomMenu: UIView {
    
    private lazy var readBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("立即阅读", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .regularFont(ofSize: 14)
        btn.backgroundColor = R.color.ff4c42()
        btn.cornerRadius = 20
        return btn
    }()
    
    private lazy var addBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("加入书架", for: .normal)
        btn.setTitleColor(R.color.b1e3c(), for: .normal)
        btn.setImage(R.image.shujia_tianjia(), for: .normal)
        btn.titleLabel?.font = .regularFont(ofSize: 14)
        btn.setImageLayout(.imageLeft, space: 5)
        btn.cornerRadius = 20
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        readBtn.addShadow(R.color.ff4c42()?.withAlphaComponent(0.6), offset: CGSize(width: 0, height: 4), radius: 8, opacity: 1)
    }
}

// MARK: - ResponseEvent

private extension BookIntroBottomMenu {
    @objc
    func readBtnAction(_ sender: UIButton) {
        eventNotificationName(UIResponderEvent.read.rawValue)
    }
    
    @objc
    func addBtnAction(_ sender: UIButton) {
        eventNotificationName(UIResponderEvent.bookcase.rawValue)
    }
}

private extension BookIntroBottomMenu {
    func setup() {
        backgroundColor = R.color.windowBgColor()
        let lineView = UIView()
        lineView.backgroundColor = R.color.ebebeb()
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(App.lineHeight)
        }
        addSubview(readBtn)
        readBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(40)
            make.width.equalToSuperview().multipliedBy(1 / 2.0)
        }
        
        addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
            make.top.equalTo(readBtn)
            make.centerX.equalToSuperview().multipliedBy(1 / 2.0)
            make.height.equalTo(readBtn)
            make.width.equalToSuperview().multipliedBy(1 / 4.0)
        }
    }
}
