//
//  YNCacheProviderTests.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 2016-10-21.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import XCTest
@testable import YNImageAsync

class YNCacheProviderTests: XCTestCase {
    
    var cacheProvider : YNCacheProvider? = nil
    let imageNames = ["mountains.jpg", "parrot-indian.jpg", "parrot.jpg", "saint-petersburg.jpg", "snow.jpg", "tiger.jpg"]

    override func setUp() {
        super.setUp()
        cacheProvider = YNCacheProvider(configuration: YNCacheConfiguration(options: [.memory, .disk], memoryCacheLimit: 30 * 1024 * 1024)) // enough to store all images
        for img in imageNames {
            if let image = UIImage(named: img) {
                let imageData = UIImageJPEGRepresentation(image, 0.9)
                cacheProvider?.cacheData(key: img, data: imageData!)
            }
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK - tests
    
    func testCacheForKey() {
        for image in imageNames {
            let imageExpectation = expectation(description: image)
            guard let provider = cacheProvider else {
                XCTFail("Failed to get cache provider")
                return
            }
            _ = provider.cacheForKey(image, completion: { (data) in
                imageExpectation.fulfill()
            })
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print(error)
        }
    }
    
    func testMemoryCacheForKey() {

    }
    
    func testDiskCacheForKey() {

    }
    
    func testCacheData() {

    }
    
    func testCacheDataToMemory() {

    }
    
    func testCacheDataToDisk() {

    }
    
    func testCleanMemoryCache() {
    }
    
    func testClearMemoryCache() {
    }
    
    func testDiskCacheSize() {

    }
    
    func testMemoryCacheSize() {

    }
    
    func testClearDiskCache() {

    }
    
    func testClearCache() {

    }
    
    func testCacheFolderFiles() {

    }
    
    func testFilterCacheWithArray() {

    }
    
    func testCacheDirectory() {

    }
    
    func testCachePath() {
    }
    
    func testFileInCacheDirectory() {
        
    }
    
    func testReadCache() {

    }
    
    func testSaveCache() {

    }
    
}
