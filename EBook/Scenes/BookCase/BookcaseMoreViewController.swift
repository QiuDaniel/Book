//
//  BookcaseMoreViewController.swift
//  EBook
//
//  Created by Daniel on 2021/9/26.
//

import UIKit

enum BookcaseMoreAction {
    case detail
    case delete
}

class BookcaseMoreViewController: BaseViewController, BindableType {
    
    var viewModel: BookcaseMoreViewModelType!
    weak var bgView: UIView!
    weak var coverImageView: UIImageView!
    weak var bookNameLabel: UILabel!
    weak var authorLabel: UILabel!
    weak var deleteBtn: UIButton!
    weak var detailBtn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        detailBtn.rx.action = input.detailAction
        deleteBtn.rx.action = input.deleteAction
        rx.disposeBag ~ [
            output.cover ~> coverImageView.kf.rx.image(),
            output.bookName ~> bookNameLabel.rx.text,
            output.author ~> authorLabel.rx.text,
        ]
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var point = touches.first?.location(in: view)
        point = bgView.layer.convert(point!, from: view.layer)
        if !bgView.layer.contains(point!) {
            viewModel.input.dismissAction.execute()
        } else {
            super.touchesEnded(touches, with: event)
        }
    }

}

private extension BookcaseMoreViewController {
    func setup() {
        modalPresentationStyle = .custom
        view.backgroundColor = .clear
        navigationBar.isHidden = true
        let bgView = UIView()
        bgView.backgroundColor = R.color.white_2c2c2c()
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80 + App.iPhoneBottomSafeHeight)
        }
        self.bgView = bgView
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = 4
        bgView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 45, height: 60))
            make.top.equalToSuperview().offset(10)
        }
        coverImageView = imageView
        let nameLabel = UILabel()
        nameLabel.textColor = R.color.b1e3c()
        nameLabel.font = .mediumFont(ofSize: 18)
        bgView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(5)
            make.leading.equalTo(imageView.snp.trailing).offset(10)
        }
        bookNameLabel = nameLabel
        
        let userLabel = UILabel()
        userLabel.textColor = R.color.black_25()
        userLabel.font = .regularFont(ofSize: 12)
        bgView.addSubview(userLabel)
        userLabel.snp.makeConstraints { make in
            make.bottom.equalTo(imageView).offset(-5)
            make.leading.equalTo(nameLabel)
        }
        authorLabel = userLabel
        
        let detailBtn = UIButton(type: .custom)
        detailBtn.setTitle("详情", for: .normal)
        detailBtn.setTitleColor(R.color.b1e3c(), for: .normal)
        detailBtn.titleLabel?.font = .regularFont(ofSize: 13)
        detailBtn.cornerRadius = 8
        detailBtn.borderColor = R.color.ebebeb()
        detailBtn.borderWidth = 1
        bgView.addSubview(detailBtn)
        detailBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 50, height: 25))
            make.centerY.equalTo(imageView)
        }
        self.detailBtn = detailBtn
        
        let deleteBtn = UIButton(type: .custom)
        deleteBtn.setTitle("删除", for: .normal)
        deleteBtn.setTitleColor(R.color.ff7828(), for: .normal)
        deleteBtn.titleLabel?.font = .regularFont(ofSize: 13)
        deleteBtn.cornerRadius = 8
        deleteBtn.borderColor = R.color.ff7828()
        deleteBtn.borderWidth = 1
        bgView.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalTo(detailBtn.snp.leading).offset(-5)
            make.size.equalTo(CGSize(width: 50, height: 25))
            make.centerY.equalTo(detailBtn)
        }
        self.deleteBtn = deleteBtn
    }
}
