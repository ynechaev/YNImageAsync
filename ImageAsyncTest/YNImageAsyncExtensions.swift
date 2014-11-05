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

extension UIImageView {
    
    
    public func yn_setImageWithUrl (imageUrl: String) -> Void {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                var session: NSURLSession = NSURLSession.sharedSession()
                var task : NSURLSessionDataTask = session.dataTaskWithURL(NSURL(string: imageUrl)!, completionHandler:{ (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
                    if (data != nil) {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.image = UIImage(data: data)
                        })
                    }
                })
                task.resume()
            }
    }
    
    public func yn_setImageWithUrl (imageUrl: String, completion: ((UIImage!, NSError!) -> Void)?) -> Void {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            var session: NSURLSession = NSURLSession.sharedSession()
            var task : NSURLSessionDataTask = session.dataTaskWithURL(NSURL(string: imageUrl)!, completionHandler:{ (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
                if (data != nil) {
                    var image: UIImage = UIImage(data: data)!
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.image = image
                    })
                    completion!(image, error)
                } else {
                    completion!(nil, error)
                }
            })
            task.resume()
        }
    }
    
    public func yn_setImageWithUrl (imageUrl: String, placeholderImage: UIImage) -> Void {
        self.image = placeholderImage
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            var session: NSURLSession = NSURLSession.sharedSession()
            var task : NSURLSessionDataTask = session.dataTaskWithURL(NSURL(string: imageUrl)!, completionHandler:{ (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
                if (data != nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.image = UIImage(data: data)
                    })
                }
            })
            task.resume()
        }
    }
    
    public func yn_setImageWithUrl (imageUrl: String, pattern: Bool) -> Void {
        if (pattern) {
            let decodedData = NSData(base64EncodedString: defaultPattern, options: NSDataBase64DecodingOptions())
            var decodedimage = UIImage(data: decodedData!)
            self.backgroundColor = UIColor(patternImage: decodedimage!)
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            var session: NSURLSession = NSURLSession.sharedSession()
            var task : NSURLSessionDownloadTask = session.downloadTaskWithURL(NSURL(string: imageUrl)!, completionHandler: { (url:NSURL!, response:NSURLResponse!, error:NSError!) -> Void in
                if (error == nil) {
                    let downloadedImage: UIImage = UIImage(data: NSData(contentsOfURL: url)!)!
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.image = downloadedImage
                        if (pattern) { self.backgroundColor = UIColor.clearColor()
                        }
                    })
                }
                
            })
            if (self.isKindOfClass(YNImageView.self)) {
                
            }
            task.resume()
        }
    }
    
}