//
//  BookIntroViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/6.
//

import Foundation

protocol BookIntroViewModelOutput {

}

protocol BookIntroViewModelType {
    var output: BookIntroViewModelOutput { get }
}

class BookIntroViewModel: BookIntroViewModelType, BookIntroViewModelOutput {
    var output: BookIntroViewModelOutput { return self }
    
    private let book: SearchBook
    
    init(book: SearchBook) {
        self.book = book
    }
}
