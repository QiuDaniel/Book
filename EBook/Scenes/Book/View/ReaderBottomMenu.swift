//
//  ReaderBottomMenu.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/16.
//

import UIKit

class ReaderBottomMenu: UIView {

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

private extension ReaderBottomMenu {
    func setup() {
//        layer.backgroundColor = R.color.white_2c2c2c()?.cgColor
        backgroundColor = R.color.white_2c2c2c()
        let previousBtn = UIButton(type: .custom)
        previousBtn.titleLabel?.font = .regularFont(ofSize: 12)
        previousBtn.setTitle("上一章", for: .normal)
        previousBtn.setTitleColor(R.color.black_45(), for: .normal)
        previousBtn.tag = 200
        let nextBtn = UIButton(type: .custom)
        nextBtn.titleLabel?.font = .regularFont(ofSize: 12)
        nextBtn.setTitle("下一章", for: .normal)
        nextBtn.setTitleColor(R.color.black_45(), for: .normal)
        nextBtn.tag = 201
        addSubview(previousBtn)
        previousBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 50, height: 30))
        }
        addSubview(nextBtn)
        nextBtn.snp.makeConstraints { make in
            make.top.equalTo(previousBtn)
            make.size.equalTo(previousBtn)
            make.trailing.equalToSuperview().offset(-10)
        }
        let slider = UISlider(frame: .zero)
        slider.minimumTrackTintColor = R.color.b1e3c()?.withAlphaComponent(0.6)
        addSubview(slider)
        slider.snp.makeConstraints { make in
            make.leading.equalTo(previousBtn.snp.trailing).offset(10)
            make.trailing.equalTo(nextBtn.snp.leading).offset(-10)
            make.height.equalTo(2)
            make.centerY.equalTo(previousBtn)
        }
        
        let catalogBtn = UIButton(type: .custom)
        catalogBtn.setTitle("目录", for:.normal)
        catalogBtn.titleLabel?.font = .regularFont(ofSize: 10)
        catalogBtn.setTitleColor(R.color.black_45(), for: .normal)
        catalogBtn.setImage(R.image.mulu(), for: .normal)
        catalogBtn.setImageLayout(.imageTop, space: 5)
        catalogBtn.tag = 202
        addSubview(catalogBtn)
        catalogBtn.snp.makeConstraints { make in
            make.top.equalTo(previousBtn.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 50, height: 70))
        }
        /**
         let settingBtn = UIButton(type: .custom)
         settingBtn.setTitle("设置", for:.normal)
         settingBtn.titleLabel?.font = .regularFont(ofSize: 10)
         settingBtn.setTitleColor(R.color.black_45(), for: .normal)
         settingBtn.setImage(R.image.shezhi(), for: .normal)
         settingBtn.setImageLayout(.imageTop, space: 5)
         settingBtn.tag = 205
         addSubview(settingBtn)
         settingBtn.snp.makeConstraints { make in
             make.top.equalTo(catalogBtn)
             make.trailing.equalToSuperview().offset(-10)
             make.size.equalTo(CGSize(width: 50, height: 70))
         }
         settingBtn.isHidden = true
         */
        
        
        let flipBtn = UIButton(type: .custom)
        flipBtn.setTitle("翻页动画", for:.normal)
        flipBtn.titleLabel?.font = .regularFont(ofSize: 10)
        flipBtn.setTitleColor(R.color.black_45(), for: .normal)
        flipBtn.setImage(R.image.fanyedonghua(), for: .normal)
        flipBtn.setImageLayout(.imageTop, space: 5)
        flipBtn.tag = 203
        addSubview(flipBtn)
        flipBtn.snp.makeConstraints { make in
            make.top.equalTo(catalogBtn)
            make.centerX.equalToSuperview().offset(-(App.screenWidth / 7.0))
            make.size.equalTo(CGSize(width: 70, height: 70))
        }
        
        let darkBtn = UIButton(type: .custom)
        darkBtn.setTitle("夜间", for:.normal)
        darkBtn.setTitle("白天", for: .selected)
        darkBtn.titleLabel?.font = .regularFont(ofSize: 10)
        darkBtn.setTitleColor(R.color.black_45(), for: .normal)
        darkBtn.setImage(R.image.yejian(), for: .normal)
        darkBtn.setImage(R.image.rijian(), for: .selected)
        darkBtn.setImageLayout(.imageTop, space: 5)
        darkBtn.tag = 204
        addSubview(darkBtn)
        darkBtn.snp.makeConstraints { make in
            make.top.equalTo(catalogBtn)
            make.centerX.equalToSuperview().offset(App.screenWidth / 7.0)
            make.size.equalTo(CGSize(width: 50, height: 70))
        }
    }
}
