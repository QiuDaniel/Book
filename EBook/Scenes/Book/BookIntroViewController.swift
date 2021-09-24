//
//  BookIntroViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/6.
//

import UIKit
import RxSwift
import RxKingfisher
import RxDataSources

class BookIntroViewController: BaseViewController, BindableType {
    
    static let kDescSectionHeight: CGFloat = 75

    var viewModel: BookIntroViewModelType!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return barStyle
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = ZLCollectionViewVerticalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = .leastNormalMagnitude
        layout.minimumInteritemSpacing = .leastNormalMagnitude
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Blank")
        view.register(R.nib.bookInfoCell)
        view.register(R.nib.bookIndexCell)
        view.register(R.nib.bookIntroTagCell)
        view.register(R.nib.bookDescCell)
        view.register(R.nib.bookCatalogCell)
        view.register(R.nib.bookCoverCell)
        view.register(R.nib.bookCopyrightCell)
        view.register(R.nib.bookInfoSectionView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        view.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        adjustScrollView(view, with: self)
        return view
    }()
    
    private lazy var loadingHud: MBProgressHUD = {
        let view = MBProgressHUD.showLoadingHud(at: self.view)
        return view
    }()
    
    private lazy var bottomMenu: BookIntroBottomMenu = {
        let view = BookIntroBottomMenu(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    private var expand = false
    private var bookDescHeight: CGFloat = 0
    private var arrowHidden = true
    
    private lazy var blurImageView: UIImageView = {
        let blurImageView = UIImageView(frame: self.view.frame)
        blurImageView.contentMode = .scaleAspectFill
        //创建毛玻璃效果层
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = blurImageView.frame
        //添加毛玻璃效果层
        blurImageView.addSubview(visualEffectView)
        return blurImageView
    }()
    private var barStyle: UIStatusBarStyle = .lightContent
    private var refreshHeader: SPRefreshHeader!
    private var bgViewInserted = false
    private var dataSource: RxCollectionViewSectionedReloadDataSource<BookIntroSection>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<BookIntroSection>.ConfigureCell {
        return { [weak self] _, collectionView, indexPath, item in
            guard let `self` = self else { fatalError() }
            switch item {
            case .bookBlankItem:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Blank", for: indexPath)
                return cell
            case .bookInfoItem(detail: let detail):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookInfoCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookInfoCellViewModel(bookDetail: detail))
                return cell
            case .bookIndexItem(detail: let detail):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookIndexCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookIndexCellViewModel(bookDetail: detail))
                return cell
            case .bookTagItem(tags: let tags):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookIntroTagCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookIntroTagCellViewModel(tags: tags))
                return cell
            case .bookDescItem(detail: let detail):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookDescCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookDescCellViewModel(detail: detail, isHidden: self.arrowHidden))
                return cell
            case .bookCatalogItem(info: let bookInfo):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookCatalogCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookCatalogCellViewModel(detail: bookInfo.detail))
                return cell
            case .bookReleationItem(book: let book), .bookAuthorItem(book: let book):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookCoverCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookCoverCellViewModel(book: book))
                return cell
            case .bookCopyrightItem(detail: let detail):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookCopyrightCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: BookCopyrightCellViewModel(detail: detail))
                return cell
            }
        }
    }
    
    private var supplementaryViewConfigure: CollectionViewSectionedDataSource<BookIntroSection>.ConfigureSupplementaryView {
        return { ds, collectionView, kind, indexPath in
            let bookSection = ds[indexPath.section]
            if kind == UICollectionView.elementKindSectionHeader {
                guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.reuseIdentifier.bookInfoSectionView, for: indexPath) else {
                    fatalError()
                }
                switch bookSection {
                case .bookReleationSection:
                    view.lineView.isHidden = true
                    view.titleLabel.text = "看过此书的人还看过"
                case.bookAuthorSection(items: let books):
                    view.lineView.isHidden = false
                    view.titleLabel.text = "作者还写过"
                    view.arrowImageView.isHidden = books.count <= 4
                    view.moreBtn.isHidden = books.count <= 4
                    view.moreLabel.isHidden = books.count <= 4
                default:
                    break
                }
                return view
            }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            view.backgroundColor = R.color.ebebeb()
            return view
        }
    }
    
    override func viewDidLoad() {
        setup()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.reloadBookcaseStatus()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        insertBgView()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.title ~> navigationBar.rx.title,
            output.cover ~> blurImageView.kf.rx.image(),
            collectionView.rx.setDelegate(self),
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            output.headerRefreshing ~> refreshHeader.rx.refreshStatus,
            output.loading ~> loadingHud.rx.animation,
            output.loading ~> bottomMenu.rx.isHidden,
            output.loading.subscribe(onNext: { load in
                if !load {
                    delay(0.01) {
                        CATransaction.withDisabledActions {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }),
            output.backImage ~> rx.backImage,
            output.bookcaseStatus ~> bottomMenu.rx.isInBookcase,
            collectionView.rx.contentOffset.map { $0.y <= 0 ? R.image.nav_back_white() : ( ($0.y / App.naviBarHeight) >= 1 ? R.image.nav_back() : R.image.nav_back_white() ) } ~> rx.backImage,
            collectionView.rx.contentOffset.map { $0.y <= 0 ? $0.y : -$0.y  } ~> blurImageView.rx.top,
            collectionView.rx.contentOffset.map { $0.y }.subscribe(onNext: { [weak self] offsetY in
                guard let `self` = self else { return }
                self.changeStyle(withOffsetY: offsetY)
            }),
            NotificationCenter.default.rx.notification(SPNotification.interfaceChanged.name).subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 3)])
            })
        ]
    }
    
    override func eventNotificationName(_ name: String, userInfo: [String : Any]? = nil) {
        let event = UIResponderEvent(rawValue: name)
        switch event {
        case .more:
            if userInfo != nil, let name = userInfo!["section"] as? String {
                viewModel.input.go2BookList(withName: name)
            }
        case .bookcase:
            viewModel.input.addBookcase()
        case .read:
            viewModel.input.go2BookChapterDetail()
        default:
            break
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BookIntroViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath]
        switch item {
        case .bookBlankItem:
            return CGSize(width: App.screenWidth, height:  App.naviBarHeight)
        case .bookInfoItem:
            return CGSize(width: App.screenWidth, height:  160)
        case .bookIndexItem:
            return CGSize(width: App.screenWidth, height:  60)
        case .bookTagItem:
            return CGSize(width: App.screenWidth, height: 36)
        case .bookDescItem(detail: let detail):
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 5
            bookDescHeight = CGFloat(ceilf(Float(detail.intro.size(withAttributes: [.paragraphStyle: paragraph, .font: UIFont.regularFont(ofSize: 12)], forStringSize: CGSize(width: App.screenWidth - 30 , height: CGFloat.greatestFiniteMagnitude)).height))) + 20
            if bookDescHeight > BookIntroViewController.kDescSectionHeight && !expand {
                arrowHidden = false
                return CGSize(width: App.screenWidth, height: 70)
            }
            return CGSize(width: App.screenWidth, height: bookDescHeight)
        case .bookCatalogItem:
            return CGSize(width: App.screenWidth, height: 40)
        case .bookReleationItem, .bookAuthorItem:
            let width: CGFloat = (App.screenWidth - 5 * 3 - 10 * 2) / 4.0
            let height = width * 4 / 3.0 + 6 * 2 + 40 + 14
            return CGSize(width: width, height: height)
        case .bookCopyrightItem:
            return CGSize(width: App.screenWidth, height: 180)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookReleationSection(items: let books), .bookAuthorSection(items: let books):
            return CGSize(width: App.screenWidth, height: books.count > 0 ? 40 : 0)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookCatalogSection:
            return CGSize(width: App.screenWidth, height: 6)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookReleationSection, .bookAuthorSection:
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookReleationSection, .bookAuthorSection:
            return 5
        default:
            return .leastNormalMagnitude
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookReleationSection:
            return 10
        default:
            return .leastNormalMagnitude
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource[indexPath]
        switch item {
        case .bookDescItem:
            if bookDescHeight > BookIntroViewController.kDescSectionHeight {
                expand = !expand
                arrowHidden = expand
                collectionView.reloadItemsAtIndexPaths([indexPath], animationStyle: .none)
            }
        case .bookCatalogItem(let info):
            viewModel.input.go2Catalog(withChapters: info.chapters)
        case .bookAuthorItem(book: let book), .bookReleationItem(book: let book):
            viewModel.input.go2BookDetail(withBook: book)
        default:
            break
        }
    }
}

