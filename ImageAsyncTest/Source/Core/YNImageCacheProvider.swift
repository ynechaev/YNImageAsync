//
//  YNImageCacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

let memoryCacheSize = 2 * 1024 * 1024 // 2Mb
let diskCacheSize = 40 * 1024 * 1024 // 40Mb

open class YNImageCacheProvider {
    
    init() {
        
    }
    
    open func imageDiskCacheForKey(_ key: String) -> UIImage? {
        return nil
    }
    
    open func imageMemoryCacheForKey(_ key: String) -> UIImage? {
        return nil
    }
    
    open func storeImageToMemory(_ image: UIImage) {
        
    }
    
    open func storeImageToDisk(_ image: UIImage) {
        
    }
    
}
