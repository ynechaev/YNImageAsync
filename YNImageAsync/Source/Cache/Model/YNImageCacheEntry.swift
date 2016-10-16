//
//  YNImageCacheEntry.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

public struct YNImageCacheEntry {
    let udid: String = UUID().uuidString
    var data: Data
    var cacheType: ImageCacheType
    var date: Date
}
