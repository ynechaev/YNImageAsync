//
//  PerformanceTests.swift
//  
//
//  Created by Yuri Nechaev on 19.07.2023.
//

import XCTest
@testable import YNImageAsync

final class PerformanceTests: XCTestCase {
    
    override func setUp() async throws {
        try FileManager.default.clearDirectory(with: DiskCacheProvider.cachePath)
        try await CacheComposer.shared.clear()
    }
    
    func test_diskStore_performance() async throws {
        // given
        let sut = CacheComposer.shared
        await sut.updateOptions([.disk])
        CacheComposer.logLevel = .errors
        
        let imageData = Array<Int>(1...10_000).map { index in (CacheComposerTests.imageData, URL(string: "http://example.com/\(index).jpg")!) }
        
        let exp = expectation(description: "Finish")
        let begin = clock()
        Task {
            for data in imageData {
                try await sut.store(data.1, data: data.0)
            }
            exp.fulfill()
        }
        await fulfillment(of: [exp], timeout: 5)
        let diff = Double(clock() - begin) / Double(CLOCKS_PER_SEC)
        // 10k writes ~ 1.2s on macbook pro M1
        print("Elapsed disk write time: \(diff)")
        let size = try await sut.diskSize()
        XCTAssertEqual(size, 50000)
        XCTAssertLessThan(diff, 5)
    }
    
    func test_memoryStore_performance() async throws {
        // given
        let sut = CacheComposer.shared
        await sut.updateOptions([.memory])
        CacheComposer.logLevel = .errors
        
        let imageData = Array<Int>(1...10_000).map { index in (CacheComposerTests.imageData, URL(string: "http://example.com/\(index).jpg")!) }
        
        let exp = expectation(description: "Finish")
        let begin = clock()
        Task {
            for data in imageData {
                try await sut.store(data.1, data: data.0)
            }
            exp.fulfill()
        }
        await fulfillment(of: [exp], timeout: 5)
        let diff = Double(clock() - begin) / Double(CLOCKS_PER_SEC)
        // 10k writes ~ 0.2s on macbook pro M1
        print("Elapsed memory write time: \(diff)")
        let size = try await sut.memorySize()
        XCTAssertEqual(size, 50000)
        XCTAssertLessThan(diff, 2)
    }

}
