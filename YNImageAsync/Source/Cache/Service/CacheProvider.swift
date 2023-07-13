//
//  CacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

public protocol Caching {
    func fetch(_ url: URL) async throws -> Data?
    func store(_ url: URL, data: Data) async throws
    func size() async throws -> UInt64
    func clear() async throws
}

@globalActor public actor CacheComposer: Caching {
    public static var shared = CacheComposer(caches: [MemoryCacheProvider(), DiskCacheProvider()])
    private let caches: [Caching]
        
    init(caches: [Caching]) {
        self.caches = caches
    }
        
    public func fetch(_ url: URL) async throws -> Data? {
        var data: Data?
        for cache in caches {
            data = try await cache.fetch(url)
            if data != nil { break }
        }
        return data
    }
    
    public func store(_ url: URL, data: Data) async throws {
        for cache in caches {
            try await cache.store(url, data: data)
        }
    }
    
    public func size() async throws -> UInt64 {
        var acc: UInt64 = 0
        for cache in caches {
            try await acc += cache.size()
        }
        return acc
    }
    
    public func clear() async throws {
        for cache in caches {
            try await cache.clear()
        }
    }
}

actor DiskCacheProvider: Caching {
    private static let cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    private static let cachePath: URL = cacheDirectory.appending(path: "YNImageAsync")
    
    func fetch(_ url: URL) async throws -> Data? {
        let filePath = try DiskCacheProvider.fileInCacheDirectory(filename: url.absoluteString)
        return try DiskCacheProvider.read(fileUrl: filePath)
    }
    
    func store(_ url: URL, data: Data) async throws {
        return try DiskCacheProvider.save(data: data, fileUrl: url)
    }
    
    func size() async throws -> UInt64 {
        try FileManager.default.allocatedSizeOfDirectory(at: DiskCacheProvider.cachePath)
    }
    
    func clear() async throws {
        let files = try DiskCacheProvider.cacheFolderFiles()
        let fileManager = FileManager.default
        try files.forEach { file in
            if fileManager.fileExists(atPath: file) {
                try fileManager.removeItem(atPath: file)
            }
        }
    }
    
    // MARK: - Disk cache utilities
    
    private static func read(fileUrl: URL) throws -> Data? {
        try Data(contentsOf: fileUrl)
    }
    
    private static func save(data: Data, fileUrl: URL) throws {
        try data.write(to: fileUrl , options: Data.WritingOptions(rawValue: 0))
    }
    
    private static func fileInCacheDirectory(filename: String) throws -> URL {
        let cachePath = DiskCacheProvider.cachePath
        
        if (!FileManager.default.fileExists(atPath: cachePath.path)) {
            try FileManager.default.createDirectory(atPath: cachePath.path, withIntermediateDirectories: false, attributes: nil)
        }
        
        if let escapedFilename = filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return cachePath.appendingPathComponent(escapedFilename)
        } else {
            return cachePath.appendingPathComponent(filename)
        }
    }
    
    private static func cacheFolderFiles() throws -> [String] {
        let cachePath = DiskCacheProvider.cachePath
        let files = try FileManager.default.contentsOfDirectory(atPath: cachePath.path)
        return files.map { cachePath.appendingPathComponent($0).absoluteString }
    }
    
}

actor MemoryCacheProvider: Caching {
    let maxMemoryCacheSize : UInt64 = 10 * 1024 * 1024 // 10Mb

    private var memoryCache = [URL: CacheEntry]()
    
    func fetch(_ url: URL) async throws -> Data? {
        memoryCache[url]?.data
    }
    
    func store(_ url: URL, data: Data) async throws {
        memoryCache[url] = CacheEntry(data: data, date: Date())
    }
    
    func size() async throws -> UInt64 {
        UInt64(memoryCache.values.reduce(0, { $0 + $1.data.count }))
    }
    
    func clear() async throws {
        memoryCache.removeAll()
    }
}

extension FileManager {

    public func allocatedSizeOfDirectory(at directoryURL: URL) throws -> UInt64 {
        var enumeratorError: Error? = nil
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [],
                                         errorHandler: errorHandler)!
        var accumulatedSize: UInt64 = 0
        for item in enumerator {
            if enumeratorError != nil { break }
            let contentItemURL = item as! URL
            accumulatedSize += try contentItemURL.regularFileAllocatedSize()
        }

        if let error = enumeratorError { throw error }
        return accumulatedSize
    }
}


fileprivate let allocatedSizeResourceKeys: Set<URLResourceKey> = [
    .isRegularFileKey,
    .fileAllocatedSizeKey,
    .totalFileAllocatedSizeKey,
]


fileprivate extension URL {
    func regularFileAllocatedSize() throws -> UInt64 {
        let resourceValues = try self.resourceValues(forKeys: allocatedSizeResourceKeys)
        guard resourceValues.isRegularFile ?? false else {
            return 0
        }
        return UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }
}
