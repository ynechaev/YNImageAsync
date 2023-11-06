YNImageAsync
==========
![Build Status](https://github.com/ynechaev/YNImageAsync/actions/workflows/ios.yml/badge.svg)
![Swift package status](https://github.com/ynechaev/YNImageAsync/actions/workflows/swift.yml/badge.svg)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=ynechaev_YNImageAsync&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=ynechaev_YNImageAsync)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=ynechaev_YNImageAsync&metric=code_smells)](https://sonarcloud.io/summary/new_code?id=ynechaev_YNImageAsync)
![license](https://img.shields.io/github/license/ynechaev/YNImageAsync.svg)

#About
YNImageAsync is a lightweight and convenient framework for fetching and caching images.

# Features
- Fast
- Swift 5 and no ObjC
- Asynchronous image loading with async/await
- LRUCache for both memory and disk cache
- Configurable with size limit for every kind of cache
- Good unit and performance test coverage
- UIImageView extension for fast and out-of-the-box image loading, including built in downsampling optimization.

# Install
### Using SPM
Follow [this guide](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) in order to add YNImageAsync as a dependency to your project.

# How to
### Set UIImageview image with url
```swift
if let url = URL(string: "https://upload.wikimedia.org/wikipedia/en/5/5f/Original_Doge_meme.jpg") {
    imageView.setImage(with: url)
}
```
### Cancel UIImageview previous loading operation
```swift
imageView.cancelPreviousLoading()
```
### Access cache directly
```swift
import XCTest

func testCache() async throws {
    let memory = MyMemoryCache() // Your implementation of Caching protocol
    let disk = MyDiskCache() // Your implementation of Caching protocol
    let yourData // Replace with your data
    let cacheComposer = CacheComposer(memoryCache: memory, diskCache: disk) 
    
    // Save cache to memory and disk
    try await cacheComposer.store(url, data) 
    
    // Get cached data for key
    let data = try await cacheComposer.fetch(url)

    XCTAssertEqual(data, yourData)
}
```
### Configure storage type
You can easily configure storage during initialization and during runtime as well
```swift
await CacheComposer.shared.updateOptions([.memory])
```

### Set cache size limit
```swift
let cache = DiskCacheProvider()
try await cache.updateCacheLimit(UInt64(100 * 1024 * 1024))
```

# Upcoming features
* Hash sum checks to update cache

# Requirements

* Swift 5
* iOS 13

# License

YNImageAsync is available under the MIT license. See the LICENSE file for more info.
