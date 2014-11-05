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
        var url : NSURL = NSURL(string: imageUrl)!
        var request: NSURLRequest = NSURLRequest(URL:url)
        var config = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: config)
        var task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
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