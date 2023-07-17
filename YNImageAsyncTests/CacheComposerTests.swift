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
    
    let imageNames = ["mountains.jpg", "parrot-indian.jpg", "parrot.jpg", "saint-petersburg.jpg", "snow.jpg", "tiger.jpg"]
    
    override func setUp() async throws {
        try FileManager.default.clearTempDirectory()
    }
    
    override func tearDown() async throws {
        try FileManager.default.clearTempDirectory()
    }
    
    func test_store() async throws {
        // given
        let memoryMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: nil)
        
        let image = UIImage(named: "mountains.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let imageData = image.jpegData(compressionQuality: 0.8)!
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
        
        let image = UIImage(named: "mountains.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let imageData = image.jpegData(compressionQuality: 0.8)!
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
        
        let image = UIImage(named: "mountains.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let imageData = image.jpegData(compressionQuality: 0.8)!
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
        
        let image = UIImage(named: "mountains.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let imageData = image.jpegData(compressionQuality: 0.8)!
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
        
        let image = UIImage(named: "mountains.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let imageData = image.jpegData(compressionQuality: 0.8)!
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
        
        let image = UIImage(named: "mountains.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let imageData = image.jpegData(compressionQuality: 0.8)!
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        memoryMock.cache[url] = imageData
                
        // when
        let size = try await sut.size()
        
        // then
        XCTAssertEqual(size, 3598826)
        XCTAssertEqual(memoryMock.sizeCalls, 1)
    }
    
    func test_whenSizeCalled_allCachesCount() async throws {
        // given
        let memoryMock = CacheMock()
        let diskMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: diskMock)
        
        let image = UIImage(named: "mountains.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let imageData = image.jpegData(compressionQuality: 0.8)!
        let url = URL(string: "http://example.com/mountains.jpg")!
        
        memoryMock.cache[url] = imageData
        diskMock.cache[url] = imageData
                
        // when
        let size = try await sut.size()
        
        // then
        XCTAssertEqual(size, 7197652)
        XCTAssertEqual(memoryMock.sizeCalls, 1)
    }
    
    func test_clear() async throws {
        // given
        let memoryMock = CacheMock()
        let diskMock = CacheMock()
        let sut = CacheComposer(memoryCache: memoryMock, diskCache: diskMock)
        
        let image = UIImage(named: "mountains.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let imageData = image.jpegData(compressionQuality: 0.8)!
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

extension FileManager {
    func clearTempDirectory() throws {
        let tmpDirectory = try contentsOfDirectory(atPath: temporaryDirectory.path)
        try tmpDirectory.forEach { file in
            let fileUrl = temporaryDirectory.appendingPathComponent(file)
            try removeItem(atPath: fileUrl.path)
        }
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
