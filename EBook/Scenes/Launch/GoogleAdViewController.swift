//
//  GoogleAdViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/13.
//

import UIKit
import GoogleMobileAds

class GoogleAdViewController: BaseViewController, BindableType {
    
    var viewModel: GoogleAdViewModelType!
    
    private var adLoader: GADAdLoader!
    var nativeAdView: GADNativeAdView!
    private weak var imageView: UIImageView!
    private weak var adIconImageView: UIImageView!
    private weak var closeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupADLoader()
    }
    
    func bindViewModel() {
//        let output = viewModel.output
//        rx.disposeBag ~ [
//            output.adImage ~> imageView.kf.rx.image(),
//            output.iconImage ~> adIconImageView.kf.rx.image(),
//        ]
    }

}

extension GoogleAdViewController {
    
    func setup() {
        navigationBar.isHidden = true
        let adView = GADNativeAdView()
        nativeAdView = adView
//        let imageView = UIImageView()
//        view.addSubview(imageView)
//        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
//        self.imageView = imageView
//        let iconImageView = UIImageView()
//        view.addSubview(iconImageView)
//        iconImageView.snp.makeConstraints { make in
//            make.leading.top.equalToSuperview()
//        }
//        adIconImageView = iconImageView
    }
    
    func setupADLoader() {
        adLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511", rootViewController: self, adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
}

extension GoogleAdViewController: GADAdLoaderDelegate, GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        viewModel.input.loadNativeAd(nativeAd)
        nativeAd.delegate = self
        
    }
    
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        printLog("ad load error")
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        printLog("ad load success")
    }
    
    
}

extension GoogleAdViewController: GADNativeAdDelegate {
    
}
