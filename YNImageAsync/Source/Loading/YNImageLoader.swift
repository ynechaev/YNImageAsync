//
//  YNImageLoader.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

public typealias ImageCompletionClosure = ((_ image: UIImage?, _ error: Error?) -> (Void))
public typealias ImageProgressClosure = ((_ progress: Float) -> Void)

public class YNImageLoader : NSObject, URLSessionDataDelegate, URLSessionDelegate, URLSessionTaskDelegate {
    
    var session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    var completionQueue: [Int: ImageCompletionClosure] = [:]
    var progressQueue: [Int: ImageProgressClosure] = [:]
    var responsesQueue: [Int: Data] = [:]
    var expectedSizeQueue: [Int: Int] = [:]
    
    static let sharedInstance : YNImageLoader = {
        let instance = YNImageLoader()
        return instance
    }()
    
    init(configuration: URLSessionConfiguration) {
        super.init()
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        self.session = session
    }
    
    override convenience init() {
        let configuration = URLSessionConfiguration.default
        self.init(configuration: configuration)
    }
    
    public func loadImageWithUrl(_ imageUrl: String, progress: @escaping ImageProgressClosure, completion: @escaping ImageCompletionClosure) -> URLSessionTask? {
        if let cachedImageData = YNImageCacheProvider.sharedInstance.memoryCacheForKey(imageUrl) {
            completion(UIImage(data: cachedImageData), nil)
            return nil
        } else {
            let task = self.session.dataTask(with: URL(string: imageUrl)!)
            launchTask(task: task, progress: progress, completion: completion)
            return task
        }
    }
    
    func launchTask(task: URLSessionTask, progress: @escaping ImageProgressClosure, completion: @escaping ImageCompletionClosure) {
        synced(lock: self) {
            completionQueue[task.taskIdentifier] = completion
            progressQueue[task.taskIdentifier] = progress
        }
        task.resume()
    }
    
    func removeQueuesForTaskId(_ taskId: Int) {
        synced(lock: self) { 
            completionQueue.removeValue(forKey: taskId)
            progressQueue.removeValue(forKey: taskId)
            responsesQueue.removeValue(forKey: taskId)
            expectedSizeQueue.removeValue(forKey: taskId)
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let existingData = self.responsesQueue[dataTask.taskIdentifier] {
            var mutableData = existingData
            mutableData.append(data)
            if let bufferSize = expectedSizeQueue[dataTask.taskIdentifier], let progressClosure = progressQueue[dataTask.taskIdentifier] {
                let percentageDownloaded = Float(mutableData.count) / Float(bufferSize)
                progressClosure(percentageDownloaded)
            }
            responsesQueue[dataTask.taskIdentifier] = mutableData
        } else {
            responsesQueue[dataTask.taskIdentifier] = data
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        expectedSizeQueue[dataTask.taskIdentifier] = Int(response.expectedContentLength)
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let completionClosure = completionQueue[task.taskIdentifier] {
            if let existingData = responsesQueue[task.taskIdentifier] {
                completionClosure(UIImage(data: existingData), error)
                if let key = task.originalRequest?.url?.absoluteString {
                    YNImageCacheProvider.sharedInstance.storeDataToMemory(key, data: existingData)
                }
            } else {
                completionClosure(nil, error)
            }
        }
        removeQueuesForTaskId(task.taskIdentifier)
    }
    
}

