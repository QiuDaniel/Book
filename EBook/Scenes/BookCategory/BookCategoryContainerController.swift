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
        }
    }
}
