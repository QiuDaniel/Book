//
//  MJRefresh+Rx.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/20.
//

import Foundation
import RxCocoa
import RxSwift

public enum MJRefreshHeaderRxStatus {
    case `default`
    case refresh
    case end
}

public enum MJRefreshFooterRxStatus {
    case more
    case noMoreData
    case end
}

extension Reactive where Base: MJRefreshComponent {
    
    public var isRefreshing: Binder<Bool> {
        return Binder(base) { refreshControl, refresh in
            if refresh {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }
    
    public var refreshStatus: Binder<MJRefreshHeaderRxStatus> {
        return Binder(base) { refreshControl, status in
            switch status {
            case .refresh:
                refreshControl.beginRefreshing()
            case .end:
                refreshControl.endRefreshing()
            default:
                break
            }
        }
    }
}

extension Reactive where Base: MJRefreshFooter {
    public var isNoMoreData: Binder<Bool> {
        return Binder(base) { refreshFooter, noMoreData in
            if noMoreData {
                refreshFooter.endRefreshingWithNoMoreData()
            } else {
                refreshFooter.resetNoMoreData()
            }
        }
    }
    
    public var refreshStatus: Binder<MJRefreshFooterRxStatus> {
        return Binder(base) { footerControl, status in
            switch status {
            case .more:
                footerControl.beginRefreshing()
            case .noMoreData:
                footerControl.endRefreshingWithNoMoreData()
            case .end:
                footerControl.endRefreshing()
            }
        }
    }
}
