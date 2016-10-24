//
//  ImageAsyncTests.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 22.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import XCTest
@testable import YNImageAsync

class ImageAsyncTests: XCTestCase {
    
    func testSetLoggingLevel() {
        
        YNImageAsync.sharedInstance.logLevel = .none
        XCTAssertFalse(YNImageAsync.sharedInstance.logLevel.contains(.debug))
        XCTAssertFalse(YNImageAsync.sharedInstance.logLevel.contains(.errors))
        XCTAssertFalse(YNImageAsync.sharedInstance.logLevel.contains(.info))
        
        YNImageAsync.sharedInstance.logLevel = .errors
        XCTAssertFalse(YNImageAsync.sharedInstance.logLevel.contains(.debug))
        XCTAssertTrue(YNImageAsync.sharedInstance.logLevel.contains(.errors))
        XCTAssertFalse(YNImageAsync.sharedInstance.logLevel.contains(.info))
        
        YNImageAsync.sharedInstance.logLevel = .debug
        XCTAssertTrue(YNImageAsync.sharedInstance.logLevel.contains(.debug))
        XCTAssertTrue(YNImageAsync.sharedInstance.logLevel.contains(.errors))
        XCTAssertFalse(YNImageAsync.sharedInstance.logLevel.contains(.info))
        
        YNImageAsync.sharedInstance.logLevel = .info
        XCTAssertTrue(YNImageAsync.sharedInstance.logLevel.contains(.debug))
        XCTAssertTrue(YNImageAsync.sharedInstance.logLevel.contains(.errors))
        XCTAssertTrue(YNImageAsync.sharedInstance.logLevel.contains(.info))
    }
    
}
