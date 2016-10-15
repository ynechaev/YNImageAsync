//
//  ViewController.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, NSURLSessionTaskDelegate {
    
    var dataProvider: YNDataProvider?
    var imageCollection: Array <ListObject> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(YNTableViewCell.self, forCellReuseIdentifier: YNTableViewCell.reuseIdentifier())
        setupDataProvider()
    }
    
    func setupDataProvider() {
        dataProvider = YNDataProvider(completionClosure: { (result, error) in
            if let completionResult = result {
                self.imageCollection = completionResult
                self.tableView.reloadData()
            } else {
                self.handleError(error)
            }
        })
    }
    
    func handleError(error: NSError?) {
        if let responseError = error {
            print("Error occured: \(responseError)")
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(YNTableViewCell.reuseIdentifier(), forIndexPath: indexPath) as! YNTableViewCell
        cell.setDataObject(imageCollection[indexPath.row])
        return cell
    }
    
}

