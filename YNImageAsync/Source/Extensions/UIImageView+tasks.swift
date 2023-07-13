//
//  YNImageAsyncExtensions.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

extension UIImageView {
    typealias ImageTask = Task<Void, Error>
    
    private static var _imageTasks = [String: ImageTask]()
        
    var imageTask: ImageTask? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UIImageView._imageTasks[tmpAddress]
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIImageView._imageTasks[tmpAddress] = newValue
        }
    }
    
    public func setImage(with url: String) {
        if let imageTask {
            imageTask.cancel()
        }
        imageTask = Task {
            try Task.checkCancellation()

            if let data = await ImageLoader.shared.loadImageData(url), let image = UIImage(data: data) {
                self.image = image
                return
            }
            return
        }
    }
    
}
