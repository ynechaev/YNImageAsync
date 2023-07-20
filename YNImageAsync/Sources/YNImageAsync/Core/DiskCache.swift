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
    private static let plistName = "AccessTimestamps.plist"
    private static let accessTimestampsURL: URL = applicationSupportDirectory.appendingPathComponent(plistName)
    private(set) var maxCacheSize : UInt64
    private var accessTimestamps = [URL: Date]()

    private static let cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    private static let applicationSupportDirectory: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]

    static let cachePath: URL = cacheDirectory.appendingPathComponent(cacheName)
    
    init(maxCacheSize: UInt64 = .max) {
        self.maxCacheSize = maxCacheSize
        Task {
            try await readAccessTimestampsFromFile()
        }
    }
    
    func fetch(_ url: URL) async throws -> Data? {
        yn_logDebug("💾 Read: \(url)")
        accessTimestamps[url] = Date()
        return try DiskCacheProvider.read(fileUrl: DiskCacheProvider.fileKeyUrl(url))
    }
    
    func store(_ url: URL, data: Data) async throws {
        yn_logDebug("💾 Store: \(url)")
        accessTimestamps[url] = Date()
        try DiskCacheProvider.save(data: data, fileUrl: DiskCacheProvider.fileKeyUrl(url))
    }
    
    func size() async throws -> UInt64 {
        try FileManager.default.allocatedSizeOfDirectory(at: DiskCacheProvider.cachePath)
    }
    
    func clear() async throws {
        try FileManager.default.clearDirectory(with: DiskCacheProvider.cachePath)
        try deleteTimestampFile()
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

enum ExpectedErrors: Int {
    case missingDirectory = 260
    case missingFile = 4
}

extension DiskCacheProvider: CacheLimiting {
    
    func updateCacheLimit(_ limit: UInt64) async throws {
        self.maxCacheSize = limit
        try await enforceCacheLimit()
    }
    
    func enforceCacheLimit() async throws {
        // Read the access timestamps from the file
        try readAccessTimestampsFromFile()
        var cacheSize = try await size()
        while cacheSize > maxCacheSize {
            // Find the least recently used file (min timestamp)
            if let urlToRemove = accessTimestamps.min(by: { $0.value < $1.value })?.key {
                // Remove the file from the cache directory
                try FileManager.default.removeItem(at: urlToRemove)
                // Remove the access timestamp entry
                accessTimestamps[urlToRemove] = nil
                // Update cache size
                cacheSize = try await size()
            } else {
                // If the accessTimestamps is empty, but cacheSize is still greater than maxCacheSize,
                // it means all files have been removed, but the cache size wasn't updated correctly.
                // In this case, break the loop to avoid an infinite loop.
                break
            }
        }
        // Save the updated access timestamps back to the file
        try saveAccessTimestampsToFile()
    }
    
    private func readAccessTimestampsFromFile() throws {
        do {
            // Read the access timestamps from the file
            let data = try Data(contentsOf: Self.accessTimestampsURL)
            let decoder = PropertyListDecoder()
            let fileAccessTimestamps = try decoder.decode([URL: Date].self, from: data)
            
            // Merge the file access timestamps with the existing access timestamps
            for (url, timestamp) in fileAccessTimestamps {
                if accessTimestamps[url] == nil {
                    // If the URL does not exist in the current access timestamps, add it
                    accessTimestamps[url] = timestamp
                } else {
                    // If the URL already exists, choose the older timestamp (priority to already stored access timestamps)
                    let currentTimestamp = accessTimestamps[url]!
                    accessTimestamps[url] = min(currentTimestamp, timestamp)
                }
            }
        } catch let error as NSError {
            try handleError(error, silence: [.missingDirectory])
        }
    }

    private func saveAccessTimestampsToFile() throws {
        let encoder = PropertyListEncoder()
        let data = try encoder.encode(accessTimestamps)
        try data.write(to: Self.accessTimestampsURL)
    }
    
    private func deleteTimestampFile() throws {
        do {
            try FileManager.default.removeItem(at: Self.accessTimestampsURL)
        } catch let error as NSError {
            try handleError(error, silence: [.missingFile])
        }
    }
    
    private func handleError(_ error: NSError, silence: [ExpectedErrors] = []) throws {
        if !silence.map({ $0.rawValue }).contains(error.code) {
            throw error
        }
    }
}

fileprivate extension FileManager {

    func allocatedSizeOfDirectory(at directoryURL: URL, excluding: [URL] = []) throws -> UInt64 {
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
            accumulatedSize += try contentItemURL.fileSize()
        }

        if let error = enumeratorError { throw error }
        return accumulatedSize
    }
}


fileprivate let allocatedSizeResourceKeys: Set<URLResourceKey> = [
    .isRegularFileKey,
    .fileSizeKey,
    .totalFileSizeKey,
]


fileprivate extension URL {
    func fileSize() throws -> UInt64 {
        let resourceValues = try self.resourceValues(forKeys: allocatedSizeResourceKeys)
        guard resourceValues.isRegularFile ?? false else {
            return 0
        }
        return UInt64(resourceValues.totalFileSize ?? resourceValues.fileSize ?? 0)
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
