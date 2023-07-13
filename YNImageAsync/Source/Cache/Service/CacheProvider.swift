//
//  CacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit
import CryptoKit

public protocol Caching {
    func fetch(_ url: URL) async throws -> Data?
    func store(_ url: URL, data: Data) async throws
    func size() async throws -> UInt64
    func clear() async throws
}

public struct CacheOptions: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    static public let memory = CacheOptions(rawValue: 1 << 0)
    static public let disk = CacheOptions(rawValue: 1 << 1)
}

@globalActor public actor CacheComposer: Caching {
    public static var shared = CacheComposer(memoryCache: MemoryCacheProvider(), diskCache: DiskCacheProvider())
    private let memoryCache: Caching?
    private let diskCache: Caching?
    public private(set) var options: CacheOptions

    init(memoryCache: Caching?, diskCache: Caching?, options: CacheOptions = [.memory, .disk]) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
        self.options = options
    }
        
    public func fetch(_ url: URL) async throws -> Data? {
        guard !options.isEmpty else {
            return nil
        }
        if options.contains(.memory), let data = try await memoryCache?.fetch(url)  {
            return data
        } else if options.contains(.disk), let data = try await diskCache?.fetch(url)  {
            if options.contains(.memory) {
                try await memoryCache?.store(url, data: data)
            }
            return data
        }
        return nil
    }
    
    public func store(_ url: URL, data: Data) async throws {
        if options.contains(.memory) {
            try await memoryCache?.store(url, data: data)
        }
        if options.contains(.disk) {
            try await diskCache?.store(url, data: data)
        }
    }
    
    public func size() async throws -> UInt64 {
        var acc: UInt64 = 0
        for cache in [memoryCache, diskCache] {
            try await acc += cache?.size() ?? 0
        }
        return acc
    }
    
    public func clear() async throws {
        for cache in [memoryCache, diskCache] {
            try await cache?.clear()
        }
    }
    
    // MARK: - Composer public API
    
    public func memorySize() async throws -> UInt64 {
        try await memoryCache?.size() ?? 0
    }
    
    public func diskSize() async throws -> UInt64 {
        try await diskCache?.size() ?? 0
    }
    
    public func updateOptions(_ options: CacheOptions) async {
        self.options = options
        if !options.contains(.memory) {
            try? await memoryCache?.clear()
        }
        if !options.contains(.disk) {
            try? await diskCache?.clear()
        }
    }
}

actor DiskCacheProvider: Caching {
    private static let cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    private static let cachePath: URL = cacheDirectory.appending(path: "YNImageAsync")
    
    func fetch(_ url: URL) async throws -> Data? {
        print("💾 Read: \(url)")
        return try DiskCacheProvider.read(fileUrl: DiskCacheProvider.fileKeyUrl(url))
    }
    
    func store(_ url: URL, data: Data) async throws {
        print("💾 Store: \(url)")
        try DiskCacheProvider.save(data: data, fileUrl: DiskCacheProvider.fileKeyUrl(url))
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
    
    private static func fileKeyUrl(_ url: URL) throws -> URL {
        let fileKey = url.absoluteString.MD5()
        return try DiskCacheProvider.fileInCacheDirectory(filename: fileKey)
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
        print("⚡️ Read: \(url)")
        return memoryCache[url]?.data
    }
    
    func store(_ url: URL, data: Data) async throws {
        print("⚡️ Store: \(url)")
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

fileprivate extension StringProtocol {
    
    func MD5() -> String {
        let digest = Insecure.MD5.hash(data: Data(utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
}
