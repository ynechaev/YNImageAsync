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

private var taskAssociationKey: UInt8 = 0

extension UIImageView {
    
    public func cancelPreviousLoading() {
        if let currentTask = self.task {
            currentTask.cancel()
        }
    }
    
    public func setImageWithUrl(_ imageUrl: String, placeholderImage: UIImage? = nil, progress: LoaderProgressClosure? = nil, completion: LoaderCompletionClosure? = nil) {
        cancelPreviousLoading()
        if let placeholder = placeholderImage {
            self.image = placeholder
        }
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
