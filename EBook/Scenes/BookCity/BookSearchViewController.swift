//
//  BookSearchViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/4.
//

import UIKit
import RxDataSources

class BookSearchViewController: BaseViewController, BindableType {

    var viewModel: BookSearchViewModelType!
    
    private lazy var searchBar: SearchNavigationBar = {
        let view = SearchNavigationBar(frame: CGRect(x: 0, y: App.screenStatusBarHeight, width: App.screenWidth, height: 64))
        view.delegate = self
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = BookSearchFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        layout.estimatedItemSize = CGSize(width: 70, height: 35)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.searchWordCell)
        view.register(R.nib.searchSectionView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        adjustScrollView(view, with: self)
        return view
    }()
    
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, String>>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.searchWordCell, for: indexPath) else {
                fatalError()
            }
            cell.bind(to: SearchWordCellViewModel(keyword: item))
            return cell
        }
    }
    
    private var supplementaryViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, String>>.ConfigureSupplementaryView {
        return { ds, collectionView, kind, indexPath in
            guard var view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.reuseIdentifier.searchSectionView, for: indexPath) else {
                fatalError()
            }
            view.bind(to: SearchSectionViewModel(title: ds[indexPath.section].model, index: indexPath.section))
            return view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        rx.disposeBag ~ [
            collectionView.rx.setDelegate(self),
            collectionView.rx.modelSelected(String.self) ~> input.keywordSelectAction.inputs,
            output.sections ~> collectionView.rx.items(dataSource: dataSource)
        ]
    }

    override func eventNotificationName(_ name: String, userInfo: [String : Any]? = nil) {
        let event = UIResponderEvent(rawValue: name)
        switch event {
        case .clearSearchHistory:
            viewModel.input.clearHistory()
        default:
            break
        }
    }
}

// MARK: - Init

private extension BookSearchViewController {
    func setup() {
        navigationBar.isHidden = true
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: collectionViewConfigure, configureSupplementaryView: supplementaryViewConfigure)
    }
}

extension BookSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: App.screenWidth, height: 40)
    }
}

extension BookSearchViewController: SearchNavgationBarDelegate {
    
    func searchBar(_ searchBar: SearchNavigationBar, clickedCancel button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: SearchNavigationBar, keyword: String, returnKey: Bool) {
        viewModel.input.searchBook(withKeyword: keyword)
    }
}
