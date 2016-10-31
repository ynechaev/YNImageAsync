YNImageAsync
==========
[![Build Status](https://travis-ci.org/ynechaev/YNImageAsync.svg?branch=master)](https://travis-ci.org/ynechaev/YNImageAsync)

#About
YNImageAsync is a lightweight and convenient framework for fetching and caching images.

# Features
- Written on Swift 3.0
- Asynchronous image loading
- Fast
- Supports both memory and drive caching
- Configurable
- Unit test coverage is good
- UIImageView extension for fast and out-of-the-box image loading.

#### Why not %framework_name%?
Here are some results of performing 10k requests by popular frameworks:
![image](https://cloud.githubusercontent.com/assets/1216785/19865426/76fe4eea-9f9c-11e6-90f1-3374a4f11c6a.png)

(smaller time is better)
You can check it by yourself by launching [this benchmark project tests](https://github.com/ynechaev/Image-Frameworks-Benchmark).

# Install
### Using cocoapods
```
pod 'YNImageAsync'
```

# How to
### Set UIImageview image with url
```swift
if let url = URL(string: "https://upload.wikimedia.org/wikipedia/en/5/5f/Original_Doge_meme.jpg") {
    imageView.setImageWithUrl(url)
}
```
### Cancel UIImageview previous loading operation
```swift
imageView.cancelPreviousLoading()
```
### Access cache directly
```swift
// Initialize cache with 30 Mb memory capacity and disk caching
let cacheProvider = CacheProvider(configuration: CacheConfiguration(options: [.memory, .disk], memoryCacheLimit: 30 * 1024 * 1024)) 

// Save cache to memory and disk
cacheProvider.cacheData("key", data) 

// Get cached data for key
provider.cacheForKey("key", completion: { (data) in
    if let cacheData = data {
        print("Cache hit")
    } else {
        print("Cache miss")
    }
})
```
### Change memory cache capacity
You don't need to initialize new instance of cache provider in order to change maximum memory cache capacity.
```swift
// New memory capacity is 10 Mb
let newLimit: Int64 = 10 * 1024 * 1024        
provider.configuration.memoryCacheLimit = newLimit
// Perform memory clean operation if capacity was reduced
provider.cleanMemoryCache()
```
### Configure storage type
You can easily configure storage during initialization and during runtime as well
```swift
provider.configuration.options = .memory
```

# Requirements

* XCode 8
* Swift 3
* iOS 9

# License

YNImageAsync is available under the MIT license. See the LICENSE file for more info.
