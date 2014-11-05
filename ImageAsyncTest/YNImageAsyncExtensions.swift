//
//  YNImageAsyncExtensions.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    public func yn_setImageWithUrl (imageUrl: String) -> Void {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            var session: NSURLSession = NSURLSession.sharedSession()
            var task : NSURLSessionDataTask = session.dataTaskWithURL(NSURL(string: imageUrl)!, completionHandler:{ (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
                if (error != nil) {
                    println("Image load error: \(error), \(error.userInfo)")
                }
                if (data != nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.image = UIImage(data: data)
                    })
                }
            })
            task.resume()
        }
    }
}