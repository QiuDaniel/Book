//
//  FileUtils.swift
//  EBook
//
//  Created by Daniel on 2021/9/13.
//

import Foundation

struct FileUtils {
    
    @discardableResult
    static func copyFile(source: String, target: String) -> Bool {
        do {
            try FileManager.default.copyItem(atPath: source, toPath: target)
            printLog("Success to copy file")
            return true
        } catch {
            printLog("Faild to copy file")
            return false
        }
    }
    
    @discardableResult
    static func removeFile(source: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: source)
            printLog("Success to remove file")
            return true
        } catch {
            printLog("Failed to remove file")
            return false
        }
    }
    
    @discardableResult
    static func moveFile(source: String, target: String) -> Bool {
        if copyFile(source: source, target: target) {
            return removeFile(source: source)
        }
        return false
    }
    
    @discardableResult
    static func removeFolder(folderPath: String) -> Bool {
        guard let files = FileManager.default.subpaths(atPath: folderPath) else {
            printLog("this folder is not exist")
            return false
        }
        for file in files {
            if !removeFile(source: folderPath + "/\(file)") {
                return false
            }
        }
        return true
    }
    
    static func listFolder(_ path: String) -> [Any]? {
        let contents = FileManager.default.enumerator(atPath: path)
        return contents?.allObjects
    }
    
    static func fileExists(atPath path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}
