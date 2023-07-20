//
//  DiskCacheProviderTests.swift
//  
//
//  Created by Yuri Nechaev on 20.07.2023.
//

import XCTest
import Foundation
@testable import YNImageAsync

class DiskCacheProviderTests: XCTestCase {
    
    var cacheProvider: DiskCacheProvider!
    
    override func setUp() async throws {
        try await super.setUp()
        // Set the cache size to a small value for testing purposes
        let maxCacheSize: UInt64 = 1024 * 1024 // 1 MB
        cacheProvider = DiskCacheProvider(maxCacheSize: maxCacheSize)
        try await cacheProvider.clear()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        do {
            // Clear the cache after each test
            try await cacheProvider.clear()
        } catch {
            XCTFail("Failed to clear the cache: \(error)")
        }
    }
    
    func testCacheLimitEnforcement() async throws {
        // Fill the cache with files until it exceeds the cache size
        let fileSize: UInt64 = 512 * 1024 // 512 KB
        let numFilesToFillCache = 5
        let urls = createAndFillCacheWithFiles(fileSize: fileSize, numFiles: numFilesToFillCache)
        
        // Access the files to update access timestamps
        for url in urls {
            _ = try? await cacheProvider.fetch(url)
        }
        
        // Ensure that the cache size is greater than the cache limit
        let size1 = try await cacheProvider.size()
        let maxSize1 = await cacheProvider.maxCacheSize
        XCTAssertGreaterThan(size1, maxSize1)
        
        // Reduce the cache size by enforcing the cache limit
        try await cacheProvider.enforceCacheLimit()
        
        // Check that the cache size is now below or equal to the cache limit
        let size2 = try await cacheProvider.size()
        let maxSize2 = await cacheProvider.maxCacheSize
        XCTAssertLessThanOrEqual(size2, maxSize2)
    }
    
    private func createAndFillCacheWithFiles(fileSize: UInt64, numFiles: Int) -> [URL] {
        var urls: [URL] = []
        try! FileManager.default.createDirectory(atPath: DiskCacheProvider.cachePath.absoluteString, withIntermediateDirectories: true, attributes: nil)
        for i in 0..<numFiles {
            let data = Data(repeating: UInt8(i % 256), count: Int(fileSize))
            let fileName = "TestFile\(i)"
            let fileURL = DiskCacheProvider.cachePath.appendingPathComponent(fileName)
            do {
                try data.write(to: fileURL)
                urls.append(fileURL)
            } catch {
                XCTFail("Failed to write file \(fileName) to cache: \(error)")
            }
        }
        return urls
    }
}

