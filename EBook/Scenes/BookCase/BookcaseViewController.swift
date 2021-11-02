//
//  BookcaseViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import UIKit
import RxDataSources
import EmptyDataSet_Swift

class BookcaseViewController: BaseViewController, BindableType {

    var viewModel: BookcaseViewModelType!
    
    private var refreshHeader: SPRefreshHeader!
    private var emptyShow = false
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.windowBgColor()
        return view
    }()
    
    private lazy var presentBgView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.alpha = 0
        view.backgroundColor = .black.withAlphaComponent(0.3)
        return view
    }()
    
    
    private lazy var searchBtn: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()
    
    private lazy var moreBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(R.image.gengduo(), for: .normal)
        btn.addTarget(self, action: #selector(moreBtnAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var emptyView: BookcaseEmptyView = {
        let view = BookcaseEmptyView(frame: CGRect(x: 0, y: App.naviBarHeight + 100, width: App.screenWidth, height: 300))
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.bookcaseCell)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, (BookRecord, BookUpdateModel?)>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<String, (BookRecord, BookUpdateModel?)>>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bookcaseCell, for: indexPath) else {
                fatalError()
            }
            cell.bind(to: BookcaseCellViewModel(record: item.0, update: item.1))
            return cell
        }
    }
    
    private var isTuqiang = !AppStorage.shared.bool(forKey: .bookCaseShowInList)
    private var isUpdateTime = AppStorage.shared.bool(forKey: .bookCaseSortByUpdateTime)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    func bindViewModel() {
        let input = viewModel.input
        let output = viewModel.output
        searchBtn.rx.action = input.searchAction
        emptyView.tutorialBtn.rx.action = input.emptyAction
        rx.disposeBag ~ [
            collectionView.rx.setDelegate(self),
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
            output.headerRefreshing ~> refreshHeader.rx.refreshStatus,
            output.headerRefreshing.subscribe(onNext: { [weak self] status in
                guard let `self` = self else { return }
                self.emptyShow = status == .end
                self.collectionView.reloadEmptyDataSet()
            }),
            
            collectionView.rx.modelSelected((BookRecord, BookUpdateModel?).self) ~> input.itemAction.inputs,
            NotificationCenter.default.rx.notification(SPNotification.bookcaseUpdate.name).subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.viewModel.input.initData()
            }),
            NotificationCenter.default.rx.notification(SPNotification.dragDismiss.name).subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.presentBgAnimation(false)
            }),
        ]
    }
    
    override func eventNotificationName(_ name: String, userInfo: [String : Any]? = nil) {
        let event = UIResponderEvent(rawValue: name)
        switch event {
        case .more:
            presentBgAnimation(true)
        default:
            break
        }
    }

}

// MARK: - UICollectionViewDelegate

extension BookcaseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: App.screenWidth, height: 80)
    }
}

// MARK: - EmptyDataSetSource

extension BookcaseViewController: EmptyDataSetSource {
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return emptyView
    }
}

// MARK: - EmptyDataSetDelegate

extension BookcaseViewController: EmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return emptyShow
    }
}

// MARk: - ResponseEvent

extension BookcaseViewController {
    @objc
    func loadNew() {
        viewModel.input.loadNewData()
    }
    
    @objc
    func moreBtnAction(_ sender: UIButton) {
        let absluteRect = sender.convert(sender.bounds, to: UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        let relyPoint = CGPoint(x: absluteRect.origin.x + absluteRect.width / 2, y: absluteRect.origin.y + absluteRect.height / 2 + 8)
        let titles = [isUpdateTime ? "阅读时间排序": "更新时间排序", isTuqiang ? "列表模式": "图墙模式"]
        let icons = [R.image.paixu()!, isTuqiang ? R.image.liebiaomoshi()! : R.image.tuqiangmoshi()!]
        let _ = YBPopupMenu.show(at: relyPoint, titles: titles, icons: icons, menuWidth: scaleF(160)) { popupMenu in
            popupMenu.delegate = self
            popupMenu.showMaskView = false
            popupMenu.itemHeight = 45
            popupMenu.font = .regularFont(ofSize: 13)
            popupMenu.separatorColor = R.color.ebebeb()!
            popupMenu.textColor = R.color.b1e3c()!
            popupMenu.arrowDirection = .bottom
            popupMenu.priorityDirection = .bottom
            popupMenu.lineLeftMargin = scaleF(10)
            popupMenu.lineRightMargin = scaleF(10)
            popupMenu.backColor = R.color.windowBgColor()!
            popupMenu.tableView.cornerRadius = 8
            popupMenu.selectedIndex = 0
            popupMenu.selectedTitleColor = R.color.b1e3c()!
            popupMenu.arrowWidth = 12
            popupMenu.arrowHeight = 8
        }
        
    }
}

// MARK: - YBPopupMenuDelegate

extension BookcaseViewController: YBPopupMenuDelegate {
    func ybPopupMenu(_ ybPopupMenu: YBPopupMenu, didSelectedAt index: Int) {
        if index == 0 {
            isUpdateTime = !isUpdateTime
            AppStorage.shared.setObject(isUpdateTime, forKey: .bookCaseSortByUpdateTime)
            AppStorage.shared.synchronous()
            viewModel.input.sortBooks(isUpdateTime)
        } else if index == 1 {
            isTuqiang = !isTuqiang
            AppStorage.shared.setObject(!isTuqiang, forKey: .bookCaseShowInList)
            AppStorage.shared.synchronous()
            collectionView.reloadData()
        }
    }

}

private extension BookcaseViewController {
    
    func setup() {
        navigationBar.isHidden = true
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(App.naviBarHeight)
        }
//        topView.addSubview(effectView)
//        effectView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        let bgView = UIView()
        bgView.cornerRadius = 4
        bgView.backgroundColor = R.color.black_04()
        topView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-80)
            make.height.equalTo(34)
            make.bottom.equalToSuperview().offset(-10)
        }
        let imageView = UIImageView(image: R.image.icon_search_orange())
        bgView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        let nameLabel = UILabel()
        nameLabel.font = .regularFont(ofSize: 14)
        nameLabel.textColor = R.color.black_25()
        nameLabel.text = "书名/作者/主角"
        bgView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.centerY.equalTo(imageView)
        }
        bgView.addSubview(searchBtn)
        searchBtn.snp.makeConstraints{ $0.edges.equalToSuperview() }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        topView.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalTo(bgView)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        view.addSubview(presentBgView)
        presentBgView.snp.makeConstraints{ $0.edges.equalToSuperview() }
        
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, (BookRecord, BookUpdateModel?)>>(configureCell: collectionViewConfigure)
        refreshHeader = SPRefreshHeader(refreshingTarget: self, refreshingAction: #selector(loadNew))
        collectionView.mj_header = refreshHeader
    }
    
    func presentBgAnimation(_ fade: Bool) {
        if fade {
            self.presentBgView.isHidden = false
            UIView.animate(withDuration: 0.4) {
                self.presentBgView.alpha = 1
            }
        } else {
            self.presentBgView.isHidden = true
            self.presentBgView.alpha = 0
        }
        
    }
    
}
