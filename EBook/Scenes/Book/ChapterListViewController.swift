//
//  ChapterListViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/13.
//

import UIKit
import RxDataSources

class ChapterListViewController: BaseViewController, BindableType {
    
    var viewModel: ChapterListViewModelType!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: App.screenWidth, height: 60)
        layout.minimumLineSpacing = .leastNormalMagnitude
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.chapterListCell)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private lazy var loadingHud: MBProgressHUD = {
        let view = MBProgressHUD.showLoadingHud(at: self.view)
        return view
    }()
    
    private var isFirst = true

    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, Chapter>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, Chapter>>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.chapterListCell, for: indexPath) else {
                fatalError()
            }
            cell.bind(to: ChapterListCellViewModel(chapter: item))
            return cell
        }
    }
    
    private var refreshHeader: SPRefreshHeader!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirst {
            isFirst = false
            return
        }
        collectionView.reloadData()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        rx.disposeBag ~ [
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            output.loading ~> loadingHud.rx.animation,
            collectionView.rx.modelSelected(Chapter.self) ~> input.itemAction.inputs,
        ]
    }

}
 
private extension ChapterListViewController {
    func setup() {
        navigationBar.title = "目录"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Chapter>>(configureCell: collectionViewConfigure)
    }
}
