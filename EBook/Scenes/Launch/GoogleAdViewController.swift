//
//  GoogleAdViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/13.
//

import UIKit
import GoogleMobileAds
import RxSwift

class GoogleAdViewController: BaseViewController, BindableType {
    
    var viewModel: GoogleAdViewModelType!
    private let openAd: GADAppOpenAd
    private var time: Int = 3
    
    private weak var countdownBtn: UIButton!
    
    init(withOpenAd openAd: GADAppOpenAd) {
        self.openAd = openAd
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openAd.present(fromRootViewController: self)
    }
    
    func bindViewModel() {}

}

// MARK: - GADFullScreenContentDelegate

extension GoogleAdViewController: GADFullScreenContentDelegate {
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        countdownBtn.isHidden = false
        SceneCoordinator.shared.window.bringSubviewToFront(countdownBtn)
        startCountdown()
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        viewModel.input.go2Main()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        viewModel.input.go2Main()
    }
    
}

private extension GoogleAdViewController {
    
    func setup() {
        openAd.fullScreenContentDelegate = self
        navigationBar.isHidden = true
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .black.withAlphaComponent(0.2)
        SceneCoordinator.shared.window.addSubview(btn)
        btn.cornerRadius = 12.5
        btn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 59, height: 25))
        }
        btn.titleLabel?.font = .regularFont(ofSize: 13)
        btn.setTitle("3s", for: .normal)
        btn.isHidden = true
        countdownBtn = btn
    }
    
    func startCountdown() {
        Observable<Int>.timer(.seconds(1), period: .seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
            time -= 1
            countdownBtn.setTitle("\(time)s", for: .normal)
            if time <= 0 {
                viewModel.input.go2Main()
            }
        }).disposed(by: rx.disposeBag)
    }
}

