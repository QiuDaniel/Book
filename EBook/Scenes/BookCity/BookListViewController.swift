//
//  BookListViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/9.
//

import UIKit
import RxDataSources

class BookListViewController: BaseViewController, BindableType {

    var viewModel: BookListViewModelType!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: App.screenWidth - 16, height: 90)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.bookIntroCell)
        adjustScrollView(view, with: self)
        return view
    }()

    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, Book>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, Book>>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookIntroCell, for: indexPath) else {
                fatalError()
            }
            cell.bind(to: BookIntroCellViewModel(book: item))
            return cell
        }
    }
    
    private var refreshHeader: SPRefreshHeader!
    private var refreshFooter: MJRefreshAutoNormalFooter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        rx.disposeBag ~ [
            output.title ~> navigationBar.rx.title,
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            output.footerRefreshing ~> refreshFooter.rx.refreshStatus,
            output.headerRefreshing ~> refreshHeader.rx.refreshStatus,
            output.isFooterHidden ~> refreshFooter.rx.isHidden,
            collectionView.rx.modelSelected(Book.self) ~> input.itemSelectAction.inputs,
        ]
    }

}

private extension BookListViewController {
    func setup() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Book>>(configureCell: collectionViewConfigure)
        refreshHeader = SPRefreshHeader(refreshingTarget: self, refreshingAction: #selector(loadNew))
        refreshFooter = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        collectionView.mj_header = refreshHeader
        collectionView.mj_footer = refreshFooter
    }
    
    @objc
    func loadNew() {
        viewModel.input.loadNewData()
    }
    
    @objc
    func loadMore() {
        viewModel.input.loadMore()
    }
}
