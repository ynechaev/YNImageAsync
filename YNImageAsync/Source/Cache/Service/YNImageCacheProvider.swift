//
//  YNImageCacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

let maxMemoryCacheSize = 3 * 1024 * 1024 // 3Mb
let maxDiskCacheSize = 40 * 1024 * 1024 // 40Mb

open class YNImageCacheProvider {

    var memoryCache: [String: YNImageCacheEntry] = [:]
    
    static let sharedInstance : YNImageCacheProvider = {
        let instance = YNImageCacheProvider()
        return instance
    }()
    
    open func memoryCacheForKey(_ key: String) -> Data? {
        if let cacheHit = memoryCache[key] {
            yn_logInfo("Cache hit: \(key)")
            return cacheHit.data
        }
        yn_logInfo("Cache miss: \(key)")
        return nil
    }
    
    open func storeDataToMemory(_ key: String, data: Data) {
        let entry = YNImageCacheEntry(data: data, cacheType: .memory, date: Date())
        yn_logInfo("Cache store: \(key)")
        memoryCache[key] = entry
        cleanMemoryCache()
    }
    
    open func imageDiskCacheForKey(_ key: String) -> UIImage? {
        return nil
    }
    
    open func storeImageToDisk(_ image: UIImage) {
        
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
        return (writePath as NSString).appendingPathComponent(filename)
    }
    
    func saveCache (cacheData: Data, path: String ) -> Bool{
        guard let fileUrl = URL(string: path) else {
            yn_logError("Failed to create file url from path: \(path)")
            return false
        }
        do {
            try cacheData.write(to: fileUrl , options: Data.WritingOptions(rawValue: 0))
            yn_logInfo("Disk cache write success: \(fileUrl)")
            return true
        } catch let saveError {
            yn_logError("\(saveError)")
            return false
        }
    }
    
}
