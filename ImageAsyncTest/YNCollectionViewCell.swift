//
//  YNCollectionViewCell.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

class YNCollectionViewCell: UICollectionViewCell {
    var imageView: YNImageView!
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = YNImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(self.imageView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
}
