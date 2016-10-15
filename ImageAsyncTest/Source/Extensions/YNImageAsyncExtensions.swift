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

public typealias ImageCompletionClosure = ((_ image: UIImage?, _ error: Error?) -> (Void))

extension UIImageView {
    
    public func yn_setImageWithUrl(_ imageUrl: String, completion: ImageCompletionClosure? = nil) {
        
        DispatchQueue.global(qos: .default).async {
            let session: URLSession = URLSession.shared
            let task = session.dataTask(with: URL(string: imageUrl)!, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
                if let imageData = data {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.image = UIImage(data: imageData)
                    })
                    completion?(UIImage(data: imageData), error)
                } else {
                    completion?(nil, error)
                }
            })
            task.resume()
        }
        
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
    
}
