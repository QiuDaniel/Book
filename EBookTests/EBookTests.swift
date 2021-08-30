//
//  EBookTests.swift
//  EBookTests
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import XCTest
@testable import EBook
@testable import RxSwift

class EBookTests: XCTestCase {

    let service = BookCityService()
    let disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAppConfig() {
        let expect = expectation(description: "EBook App Config")
        let service = InitService()
        service.getAppConfigs(device: UIDevice.current.uniqueID).subscribe(onNext: { config in
            printLog("BookCity:\(config)")
            XCTAssert(true)
            expect.fulfill()
        }).disposed(by: disposeBag)
        waitForExpectations(timeout: 10)
        
    }

    func testBookCity() {
        let expect = expectation(description: "Get BookCity")
        
        service.getBookCity(device: "90be4c1a6604457598bd94043e93998c").subscribe(onNext: { bookCity in
            printLog("BookCity:\(bookCity)")
            XCTAssert(true)
            expect.fulfill()
        }).disposed(by: disposeBag)
        waitForExpectations(timeout: 10)
    }
    
    func testBookCityCate() {
        let expect = expectation(description: "Get BookCity")
        service.getBookCityCate(staticPath: "http://statics.rungean.com/static/book/index/58/1/169.json").subscribe(onNext: { books in
            printLog("Books:\(books)")
            XCTAssert(true)
            expect.fulfill()
        }).disposed(by: disposeBag)
        waitForExpectations(timeout: 10)
    }
    
    func testBookCityBanner() {
        let expect = expectation(description: "Get BookCity")
        service.getBookCityBanner(staticPath: "http://statics.rungean.com/static/banner/46/1/all.json").subscribe(onNext: { banners in
            printLog("Books:\(banners)")
            XCTAssert(true)
            expect.fulfill()
        }).disposed(by: disposeBag)
        waitForExpectations(timeout: 10)
    }
    
    func testBookSearch() {
        let expect = expectation(description: "Get BookCity")
        let searchService = NovelSearchService()
        searchService.searchNovel(withKeyword: "神奇", pageIndex: 1, pageSize: 20, reader: .male).subscribe(onNext: { result in
            printLog("Books:\(result)")
            XCTAssert(true)
            expect.fulfill()
        }).disposed(by: disposeBag)
        waitForExpectations(timeout: 10)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
