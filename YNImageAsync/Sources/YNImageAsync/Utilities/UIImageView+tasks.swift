//
//  YNImageAsyncExtensions.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

extension UIImageView {
    private static var taskQueue = DispatchQueue(label: "image-view-tasks", attributes: .concurrent)
    private static var resizeQueue = DispatchQueue(label: "image-view-resize-tasks")

    typealias ImageTask = Task<Void, Error>
    
    private static var _imageTasks = [String: ImageTask]()
        
    var imageTask: ImageTask? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UIImageView.taskQueue.sync {
                UIImageView._imageTasks[tmpAddress]
            }
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIImageView.taskQueue.async(flags: .barrier) {
                UIImageView._imageTasks[tmpAddress] = newValue
            }
        }
    }
    
    public func setImage(with url: String) {
        let bounds = self.bounds
        if let imageTask {
            imageTask.cancel()
        }
        imageTask = Task(priority: .background) {
            try Task.checkCancellation()

            if let data = await ImageLoader.shared.loadImageData(url),
                let image = await UIImageView.resizeImage(data, size: bounds.size) {
                self.image = image
                return
            }
            return
        }
    }
    
    private static func resizeImage(_ data: Data, size: CGSize) async -> UIImage? {
        let scale = UIScreen.main.scale
        return await withCheckedContinuation { continuation in
            resizeQueue.async {
                let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
                guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let maxDimensionInPixels = max(size.width, size.height) * scale
                
                let downsampledOptions = [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceShouldCacheImmediately: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
                ] as CFDictionary
                
                guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let resizedImage = UIImage(cgImage: downsampledImage)
                continuation.resume(returning: resizedImage)
            }
        }
    }
    
}
