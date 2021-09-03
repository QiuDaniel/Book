//
//  FSPageView+Rx.swift
//  RabbitOptimization
//
//  Created by Daniel on 2019/8/27.
//  Copyright © 2019 Daniel. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: FSPagerView {
    func items<
        DataSource: RxFSPagerViewDataSourceType & FSPagerViewDataSource,
        O: ObservableType>
        (dataSource: DataSource)
        -> (_ source: O)
    -> Disposable where DataSource.Element == O.Element
    {
        base.dataSource = nil
        return { source in
            return source.subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource, retainDataSource: true) { [weak pagerView = self.base] (_: RxFSPagerViewDataSourceProxy, event) -> Void in
                guard let pagerView = pagerView else {
                    return
                }
                dataSource.pagerView(pagerView, observedEvent: event)
            }
        }
    }
}

public extension Reactive where Base: FSPagerView {
    
    var itemSelected: ControlEvent<Int> {
        let source = base.collectionView.rx.itemSelected.map {
            $0.item % self.base.numberOfSections
        }
        
        return ControlEvent(events: source)
    }
    
    var itemDeselected: ControlEvent<Int> {
        let source = base.collectionView.rx.itemDeselected.map {
            $0.item % self.base.numberOfSections
        }
        
        return ControlEvent(events: source)
    }
    
    func modelSelected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        return base.collectionView.rx.modelSelected(modelType)
    }
    
    var itemScrolled: ControlEvent<Int> {
        let source = base.collectionView.rx.didScroll.flatMap { _ -> Observable<Int> in
            guard self.base.numberOfItems > 0 else { return .never() }
            let currentIndex = lround(Double(self.base.scrollOffset)) % self.base.numberOfItems
            guard currentIndex != self.base.currentIndex else { return .never() }
            self.base.currentIndex = currentIndex
            return Observable.just(currentIndex)
        }
        
        return ControlEvent(events: source)
    }
    
    var automaticSlidingInterval: Binder<CGFloat> {
        return Binder(base) { view, interval in
            view.automaticSlidingInterval = interval
        }
    }
    
    var isScrollEnabled: Binder<Bool> {
        return Binder(base) { view, enable in
            view.isScrollEnabled = enable
        }
    }
}

public extension Reactive where Base: FSPagerView {
    
    func deselectItem(animated: Bool) -> Binder<Int> {
        return Binder(base) { this, item in
            this.collectionView.deselectItem(
                at: IndexPath(item: item, section: 0),
                animated: animated
            )
        }
    }
}

extension ObservableType {
    fileprivate func subscribeProxyDataSource<DelegateProxy: DelegateProxyType>(ofObject object: DelegateProxy.ParentObject, dataSource: DelegateProxy.Delegate, retainDataSource: Bool, binding: @escaping (DelegateProxy, Event<Element>) -> Void)
        -> Disposable
        where DelegateProxy.ParentObject: UIView
        , DelegateProxy.Delegate: AnyObject {
            let proxy = DelegateProxy.proxy(for: object)
            let unregisterDelegate = DelegateProxy.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)
            // this is needed to flush any delayed old state (https://github.com/RxSwiftCommunity/RxDataSources/pull/75)
            object.layoutIfNeeded()
            
            let subscription = self.asObservable()
                .observeOn(MainScheduler())
                .catchError { error in
                    bindingError(error)
                    return Observable.empty()
                }
                // source can never end, otherwise it would release the subscriber, and deallocate the data source
                .concat(Observable.never())
                .takeUntil(object.rx.deallocated)
                .subscribe { [weak object] (event: Event<Element>) in
                    
                    if let object = object {
                        assert(proxy === DelegateProxy.currentDelegate(for: object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(String(describing: DelegateProxy.currentDelegate(for: object)))")
                    }
                    
                    binding(proxy, event)
                    
                    switch event {
                    case .error(let error):
                        bindingError(error)
                        unregisterDelegate.dispose()
                    case .completed:
                        unregisterDelegate.dispose()
                    default:
                        break
                    }
            }
            
            return Disposables.create { [weak object] in
                subscription.dispose()
                object?.layoutIfNeeded()
                unregisterDelegate.dispose()
            }
    }
}

func bindingError(_ error: Swift.Error) {
    let error = "Binding error: \(error)"
    #if DEBUG
    rxFatalError(error)
    #else
    print(error)
    #endif
}

/// Swift does not implement abstract methods. This method is used as a runtime check to ensure that methods which intended to be abstract (i.e., they should be implemented in subclasses) are not called directly on the superclass.
func rxAbstractMethod(message: String = "Abstract method", file: StaticString = #file, line: UInt = #line) -> Swift.Never {
    rxFatalError(message, file: file, line: line)
}

func rxFatalError(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Swift.Never  {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage(), file: file, line: line)
}
