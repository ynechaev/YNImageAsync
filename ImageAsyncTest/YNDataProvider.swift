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

let url = URL(string:"https://s3.amazonaws.com/work-project-image-loading/images.json")

public typealias DataCompletionClosure = ((_ result: Array<ListObject>?, _ error: NSError?) -> Void)

open class YNDataProvider {
    var completionClosure: DataCompletionClosure
    
    public init(completionClosure com: @escaping DataCompletionClosure) {
        self.completionClosure = com
        loadItunesInfo(url!)
    }
    
    func loadItunesInfo(_ itunesUrl: URL) -> Void {
        let session = URLSession.shared
        let task = session.dataTask(with: itunesUrl, completionHandler: self.apiHandler)
        task.resume()
    }
    
    func apiHandler(data: Data?, response: URLResponse?, error: Error?) -> Void {
        if let apiError = error {
            print("API error: \(apiError)")
        }
        
        guard let apiData = data else { return }
        
        do {
            let json = try JSONSerialization.jsonObject(with: apiData, options:JSONSerialization.ReadingOptions(rawValue: 0))
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
    
    func processRequestResult(_ response: NSDictionary) {
        var temp: Array <ListObject> = []
        if let root = response["images"] as? Array<AnyObject> {
            for obj in root {
                if let url = obj["url"] as? String, let title = obj["title"] as? String {
                    let listObject = ListObject(imageUrl: url, imageTitle: title)
                    temp.append(listObject)
                }
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.completionClosure(temp, nil)
            })
        } else {
            self.completionClosure(nil, nil)
        }
    }
    
}
