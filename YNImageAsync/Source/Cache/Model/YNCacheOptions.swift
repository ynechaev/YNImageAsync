//
//  YNImageCachePolicy.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 16.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

public struct YNCacheConfiguration {
    public var options : YNCacheOptions
    public var memoryCacheLimit : Int64
}

public struct YNCacheOptions : OptionSet {
    
    public let rawValue: Int
    public static let none   = YNCacheOptions(rawValue: 0)
    public static let memory = YNCacheOptions(rawValue: 1 << 0)
    public static let disk   = YNCacheOptions(rawValue: 1 << 1)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
