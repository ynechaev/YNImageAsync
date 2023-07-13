//
//  CacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

protocol Caching {
    func fetch(_ url: URL) async throws -> Data?
    func store(_ url: URL, data: Data) async throws
    func size() async throws -> UInt64
    func clear() async throws
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

public actor MemoryCacheProvider: Caching {
    let maxMemoryCacheSize : Int64 = 10 * 1024 * 1024 // 10Mb

    internal var memoryCache: [String: CacheEntry] = [:]
    
    public static let sharedInstance : CacheProvider = {
        let options : CacheOptions = [.memory, .disk]
        let conf = CacheConfiguration(options: options, memoryCacheLimit: maxMemoryCacheSize)
        let instance = CacheProvider(configuration: conf)
        return instance
    }()
    
    public init(configuration: CacheConfiguration) {
        self.configuration = configuration
    }
    
    public func cacheForKey(_ key: String, completion: @escaping ((_ data: Data?) -> Void)) {
        if let memCache = memoryCacheForKey(key) {
            completion(memCache)
        } else {
            diskCacheForKey(key, completion: completion)
        }
    }
    
    public func memoryCacheForKey(_ key: String) -> Data? {
        if configuration.options.contains(.memory) {
            if let cacheHit = memoryCache[key] {
                yn_logInfo("Mem cache hit: \(key)")
                return cacheHit.data
            }
            yn_logInfo("Mem cache miss: \(key)")
        }
        return nil
    }
    
    public func diskCacheForKey(_ key: String, completion: @escaping ((_ data: Data?) -> Void)) {
        if configuration.options.contains(.disk) {
            let filePath = fileInCacheDirectory(filename: key)
            let url = URL(fileURLWithPath: filePath)
            readCache(fileUrl: url, completion: { (data) in
                if let cacheHit = data {
                    yn_logInfo("Disk cache hit: \(key)")
                    self.cacheDataToMemory(key, cacheHit)
                    completion(cacheHit)
                    return
                } else {
                    yn_logInfo("Disk cache miss: \(key)")
                    completion(nil)
                    return
                }
            })
        } else {
            completion(nil)
        }
    }
    
    public func cacheData(_ key: String, _ data: Data, completion: CacheCompletionClosure? = nil) {
        cacheDataToMemory(key, data)
        cacheDataToDisk(key, data, completion: completion)
    }
    
    public func cacheDataToMemory(_ key: String, _ data: Data) {
        if configuration.options.contains(.memory) {
            let entry = CacheEntry(data: data, date: Date())
            yn_logInfo("Cache store: \(key)")
            memoryCache[key] = entry
            cleanMemoryCache()
        }
    }
    
    public func cacheDataToDisk(_ key: String, _ data: Data, completion: CacheCompletionClosure? = nil) {
        if configuration.options.contains(.disk) {
            let filePath = fileInCacheDirectory(filename: key)
            let url = URL(fileURLWithPath: filePath)
            saveCache(cacheData: data, fileUrl: url, completion: completion)
        } else {
            if let completionClosure = completion {
                completionClosure(true)
            }
        }
    }
    
    public func cleanMemoryCache() {
        let sorted = memoryCache.values.sorted { (entry1, entry2) -> Bool in
            return entry1.date > entry2.date
        }
        let maxSize = configuration.memoryCacheLimit
        let memorySize = memoryCacheSize()
        if memorySize > maxSize {
            yn_logInfo("Memory cache \(memoryCacheSize()) > max \(maxSize)")
            var size : Int64 = 0
            var newCache : Array<CacheEntry> = []
            for cacheEntry in sorted {
                size += Int64(cacheEntry.data.count)
                if size > maxSize {
                    yn_logInfo("Found \(sorted.count - newCache.count) elements exceeding capacity")
                    filterCacheWithArray(array: newCache)
                    break
                }
                newCache.append(cacheEntry)
            }
        }
    }
    
    public func clearMemoryCache() {
        memoryCache.removeAll()
    }
    
    public func diskCacheSize() -> Int64 {
        let files = cacheFolderFiles()
        var folderSize : Int64 = 0
        for file in files {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: file)
                let fileSize = attributes[FileAttributeKey.size] as! NSNumber
                folderSize += fileSize.int64Value
            } catch let error {
                yn_logInfo("Cache folder file attribute error: \(error)")
            }
        }
        return folderSize
    }
    
    public func memoryCacheSize() -> Int64 {
        var size: Int64 = 0
        for cacheEntry in memoryCache.values {
            size += Int64(cacheEntry.data.count)
        }
        return size
    }
    
    public func clearDiskCache() {
        let files = cacheFolderFiles()
        for file in files {
            yn_logInfo("Trying to delete \(file)")
            do {
                try FileManager.default.removeItem(atPath: file)
                yn_logInfo("Deleted disk cache: \(file)")
            } catch let error {
                yn_logInfo("Cache folder read error: \(error)")
            }
        }
    }

    public func clearCache() {
        clearMemoryCache()
        clearDiskCache()
    }
    
    func filterCacheWithArray(array: Array <CacheEntry>) {
        let tempCache = memoryCache
        for (key, entry) in tempCache {
            if !array.contains(where: { (filterEntry) -> Bool in
                return entry.udid == filterEntry.udid
            }) {
                memoryCache.removeValue(forKey: key)
                yn_logInfo("Removing \(entry.udid)")
            }
        }
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
