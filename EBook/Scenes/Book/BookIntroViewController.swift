//
//  BookIntroViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/6.
//

import UIKit
import RxKingfisher

class BookIntroViewController: BaseViewController, BindableType {

    var viewModel: BookIntroViewModelType!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false;
        view.showsHorizontalScrollIndicator = false;
        view.backgroundColor = .clear
        adjustScrollView(view, with: self)
        return view
    }()
    
    private weak var blurImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.cover ~> blurImageView!.kf.rx.image()
        ]
    }
    

}

private extension BookIntroViewController {
    
    func setup() {
        navigationBar.backgroundView.alpha = 0
        navigationBar.bottomBorderColor = .clear
        view.insertSubview(collectionView, belowSubview: navigationBar)
        collectionView.snp.makeConstraints{ $0.edges.equalToSuperview() }
        createFrostBackground(belowSubView: collectionView)
    }
    
    func createFrostBackground (belowSubView subView:UIView) {
        let w = self.view.frame.width
        let h = self.view.frame.height
        let blurImageView = UIImageView(frame: CGRect(x: -w / 2, y: -h / 2, width: w * 2, height: h * 2)) //模糊背景是界面的4倍大小
        blurImageView.contentMode = .scaleAspectFill
//        blurImageView.image = img
        //创建毛玻璃效果层
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = blurImageView.frame
        //添加毛玻璃效果层
        blurImageView.addSubview(visualEffectView)
        self.view.insertSubview(blurImageView, belowSubview: subView)
        self.blurImageView = blurImageView
    }
}
