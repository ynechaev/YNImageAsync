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
    
    public func yn_setImageWithUrl(_ imageUrl: String, completion: ImageCompletionClosure? = nil) {
        
        if let currentTask = self.task {
            currentTask.cancel()
        }
        
        self.task = YNImageLoader.sharedInstance.loadImageWithUrl(imageUrl, completion: { (image: UIImage?, error: Error?) -> (Void) in
            DispatchQueue.main.async(execute: { () -> Void in
                if let responseImage = image {
                    self.image = responseImage
                    if let completionBlock = completion {
                        completionBlock(responseImage, nil)
                    }
                } else {
                    if let completionBlock = completion {
                        completionBlock(nil, error)
                    }
                }
            })
        })
        
    }
    
    public func yn_setImageWithUrl(_ imageUrl: String, placeholderImage: UIImage, completion: ImageCompletionClosure?) -> Void {
        self.image = placeholderImage
        yn_setImageWithUrl(imageUrl)
    }
    
    public func yn_setImageWithUrl(_ imageUrl: String, pattern: Bool) -> Void {
        if (pattern) {
            if let decodedData = Data(base64Encoded: defaultPattern, options: NSData.Base64DecodingOptions()) {
                let decodedimage = UIImage(data: decodedData)
                self.backgroundColor = UIColor(patternImage: decodedimage!)
            }
        }
        yn_setImageWithUrl(imageUrl) { (image, error) -> (Void) in
            if pattern && image != nil {
                self.backgroundColor = UIColor.clear
            }
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
