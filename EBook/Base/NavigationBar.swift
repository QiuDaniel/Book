//
//  NavigationBar.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/31.
//

import UIKit
import RxSwift
import RxCocoa

class NavigationBar: UIView {
    
    private let titleViewWidth: CGFloat = 200.0
    private let barTitleTag = 50000

    var backgroundView: UIView {
        get {
            return _backgroundView
        }
    }
    
    var titleLabel: UILabel? {
        get {
            let label = _titleView?.viewWithTag(barTitleTag) as? UILabel
            return label
        }
    }
    
    var title: String? {
        get {
            return _title
        }
        
        set {
            _title = newValue
            titleLabel?.text = newValue
        }
    }
    
    private var _title: String?
    
    var titleView: UIView? {
        get {
            return _titleView
        }
        
        set {
            _titleView?.removeFromSuperview()
            _titleView = newValue
            if let view = newValue {
                _contanierView.addSubview(view)
                _contanierView.sendSubviewToBack(view)
                view.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.height.equalTo(view.height)
                }
            }
        }
    }
    
    private var _titleView: UIView?
    
    var leftBarView: UIView? {
        get {
            return _leftBarView
        }
        
        set {
            _leftBarView?.removeFromSuperview()
            _leftBarView = newValue
            if let leftBar = newValue {
                leftBar.frame = CGRect(x: 8, y: 0, width: 44, height: 44)
                _contanierView.addSubview(leftBar)
                if let titleView = _titleView {
                    titleView.snp.remakeConstraints { (make) in
                        make.centerY.equalToSuperview()
                        make.leading.equalTo(_leftBarView != nil ? _leftBarView!.snp.trailing : _contanierView.snp.leading).offset(_leftBarView != nil ? 4 : 20)
                        make.trailing.equalTo(_rightBarView != nil ? _rightBarView!.snp.leading : _contanierView.snp.trailing).offset(-4)
                        make.height.equalTo(titleView.height)
                    }
                }
            }
        }
    }
    
    private var _leftBarView: UIView?
    
    var rightBarView: UIView? {
        get {
            return _rightBarView
        }
        set {
            _rightBarView?.removeFromSuperview()
            _rightBarView = newValue
            if let rightBar = newValue {
                _contanierView.addSubview(rightBar)
                rightBar.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.trailing.equalToSuperview().offset(-8)
                    make.size.equalTo(rightBar.size)
                }
                _contanierView.bringSubviewToFront(rightBar)
                
                if let titleView = _titleView {
                    titleView.snp.remakeConstraints { (make) in
                        make.centerY.equalToSuperview()
                        make.leading.equalTo(_leftBarView != nil ? _leftBarView!.snp.trailing : _contanierView.snp.leading).offset(_leftBarView != nil ? 4 : 20)
                        make.trailing.equalTo(_leftBarView != nil ? _leftBarView!.snp.leading : _contanierView.snp.trailing).offset(-4)
                        make.height.equalTo(titleView.height)
                    }
                }
            }
        }
    }
    
    private var _rightBarView: UIView?
    
    var titleColor: UIColor? {
        get {
            return _titleColor
        }
        set {
            _titleColor = newValue
            if let color = newValue {
                titleLabel?.textColor = color
            }
        }
        
    }
    
    private var _titleColor: UIColor?
    
    var bottomBorderColor: UIColor? {
        get {
            return _bottomBorderColor
        }
        
        set {
            _bottomBorderColor = newValue
            bottomBorder.backgroundColor = newValue
        }
    }
    
    private var _bottomBorderColor: UIColor?

    private lazy var _backgroundView: UIView = {
        let view = UIView(frame: frame)
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var _contanierView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: App.screenStatusBarHeight, width: App.screenWidth, height: App.naviBarHeight - App.screenStatusBarHeight))
        return view
    }()
    
    private lazy var bottomBorder: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        clipsToBounds = false
        backgroundColor = .clear
        addSubview(_contanierView)
        _contanierView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(App.screenStatusBarHeight)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        _contanierView.addSubview(bottomBorder)
        bottomBorder.snp.makeConstraints { (make) in
            make.height.equalTo(App.lineHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-App.lineHeight)
        }
        
        addSubview(_backgroundView)
        _backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        sendSubviewToBack(_backgroundView)
        let view = UIView(frame: CGRect(x: (_contanierView.width - titleViewWidth) / 2, y: 0, width: titleViewWidth, height: _contanierView.height))
        view.backgroundColor = .clear
        self.titleView = view
        let label = UILabel(frame: CGRect(x: 0, y: 5, width: titleViewWidth, height: _titleView!.height - 10))
        label.backgroundColor = .clear
        label.textColor = _titleColor != nil ? _titleColor : R.color.b1e3c()
        label.font = .semiboldFont(ofSize: 17)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 14 / 18.0
        label.tag = barTitleTag
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(_contanierView)
            make.width.equalTo(titleViewWidth)
        }
    }
    
}

extension Reactive where Base: NavigationBar {
    var title: Binder<String?> {
        return Binder(base) { bar, title in
            bar.title = title
        }
    }
}
