//
//  LRUCacheTests.swift
//  
//
//  Created by Yuri Nechaev on 20.07.2023.
//

import XCTest
@testable import YNImageAsync

class LRUCacheTests: XCTestCase {

    func testLRUCache() async {
        let cacheSizeLimit = 1000
        let cache = LRUCache<Int>(maxTotalSize: UInt64(cacheSizeLimit))

        // Store data in the cache
        let data1 = Data(repeating: 1, count: 500)
        let data2 = Data(repeating: 2, count: 200)
        let data3 = Data(repeating: 3, count: 300)
        let key1 = 1
        let key2 = 2
        let key3 = 3

        await cache.storeData(data1, for: key1)
        await cache.storeData(data2, for: key2)
        await cache.storeData(data3, for: key3)

        // Check if data can be loaded correctly
        let loadedData1 = await cache.loadData(for: key1)
        let loadedData2 = await cache.loadData(for: key2)
        let loadedData3 = await cache.loadData(for: key3)

        XCTAssertEqual(loadedData1, data1)
        XCTAssertEqual(loadedData2, data2)
        XCTAssertEqual(loadedData3, data3)

        // Check if the cache size is correct
        let expectedTotalSize = data1.count + data2.count + data3.count
        let size1 = await cache.size()
        XCTAssertEqual(size1, UInt64(expectedTotalSize))

        // Store a new data that exceeds the cache size limit
        let largeData = Data(repeating: 4, count: cacheSizeLimit + 100)
        let largeKey = 4

        await cache.storeData(largeData, for: largeKey)

        // Check if the large data was not stored in the cache due to its size
        let loadedLargeData = await cache.loadData(for: largeKey)
        XCTAssertNil(loadedLargeData)

        // Check if the cache size is still within the limit
        let size2 = await cache.size()
        XCTAssertLessThanOrEqual(size2, UInt64(cacheSizeLimit))
    }
    
    func testPerformanceLRUCache() async {
        let cacheSizeLimit: UInt64 = 100000  // Cache size limit of 100000 bytes
        let numberOfItems = 10000   // Number of data items to store in the cache
        
        let cache = LRUCache<Int>(maxTotalSize: cacheSizeLimit)
        
        // Generate random data items
        let randomDataItems = (0..<numberOfItems).map { _ in
            Data(repeating: UInt8.random(in: 0...255), count: Int.random(in: 1...1000))
        }
        
        let storeExpectation = XCTestExpectation(description: "Store Data")
        let loadExpectation = XCTestExpectation(description: "Load Data")
        
        // Measure the time taken to store the data items in the cache
        let storeStartTime = DispatchTime.now()
        for (index, data) in randomDataItems.enumerated() {
            let key = index
            await cache.storeData(data, for: key)
            
            if index == numberOfItems - 1 {
                storeExpectation.fulfill()
            }
        }
        
        await fulfillment(of: [storeExpectation], timeout: 30)
                
        let storeEndTime = DispatchTime.now()
        let storeTimeElapsed = Double(storeEndTime.uptimeNanoseconds - storeStartTime.uptimeNanoseconds) / 1_000_000_000.0
        print("Time taken to store \(numberOfItems) data items: \(storeTimeElapsed) seconds")
        
        // Measure the time taken to load the data items from the cache
        let loadStartTime = DispatchTime.now()
        for index in 0..<numberOfItems {
            let key = index
            _ = await cache.loadData(for: key)
            
            if index == numberOfItems - 1 {
                loadExpectation.fulfill()
            }
        }
        
        await fulfillment(of: [loadExpectation], timeout: 30)

        let loadEndTime = DispatchTime.now()
        let loadTimeElapsed = Double(loadEndTime.uptimeNanoseconds - loadStartTime.uptimeNanoseconds) / 1_000_000_000.0
        print("Time taken to load \(numberOfItems) data items: \(loadTimeElapsed) seconds")
    }
}
