//
//  YNCollectionViewCell.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit
import YNImageAsync

class ListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = UIImage(named: "placeholder-image")
    }
    
    static let reuseIdentifier: String = String(describing: ListCollectionViewCell.self)
}

extension ListCollectionViewCell: ViewConfigurable {
    func configureView(_ model: ItemViewModel) {
        imageView.setImage(with: model.imageUrl)
        titleLabel.text = model.imageTitle
    }
}
