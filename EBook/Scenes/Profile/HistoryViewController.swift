//
//  HistoryViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import UIKit
import RxDataSources

class HistoryViewController: BaseViewController, BindableType {

    var viewModel: HistoryViewModelType!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: App.screenWidth, height: 60)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.historyCell)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, BookRecord>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, BookRecord>>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.historyCell, for: indexPath) else {
                fatalError()
            }
            cell.bind(to: HistoryCellViewModel(record: item))
            return cell
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            NotificationCenter.default.rx.notification(SPNotification.browseHistoryDelete.name).subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.viewModel.input.deleteHistory()
            })
        ]
    }
}

private extension HistoryViewController {
    func setup() {
        navigationBar.title = "最近浏览"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, BookRecord>>(configureCell: collectionViewConfigure)
    }
}
