//
//  BookCityBannerCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import UIKit
import RxFSPagerView
import RxKingfisher
import Kingfisher
import RxSwift

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        output.imageRes.asDriver(onErrorJustReturn: []).drive(pagerView.rx.items(cellIdentifier: "Image")){ [weak self]
            _, item, cell in
            guard let `self` = self else { return }
            cell.imageView?.kf.rx.setImage(with: item).asObservable().subscribe(onNext: {_ in }).disposed(by: self.rx.disposeBag)
        }.disposed(by: rx.disposeBag)
        
        rx.disposeBag ~ [
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
