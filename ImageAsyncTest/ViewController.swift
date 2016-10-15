//
//  ViewController.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSURLSessionTaskDelegate {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    let reuseIdentifier = "imageCell"
    var url = NSURL(string:"https://itunes.apple.com/search?term=game&media=software")
    var itunesTask: NSURLSessionDataTask!
    var imageCollection: NSArray!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageCollection = NSArray()
        
        imageCollectionView.registerClass(YNCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        loadItunesInfo(url!)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadItunesInfo(itunesUrl: NSURL) -> Void {
        let session = NSURLSession.sharedSession()
        self.itunesTask = session.dataTaskWithURL(itunesUrl, completionHandler: self.apiHandler)
        self.itunesTask.resume()
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
    
    func processRequestResult(objects: AnyObject) {
        print("JSONDictionary! \(objects)")
        let results: NSArray = objects["results"] as! NSArray
        imageCollection = results
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.imageCollectionView.reloadData()
        })
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! YNCollectionViewCell
        let object: AnyObject = imageCollection.objectAtIndex(indexPath.row)
        let imageUrl = object["artworkUrl512"] as? String
//        cell.imageView.yn_setImageWithUrl(imageUrl!)
        cell.imageView.yn_setImageWithUrl(imageUrl!, pattern: true)
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
}

