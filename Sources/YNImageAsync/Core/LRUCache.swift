//
//  File.swift
//  
//
//  Created by Yuri Nechaev on 20.07.2023.
//

import Foundation

actor LRUCache<Key: Hashable>: CacheLimiting {
    private var maxTotalSize: UInt64
    private var cache = [Key: Data]()
    private var recentKeys = DoublyLinkedList<Key>()
    private var keyNodes = [Key: DoublyLinkedList<Key>.Node]()
    private var totalSize: UInt64 = 0

    init(maxTotalSize: UInt64) {
        self.maxTotalSize = maxTotalSize
    }

    func loadData(for key: Key) async -> Data? {
        if let data = cache[key] {
            updateKeyUsage(key)
            return data
        } else {
            return nil
        }
    }

    func storeData(_ data: Data, for key: Key) async {
        let dataSize = UInt64(data.count)

        if dataSize > maxTotalSize {
            // Data size is larger than the cache, we cannot store it.
            return
        }

        // Check if we have enough space in the cache to store the data.
        while totalSize + dataSize > maxTotalSize, let keyToRemove = recentKeys.tail?.value {
            evict(with: keyToRemove)
        }

        // Store the data in the cache.
        cache[key] = data
        totalSize += dataSize
        updateKeyUsage(key)
    }

    func size() -> UInt64 {
        UInt64(cache.values.reduce(0) { $0 + $1.count })
    }

    func clear() async {
        cache.removeAll()
        recentKeys.removeAll()
        keyNodes.removeAll()
        totalSize = 0
    }

    func updateCacheLimit(_ limit: UInt64) async {
        maxTotalSize = limit
        await enforceCacheLimit()
    }

    private func enforceCacheLimit() async {
        while totalSize > maxTotalSize, let keyToRemove = recentKeys.tail?.value {
            evict(with: keyToRemove)
        }
    }

    private func evict(with key: Key) {
        totalSize -= UInt64(cache[key]?.count ?? 0)
        cache[key] = nil
        if let node = keyNodes[key] {
            recentKeys.remove(node)
            keyNodes[key] = nil
        }
    }

    private func updateKeyUsage(_ key: Key) {
        if let node = keyNodes[key] {
            recentKeys.moveToFront(node)
        } else {
            let newNode = recentKeys.insertAtFront(key)
            keyNodes[key] = newNode
        }
    }
}
