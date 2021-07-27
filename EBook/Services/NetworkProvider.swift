//
//  NetworkProvider.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation
import Moya

final class NetworkProvider: MoyaProvider<Network> {
    #if DEBUG
       private static let plugins: [PluginType] = [NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions:.verbose)), NetworkErrorPlugin()]
    #else
        private static let plugins: [PluginType] = [NetworkErrorPlugin()]
    #endif
        
        static let shared: NetworkProvider = {
            return NetworkProvider(session: NetworkSession.shared, plugins: plugins)
        }()
}
