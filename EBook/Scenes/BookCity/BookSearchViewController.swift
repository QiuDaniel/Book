//
//  BookSearchViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/4.
//

import UIKit
import RxDataSources
import RxSwift

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
        layout.estimatedItemSize = CGSize(width: App.screenWidth - 16 * 2, height: 40)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.searchWordCell)
        view.register(R.nib.searchResultCell)
        view.register(R.nib.searchSectionView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        adjustScrollView(view, with: self)
        return view
    }()
    
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<BookSearchSection>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<BookSearchSection>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            switch item {
            case .historySearchItem(name: let name), .hotSearchItem(name: let name):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.searchWordCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: SearchWordCellViewModel(keyword: name))
                return cell
            case .resultSearchItem(model: let model):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.searchResultCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: SearchResultCellViewModel(model: model))
                return cell
            }
        }
    }
    
    private var supplementaryViewConfigure: CollectionViewSectionedDataSource<BookSearchSection>.ConfigureSupplementaryView {
        return { ds, collectionView, kind, indexPath in
            let section = ds[indexPath.section]
            switch section {
            case .historySearchSection(title: let title, items: _), .hotSearchSection(title: let title, items: _):
                guard var view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.reuseIdentifier.searchSectionView, for: indexPath) else {
                    fatalError()
                }
                view.bind(to: SearchSectionViewModel(title: title, index: indexPath.section))
                return view
            default:
                return UICollectionReusableView()
            }
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
            collectionView.rx.modelSelected(BookSearchSectionItem.self) ~> input.keywordSelectAction.inputs,
            output.selectedText.unwrap() ~> searchBar.rx.searchText,
            output.keyboardHide.subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.view.endEditing(true)
            }),
            output.searchSections ~> collectionView.rx.items(dataSource: dataSource)
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
        dataSource = RxCollectionViewSectionedReloadDataSource<BookSearchSection>(configureCell: collectionViewConfigure, configureSupplementaryView: supplementaryViewConfigure)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BookSearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let searchSection = dataSource[section]
        var height: CGFloat = 0
        switch searchSection {
        case .historySearchSection, .hotSearchSection:
            height = 40
        default:
            break
        }
        return CGSize(width: App.screenWidth, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let searchSection = dataSource[section]
        switch searchSection {
        case .historySearchSection, .hotSearchSection:
            return 5
        default:
            return .leastNormalMagnitude
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let searchSection = dataSource[section]
        switch searchSection {
        case .historySearchSection, .hotSearchSection:
            return 5
        default:
            return .leastNormalMagnitude
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let searchSection = dataSource[section]
        switch searchSection {
        case .historySearchSection, .hotSearchSection:
            return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        default:
            return .zero
        }
    }
}

// MARK: - SearchNavgationBarDelegate

extension BookSearchViewController: SearchNavgationBarDelegate {
    
    func searchBar(_ searchBar: SearchNavigationBar, clickedCancel button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: SearchNavigationBar, keyword: String, returnKey: Bool) {
        printLog("keyword:\(keyword)")
        self.viewModel.input.searchBook(withKeyword: keyword, isReturnKey: returnKey)
    }
    
    func clearSearchBar() {
        viewModel.input.backSearchView()
    }
}
