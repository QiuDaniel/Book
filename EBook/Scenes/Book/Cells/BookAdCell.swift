//
//  BookAdCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/14.
//

import UIKit
import GoogleMobileAds

class BookAdCell: UICollectionViewCell {
    
    private var bannerView: GADBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(App.screenWidth)
        bannerView = GADBannerView(adSize: adSize)
        bannerView.adUnitID = VendorKey.bookIntroAd.name
        bannerView.rootViewController = SceneCoordinator.shared.currentController
        bannerView.load(GADRequest())
        contentView.addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
