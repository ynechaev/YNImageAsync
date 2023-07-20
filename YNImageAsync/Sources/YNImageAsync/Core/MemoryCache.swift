//
//  File.swift
//  
//
//  Created by Yuri Nechaev on 20.07.2023.
//

import Foundation

actor MemoryCacheProvider: Caching {
    let queue = DispatchQueue(label: "MemoryPressureQueue")

    private var dispatchSource: DispatchSourceMemoryPressure?
    
    let maxMemoryCacheSize : UInt64
    private let memoryCache: LRUCache<URL>
    
    init(maxMemoryCacheSize: UInt64 = .max) {
        self.maxMemoryCacheSize = maxMemoryCacheSize
        self.memoryCache = .init(maxTotalSize: maxMemoryCacheSize)
        Task {
            await subscribeForMemoryPressure()
        }
    }

    
    func fetch(_ url: URL) async throws -> Data? {
        yn_logDebug("⚡️ Read: \(url)")
        return await memoryCache.loadData(for: url)
    }
    
    func store(_ url: URL, data: Data) async throws {
        yn_logDebug("⚡️ Store: \(url)")
        await memoryCache.storeData(data, for: url)
    }
    
    func size() async throws -> UInt64 {
        await memoryCache.size()
    }
    
    func clear() async throws {
        await memoryCache.clear()
    }
    
    private func subscribeForMemoryPressure() async {
        if let source: DispatchSourceMemoryPressure = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: self.queue) as? DispatchSource {
            let eventHandler: DispatchSourceProtocol.DispatchSourceHandler = {
                let event: DispatchSource.MemoryPressureEvent = source.data
                if source.isCancelled == false {
                    self.didReceive(memoryPressureEvent: event)
                }
            }

            source.setEventHandler(handler:eventHandler)
            source.setRegistrationHandler(handler:eventHandler)
            self.dispatchSource = source
            self.dispatchSource?.activate()
        }
    }
    
    private func didReceive(memoryPressureEvent: DispatchSource.MemoryPressureEvent) {
        switch memoryPressureEvent {
        case .warning, .critical:
            Task {
                let size = try? await size()
                yn_logError("🔥 Memory pressure detected: \(memoryPressureEvent)\nCache size: \(String(describing: size))")
                await memoryCache.clear()
            }
            break
        default:
            break
        }
    }
}

extension MemoryCacheProvider: CacheLimiting {
    
    func updateCacheLimit(_ limit: UInt64) async {
        await memoryCache.updateCacheLimit(limit)
    }

}
