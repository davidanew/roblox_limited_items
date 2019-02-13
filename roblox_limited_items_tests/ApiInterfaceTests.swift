//
//  roblox_limited_items_tests.swift
//  roblox_limited_items_tests
//
//  Created by David New on 11/02/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import XCTest
import SwifyJSON
@testable import roblox_limited_items

class ApiInterfaceTests: XCTestCase {
    
    // greate object of class under test
    let iut = ApiInterface()
    // getlatestCollectables is asyncronous so needs a callback function
    // this is the expectation handler for this
    let getLatestCollectablesExpectation = XCTestExpectation(description: "getLatestCollectablesExpectation")
    
    // test getLatestCollectables in ApiInterface (should rename this test)
    func testGetLatestCollectablesList() {
 
        print("Running testGetLatestCollectablesList")
        // run funnction, it needs the name of the callback
        iut.getLatestCollectables(getLatestCollectablesCompletionHandler: getLatestCollectablesCompletionHandler)
        //the funtion will call getLatestCollectablesCompletionHandler, which will fulfill the expectation
        wait(for: [getLatestCollectablesExpectation], timeout: 10)
    }
    
    // the callback for testGetLatestCollectablesList
    func getLatestCollectablesCompletionHandler(catalog : [String]) -> Void {
        print("callback successful, recieved \(catalog)")
        // fulfill expectation in testGetLatestCollectablesList
        getLatestCollectablesExpectation.fulfill()
    }
    
    func testJsonAlamofire() {
        print("Running testJsonAlamofire")
        let url = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
        iut.jsonAlamofire(url: url, jsonHandler: <#T##(JSON?, (([String]) -> Void)?) -> Void#>)

    }
    
    func didJsonAlamofire(  )
    
    
}
