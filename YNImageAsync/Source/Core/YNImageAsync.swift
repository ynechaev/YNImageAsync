//
//  YNImageAsync.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 16.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

public class YNImageAsync {
    
    var logLevel: YNLogLevel
    
    static let sharedInstance : YNImageAsync = {
        let instance = YNImageAsync(logLevel: YNLogLevel.none)
        return instance
    }()
    
    init(logLevel: YNLogLevel) {
        self.logLevel = logLevel
    }
    
    static func setLoggingLevel(level: YNLogLevel) {
        YNImageAsync.sharedInstance.logLevel = level
    }
}