// MARK: - ZLCollectionViewBaseFlowLayoutDelegate

extension BookIntroViewController: ZLCollectionViewBaseFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, backColorForSection section: Int) -> UIColor {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookBlankSection, .bookInfoSection, .bookIndexSection:
            return .clear
        default:
            return R.color.windowBgColor()!
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, registerBackView section: Int) -> String {
        let bookSection = dataSource[section]
        switch bookSection {
        case .bookReleationSection:
            return "BookIntroTagBgView"
        default:
            return ""
        }
    }
}

private extension BookIntroViewController {
    
    func setup() {
        navigationBar.backgroundView.alpha = 0
        navigationBar.bottomBorderColor = .clear
        view.insertSubview(collectionView, belowSubview: navigationBar)
        collectionView.snp.makeConstraints{ $0.edges.equalToSuperview() }
        view.addSubview(bottomMenu)
        bottomMenu.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(50 + App.iPhoneBottomSafeHeight)
        }
        dataSource = RxCollectionViewSectionedReloadDataSource<BookIntroSection>(configureCell: collectionViewConfigure, configureSupplementaryView: supplementaryViewConfigure)
        refreshHeader = SPRefreshHeader(refreshingTarget: self, refreshingAction: #selector(loadNew))
        collectionView.mj_header = refreshHeader
    }
    
    @objc
    func loadNew() {
        viewModel.input.loadNewData()
    }
    
    func insertBgView() {
        guard !bgViewInserted else {
            return
        }
        for view in collectionView.subviews {
            if view.isKind(of: UICollectionReusableView.self) {
                collectionView.insertSubview(blurImageView, belowSubview: view)
                bgViewInserted = true
                return
            }
        }
    }
    
    func changeStyle(withOffsetY offsetY: CGFloat) {
        if offsetY <= 0 {
            self.navigationBar.backgroundView.alpha = 0
            self.navigationBar.titleLabel?.isHidden = true
        } else {
            let alpha: CGFloat = (offsetY / App.naviBarHeight)
            self.navigationBar.backgroundView.alpha = alpha >= 1 ? 1: 0
            if alpha > 1 {
                switch UserinterfaceManager.shared.interfaceStyle {
                case .system:
                    switch self.traitCollection.userInterfaceStyle {
                    case .light, .unspecified:
                        self.barStyle = .darkContent
                    case .dark:
                        self.barStyle = .lightContent
                    default:
                        break
                    }
                case .dark:
                    self.barStyle = .lightContent
                case .light:
                    self.barStyle = .darkContent
                }
                self.navigationBar.titleLabel?.isHidden = false
            } else {
                self.barStyle = .lightContent
                self.navigationBar.titleLabel?.isHidden = true
            }
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
