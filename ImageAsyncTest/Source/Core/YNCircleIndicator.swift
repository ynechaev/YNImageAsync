//
//  YNCircleIndicator.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 05.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit

class YNCircleIndicator: UIView {
    
    var currentProgress: Float = 0.0
    
    func setProgress (progress: Float) -> Void {
        currentProgress = progress
        self.setNeedsLayout()
    }
    
    override func drawRect(rect: CGRect) {
        self.drawCanvas1(frame: rect)
    }
    
    func drawCanvas1(#frame: CGRect) {
        
        //// Oval Drawing
        var ovalRect = CGRectMake(frame.minX + floor((frame.width - 40) * 0.50000 + 0.5), frame.minY + floor((frame.height - 40) * 0.50000 + 0.5), 40, 40)
        var ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPointMake(ovalRect.midX, ovalRect.midY), radius: ovalRect.width / 2, startAngle: -90 * CGFloat(M_PI)/180, endAngle: 0 * CGFloat(M_PI)/180, clockwise: true)
        ovalPath.addLineToPoint(CGPointMake(ovalRect.midX, ovalRect.midY))
        ovalPath.closePath()
        
        UIColor.grayColor().setFill()
        ovalPath.fill()
    }
}
