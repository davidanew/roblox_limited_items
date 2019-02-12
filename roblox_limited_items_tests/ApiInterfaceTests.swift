//
//  roblox_limited_items_tests.swift
//  roblox_limited_items_tests
//
//  Created by David New on 11/02/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import XCTest
@testable import roblox_limited_items

class ApiInterfaceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testFirstTest() {
        var testStringArray : [String]
        print("running my first test")
        let iut = ApiInterface()
        testStringArray = iut.getLatestCollectablesList()
        print (testStringArray)
        //XCTAssertTrue(false)
    }
    
    

}
