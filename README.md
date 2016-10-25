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

# Install
### Using cocoapods
```
pod 'YNImageAsync', '~> 1.0'
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
### Configure maximum memory usage limit
### Configure storage type

# Things to do
- Refactor YNImageLoader for dependency injection pattern and test coverage.
- Encapsulate request task and meta data into separate object.
