//
//  ChapterDetailViewController.swift
//  EBook
//
//  Created by Daniel on 2021/9/13.
//

import UIKit

class ChapterDetailViewController: BaseViewController, BindableType {
    
    var viewModel: ChapterDetailViewModelType!
    
    private var reader: DUAReader!
    
    private lazy var loadingHud: MBProgressHUD = {
        let hud = MBProgressHUD.showLoadingHud(at: view)
        return hud
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.loading ~> loadingHud.rx.animation,
            output.chapterList.subscribe(onNext: { [weak self] chapters, idx in
                guard let `self` = self else { return }
                self.reader.readWith(chapters: chapters, selectedChapterIndex:idx)
            })
        ]
    }


}

extension ChapterDetailViewController: DUAReaderDelegate {
    
    func readerDidClickSettingFrame(reader: DUAReader) {
        
    }
    
    func reader(reader: DUAReader, readerStateChanged state: DUAReaderState) {
        
    }
    
    func reader(reader: DUAReader, readerProgressUpdated curChapter: Int, curPage: Int, totalPages: Int) {
        
    }
    
    func reader(reader: DUAReader, chapterTitles: [String]) {
        
    }
}


private extension ChapterDetailViewController {
    func setup() {
        navigationBar.isHidden = true
        reader = DUAReader()
        let configuration = DUAConfiguration()
        configuration.backgroundImage = R.color.windowBgColor()?.toImage()
        configuration.textColor = R.color.b1e3c()!
        reader.config = configuration
        reader.delegate = self
        view.addSubview(reader.view)
        reader.view.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))  }
    }
}
