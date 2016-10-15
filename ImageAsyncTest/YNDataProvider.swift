//
//  YNDataProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

public struct ListObject: YNCellObjectProtocol {
    public var imageUrl: String
    public var imageTitle: String
    
    init(imageUrl: String, imageTitle: String) {
        self.imageUrl = imageUrl
        self.imageTitle = imageTitle
    }
}

let url = NSURL(string:"https://s3.amazonaws.com/work-project-image-loading/images.json")

public typealias DataCompletionClosure = ((result: Array<ListObject>?, error: NSError?) -> Void)

public class YNDataProvider {
    var completionClosure: DataCompletionClosure
    
    public init(completionClosure com: DataCompletionClosure) {
        self.completionClosure = com
        loadItunesInfo(url!)
    }
    
    func loadItunesInfo(itunesUrl: NSURL) -> Void {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(itunesUrl, completionHandler: self.apiHandler)
        task.resume()
    }
    
    func apiHandler(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void {
        if let apiError = error {
            print("API error: \(apiError), \(apiError.userInfo)")
        }
        
        guard let apiData = data else { return }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(apiData, options:NSJSONReadingOptions(rawValue: 0))
            guard let dict: NSDictionary = json as? NSDictionary else {
                print("Not a Dictionary")
                return
            }
            processRequestResult(dict)
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
    }
    
    func processRequestResult(response: NSDictionary) {
        var temp: Array <ListObject> = []
        if let root = response["images"] as? Array<AnyObject> {
            for obj in root {
                if let url = obj["url"] as? String, title = obj["title"] as? String {
                    let listObject = ListObject(imageUrl: url, imageTitle: title)
                    temp.append(listObject)
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.completionClosure(result: temp, error: nil)
            })
        } else {
            self.completionClosure(result: nil, error: nil)
        }
    }
    
}