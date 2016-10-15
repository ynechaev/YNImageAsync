//
//  YNCollectionViewCell.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

class YNTableViewCell: UITableViewCell, YNCellDataProtocol {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.cellImage.image = nil
//        self.cellTitle.text = nil
    }
    
    static func reuseIdentifier() -> String {
        return String(describing: YNTableViewCell.self)
    }
    
    func setDataObject<T: Any>(_ dataObject: T) where T: YNCellObjectProtocol {
        self.cellImage.yn_setImageWithUrl(dataObject.imageUrl, pattern: true)
        self.cellTitle.text = dataObject.imageTitle
    }
    
}
