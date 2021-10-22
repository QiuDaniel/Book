//
//  CategoryGroupController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import UIKit
import DQSegmentedControl

class CategoryGroupController: UIViewController {
    
    private let kSegmentHeight: CGFloat = 48
    
    private lazy var contentView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = .leastNormalMagnitude
        layout.minimumLineSpacing = .leastNormalMagnitude
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: App.screenWidth, height: App.screenHeight - App.naviBarHeight - App.tabBarHeight)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = R.color.windowBgColor()
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Content")
        view.isPagingEnabled = true
        view.alwaysBounceVertical = false
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var segmentControl: DQSegmentedControl = {
        let titles = categories
        let segment = DQSegmentedControl(titles)
        segment.backgroundColor = .clear
        segment.selectedSegmentIndex = segmentSelectedIndex
        segment.titleTextAttributes = [.foregroundColor: R.color.c_848fad()!, .font: UIFont.regularFont(ofSize: 16)]
        segment.selectedTitleTextAttributes = [.foregroundColor: R.color.b1e3c()!, .font: UIFont.mediumFont(ofSize: 16)]
        segment.selectionIndicatorColor = R.color.ff7828()!
        segment.selectionIndicatorHeight = 2
        segment.selectionIndicatorLocation = .down
        segment.selectionStyle = .textWidthStripe
        segment.segmentWidthStyle = .dynamic
        segment.segmentEdgeInset = UIEdgeInsets(top: 0, left: 20, bottom: 5, right: 0)
        segment.selectionIndicatorEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 24)
        segment.delegate = self
        return segment
    }()
    
    private lazy var segmentBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.e6e6e6()
        return view
    }()
    
    var bottomLineAlpha: CGFloat {
        get {
            return _bottomLineAlpha
        }
        set {
            _bottomLineAlpha = newValue
            if newValue < 0 {
                _bottomLineAlpha = 0
            } else if newValue > 1 {
                _bottomLineAlpha = 1
            }
            lineView.alpha = _bottomLineAlpha
        }
    }
    
    var _bottomLineAlpha: CGFloat = 0
    
    private var segmentSelectedIndex = 0
    private let controllers: [UIViewController]
    private let categories: [String]

    init(controllers:[UIViewController], categories: [String]) {
        self.controllers = controllers
        self.categories = categories
        super.init(nibName: nil, bundle: nil)
        segmentSelectedIndex = AppManager.shared.gender == .male ? 0 : 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showView(segmentSelectedIndex)
    }
}

extension CategoryGroupController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Content", for: indexPath)
        cell.contentView.removeAllSubviews()
        if let vc = controllers[indexPath.item] as? BookCategoryViewController {
            if indexPath.item == segmentSelectedIndex && !vc.isChild {
                vc.loadData()
                vc.isChild = true
            }
            cell.contentView.addSubview(vc.view)
            vc.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
        return cell
    }
    
}

extension CategoryGroupController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.width
        let index = Int(scrollView.contentOffset.x / width)
        if let vc = controllers[index] as? BookCategoryViewController {
            if !vc.isChild {
                vc.loadData()
                vc.isChild = true
            }
        }
        segmentControl.setSelectedSegment(index, animated: true)
    }
}

extension CategoryGroupController: DQSegmentedControlDelegate {
    func segmentControl(_ control: DQSegmentedControl, didSelectedAt index: Int) {
        contentView.scrollToItem(at: IndexPath(item: index, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: true)
        delay(0.2) {
            if let vc = self.controllers[index] as? BookCategoryViewController {
                if !vc.isChild {
                    vc.loadData()
                    vc.isChild = true
                }
            }
        }
    }
}

private extension CategoryGroupController {
    func setup() {
        view.addSubview(segmentBgView)
        segmentBgView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(App.naviBarHeight)
        }
        segmentBgView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(App.lineHeight)
        }
        segmentBgView.addSubview(segmentControl)
        segmentControl.snp.makeConstraints { make in
            make.bottom.equalTo(lineView.snp.top)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(kSegmentHeight - App.lineHeight)
        }
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(segmentBgView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        controllers.forEach{ addChild($0) }
    }
    
    func showView(_ selectedIndex: Int) {
        if selectedIndex != 0 {
            contentView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: false)
        }
    }
    
    func loadData(_ selectedIndex: Int) {
        if selectedIndex != 0 {
            if let vc = controllers[selectedIndex] as? BookCategoryViewController {
                if !vc.isChild {
                    vc.loadData()
                    vc.isChild = true
                }
            }
        }
    }
}

