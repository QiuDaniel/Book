//
//  HistoryViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import UIKit
import RxDataSources
import EmptyDataSet_Swift

class HistoryViewController: BaseViewController, BindableType {

    var viewModel: HistoryViewModelType!
    private var emptyShow = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: App.screenWidth, height: 60)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.historyCell)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private lazy var emptyView: BookcaseEmptyView = {
        let view = BookcaseEmptyView(frame: CGRect(x: 0, y: App.naviBarHeight + 100, width: App.screenWidth, height: 300))
        view.titleLabel.text = "浏览记录空空如也，快去看书吧～"
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
        let input = viewModel.input
        emptyView.tutorialBtn.rx.action = input.emptyAction
        rx.disposeBag ~ [
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            collectionView.rx.modelSelected(BookRecord.self) ~> input.itemAction.inputs,
            NotificationCenter.default.rx.notification(SPNotification.browseHistoryDelete.name).subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.viewModel.input.deleteHistory()
            }),
            output.sectionReload.subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.emptyShow = true
                self.collectionView.reloadEmptyDataSet()
            })
        ]
    }
}

// MARK: - EmptyDataSetSource

extension HistoryViewController: EmptyDataSetSource {
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return emptyView
    }
}

// MARK: - EmptyDataSetDelegate

extension HistoryViewController: EmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return emptyShow
    }
}

private extension HistoryViewController {
    func setup() {
        emptyShow = AppManager.shared.browseHistory.count == 0
        navigationBar.title = "最近浏览"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, BookRecord>>(configureCell: collectionViewConfigure)
    }
}
