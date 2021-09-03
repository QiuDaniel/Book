//
//  BookCityViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import UIKit
import RxDataSources

class BookCityViewController: BaseViewController, BindableType {
    
    var viewModel: BookCityViewModelType!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var topView: TopSearchView = {
        let view = TopSearchView(frame: .zero)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = ZLCollectionViewVerticalLayout()
        layout.delegate = self
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.f2f2f2()
        view.register(R.nib.bookCityBannerCell)
        view.register(R.nib.bookIntroCell)
        view.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        view.register(R.nib.bookCitySectionView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        adjustScrollView(view, with: self)
        return view
    }()

    private var dataSource: RxCollectionViewSectionedReloadDataSource<BookCitySection>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<BookCitySection>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            switch item {
            case let .bannerSectionItem(banners: banners):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookCityBannerCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookCityBannerCellViewModel(banners: banners))
                return cell
            case let .categorySectionItem(book: book):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookIntroCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookIntroCellViewModel(book: book))
                return cell
            }
        }
    }
    
    private var supplementaryViewConfigure: CollectionViewSectionedDataSource<BookCitySection>.ConfigureSupplementaryView {
        return { [weak self] _, collectionView, kind, indexPath in
            guard let `self` = self else { fatalError() }
            let bookSection = self.dataSource[indexPath.section]
            switch bookSection {
            case .categorySection:
                guard var section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.reuseIdentifier.bookCitySectionView, for: indexPath) else {
                    fatalError()
                }
                let cate = AppManager.shared.bookCity!.male[indexPath.section - 1]
                section.bind(to: BookCitySectionViewModel(cate: cate))
                return section
            default:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
                return view
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        delay(0.4) {
            self.collectionView.reloadData()
        }
    }
    
    func bindViewModel() {
        let output = viewModel.ouput
        rx.disposeBag ~ [
            collectionView.rx.setDelegate(self),
            output.sections ~> collectionView.rx.items(dataSource: dataSource)
        ]
    }
    
    // MARK: - ResponseEvent
    
    override func eventNotificationName(_ name: String, userInfo: [String : Any]? = nil) {
        let event = UIResponderEvent(rawValue: name)
        switch event {
        case .searchNovel:
            printLog("111111")
        default:
            break
        }
    }
}

private extension BookCityViewController {
    func setup() {
        navigationBar.isHidden = true
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(App.naviBarHeight + 10)
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }
        dataSource = RxCollectionViewSectionedReloadDataSource<BookCitySection>(configureCell: collectionViewConfigure, configureSupplementaryView: supplementaryViewConfigure)
    }
    
}

// MARK: - UICollectionViewDelegate

extension BookCityViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath]
        switch item {
        case .bannerSectionItem:
            return CGSize(width: App.screenWidth - 16, height: 120)
        case .categorySectionItem:
            return CGSize(width: App.screenWidth - 16, height: 90)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let bookSection = dataSource[section]
        switch bookSection {
        case .categorySection:
            return CGSize(width: App.screenWidth, height: 40)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bannerSection:
            return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        default:
            return UIEdgeInsets(top: 8, left: 8, bottom: 16, right: 8)
        }
    }
    
}

// MARK: - ZLCollectionViewBaseFlowLayoutDelegate

extension BookCityViewController: ZLCollectionViewBaseFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, backColorForSection section: Int) -> UIColor {
        return .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, registerBackView section: Int) -> String {
        let bookSection = dataSource[section]
        switch bookSection {
        case .categorySection:
            return "BookCitySectionBgView"
        default:
            return ""
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, attachToTop section: Int) -> Bool {
        return true
    }
}
