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
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func bindViewModel() {
        let output = viewModel.ouput
        rx.disposeBag ~ [
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
        dataSource = RxCollectionViewSectionedReloadDataSource<BookCitySection>(configureCell: collectionViewConfigure)
    }
    
}

// MARK: - UICollectionViewDelegate

extension BookCityViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath]
        switch item {
        case .bannerSectionItem:
            return CGSize(width: App.screenWidth, height: 120)
        }
    }
}

// MARK: - ZLCollectionViewBaseFlowLayoutDelegate

extension BookCityViewController: ZLCollectionViewBaseFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, backColorForSection section: Int) -> UIColor {
        return .clear
    }
}
