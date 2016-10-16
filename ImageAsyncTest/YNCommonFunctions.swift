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
    if YNImageAsync.sharedInstance.logLevel .contains(level) {
        print(items)
    }
}

struct YNLogLevel : OptionSet {
    let rawValue: Int
    static let none   = YNLogLevel(rawValue: 0)
    static let errors = YNLogLevel(rawValue: 1 << 0)
    static let debug  = YNLogLevel(rawValue: (1 << 1) << errors.rawValue)
    static let info   = YNLogLevel(rawValue: (1 << 2) << debug.rawValue)
}

func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}
