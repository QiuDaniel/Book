//
//  CategoryListViewController.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import UIKit
import RxDataSources

class CategoryListViewController: BaseViewController, BindableType {

    var viewModel: CategoryListViewModelType!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: App.screenWidth - 16, height: 90)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.f2f2f2()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        
        rx.disposeBag ~ [
            output.title ~> navigationBar.rx.title,
            output.sections ~> collectionView.rx.items(dataSource: dataSource)
        ]
    }

}

private extension CategoryListViewController {
    func setup() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Book>>(configureCell: collectionViewConfigure)
    }
}
