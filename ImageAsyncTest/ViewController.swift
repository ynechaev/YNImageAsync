//
//  ViewController.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, URLSessionTaskDelegate {
    
    var dataProvider: YNDataProvider?
    var imageCollection: Array <ListObject> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(YNTableViewCell.self, forCellReuseIdentifier: YNTableViewCell.reuseIdentifier())
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
    
    func handleError(_ error: NSError?) {
        if let responseError = error {
            print("Error occured: \(responseError)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: YNTableViewCell.reuseIdentifier(), for: indexPath) as! YNTableViewCell
        cell.setDataObject(imageCollection[(indexPath as NSIndexPath).row])
        return cell
    }
    
}

