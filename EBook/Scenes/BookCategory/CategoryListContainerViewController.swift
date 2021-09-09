//
//  CategoryListContainerViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/9.
//

import UIKit

class CategoryListContainerViewController: BaseViewController {

    private var dispalyer: CategoryListGroupController?
    private let styles: [CategoryStyle] = [.hot, .new, .praise, .finish]
    private let styleNames: [CategoryStyle: String] = [.hot: "热门", .praise: "好评", .new: "新书", .finish: "完结"]
    private let category: BookCategory
    
    init(category: BookCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    func setup() {
        navigationBar.title = category.name
        let categories = styles.map { styleNames[$0]! }
        let controllers: [UIViewController] = styles.map { style in
            var vc = CategoryListViewController()
            vc.bind(to: CategoryListViewModel(categoryStyle: style, category: category))
            return vc
        }
        if dispalyer == nil {
            dispalyer = CategoryListGroupController(controllers: controllers, categories: categories)
            dispalyer?.willMove(toParent: nil)
            addChild(dispalyer!)
            dispalyer?.didMove(toParent: self)
            view.insertSubview(dispalyer!.view, belowSubview: navigationBar)
            dispalyer?.view.snp.makeConstraints{ $0.edges.equalToSuperview() }
        }
    }

}
