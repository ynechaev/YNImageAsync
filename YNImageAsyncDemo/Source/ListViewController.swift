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

class ListViewController: UICollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ItemViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemViewModel>

    private var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var clearCacheButton: UIBarButtonItem!
    
    let dataProvider = ListDataProvider()
    let viewModel = ListViewModel()
    private lazy var dataSource = makeDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.setCollectionViewLayout(makeLayout(), animated: false)
        self.collectionView.dataSource = dataSource
        self.collectionView.prefetchDataSource = self
        viewModel.$images
            .sink { _ in
            } receiveValue: { [weak self] value in
                self?.applySnapshot(data: value)
            }
            .store(in: &subscriptions)
        viewModel.fetch()
    }
    
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
    
    func applySnapshot(data: [ItemViewModel], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func handleError(_ error: Error) {
        print("Error occured: \(error)")
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        present(alertController, animated: true)
    }
    
    @IBAction func didTapClearCache(sender: AnyObject) {
        Task {
            do {
                clearCacheButton.isEnabled = false
                try await CacheComposer.shared.clear()
                clearCacheButton.isEnabled = true
                collectionView.reloadData()
            } catch {
                print("Cache clear error: \(error)")
            }
        }
    }
}

extension ListViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // ask viewModel to prefetch images
    }

}

private extension ListViewController {
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, ItemViewModel> {
        UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, viewModel in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.reuseIdentifier, for: indexPath) as! ListCollectionViewCell
                cell.configureView(viewModel)
                return cell
            }
        )
    }
}

extension ListViewController {
    enum Section {
      case main
    }
}
