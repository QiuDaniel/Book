//
//  BookCategoryContainerController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import UIKit

class BookCategoryContainerController: BaseViewController {
    
    private var dispalyer: CategoryGroupController?
    private let genders: [ReaderType] = [.male, .female]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
