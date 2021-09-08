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
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.bookTagCell)
        view.register(R.nib.bookCategoryCell)
        view.register(R.nib.bookCategorySectionView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, Any>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, Any>>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            if item is BookCategory {
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookCategoryCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookCategoryCellViewModel(category: item as! BookCategory))
                return cell
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
            cell.arrowImageView.isHidden = indexPath.section == 1
            cell.actionBtn.isHidden = indexPath.section == 1
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
            collectionView.rx.setDelegate(self),
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            collectionView.rx.modelSelected(AnyObject.self) ~> input.tapAction.inputs
        ]
    }
    
    func loadData() {
        viewModel.input.loadData()
    }
    
    override func eventNotificationName(_ name: String, userInfo: [String : Any]? = nil) {
        let event = UIResponderEvent(rawValue: name)
        switch event {
        case .more:
            viewModel.input.moreAction()
        default:
            break
        }
    }

}

extension BookCategoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: (App.screenWidth - 8 * 3) / 2.0, height: 90)
        } else if indexPath.section == 1 {
            return CGSize(width: (App.screenWidth - 8 * 2) / 2.0, height: 100)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 || section == 1 {
            return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 || section == 1 {
            return CGSize(width: App.screenWidth, height: 40)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 8
        }
        return .leastNormalMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 8
        }
        return .leastNormalMagnitude
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
