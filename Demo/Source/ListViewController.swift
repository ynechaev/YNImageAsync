//
//  ViewController.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit
import YNImageAsync

class ListViewController: UITableViewController, URLSessionTaskDelegate {
    @IBOutlet weak var clearCacheButton: UIBarButtonItem!
    
    var dataProvider: ListDataProvider?
    var imageCollection: Array <ListObject> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataProvider()
    }
    
    func setupDataProvider() {
        dataProvider = ListDataProvider(completionClosure: { (result, error) in
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
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier(), for: indexPath) as! ListTableViewCell
        cell.setDataObject(imageCollection[(indexPath as NSIndexPath).row])
        return cell
    }
    
    @IBAction func didTapClearCache(sender: AnyObject) {
        Task {
            do {
                clearCacheButton.isEnabled = false
                try await CacheComposer.shared.clear()
                clearCacheButton.isEnabled = true
                tableView.reloadData()
            } catch {
                yn_logError("Cache clear error: \(error)")
            }
        }
    }
    
}

