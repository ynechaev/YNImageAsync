//
//  YNImageCacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

let maxMemoryCacheSize = 3 * 1024 * 1024 // 3Mb

open class YNImageCacheProvider {

    var memoryCache: [String: YNImageCacheEntry] = [:]
    
    static let sharedInstance : YNImageCacheProvider = {
        let instance = YNImageCacheProvider()
        return instance
    }()
    
    open func cacheForKey(_ key: String) -> Data? {
        if let memCache = memoryCacheForKey(key) {
            return memCache
        } else {
            return diskCacheForKey(key)
        }
    }
    
    open func memoryCacheForKey(_ key: String) -> Data? {
        if let cacheHit = memoryCache[key] {
            yn_logInfo("Mem cache hit: \(key)")
            return cacheHit.data
        }
        yn_logInfo("Mem cache miss: \(key)")
        return nil
    }
    
    open func diskCacheForKey(_ key: String) -> Data? {
        if let cacheHit = readCache(path: fileInDocumentsDirectory(filename: key)) {
            yn_logInfo("Disk cache hit: \(key)")
            return cacheHit
        }
        yn_logInfo("Mem cache miss: \(key)")
        return nil
    }
    
    open func cacheData(key: String, data: Data) {
        cacheDataToMemory(key, data: data)
        cacheDataToDisk(key, data: data)
    }
    
    open func cacheDataToMemory(_ key: String, data: Data) {
        let entry = YNImageCacheEntry(data: data, cacheType: .memory, date: Date())
        yn_logInfo("Cache store: \(key)")
        memoryCache[key] = entry
        cleanMemoryCache()
    }
    
    open func cacheDataToDisk(_ key: String, data: Data) {
        saveCache(cacheData: data, path: fileInDocumentsDirectory(filename: key))
    }
    
    open func cleanMemoryCache() {
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
    
    open func clearMemoryCache() {
        memoryCache.removeAll()
    }
    
    open func clearDiskCache() {
        
    }
    
    open func clearCache() {
        clearMemoryCache()
        clearDiskCache()
    }
    
    func documentsDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return documentsFolderPath
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let writePath = (documentsDirectory() as NSString).appendingPathComponent("YNImageAsync")
        
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
