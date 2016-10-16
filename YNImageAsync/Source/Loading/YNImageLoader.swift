//
//  YNImageLoader.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

public typealias LoaderCompletionClosure = ((_ data: Data?, _ error: Error?) -> (Void))
public typealias LoaderProgressClosure = ((_ progress: Float) -> Void)

public class YNImageLoader : NSObject, URLSessionDataDelegate, URLSessionDelegate, URLSessionTaskDelegate {
    
    var session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    var completionQueue: [Int: LoaderCompletionClosure] = [:]
    var progressQueue: [Int: LoaderProgressClosure] = [:]
    var responsesQueue: [Int: Data] = [:]
    var expectedSizeQueue: [Int: Int] = [:]
    
    static let sharedInstance : YNImageLoader = {
        let instance = YNImageLoader()
        return instance
    }()
    
    init(configuration: URLSessionConfiguration) {
        super.init()
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.session = session
    }
    
    override convenience init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData;
        self.init(configuration: configuration)
    }
    
    public func loadImageWithUrl(_ imageUrl: String, progress: @escaping LoaderProgressClosure, completion: @escaping LoaderCompletionClosure) -> URLSessionTask? {
        if let cachedImageData = YNImageCacheProvider.sharedInstance.cacheForKey(imageUrl) {
            completion(cachedImageData, nil)
            return nil
        } else {
            let task = self.session.dataTask(with: URL(string: imageUrl)!)
            launchTask(task: task, progress: progress, completion: completion)
            return task
        }
    }
    
    func launchTask(task: URLSessionTask, progress: @escaping LoaderProgressClosure, completion: @escaping LoaderCompletionClosure) {
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
            notifyProgress(mutableData, dataTask)
            synced(lock: self, closure: { 
                responsesQueue[dataTask.taskIdentifier] = mutableData
            })
        } else {
            synced(lock: self, closure: {
                responsesQueue[dataTask.taskIdentifier] = data
            })
            notifyProgress(data, dataTask)
        }
    }
    
    func notifyProgress(_ data: Data, _ dataTask: URLSessionDataTask) {
        if let bufferSize = expectedSizeQueue[dataTask.taskIdentifier], let progressClosure = progressQueue[dataTask.taskIdentifier] {
            let percentageDownloaded = Float(data.count) / Float(bufferSize)
            DispatchQueue.main.async {
                progressClosure(percentageDownloaded)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        synced(lock: self, closure: {
            expectedSizeQueue[dataTask.taskIdentifier] = Int(response.expectedContentLength)
        })
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let completionClosure = completionQueue[task.taskIdentifier] {
            if error != nil {
                DispatchQueue.main.async {
                    completionClosure(nil, error)
                }
            } else {
                if let existingData = responsesQueue[task.taskIdentifier] {
                    DispatchQueue.main.async {
                        completionClosure(existingData, error)
                    }
                    if let key = task.originalRequest?.url?.absoluteString {
                        YNImageCacheProvider.sharedInstance.cacheData(key: key, data: existingData)
                    }
                }
            }
        }
        removeQueuesForTaskId(task.taskIdentifier)
    }
    
}

