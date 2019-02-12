//
//  roblox_limited_items_tests.swift
//  roblox_limited_items_tests
//
//  Created by David New on 11/02/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import XCTest
@testable import roblox_limited_items

protocol RecieveCatalogDelegate {
    func recieveCatalog(catalog : [String]) ->Bool
}



class ApiInterfaceTests: XCTestCase, RecieveCatalogDelegate {
    
    let getLatestCollectablesListWithProtocolExpectation = XCTestExpectation(description: "getLatestCollectablesListWithProtocolExpectation")

    func testGetLatestCollectablesList() {
        var testStringArray : [String]
        print("running test")
        let iut = ApiInterface()
        testStringArray = iut.getLatestCollectablesList()
        print ("result from getLatestCollectablesList \(testStringArray)")
        iut.recieveCatalogDelegate = self as! RecieveCatalogDelegate
        iut.getLatestCollectablesListWithProtocol()
        wait(for: [getLatestCollectablesListWithProtocolExpectation], timeout: 10)
        
        //XCTAssertTrue(false)
        
        //let destinationVC = segue.destination as! SetUsernameController
        //destinationVC.recieverIdentifierDelegate = self
    }
    func recieveCatalog(catalog: [String]) -> Bool {
        print ("result from getLatestCollectablesListWithProtocol \(catalog)")
        getLatestCollectablesListWithProtocolExpectation.fulfill()
        return true
    }
    
    
}

extension ApiInterfaceTests {

}

