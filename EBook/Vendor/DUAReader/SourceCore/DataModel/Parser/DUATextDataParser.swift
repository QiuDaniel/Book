//
//  DUATextDataParser.swift
//  DUAReader
//
//  Created by mengminduan on 2017/12/26.
//  Copyright © 2017年 nothot. All rights reserved.
//

import UIKit
import DTCoreText

class DUATextDataParser: DUADataParser {

    override func parseChapterFromBook(path: String, title: String? = nil, completeHandler: @escaping (Array<String>, Array<DUAChapterModel>) -> Void) {
        let url = URL(fileURLWithPath: path)
        var content = try! String(contentsOf: url, encoding: String.Encoding.utf8)
        content = DUAUtils.formatterHTMLString(content)!
        var models = Array<DUAChapterModel>()
        var titles = Array<String>()
        DispatchQueue.global().async {
            let document = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
            let newPath: NSString = path as NSString
            let fileName = newPath.lastPathComponent.split(separator: ".").first            
            let bookPath = document! + "/\(String(fileName!))"
            if !FileManager.default.fileExists(atPath: bookPath) {
                try? FileManager.default.createDirectory(atPath: bookPath, withIntermediateDirectories: true, attributes: nil)
            }
            
            let results = self.doTitleMatchWith(content: content)
            if results.count == 0 {
                let model = DUAChapterModel()
                model.chapterIndex = 0
                model.path = path
                model.title = title
                completeHandler([], [model])
            } else {
                var endIndex = content.startIndex
                for (index, result) in results.enumerated() {
                    let startIndex = content.index(content.startIndex, offsetBy: result.range.location)
                    endIndex = content.index(startIndex, offsetBy: result.range.length)
                    let currentTitle = String(content[startIndex...endIndex])
                    titles.append(currentTitle)
                    let chapterPath = bookPath + "/chapter" + String(index + 1) + ".txt"
                    let model = DUAChapterModel()
                    model.chapterIndex = index + 1
                    model.title = currentTitle
                    model.path = chapterPath
                    models.append(model)
                    
                    if FileManager.default.fileExists(atPath: chapterPath) {
                        continue
                    }
                    var endLoaction = 0
                    if index == results.count - 1 {
                        endLoaction = content.count - 1
                    }else {
                        endLoaction = results[index + 1].range.location - 1
                    }
                    let startLocation = content.index(content.startIndex, offsetBy: result.range.location)
                    let subString = String(content[startLocation...content.index(content.startIndex, offsetBy: endLoaction)])
                    try! subString.write(toFile: chapterPath, atomically: true, encoding: String.Encoding.utf8)
                    
                }
                DispatchQueue.main.async {
                    completeHandler(titles, models)
                }
            }
        }
    }
    
    override func attributedStringFromChapterModel(chapter: DUAChapterModel, config: DUAConfiguration) -> NSAttributedString? {
        guard let path = chapter.path else { return nil }
        let tmpUrl = URL(fileURLWithPath: path)
        #warning("这里会奔溃")
//        let tmpUrl = URL(fileURLWithPath: chapter.path!)
        var tmpString = try? String(contentsOf: tmpUrl, encoding: String.Encoding.utf8)
        tmpString = DUAUtils.formatterHTMLString(tmpString)
        if tmpString == nil {
            return nil
        }
        let textString: String = tmpString!
        var titleString = chapter.title != nil ? chapter.title! : ""
        let results = self.doTitleMatchWith(content: textString)
        var titleRange = NSRange(location: 0, length: 0)
        if results.count != 0 {
            titleRange = results[0].range
        }
        var contentString = textString
        if titleRange.length > 1 {
            let startLocation = textString.index(textString.startIndex, offsetBy: titleRange.location)
            let endLocation = textString.index(startLocation, offsetBy: titleRange.length - 1)
            titleString = String(textString[startLocation...endLocation])
            contentString = String(textString[textString.index(after: endLocation)...textString.index(before: textString.endIndex)])
        }
        
        let paraString = self.formatChapterString(contentString: contentString)

        let paragraphStyleTitle = NSMutableParagraphStyle()
        paragraphStyleTitle.alignment = NSTextAlignment.center
        let dictTitle: [NSAttributedString.Key: Any] = [.font:UIFont.boldSystemFont(ofSize: 19),
                                                  .paragraphStyle:paragraphStyleTitle, .foregroundColor:config.titleColor]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.justified
        paragraphStyle.lineHeightMultiple = config.lineHeightMutiplier
        let font = UIFont(name: config.fontName, size: config.fontSize)
        let dict: [NSAttributedString.Key: Any] = [.font:font!,
                                                        .paragraphStyle:paragraphStyle,
                                                        .foregroundColor:config.textColor]
        
        let newTitle = "\n" + titleString + "\n\n"
        let attrString = NSMutableAttributedString(string: newTitle, attributes: dictTitle)
        let content = NSMutableAttributedString(string: paraString, attributes: dict)
        attrString.append(content)
        
        return attrString
    }
    
    
    func formatChapterString(contentString: String) -> String {
        let paragraphArray = contentString.split(separator: "\n")
        var newParagraphString: String = ""
        for (index, paragraph) in paragraphArray.enumerated() {
            let string0 = paragraph.replacingOccurrences(of: " ", with: "")
            let string1 = string0.replacingOccurrences(of: "\t", with: "")
            var newParagraph = string1.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if newParagraph.count != 0 {
                newParagraph = "\t" + newParagraph
                if index != paragraphArray.count - 1 {
                    newParagraph = newParagraph + "\n"
                }
                newParagraphString.append(String(newParagraph))
            }
        }
        return newParagraphString
    }
    
    func doTitleMatchWith(content: String) -> [NSTextCheckingResult] {
        let pattern = "第[ ]*[0-9一二三四五六七八九十百千]*[ ]*[章回].*"
        let regExp = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        let results = regExp.matches(in: content, options: .reportCompletion, range: NSMakeRange(0, content.count))
        return results
    }

    
}
