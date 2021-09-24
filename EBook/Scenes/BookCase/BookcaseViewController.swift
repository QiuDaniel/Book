//
//  BookcaseViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import UIKit

class BookcaseViewController: BaseViewController, BindableType {

    var viewModel: BookcaseViewModelType!
    
    private var refreshHeader: SPRefreshHeader!

    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.windowBgColor()
        return view
    }()
    
    private lazy var effectView: UIVisualEffectView = {
        var blurEffect = UIBlurEffect(style: .extraLight)
        switch UserinterfaceManager.shared.interfaceStyle {
        case .system:
            blurEffect = UIBlurEffect(style: .systemMaterial)
        case .dark:
            blurEffect = UIBlurEffect(style: .dark)
        default:
            break
        }
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    private lazy var searchBtn: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()
    
    private lazy var moreBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(R.image.gengduo(), for: .normal)
        return btn
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        adjustScrollView(view, with: self)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    func bindViewModel() {
        let input = viewModel.input
        searchBtn.rx.action = input.searchAction
    }

}

private extension BookcaseViewController {
    
    func setup() {
        navigationBar.isHidden = true
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(App.naviBarHeight)
        }
        topView.addSubview(effectView)
        effectView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        let bgView = UIView()
        bgView.cornerRadius = 4
        bgView.backgroundColor = R.color.black_04()
        topView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-80)
            make.height.equalTo(34)
            make.bottom.equalToSuperview().offset(-10)
        }
        let imageView = UIImageView(image: R.image.icon_search_orange())
        bgView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        let nameLabel = UILabel()
        nameLabel.font = .regularFont(ofSize: 14)
        nameLabel.textColor = R.color.black_25()
        nameLabel.text = "书名/作者/主角"
        bgView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.centerY.equalTo(imageView)
        }
        bgView.addSubview(searchBtn)
        searchBtn.snp.makeConstraints{ $0.edges.equalToSuperview() }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        topView.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalTo(bgView)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
}
