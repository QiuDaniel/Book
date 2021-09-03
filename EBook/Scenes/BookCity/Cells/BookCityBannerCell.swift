//
//  BookCityBannerCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import UIKit
import RxKingfisher
import Kingfisher
import RxSwift
import RxDataSources

class BookCityBannerCell: UICollectionViewCell, BindableType {

    var viewModel: BookCityBannerCellViewModelType!
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            pagerView.delegate = self
            pagerView.isInfinite = true
            pagerView.cornerRadius = 8
            pagerView.masksToBounds = true
            pagerView.itemSize = CGSize(width: App.screenWidth - 16, height: 120)
            pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "Image")
        }
    }
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            pageControl.setFillColor(R.color.ff7828(), for: .selected)
            pageControl.setFillColor(.white, for: .normal)
        }
    }
    private var dataSource: RxFSPagerViewSectionedReloadDataSource<SectionModel<String, Resource>>!
    private var pagerViewDataSource: FSPagerViewSectionedDataSource<SectionModel<String, Resource>>.ConfigureCell {
        return { [weak self] _, pagerView, index, item in
            guard let `self` = self else { fatalError() }
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "Image", at: index)
            cell.imageView?.kf.rx.setImage(with: item).asObservable().observeOn(MainScheduler.instance).subscribe(onNext: {_ in }).disposed(by: self.rx.disposeBag)
            return cell
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = RxFSPagerViewSectionedReloadDataSource<SectionModel<String, Resource>>(configureCell: pagerViewDataSource)
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.sections ~> pagerView.rx.items(dataSource: dataSource),
            output.imageRes.map{ $0.count } ~> pageControl.rx.numberOfPages,
            output.imageRes.map{ $0.count > 1 ? 3 : 0 } ~> pagerView.rx.automaticSlidingInterval,
            output.imageRes.map{ $0.count > 1 } ~> pagerView.rx.isScrollEnabled,
            pagerView.rx.itemScrolled ~> pageControl.rx.currentPage,
        ]
    }

}

extension BookCityBannerCell: FSPagerViewDelegate {
    
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false
    }
}
