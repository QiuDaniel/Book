//
//  SearchNavigationBar.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/5.
//

import UIKit

protocol SearchNavgationBarDelegate:AnyObject {
    func searchBar(_ searchBar: SearchNavigationBar, keyword: String, returnKey: Bool)
    func searchBar(_ searchBar: SearchNavigationBar, clickedCancel button:UIButton)
}

extension SearchNavgationBarDelegate {
    func searchBar(_ searchBar: SearchNavigationBar, keyword: String, returnKey: Bool) {}
    func searchBar(_ searchBar: SearchNavigationBar, clickedCancel button:UIButton) {}
}

class SearchNavigationBar: UIView {
    
    weak var delegate: SearchNavgationBarDelegate?

    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("取消", for: .normal)
        btn.setTitle("取消", for: .highlighted)
        btn.setTitleColor(R.color.ff7828()!, for: .normal)
        btn.setTitleColor(R.color.ff7828(), for: .highlighted)
        btn.titleLabel?.font = .mediumFont(ofSize: 14)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 12.0 / 14.0
        btn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: R.image.icon_search_orange())
        return imageView
    }()
    
    private lazy var searchTF: UITextField = {
        let tf = UITextField(frame: .zero)
        tf.font = .regularFont(ofSize: 12)
        tf.textColor = R.color.b1e3c()
        let attributedPlaceholder = NSAttributedString(string: "书名/作者/主角", attributes: [.foregroundColor: R.color.b1e3c()!.withAlphaComponent(0.3), .font: UIFont.regularFont(ofSize: 12)])
        tf.attributedPlaceholder = attributedPlaceholder
        tf.delegate = self
        tf.returnKeyType = .search
        tf.spellCheckingType = .no
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.tintColor = R.color.ff7828()
        return tf
    }()
    
    deinit {
        #if DEBUG
        printLog("=======dealloc========\(self)")
        #endif
//        NotificationCenter.default.removeObserver(self)
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

// MARK: - UITextFieldDelegate

extension SearchNavigationBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchKeyword(textField.text, isReturnKey: true)
        return true
    }
}

// MARK: - ResponseEvent

private extension SearchNavigationBar {
    @objc
    func cancelBtnAction(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.searchBar(self, clickedCancel: sender)
        }
    }
    
    @objc
    func handleTextFieldTextChanged(_ notificiation: Notification) {
        guard let textFiled = notificiation.object as? UITextField else { return }
        let searchWord = textFiled.text
        searchKeyword(searchWord, isReturnKey: false)
    }
}

// MARK: - Public

extension SearchNavigationBar {
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return searchTF.becomeFirstResponder()
    }
}


// MARK: - Init

private extension SearchNavigationBar {
    func setup() {
        addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.width.equalTo(scaleF(30))
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        cancelBtn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        cancelBtn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        let searchTFBg = UIView()
        searchTFBg.backgroundColor = R.color.f8f8f8()
        searchTFBg.cornerRadius = 4
        addSubview(searchTFBg)
        searchTFBg.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
            make.trailing.equalTo(cancelBtn.snp.leading).offset(-12)
        }
        searchTFBg.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 18, height: 18))
            make.centerY.equalToSuperview()
        }
        searchTFBg.addSubview(searchTF)
        searchTF.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
//        NotificationCenter.default.addObserver(self, selector:#selector(handleTextFieldTextChanged) , name: UITextField.textDidChangeNotification, object: nil)
    }
    
    func searchKeyword(_ keyword: String?, isReturnKey: Bool) {
        if isEmpty(keyword) {
            printLog("====qd=====searchword is empty")
            return
        }
        if let delegate = delegate {
            delegate.searchBar(self, keyword: keyword!, returnKey: isReturnKey)
        }
    }
}
