//
//  YNCollectionViewCell.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit
import YNImageAsync

class ListTableViewCell: UITableViewCell, ListCellDataProtocol {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cellImage.layer.rasterizationScale = UIScreen.main.scale
        self.cellImage.layer.shouldRasterize = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellImage.image = nil
        self.cellImage.cancelPreviousLoading()
    }
    
    static func reuseIdentifier() -> String {
        return String(describing: ListTableViewCell.self)
    }
    
    func setDataObject<T: Any>(_ dataObject: T) where T: ListCellObjectProtocol {
        if let url = URL(string: dataObject.imageUrl) {
            self.cellImage.setImageWithUrl(url)
        }
        self.cellTitle.text = dataObject.imageTitle
    }
    
}
