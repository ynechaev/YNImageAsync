//
//  YNImageView.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 05.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

protocol ImageProgressDelegate: NSObjectProtocol {
    func didChangeProgress (_ progress: Float) -> Void
}

class YNImageView: UIImageView, URLSessionTaskDelegate, ImageProgressDelegate {
    var circleIndicator: YNCircleIndicator!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareCircleIndicator(frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareCircleIndicator(_ frame: CGRect) -> Void {
        self.circleIndicator = YNCircleIndicator(frame: frame)
        self.circleIndicator.isOpaque = false
        self.addSubview(self.circleIndicator)
        self.bringSubview(toFront: self.circleIndicator)
    }
    
    func didChangeProgress(_ progress: Float) {
        self.circleIndicator.currentProgress = progress
    }
}
