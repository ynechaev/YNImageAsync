//
//  YNImageAsyncExtensions.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import Foundation
import UIKit

let defaultPattern = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAO0lEQVQYV2NkIBIwwtSdOXPmv4mJCZyPrp94hSCTQLpBpiGzyTeRZDcS8jxOX4I0IocEToUwRTCaaBMBIqwoC66FcWAAAAAASUVORK5CYII="

public typealias ImageCompletionClosure = ((image: UIImage?, error: NSError?) -> (Void))

extension UIImageView {
    
    public func yn_setImageWithUrl(imageUrl: String, completion: ImageCompletionClosure? = nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let session: NSURLSession = NSURLSession.sharedSession()
            let task : NSURLSessionDataTask = session.dataTaskWithURL(NSURL(string: imageUrl)!, completionHandler:{ (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let imageData = data {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.image = UIImage(data: imageData)
                    })
                    completion?(image: UIImage(data: imageData), error: error)
                } else {
                    completion?(image: nil, error: error)
                }
            })
            task.resume()
        }
    }
    
    public func yn_setImageWithUrl(imageUrl: String, placeholderImage: UIImage, completion: ImageCompletionClosure?) -> Void {
        self.image = placeholderImage
        yn_setImageWithUrl(imageUrl)
    }
    
    public func yn_setImageWithUrl(imageUrl: String, pattern: Bool) -> Void {
        if (pattern) {
            if let decodedData = NSData(base64EncodedString: defaultPattern, options: NSDataBase64DecodingOptions()) {
                let decodedimage = UIImage(data: decodedData)
                self.backgroundColor = UIColor(patternImage: decodedimage!)
            }
        }
        yn_setImageWithUrl(imageUrl) { (image, error) -> (Void) in
            if pattern && image != nil {
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
}