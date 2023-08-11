//
//  ViewController.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit
import YNImageAsync
import Combine

class ListViewController: UITableViewController {
    private var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var clearCacheButton: UIBarButtonItem!
    
    let dataProvider = ListDataProvider()
    let viewModel = ListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.$images
            .makeConnectable()
            .autoconnect()
            .sink { _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.tableView.reloadData()
                }
            }
            .store(in: &subscriptions)
        viewModel.fetch()
    }
    
    func handleError(_ error: Error) {
        print("Error occured: \(error)")
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        present(alertController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier(), for: indexPath) as! ListTableViewCell
        let model = viewModel.images[indexPath.row]
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

