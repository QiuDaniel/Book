//
//  UserInterfaceViewController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/12.
//

import UIKit
import RxDataSources

class UserInterfaceViewController: BaseViewController, BindableType {

    var viewModel: UserInterfaceViewModelType!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = .leastNormalMagnitude
        layout.minimumLineSpacing = .leastNormalMagnitude
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(R.nib.themeSettingCell)
        view.register(R.nib.themeFollowCell)
        view.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        return view
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, Int>>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<SectionModel<Int, Int>>.ConfigureCell {
        return { _, collectionView, indexPath, _ in
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.themeFollowCell, for: indexPath) else {
                    fatalError()
                }
                return cell
            default:
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.themeSettingCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: ThemeSettingCellViewModel(index: indexPath.item))
                return cell
            }
        }
    }
    
    private var configureSupplementaryView: CollectionViewSectionedDataSource<SectionModel<Int, Int>>.ConfigureSupplementaryView {
        return { _, collectionView, kind, indexPath in
            let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            let line = UIView()
            line.backgroundColor = R.color.f2f2f2()
            section.addSubview(line)
            line.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(8)
            }
            let label = UILabel()
            label.text = "手动选择"
            label.font = .regularFont(ofSize: 14)
            label.textColor = R.color.c_848fad()
            section.addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalTo(line.snp.bottom).offset(20)
            }
            return section
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.reloadSection()
        refreshUserInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            collectionView.rx.setDelegate(self),
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
        ]
    }

    override func eventNotificationName(_ name: String, userInfo: [String : Any]? = nil) {
        let event = UIResponderEvent(rawValue: name)
        switch event {
        case .switchUserInterface:
            viewModel.input.reloadSection()
            refreshUserInterface()
        default:
            break
        }
    }
}

extension UserInterfaceViewController: UICollectionViewDelegateFlowLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: App.screenWidth, height: 90)
        }
        return CGSize(width: App.screenWidth, height: 62)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 && UserinterfaceManager.shared.interfaceStyle != .system {
            return CGSize(width: App.screenWidth, height: 55)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
}

private extension UserInterfaceViewController {
    func setup() {
        navigationBar.title = "深色模式"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<Int, Int>>(configureCell: collectionViewConfigure, configureSupplementaryView: configureSupplementaryView)
    }
    
    func refreshUserInterface() {
        let style =  UserinterfaceManager.shared.interfaceStyle
        if style != .system {
            delay(0.01) {
                self.collectionView.selectItem(at: IndexPath(item: style.rawValue - 1, section: 1), animated: false, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
            }
        }
    }
}
