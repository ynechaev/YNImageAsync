//
//  File.swift
//  
//
//  Created by Yuri Nechaev on 20.07.2023.
//

import Foundation
import CryptoKit

actor DiskCacheProvider: Caching {
    private static let cacheName = "YNImageAsync"
    
    private var maxCacheSize : UInt64
    
    private static let cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    static let cachePath: URL = cacheDirectory.appendingPathComponent(cacheName)
    
    init(maxCacheSize: UInt64 = .max) {
        self.maxCacheSize = maxCacheSize
    }
    
    func fetch(_ url: URL) async throws -> Data? {
        yn_logDebug("💾 Read: \(url)")
        return try DiskCacheProvider.read(fileUrl: DiskCacheProvider.fileKeyUrl(url))
    }
    
    func store(_ url: URL, data: Data) async throws {
        yn_logDebug("💾 Store: \(url)")
        try DiskCacheProvider.save(data: data, fileUrl: DiskCacheProvider.fileKeyUrl(url))
    }
    
    func size() async throws -> UInt64 {
        try FileManager.default.allocatedSizeOfDirectory(at: DiskCacheProvider.cachePath)
    }
    
    func clear() async throws {
        try FileManager.default.clearDirectory(with: DiskCacheProvider.cachePath)
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
}

extension DiskCacheProvider: CacheLimiting {
    
    func updateCacheLimit(_ limit: UInt64) async {
        self.maxCacheSize = limit
        await enforceCacheLimit()
    }
    
    
    func enforceCacheLimit() async {
        // remove some files to clear cache
    }
    
}

fileprivate extension FileManager {

    func allocatedSizeOfDirectory(at directoryURL: URL) throws -> UInt64 {
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

extension FileManager {
    func clearDirectory(with url: URL) throws {
        guard let tmpDirectory = try? contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else {
            return
        }
        try tmpDirectory.forEach { file in
            let fileUrl = url.appendingPathComponent(file.lastPathComponent)
            try removeItem(at: fileUrl)
        }
    }
}
