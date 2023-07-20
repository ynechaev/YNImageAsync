//
//  YNCellDataProtocol.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

protocol ViewConfigurable {
    associatedtype Model
    
    func configureView(_ model: Model)
}
