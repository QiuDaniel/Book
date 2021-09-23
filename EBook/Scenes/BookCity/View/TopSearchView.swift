//
//  TopSearchView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import UIKit

class TopSearchView: UIView {
    private lazy var bgView: UIView = {
        let view = UIView()
        return view
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
        bgView.addGradient(withStartPoint: CGPoint(x: 0, y: 0), startColor: R.color.ffae57()!, endPoint: CGPoint(x: 1, y: 0), endColor: R.color.ff7828()!)
    }
    
}

private extension TopSearchView {
    func setup() {
        addSubview(bgView)
        bgView.snp.makeConstraints { $0.edges.equalToSuperview() }
        let containerView = UIView()
        containerView.cornerRadius = 4
        containerView.backgroundColor = R.color.ebebeb()
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-10)
        }
        let imageView = UIImageView(image: R.image.icon_search_orange())
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        let nameLabel = UILabel()
        nameLabel.font = .regularFont(ofSize: 14)
        nameLabel.textColor = R.color.black_25()
        nameLabel.text = "书名/作者/主角"
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.centerY.equalTo(imageView)
        }
        
        let searchBtn = UIButton(type: .custom)
        searchBtn.addTarget(self, action: #selector(searchBtnAction), for: .touchUpInside)
        containerView.addSubview(searchBtn)
        searchBtn.snp.makeConstraints{ $0.edges.equalToSuperview() }
    }
    
    // MARK: - ResponseEvent
    
    @objc func searchBtnAction(_ sender: UIButton) {
        eventNotificationName(UIResponderEvent.searchNovel.rawValue)
    }
}
