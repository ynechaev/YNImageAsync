YNImageAsync
==========
[![Build Status](https://travis-ci.org/ynechaev/YNImageAsync.svg?branch=master)](https://travis-ci.org/ynechaev/YNImageAsync) [![CocoaPods](https://img.shields.io/cocoapods/v/YNImageAsync.svg)]() [![license](https://img.shields.io/github/license/ynechaev/YNImageAsync.svg)]()

#About
YNImageAsync is a lightweight and convenient framework for fetching and caching images.

# Features
- Fully written in Swift 5
- Asynchronous image loading with async/await
- LRUCache for both memory and disk cache
- Fast
- Supports both memory and drive caching
- Configurable with size limit for every kind of cache
- Good unit and performance test coverage
- UIImageView extension for fast and out-of-the-box image loading.

#### Why not %framework_name%?
Here are some results of performing 10k requests by popular frameworks:
![image](https://cloud.githubusercontent.com/assets/1216785/19865426/76fe4eea-9f9c-11e6-90f1-3374a4f11c6a.png)

(smaller time is better)
You can check it by yourself by launching [this benchmark project tests](https://github.com/ynechaev/Image-Frameworks-Benchmark).

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

# Upcoming features
* Hash sum checks to update cache

# Requirements

* Swift 5
* iOS 13

# License

YNImageAsync is available under the MIT license. See the LICENSE file for more info.
