//
//  String.swift
//  EBook
//
//  Created by Daniel on 2021/9/15.
//

import Foundation

extension String {
    //https://stackoverflow.com/questions/47281756/xcode-9-1-swift-4-unable-to-compile-with-nsdocumenttypedocumentattribute-if-if
    var htmlToString:String {
        return try! NSAttributedString(data: data(using: .utf8)!, options: [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string
    }
}
