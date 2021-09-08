//
//  BookCategoryViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import UIKit
import RxDataSources

class BookCategoryViewController: BaseViewController, BindableType {

    var viewModel: BookCategoryViewModelType!
    var isChild = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.bookTagCell)
        view.register(R.nib.bookCategorySectionView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, Any>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, Any>>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            if item is BookCategory {
                
            }
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookTagCell, for: indexPath) else {
                fatalError()
            }
            cell.bind(to: BookTagCellViewModel(tag: item as! BookTag))
            return cell
        }
    }
    
    private var supplementaryViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, Any>>.ConfigureSupplementaryView {
        return { ds, collectionView, kind, indexPath in
            let section = ds[indexPath.section]
            guard let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.reuseIdentifier.bookCategorySectionView, for: indexPath) else {
                fatalError()
            }
            cell.titleLabel.text = section.model
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
            collectionView.rx.setDelegate(self),
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
        ]
    }
    
    func loadData() {
        viewModel.input.loadData()
    }

}

extension BookCategoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: (App.screenWidth - 8 * 3) / 2.0, height: 90)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: App.screenWidth, height: 40)
        }
        return .zero
    }
    
}

private extension BookCategoryViewController {
    func setup() {
        navigationBar.isHidden = true
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints{ $0.edges.equalToSuperview() }
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Any>>(configureCell: collectionViewConfigure, configureSupplementaryView: supplementaryViewConfigure)
    }
}
