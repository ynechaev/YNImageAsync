//
//  CacheComposerTests.swift
//  ImageAsyncTest
//
//  Created by Yuri Nechaev on 2016-10-21.
//  Copyright © 2023 Yuri Nechaev. All rights reserved.
//

import XCTest
@testable import YNImageAsync

class CacheComposerTests: XCTestCase {
    static let cacheName = "CacheComposerTests"
    static let imageData = "image".data(using: .utf8)!
    
    override func setUp() async throws {
        try FileManager.default.clearDirectory(with: DiskCacheProvider.cachePath())
    }
    
    override func tearDown() async throws {
        try FileManager.default.clearDirectory(with: DiskCacheProvider.cachePath())
    }
    
    func test_store() async throws {
        // given
        let memoryMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: nil)
        
        let imageData = CacheComposerTests.imageData
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        // when
        try await sut.store(url, data: imageData)
        
        // then
        XCTAssertEqual(memoryMock.cache.count, 1)
        XCTAssertEqual(memoryMock.cache[url], imageData)
        XCTAssertEqual(memoryMock.storeCalls, 1)
    }
    
    func test_store_diskThrottling_notBlockingActor() async throws {
        // given
        let memoryMock = CacheMock()
        let diskMock = CacheMock(storeThrottling: 1)
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: diskMock)
        
        let imageData = CacheComposerTests.imageData
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        // when
        let expectation = XCTestExpectation(description: "Store task timeout")

        let task = Task {
            try await sut.store(url, data: imageData)
            expectation.fulfill()
        }
        
        // then

        await fulfillment(of: [expectation], timeout: 0.5)
        task.cancel()
    }
    
    func test_fetch() async throws {
        // given
        let memoryMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: nil)
        
        let imageData = CacheComposerTests.imageData
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        memoryMock.cache[url] = imageData
                
        // when
        let fetchedData = try await sut.fetch(url)
        
        // then
        XCTAssertEqual(imageData, fetchedData)
        XCTAssertEqual(memoryMock.fetchCalls, 1)
    }
    
    func test_whenFetch_callsMemory_ThenDisk() async throws {
        // given
        let memoryMock = CacheMock()
        let diskMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: diskMock)
        
        let imageData = CacheComposerTests.imageData
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        diskMock.cache[url] = imageData
                
        // when
        let fetchedData = try await sut.fetch(url)
        
        // then
        XCTAssertEqual(imageData, fetchedData)
        XCTAssertEqual(memoryMock.fetchCalls, 1)
        XCTAssertEqual(diskMock.fetchCalls, 1)
    }
    
    func test_whenFetch_callsMemory_ifFound_diskNotCalled() async throws {
        // given
        let memoryMock = CacheMock()
        let diskMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: diskMock)
        
        let imageData = CacheComposerTests.imageData
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        memoryMock.cache[url] = imageData
                
        // when
        let fetchedData = try await sut.fetch(url)
        
        // then
        XCTAssertEqual(imageData, fetchedData)
        XCTAssertEqual(memoryMock.fetchCalls, 1)
        XCTAssertEqual(diskMock.fetchCalls, 0)
    }
    
    func test_size() async throws {
        // given
        let memoryMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: nil)
        
        let imageData = CacheComposerTests.imageData
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        memoryMock.cache[url] = imageData
                
        // when
        let size = try await sut.size()
        
        // then
        XCTAssertEqual(size, 5)
        XCTAssertEqual(memoryMock.sizeCalls, 1)
    }
    
    func test_whenSizeCalled_allCachesCount() async throws {
        // given
        let memoryMock = CacheMock()
        let diskMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: diskMock)
        
        let imageData = CacheComposerTests.imageData
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        memoryMock.cache[url] = imageData
        diskMock.cache[url] = imageData
                
        // when
        let size = try await sut.size()
        
        // then
        XCTAssertEqual(size, 10)
        XCTAssertEqual(memoryMock.sizeCalls, 1)
    }
    
    func test_clear() async throws {
        // given
        let memoryMock = CacheMock()
        let diskMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: diskMock)
        
        let imageData = CacheComposerTests.imageData
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        memoryMock.cache[url] = imageData
        diskMock.cache[url] = imageData
                
        // when
        try await sut.clear()
        
        // then
        XCTAssertEqual(memoryMock.clearCalls, 1)
        XCTAssertEqual(diskMock.clearCalls, 1)
        XCTAssertEqual(memoryMock.cache.count, 0)
        XCTAssertEqual(diskMock.cache.count, 0)
    }
    
}

final class CacheMock: Caching {
    var cache = [URL: Data]()
    private(set) var fetchCalls = 0
    private(set) var storeCalls = 0
    private(set) var sizeCalls = 0
    private(set) var clearCalls = 0
    
    private let storeThrottling: TimeInterval?
    
    init(storeThrottling: TimeInterval? = nil) {
        self.storeThrottling = storeThrottling
    }
    
    func fetch(_ url: URL) async throws -> Data? {
        fetchCalls += 1
        return cache[url]
    }
    
    func store(_ url: URL, data: Data) async throws {
        storeCalls += 1
        if let storeThrottling {
            try await Task.sleep(nanoseconds: UInt64(storeThrottling * Double(NSEC_PER_SEC)))
        }
        cache[url] = data
    }
    
    func size() async throws -> UInt64 {
        sizeCalls += 1
        return UInt64(cache.values.reduce(0, { $0 + $1.count }))
    }
    
    func clear() async throws {
        clearCalls += 1
        cache.removeAll()
    }
}

extension UIImage {
    
    static func build(with size: CGSize, filledWithColor color: UIColor = .clear, scale: CGFloat = 0.0, opaque: Bool = false) -> UIImage? {
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        color.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
