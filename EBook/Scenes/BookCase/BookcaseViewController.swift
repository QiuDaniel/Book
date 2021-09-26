//
//  BookcaseViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import UIKit
import RxDataSources

class BookcaseViewController: BaseViewController, BindableType {

    var viewModel: BookcaseViewModelType!
    
    private var refreshHeader: SPRefreshHeader!

    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.windowBgColor()
        return view
    }()
    
//    private lazy var effectView: UIVisualEffectView = {
//        var blurEffect = UIBlurEffect(style: .extraLight)
//        switch UserinterfaceManager.shared.interfaceStyle {
//        case .system:
//            blurEffect = UIBlurEffect(style: .systemMaterial)
//        case .dark:
//            blurEffect = UIBlurEffect(style: .dark)
//        default:
//            break
//        }
//        let view = UIVisualEffectView(effect: blurEffect)
//        return view
//    }()
    
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
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.bookcaseCell)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, (BookRecord, BookUpdateModel)>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, (BookRecord, BookUpdateModel)>>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookcaseCell, for: indexPath) else {
                fatalError()
            }
            cell.bind(to: BookcaseCellViewModel(record: item.0, update: item.1))
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    func bindViewModel() {
        let input = viewModel.input
        let output = viewModel.output
        searchBtn.rx.action = input.searchAction
        
        rx.disposeBag ~ [
            collectionView.rx.setDelegate(self),
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            output.headerRefreshing ~> refreshHeader.rx.refreshStatus,
            collectionView.rx.modelSelected((BookRecord, BookUpdateModel).self) ~> input.itemAction.inputs,
            NotificationCenter.default.rx.notification(SPNotification.bookcaseUpdate.name).subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.viewModel.input.initData()
            }),
        ]
    }

}

// MARK: - UICollectionViewDelegate

extension BookcaseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: App.screenWidth, height: 80)
    }
}

// MARk: - ResponseEvent

extension BookcaseViewController {
    @objc
    func loadNew() {
        viewModel.input.loadNewData()
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
//        topView.addSubview(effectView)
//        effectView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
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
        
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, (BookRecord, BookUpdateModel)>>(configureCell: collectionViewConfigure)
        refreshHeader = SPRefreshHeader(refreshingTarget: self, refreshingAction: #selector(loadNew))
        collectionView.mj_header = refreshHeader
    }
    
}
