//
//  ViewController.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

let reuseIdentifier = "imageCell"
var url = NSURL(string:"https://itunes.apple.com/search?term=blog&media=software")
var itunesTask: NSURLSessionDataTask!

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSURLSessionDelegate {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var imageCollection: NSArray!
    
    var session = NSURLSession.sharedSession()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageCollection = NSArray()
        
        imageCollectionView.registerClass(YNCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        loadItunesInfo(url!)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadItunesInfo (itunesUrl: NSURL) -> Void {
        var request: NSURLRequest = NSURLRequest(URL: itunesUrl)
//        itunesTask = session.dataTaskWithRequest(request)
//        itunesTask = session.dataTaskWithURL(itunesUrl, completionHandler:apiHandler)
        itunesTask = session.dataTaskWithRequest(request, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            if (error != nil) {
                println("API error: \(error), \(error.userInfo)")
            }
            var jsonError:NSError?
            var json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as NSDictionary
            if (jsonError != nil) {
                println("Error parsing json: \(jsonError)")
            }
            else {
                var results: NSArray = json["results"] as NSArray
                self.imageCollection = results
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageCollectionView.reloadData()
                })
            }
        })
        itunesTask.resume()
    }
    
    func apiHandler(data:NSData!, response:NSURLResponse!, error:NSError!) -> Void {
        if (error != nil) {
            println("API error: \(error), \(error.userInfo)")
        }
        var jsonError:NSError?
        var json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as NSDictionary
        if (jsonError != nil) {
            println("Error parsing json: \(jsonError)")
        }
        else {
            var results: NSArray = json["results"] as NSArray
            imageCollection = results
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageCollectionView.reloadData()
            })
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as YNCollectionViewCell
        var object: AnyObject = self.imageCollection.objectAtIndex(indexPath.row)
        var imageUrl = object["artworkUrl512"] as? String
        cell.imageView.yn_setImageWithUrl(imageUrl!)
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }

}

