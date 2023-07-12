//
//  ImageLoader.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

actor ImageLoader {
    private let loader: DataLoader
    
    static let shared: ImageLoader = ImageLoader(loader: DataLoader(cache: MemoryCache()))
    
    init(loader: DataLoader) {
        self.loader = loader
    }
    
    func loadImageData(_ url: String) async -> Data? {
        guard let url = URL(string: url) else {
            print("Invalid url: \(url)")
            return nil
        }
        do {
            return try await loader.load(url)
        } catch {
            print("Image loader error: \(error.localizedDescription)")
            return nil
        }
    }
}

actor DataLoader {
    private let cache: MemoryCache
    private let session: URLSession
    private var activeTasks = [URL: Task<Data, Error>]()
    
    init(cache: MemoryCache, session: URLSession = .shared) {
        self.cache = cache
        self.session = session
    }
    
    func load(_ url: URL) async throws -> Data {
        if let existingTask = activeTasks[url] {
            return try await existingTask.value
        }
        
        let task = Task<Data, Error> {
            if let cachedData = await cache.data(with: url.absoluteString) {
                activeTasks[url] = nil
                return cachedData
            }
            let (data, _) = try await session.data(from: url)
            await cache.store(data, for: url.absoluteString)
            activeTasks[url] = nil
            return data
        }
        activeTasks[url] = task
        return try await task.value
    }
}

actor MemoryCache {
    private var cache = [String: Data]()
    
    func store(_ data: Data, for key: String) {
        cache[key] = data
    }
    
    func data(with key: String) -> Data? {
        cache[key]
    }
}

