//
//  BookCategoryContainerController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import UIKit
import RxSwift

class BookCategoryContainerController: BaseViewController {
    
    private var dispalyer: CategoryGroupController?
    private let genders: [ReaderType] = [.male, .female]
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            userStyleChanged(traitCollection)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        NotificationCenter.default.rx.notification(SPNotification.genderChanged.name).subscribe(onNext: { [weak self]_ in
            guard let `self` = self else { return }
            self.dispalyer?.segmentControl.setSelectedSegment(AppManager.shared.gender == .male ? 0 : 1, animated: false)
        }).disposed(by: rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
    }
    
}

private extension BookCategoryContainerController {
    func setup() {
        navigationBar.isHidden = true
        let categories = genders.map{ $0 == .male ? "男生" : "女生" }
        let controllers: [UIViewController] = genders.map { gender in
            var vc = BookCategoryViewController()
            vc.bind(to: BookCategoryViewModel(gender: gender))
            return vc
        }
        if dispalyer == nil {
            dispalyer = CategoryGroupController(controllers: controllers, categories: categories)
            dispalyer?.willMove(toParent: nil)
            addChild(dispalyer!)
            dispalyer?.didMove(toParent: self)
            view.addSubview(dispalyer!.view)
            dispalyer?.view.snp.makeConstraints{ $0.edges.equalToSuperview() }
            userStyleChanged(traitCollection)
        }
    }
    
    func userStyleChanged(_ traitCollection: UITraitCollection) {
        switch UserinterfaceManager.shared.interfaceStyle {
        case .system:
            switch traitCollection.userInterfaceStyle {
            case .dark:
                dispalyer?.segmentControl.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#A1A1A1")!, .font: UIFont.regularFont(ofSize: 16)]
                dispalyer?.segmentControl.selectedTitleTextAttributes = [.foregroundColor: UIColor(hexString: "#E0E0E0")!, .font: UIFont.mediumFont(ofSize: 16)]
                dispalyer?.segmentControl.selectionIndicatorColor = UIColor(hexString: "#D27239")!
            default:
                dispalyer?.segmentControl.titleTextAttributes = [.foregroundColor:UIColor(hexString: "#848FAD")!, .font: UIFont.regularFont(ofSize: 16)]
                dispalyer?.segmentControl.selectedTitleTextAttributes = [.foregroundColor: UIColor(hexString: "#0B1E3C")!, .font: UIFont.mediumFont(ofSize: 16)]
                dispalyer?.segmentControl.selectionIndicatorColor = UIColor(hexString: "#FF7828")!
            }
            break
        case .light:
            dispalyer?.segmentControl.titleTextAttributes = [.foregroundColor:UIColor(hexString: "#848FAD")!, .font: UIFont.regularFont(ofSize: 16)]
            dispalyer?.segmentControl.selectedTitleTextAttributes = [.foregroundColor: UIColor(hexString: "#0B1E3C")!, .font: UIFont.mediumFont(ofSize: 16)]
            dispalyer?.segmentControl.selectionIndicatorColor = UIColor(hexString: "#FF7828")!
        case .dark:
            dispalyer?.segmentControl.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#A1A1A1")!, .font: UIFont.regularFont(ofSize: 16)]
            dispalyer?.segmentControl.selectedTitleTextAttributes = [.foregroundColor: UIColor(hexString: "#E0E0E0")!, .font: UIFont.mediumFont(ofSize: 16)]
            dispalyer?.segmentControl.selectionIndicatorColor = UIColor(hexString: "#D27239")!
        }
    }
}
