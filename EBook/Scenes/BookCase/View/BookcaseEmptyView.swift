//
//  BookcaseMoreView.swift
//  EBook
//
//  Created by Daniel on 2021/9/26.
//

import UIKit

class BookcaseEmptyView: UIView {
    
    private var bgView: UIView!
    var titleLabel: UILabel!
    private var iconImageView: UIImageView!
    var tutorialBtn: UIButton!
    
#if DEBUG
    deinit {
        printLog("===dealloc===\(self)")
    }
#endif
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension BookcaseEmptyView {
    func setup() {
        createSubViews()
        addSubview(bgView)
        bgView.snp.makeConstraints { $0.edges.equalToSuperview() }
        bgView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(scaleF(8))
            make.centerX.equalTo(iconImageView)
        }
        bgView.addSubview(tutorialBtn)
        tutorialBtn.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(scaleF(80))
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.height.equalTo(48)
        }
    }
    
    func createSubViews() {
        bgView = UIView()
        bgView.backgroundColor = R.color.windowBgColor()
        iconImageView = UIImageView(image: R.image.icon_empty_account())
        titleLabel = UILabel()
        titleLabel.textColor = R.color.b5bcce()
        titleLabel.font = .regularFont(ofSize: 12)
        titleLabel.text = "书架空空如也"
        tutorialBtn = UIButton(type: .custom)
        tutorialBtn.setTitleColor(R.color.ff7828(), for: .normal)
        tutorialBtn.setTitle("去书城逛逛", for: .normal)
        tutorialBtn.titleLabel?.font = .regularFont(ofSize: 16)
        tutorialBtn.cornerRadius = 24
        tutorialBtn.borderColor = R.color.ff7828()
        tutorialBtn.borderWidth = 1
        tutorialBtn.backgroundColor = .clear
    }
}
