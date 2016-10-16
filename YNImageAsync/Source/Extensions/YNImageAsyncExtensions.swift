//
//  YNImageAsyncExtensions.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

let defaultPattern = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAO0lEQVQYV2NkIBIwwtSdOXPmv4mJCZyPrp94hSCTQLpBpiGzyTeRZDcS8jxOX4I0IocEToUwRTCaaBMBIqwoC66FcWAAAAAASUVORK5CYII="


private var taskAssociationKey: UInt8 = 0

extension UIImageView {
    
    public func yn_cancelPreviousLoading() {
        if let currentTask = self.task {
            currentTask.cancel()
        }
    }
    
    public func yn_setImageWithUrl(_ imageUrl: String, progress: LoaderProgressClosure? = nil, completion: LoaderCompletionClosure? = nil) {
        yn_cancelPreviousLoading()
        self.task = YNImageLoader.sharedInstance.loadImageWithUrl(imageUrl, progress: { (progress) in
            
            }, completion: { (data, error) -> (Void) in
                if let newImageData = data {
                    self.image = UIImage(data: newImageData)
                }
                if let completionClosure = completion {
                    completionClosure(data, error)
                }
        })
    }
    
    public func yn_setImageWithUrl(_ imageUrl: String, placeholderImage: UIImage, progress: @escaping LoaderProgressClosure, completion: @escaping LoaderCompletionClosure) -> Void {
        self.image = placeholderImage
        yn_setImageWithUrl(imageUrl, progress: progress, completion: completion)
    }
    
    public func yn_setImageWithUrl(_ imageUrl: String, pattern: Bool, progress: @escaping LoaderProgressClosure, completion: @escaping LoaderCompletionClosure) -> Void {
        if (pattern) {
            if let decodedData = Data(base64Encoded: defaultPattern, options: NSData.Base64DecodingOptions()) {
                let decodedimage = UIImage(data: decodedData)
                self.backgroundColor = UIColor(patternImage: decodedimage!)
            }
        }
        yn_setImageWithUrl(imageUrl, progress: progress) { (image, error) -> (Void) in
            if pattern && image != nil {
                self.backgroundColor = UIColor.clear
            }
            completion(image, error)
        }
    }
    
    // MARK: Associated task object
    
    var task: URLSessionTask? {
        get {
            return objc_getAssociatedObject(self, &taskAssociationKey) as? URLSessionTask
        }
        set(newValue) {
            objc_setAssociatedObject(self, &taskAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}
