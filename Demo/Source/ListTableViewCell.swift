//
//  YNCollectionViewCell.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit
import YNImageAsync

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellImage.image = nil
    }
    
    static func reuseIdentifier() -> String {
        return String(describing: ListTableViewCell.self)
    }
}

extension ListTableViewCell: ViewConfigurable {
    func configureView(_ model: ItemViewModel) {
        self.cellImage.setImage(with: model.imageUrl)
        self.cellTitle.text = model.imageTitle
    }
}
