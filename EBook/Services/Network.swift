//
//  Network.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation
import Moya
import Alamofire

enum Network {
    case appConfig(String, String)
    case bookCity(String, String)
    case bookPath(String)
    case bookSearch(String, String, Int, Int, String, Int)
    case bookHeatPath(String)
    case downloadAsset(String)
    case checkBookUpdate(String, String, String)
    case foundBookCount(String, String)
    case findbook(String, String?, String, String)
}

extension Network: TargetType {
    
    var baseURL: URL {
        var urlString = Constants.host.value
        switch self {
        case .bookPath(let path), .bookHeatPath(let path), .downloadAsset(let path):
            urlString = path
        default:
            break
        }
        guard let url = URL(string: urlString) else {
            fatalError("URL Failed:\(urlString)")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .appConfig:
            return "/api/v1/config"
        case .bookCity:
            return "/api/v1/getbookcolumn"
        case .bookSearch:
            return "/api/v1/novelsearch"
        case .checkBookUpdate:
            return "/api/v1/checkbookupdate"
        case .foundBookCount:
            return "/api/v1/findbook/count"
        case .findbook:
            return "/api/v1/findbook"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .appConfig, .bookCity, .bookPath, .bookSearch, .bookHeatPath, .downloadAsset, .checkBookUpdate, .foundBookCount:
            return .get
        case .findbook:
            return .post
        }
    }
    
    var task: Task {
        let encoding = URLEncoding.default
        switch self {
        case .bookPath, .bookHeatPath:
            return .requestPlain
        case let .bookCity(device, pkgName), let .appConfig(device, pkgName):
            var params: [String: Any] = [:]
            params["device"] = device
            params["pkgName"] = pkgName
            return .requestParameters(parameters: params, encoding: encoding)
        case let .bookSearch(content, device, pageIndex, pageSize, pkgName, type):
            var params: [String: Any] = [:]
            params["content"] = content
            params["device"] = device
            params["pageIndex"] = pageIndex
            params["pageSize"] = pageSize
            params["pkgName"] = pkgName
            params["type"] = type
            return .requestParameters(parameters: params, encoding: encoding)
        case let .checkBookUpdate(bookIds, device, pkgName):
            var params: [String: Any] = [:]
            params["bookIds"] = bookIds
            params["device"] = device
            params["pkgName"] = pkgName
            return .requestParameters(parameters: params, encoding: encoding)
        case let .foundBookCount(device, pkgName):
            var params: [String: Any] = [:]
            params["device"] = device
            params["pkgName"] = pkgName
            return .requestParameters(parameters: params, encoding: encoding)
        case let .findbook(device, keyword, pkgName, bookName):
            var params: [String: Any] = [:]
            params["device"] = device
            params["pkgName"] = pkgName
            if !isEmpty(keyword) {
                params["keyword"] = keyword
            }
            params["bookName"] = bookName
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .downloadAsset:
            return .downloadDestination(DefaultDownloadDestination)
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
    var headers: [String : String]? {
        var localParams:[String: String] = [:]
//        localParams["versionNumber"] = "3"
        localParams["appId"] = App.appId
//        localParams["channelId"] = "41"
//        localParams["device"] = ""
        return localParams
    }
}

//定义下载的DownloadDestination（不改变文件名，同名文件不会覆盖）
private let DefaultDownloadDestination: DownloadDestination = { temporaryURL, response in
    return (DefaultDownloadDir.appendingPathComponent(response.suggestedFilename!), [.removePreviousFile])
}
 
//默认下载保存地址（用户文档目录）
let DefaultDownloadDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory,
                                                 in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()
