//
//  LaunchViewController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/24.
//

import UIKit
import GoogleMobileAds

class LaunchViewController: UIViewController, BindableType {
    
    var viewModel: LaunchViewModel!
    
#if DEBUG
    deinit {
        printLog("====qd====dealloc===\(self)")
    }
#endif
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        rx.disposeBag ~ [
            output.initInfo.subscribe(onNext: { [weak self] (config, bookCity) in
                guard let `self` = self else { return }
                self.handleConfig(config)
                AppManager.shared.saveBookCity(bookCity)
                GADAppOpenAd.load(withAdUnitID: VendorKey.openAd.name, request: GADRequest(), orientation: .portrait) { appOpenAd, error in
                    if error != nil {
                        printLog("Failed to load app open ad: \(error!)")
                        input.go2Main()
                        return
                    }
                    input.go2Ads(withOpenAd: appOpenAd)
                }
            })
        ]
    }

}

private extension LaunchViewController {
    func handleConfig(_ config: AppConfig) {
        AppStorage.shared.setObject(config.staticDomain, forKey: .staticDomain)
        AppStorage.shared.synchronous()
    }
}
