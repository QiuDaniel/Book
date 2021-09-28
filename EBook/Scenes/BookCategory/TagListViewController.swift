//
//  TagListViewController.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import UIKit
import RxDataSources

class TagListViewController: BaseViewController, BindableType {
    
    var viewModel: TagListViewModelType!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (App.screenWidth - (5 * 4)) / 3.0, height: 60)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 20, right: 5)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.tagListCell)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, BookTag>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, BookTag>>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.tagListCell, for: indexPath) else {
                fatalError()
            }
            cell.bind(to: TagListCellViewModel(tag: item))
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
        rx.disposeBag ~ [
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            collectionView.rx.modelSelected(BookTag.self) ~> input.tagAction.inputs
        ]
    }

}

private extension TagListViewController {
    func setup() {
        navigationBar.title = "热门主题"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, BookTag>>(configureCell: collectionViewConfigure)
    }
}
