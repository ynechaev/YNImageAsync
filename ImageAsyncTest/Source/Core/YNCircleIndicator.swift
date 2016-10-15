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
    
    func setProgress (_ progress: Float) -> Void {
        currentProgress = progress
        self.setNeedsLayout()
    }
    
    override func draw(_ rect: CGRect) {
        self.drawCanvas1(rect)
    }
    
    func drawCanvas1(_ frame: CGRect) {
        
        //// Oval Drawing
        let ovalRect = CGRect(x: frame.minX + floor((frame.width - 40) * 0.50000 + 0.5), y: frame.minY + floor((frame.height - 40) * 0.50000 + 0.5), width: 40, height: 40)
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: -90 * CGFloat(M_PI)/180, endAngle: 0 * CGFloat(M_PI)/180, clockwise: true)
        ovalPath.addLine(to: CGPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.close()
        
        UIColor.gray.setFill()
        ovalPath.fill()
    }
}
