//
//  ViewController.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit
import YNImageAsync

class ListViewController: UITableViewController {
    @IBOutlet weak var clearCacheButton: UIBarButtonItem!
    
    let dataProvider = ListDataProvider()
    var viewModel: ListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    func fetchData() {
        Task {
            do {
                if let model = try await dataProvider.loadList() {
                    viewModel = .init(response: model)
                    tableView.reloadData()
                }
            } catch {
                handleError(error)
            }
        }
    }
    
    func handleError(_ error: Error) {
        print("Error occured: \(error)")
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        present(alertController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.images?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier(), for: indexPath) as! ListTableViewCell
        guard let model = viewModel?.images?[indexPath.row] else {
            return cell
        }
        cell.configureView(model)
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
                print("Cache clear error: \(error)")
            }
        }
    }
    
}

