//
//  ChapterEndViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/27.
//

import UIKit
import RxDataSources

class ChapterEndViewController: BaseViewController, BindableType {

    var viewModel: ChapterEndViewModelType!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Blank")
        view.register(R.nib.bookEndStatusCell)
        view.register(R.nib.bookCoverCell)
        view.register(R.nib.bookInfoSectionView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.white_2c2c2c()
        return view
    }()
    
    private lazy var backBookcaseBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("返回书架", for: .normal)
        btn.setTitleColor(R.color.ff7828(), for: .normal)
        btn.titleLabel?.font = .regularFont(ofSize: 16)
        return btn
    }()
    
    private var refreshHeader: SPRefreshHeader!

    private var dataSource: RxCollectionViewSectionedReloadDataSource<ChapterEndSection>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<ChapterEndSection>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            switch item {
            case .bookEndItem(book: let book):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookEndStatusCell, for: indexPath) else { fatalError() }
                cell.bind(to: BookEndStatusCellViewModel(book: book))
                return cell
            case .bookReleationItem(book: let book):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookCoverCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookCoverCellViewModel(book: book))
                return cell
            }
        }
    }
    
    private var supplementaryViewConfigure: CollectionViewSectionedDataSource<ChapterEndSection>.ConfigureSupplementaryView {
        return { ds, collectionView, kind, indexPath in
            let bookSection = ds[indexPath.section]
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.reuseIdentifier.bookInfoSectionView, for: indexPath) else {
                fatalError()
            }
            switch bookSection {
            case .bookReleationSection:
                view.lineView.isHidden = true
                view.titleLabel.text = "书荒救济站"
                view.moreBtn.isHidden = true
            default:
                break
            }
            return view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshHeader.beginRefreshing()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            collectionView.rx.setDelegate(self),
            output.title ~> navigationBar.rx.title,
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            output.headerRefreshing ~> refreshHeader.rx.refreshStatus,
            output.bottomMenuHidden ~> bottomView.rx.isHidden,
        ]
    }
    

}

extension ChapterEndViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath]
        switch item {
        case .bookEndItem:
            return CGSize(width: App.screenWidth, height: 200)
        case .bookReleationItem:
            let width: CGFloat = (App.screenWidth - 5 * 3 - 10 * 2) / 4.0
            let height = width * 4 / 3.0 + 6 * 2 + 40 + 14
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookReleationSection(items: let books):
            return CGSize(width: App.screenWidth, height: books.count > 0 ? 40 : 0)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookReleationSection:
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookReleationSection:
            return 5
        default:
            return .leastNormalMagnitude
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookReleationSection:
            return 10
        default:
            return .leastNormalMagnitude
        }
    }
}

private extension ChapterEndViewController {
    
    func setup() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets(top: App.screenHeight - App.tabBarHeight, left: 0, bottom: 0, right: 0)) }
        let lineView = UIView()
        lineView.backgroundColor = R.color.ebebeb()
        bottomView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(App.lineHeight)
        }
        bottomView.addSubview(backBookcaseBtn)
        backBookcaseBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 44))
        }
        dataSource = RxCollectionViewSectionedReloadDataSource<ChapterEndSection>(configureCell: collectionViewConfigure, configureSupplementaryView: supplementaryViewConfigure)
        refreshHeader = SPRefreshHeader(refreshingTarget: self, refreshingAction: #selector(loadNew))
        collectionView.mj_header = refreshHeader
    }
    
    @objc
    func loadNew() {
        viewModel.input.loadNewData()
    }
    
}
