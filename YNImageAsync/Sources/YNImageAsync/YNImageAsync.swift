//
//  CacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yuri Nechaev. All rights reserved.
//

import Foundation

public protocol Caching {
    func fetch(_ url: URL) async throws -> Data?
    func store(_ url: URL, data: Data) async throws
    func size() async throws -> UInt64
    func clear() async throws
}

protocol CacheLimiting {
    func updateCacheLimit(_ limit: UInt64) async
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
    private var memoryCacheSizeLimit: UInt64 = 40 * 1024 * 1024 // Default 40 MB
    private var diskCacheSizeLimit: UInt64 = .max // Default unlimited MB
    
    public static var shared = CacheComposer(memoryCache: MemoryCacheProvider(maxMemoryCacheSize: .max),
                                             diskCache: DiskCacheProvider(maxCacheSize: .max))
    private let memoryCache: Caching?
    private let diskCache: Caching?
    private var diskStoreTasks = [URL: Task<Void, Error>]()
    public private(set) var options: CacheOptions
    static var logLevel: LogLevel = .info
    
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
            if diskStoreTasks[url] == nil {
                let storeTask = Task.detached { [weak self] in
                    guard let self else { return }
                    try await self.diskCache?.store(url, data: data)
                }
                diskStoreTasks[url] = storeTask
            }
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
