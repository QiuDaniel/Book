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
        adjustScrollView(view, with: self)
        return view
    }()
    
    private var refreshHeader: SPRefreshHeader!

    private var dataSource: RxCollectionViewSectionedReloadDataSource<ChapterEndSection>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<ChapterEndSection>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            switch item {
            case .bookEndItem:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookEndStatusCell, for: indexPath) else { fatalError() }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            collectionView.rx.setDelegate(self),
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            output.headerRefreshing ~> refreshHeader.rx.refreshStatus,
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
        dataSource = RxCollectionViewSectionedReloadDataSource<ChapterEndSection>(configureCell: collectionViewConfigure)
        refreshHeader = SPRefreshHeader(refreshingTarget: self, refreshingAction: #selector(loadNew))
        collectionView.mj_header = refreshHeader
    }
    
    @objc
    func loadNew() {
        viewModel.input.loadNewData()
    }
}
