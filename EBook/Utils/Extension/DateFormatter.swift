//
//  DateFormatter.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/11.
//

import Foundation

extension DateFormatter {
    
    static func dateFormatterForCurrentThread() -> DateFormatter {
        let currentThreadDic = Thread.current.threadDictionary
        var dateFormatter = currentThreadDic.object(forKey: NSString("com.daniel.ebook-dateformatter")) as? DateFormatter
        if dateFormatter == nil {
            dateFormatter = DateFormatter()
            currentThreadDic.setObject(dateFormatter!, forKey: NSString("com.daniel.ebook-dateformatter"))
        }
        return dateFormatter!
    }
    
}
