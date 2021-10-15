//
//  Date.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import Foundation

extension Date {
    static func timeAgoSinceDate(_ date: Date, numericDates: Bool = true) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([
            NSCalendar.Unit.minute,
            NSCalendar.Unit.hour,
            NSCalendar.Unit.day,
            NSCalendar.Unit.weekOfYear,
            NSCalendar.Unit.month,
            NSCalendar.Unit.year,
            NSCalendar.Unit.second
            ], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) 年前"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 年前"
            } else {
                return "去年"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) 月前"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 个月前"
            } else {
                return "上个月"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) 周前"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 周前"
            } else {
                return "上一周"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) 天前"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 天前"
            } else {
                return "昨天"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) 小时前"
        } else if (components.hour! >= 1){
            return "1 小时前"
        } else if (components.minute! >= 2) {
            return "\(components.minute!) 分钟前"
        } else if (components.minute! >= 1){
            return "1 分钟前"
        } else if (components.second! >= 3) {
            return "\(components.second!) 秒前"
        } else {
            return "刚刚"
        }
    }
    
    static func bookHistoryTimeSinceDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter.dateFormatterForCurrentThread()
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([
            .minute, .hour, .day, .weekOfYear, .month, .year, .second], from: earliest, to: latest, options: NSCalendar.Options())
        let earlierstComp = (calendar as NSCalendar).components([.day, .month, .year], from: earliest)
        let latestComp = (calendar as NSCalendar).components([.day, .month, .year], from: latest)
        
        if earlierstComp.year != latestComp.year {
            dateFormatter.dateFormat = "yyyy年MM月dd日 MM:ss"
            return dateFormatter.string(from: date)
        } else {
            if earlierstComp.month != latestComp.month {
                dateFormatter.dateFormat = "MM月dd日 MM:ss"
                return dateFormatter.string(from: date)
            } else {
                if earlierstComp.day == latestComp.day {
                    if (components.hour! >= 1) {
                        dateFormatter.dateFormat = "MM:ss"
                        let str = dateFormatter.string(from: date)
                        return "今天 \(str)"
                    } else if (components.minute! >= 2) {
                        return "\(components.minute!) 分钟前"
                    } else if (components.minute! >= 1) {
                        return "1分钟前"
                    } else if (components.second! >= 3) {
                        return "\(components.second!) 秒前"
                    } else {
                        return "刚刚"
                    }
                } else {
                    if components.day! < 1 {
                        dateFormatter.dateFormat = "HH:MM"
                        let str = dateFormatter.string(from: date)
                        return "昨天 \(str)"
                    } else if components.day! >= 1 && components.day! < 2 {
                        dateFormatter.dateFormat = "HH:MM"
                        let str = dateFormatter.string(from: date)
                        return "前天 \(str)"
                    } else {
                        dateFormatter.dateFormat = "MM月dd日 HH:MM"
                        return dateFormatter.string(from: date)
                    }
                    
                }
            }
        }
    }
    
    static func localDateFormatAnyDate(_ anyDate: Date) -> Date {
        let sourceTimeZone = TimeZone(abbreviation: "UTC")
        let desTimeZone = TimeZone.current
        let sourceGMOffset = sourceTimeZone!.secondsFromGMT(for: anyDate)
        let destinationGMTOffset = desTimeZone.secondsFromGMT(for: anyDate)
        let interval = destinationGMTOffset - sourceGMOffset
        let date = Date(timeInterval: TimeInterval(interval), since: anyDate)
        return date
    }
}
