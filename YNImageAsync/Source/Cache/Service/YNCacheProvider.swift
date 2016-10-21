//
//  YNCacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

let maxMemoryCacheSize : Int64 = 10 * 1024 * 1024 // 10Mb

public class YNCacheProvider {

    internal var memoryCache: [String: YNCacheEntry] = [:]
    public var configuration: YNCacheConfiguration
    
    public static let sharedInstance : YNCacheProvider = {
        let options : YNCacheOptions = [.memory, .disk]
        let conf = YNCacheConfiguration(options: options, memoryCacheLimit: maxMemoryCacheSize)
        let instance = YNCacheProvider(configuration: conf)
        return instance
    }()
    
    public init(configuration: YNCacheConfiguration) {
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
            readCache(path: key, completion: { (data) in
                if let cacheHit = data {
                    yn_logInfo("Disk cache hit: \(key)")
                    self.cacheDataToMemory(key, data: cacheHit)
                    completion(cacheHit)
                } else {
                    yn_logInfo("Disk cache miss: \(key)")
                }
            })
        }
        completion(nil)
    }
    
    public func cacheData(key: String, data: Data) {
        cacheDataToMemory(key, data: data)
        cacheDataToDisk(key, data: data)
    }
    
    public func cacheDataToMemory(_ key: String, data: Data) {
        if configuration.options.contains(.memory) {
            let entry = YNCacheEntry(data: data, date: Date())
            yn_logInfo("Cache store: \(key)")
            memoryCache[key] = entry
            cleanMemoryCache()
        }
    }
    
    public func cacheDataToDisk(_ key: String, data: Data) {
        if configuration.options.contains(.disk) {
            saveCache(cacheData: data, path: fileInCacheDirectory(filename: key))
        }
    }
    
    public func cleanMemoryCache() {
        let sorted = memoryCache.values.sorted { (entry1, entry2) -> Bool in
            return entry1.date > entry2.date
        }
        let maxSize = configuration.memoryCacheLimit
        if memoryCacheSize() > maxSize {
            yn_logInfo("Memory cache \(memoryCacheSize()) > max \(maxSize)")
            var size : Int = 0
            for cacheEntry in sorted {
                size += cacheEntry.data.count
                if memoryCacheSize() - size < maxSize {
                    if let borderIndex = sorted.index(where: { (entry) -> Bool in
                        return cacheEntry.udid == entry.udid
                    }) {
                        yn_logInfo("Found \(borderIndex) elements exceeding capacity")
                        var newCache = sorted
                        newCache.removeFirst(borderIndex)
                        filterCacheWithArray(array: newCache)
                    }
                    return
                }
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
            size += cacheEntry.data.count
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
    
    func cacheFolderFiles() -> [String] {
        var returnedValue: [String] = []
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: cachePath())
            for file in files {
                let path = cachePath()
                let fullPath = (path as NSString).appendingPathComponent(file)
                returnedValue.append(fullPath)
            }
        } catch let error {
            yn_logInfo("Cache folder read error: \(error)")
        }
        return returnedValue
    }
    
    func filterCacheWithArray(array: Array <YNCacheEntry>) {
        let tempCache = memoryCache
        for (key, entry) in tempCache {
            guard let _ = array.index(where: { (filterEntry) -> Bool in
                return entry.udid == filterEntry.udid
            }) else {
                memoryCache.removeValue(forKey: key)
                yn_logInfo("Removing \(entry.udid)")
                break
            }
        }
    }
    
    func cacheDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return documentsFolderPath
    }
    
    func cachePath() -> String {
        return (cacheDirectory() as NSString).appendingPathComponent("YNImageAsync")
    }
    
    func fileInCacheDirectory(filename: String) -> String {
        
        let writePath = cachePath()
        
        if (!FileManager.default.fileExists(atPath: writePath)) {
            do {
                try FileManager.default.createDirectory(atPath: writePath, withIntermediateDirectories: false, attributes: nil) }
            catch let error {
                yn_logError("Failed to create directory: \(writePath) - \(error)")
            }
        }
        
        if let escapedFilename = filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return (writePath as NSString).appendingPathComponent(escapedFilename)
        } else {
            return (writePath as NSString).appendingPathComponent(filename)
        }
    }
    
    func readCache(path: String, completion: @escaping ((_ data: Data?) -> Void)) {
        let fileUrl = URL(fileURLWithPath: path)
        DispatchQueue.global(qos: .default).async {
            do {
                let data = try Data(contentsOf: fileUrl)
                yn_logInfo("Disk cache read success: \(fileUrl)")
                completion(data)
            } catch let readError {
                yn_logInfo("Disk cache read error: \(readError)")
                completion(nil)
            }
        }
    }
    
    func saveCache(cacheData: Data, path: String ) {
        let fileUrl = URL(fileURLWithPath: path)
        DispatchQueue.global(qos: .default).async {
            do {
                try cacheData.write(to: fileUrl , options: Data.WritingOptions(rawValue: 0))
                yn_logInfo("Disk cache write success: \(fileUrl)")
            } catch let saveError {
                yn_logError("Disk cache write error: \(saveError)")
            }
        }
    }
    
}
