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
    case bookCityPath(String)
    case bookSearch(String, String, Int, Int, String, Int)
    case bookHeatPath(String)
}

extension Network: TargetType {
    
    var baseURL: URL {
        var urlString = Constants.host.value
        switch self {
        case .bookCityPath(let path), .bookHeatPath(let path):
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
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .appConfig, .bookCity, .bookCityPath, .bookSearch, .bookHeatPath:
            return .get
        }
    }
    
    var task: Task {
        let encoding = URLEncoding.default
        switch self {
        case .bookCityPath, .bookHeatPath:
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
