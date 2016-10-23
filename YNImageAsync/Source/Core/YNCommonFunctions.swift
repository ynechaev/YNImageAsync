//
//  YNCommonFunctions.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

func yn_logError(_ items: Any...) {
    yn_log(items, level: .errors)
}

func yn_logDebug(_ items: Any...) {
    yn_log(items, level: .debug)
}

func yn_logInfo(_ items: Any...) {
    yn_log(items, level: .info)
}

func yn_log(_ items: Any..., level: YNLogLevel) {
    if YNImageAsync.sharedInstance.logLevel.contains(level) {
        print(items)
    }
}

public struct YNLogLevel : OptionSet {

    public let rawValue: Int
    public static let none   = YNLogLevel(rawValue: 0)
    public static let errors = YNLogLevel(rawValue: 1 << 0)
    public static let debug  = YNLogLevel(rawValue: (1 << 1) | errors.rawValue)
    public static let info   = YNLogLevel(rawValue: (1 << 2) | debug.rawValue)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}
