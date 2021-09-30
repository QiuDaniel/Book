//
//  ProfileViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import UIKit
import RxDataSources

class ProfileViewController: BaseViewController, BindableType {

    var viewModel: ProfileViewModelType!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = .leastNormalMagnitude
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.f2f2f2()
        view.register(R.nib.profileCell)
        adjustScrollView(view, with: self)
        return view
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<ProfileSection>!
    private var collectionViewConfigure: CollectionViewSectionedDataSource<ProfileSection>.ConfigureCell {
        return { _, collectionView, indexPath, item in
            switch item {
            case let .normalFunctionItem(index: index), let .otherItem(index: index):
                guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profileCell, for: indexPath) else {
                    fatalError()
                }
                cell.bind(to: ProfileCellViewModel(index: index))
                return cell
            }
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
            collectionView.rx.modelSelected(ProfileSectionItem.self) ~> input.itemAction.inputs,
            output.sections ~> collectionView.rx.items(dataSource: dataSource),
        ]
    }
    

}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let item = dataSource[indexPath]
//        switch item {
//        case .normalFunctionItem:
            return CGSize(width: App.screenWidth, height: 50)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: App.screenWidth, height: 8)
    }
}

private extension ProfileViewController {
    func setup() {
        navigationBar.title = "设置"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        dataSource = RxCollectionViewSectionedReloadDataSource<ProfileSection>(configureCell: collectionViewConfigure)
    }
}
