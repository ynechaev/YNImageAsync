//
//  YNCellDataProtocol.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

public protocol YNCellDataProtocol {
    
    func setDataObject<T: AnyObject where T: YNCellObjectProtocol>(dataObject: T)
    static func reuseIdentifier() -> String

}