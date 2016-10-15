//
//  YNImageLoader.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

public typealias ImageCompletionClosure = ((_ image: UIImage?, _ error: Error?) -> (Void))

public class YNImageLoader {
    
    var session: URLSession
    
    static let sharedInstance : YNImageLoader = {
        let instance = YNImageLoader(session: URLSession.shared)
        return instance
    }()
    
    init(session: URLSession) {
        self.session = session
    }
    
    public func loadImageWithUrl(_ imageUrl: String, completion: ImageCompletionClosure? = nil) -> URLSessionTask {
        
        let session: URLSession = URLSession.shared

        let task = session.dataTask(with: URL(string: imageUrl)!, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
            if let imageData = data {
                let constructedImage = UIImage(data: imageData)
                if let completionBlock = completion {
                    completionBlock(constructedImage, error)
                }
            } else {
                if let completionBlock = completion {
                    completionBlock(nil, error)
                }
            }
        })
        task.resume()
        return task
        
    }
    
}

