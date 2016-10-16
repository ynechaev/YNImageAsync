//
//  YNImageCacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

let maxMemoryCacheSize = 10 * 1024 * 1024 // 10Mb

public class YNImageCacheProvider {

    var memoryCache: [String: YNImageCacheEntry] = [:]
    public var cacheOptions: YNCacheOptions
    
    public static let sharedInstance : YNImageCacheProvider = {
        let instance = YNImageCacheProvider(cacheOptions: [.memory, .disk])
        return instance
    }()
    
    init(cacheOptions: YNCacheOptions) {
        self.cacheOptions = cacheOptions
    }
    
    public func cacheForKey(_ key: String) -> Data? {
        if let memCache = memoryCacheForKey(key) {
            return memCache
        } else {
            return diskCacheForKey(key)
        }
    }
    
    public func memoryCacheForKey(_ key: String) -> Data? {
        if cacheOptions.contains(.memory) {
            if let cacheHit = memoryCache[key] {
                yn_logInfo("Mem cache hit: \(key)")
                return cacheHit.data
            }
            yn_logInfo("Mem cache miss: \(key)")
        }
        return nil
    }
    
    public func diskCacheForKey(_ key: String) -> Data? {
        if cacheOptions.contains(.disk) {
            if let cacheHit = readCache(path: fileInCacheDirectory(filename: key)) {
                yn_logInfo("Disk cache hit: \(key)")
                return cacheHit
            }
            yn_logInfo("Mem cache miss: \(key)")
        }
        return nil
    }
    
    public func cacheData(key: String, data: Data) {
        cacheDataToMemory(key, data: data)
        cacheDataToDisk(key, data: data)
    }
    
    public func cacheDataToMemory(_ key: String, data: Data) {
        if cacheOptions.contains(.memory) {
            let entry = YNImageCacheEntry(data: data, cacheType: .memory, date: Date())
            yn_logInfo("Cache store: \(key)")
            memoryCache[key] = entry
            cleanMemoryCache()
        }
    }
    
    public func cacheDataToDisk(_ key: String, data: Data) {
        if cacheOptions.contains(.disk) {
            saveCache(cacheData: data, path: fileInCacheDirectory(filename: key))
        }
    }
    
    public func cleanMemoryCache() {
        let sorted = memoryCache.values.sorted { (entry1, entry2) -> Bool in
            return entry1.date > entry2.date
        }
        if memoryCacheSize() > maxMemoryCacheSize {
            yn_logInfo("Memory cache \(memoryCacheSize()) > max \(maxMemoryCacheSize)")
            var size : Int = 0
            for cacheEntry in sorted {
                size += cacheEntry.data.count
                if memoryCacheSize() - size < maxMemoryCacheSize {
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
    
    public func clearDiskCache() {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: cachePath())
            for file in files {
                try FileManager.default.removeItem(atPath: file)
                yn_logInfo("Deleted disk cache: \(file)")
            }
        } catch let error {
            yn_logInfo("Cache folder read error: \(error)")
        }
    }

    public func clearCache() {
        clearMemoryCache()
        clearDiskCache()
    }
    
    func filterCacheWithArray(array: Array <YNImageCacheEntry>) {
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
    
    func memoryCacheSize() -> Int {
        var size: Int = 0
        for cacheEntry in memoryCache.values {
            size += cacheEntry.data.count
        }
        return size
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
    
    func readCache(path: String) -> Data? {
        let fileUrl = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: fileUrl)
            yn_logInfo("Disk cache read success: \(fileUrl)")
            return data
        } catch let readError {
            yn_logInfo("Disk cache read error: \(readError)")
            return nil
        }
    }
    
    func saveCache(cacheData: Data, path: String ) {
        let fileUrl = URL(fileURLWithPath: path)
        do {
            try cacheData.write(to: fileUrl , options: Data.WritingOptions(rawValue: 0))
            yn_logInfo("Disk cache write success: \(fileUrl)")
        } catch let saveError {
            yn_logError("Disk cache write error: \(saveError)")
        }
    }
    
}
