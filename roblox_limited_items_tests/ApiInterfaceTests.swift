//  Copyright © 2019 David New. All rights reserved.

import XCTest
//import SwiftyJSON
@testable import roblox_limited_items

class ApiInterfaceTests: XCTestCase {
    //class to test ApiInterface
    
    // greate object of class under test
    let iut = ApiInterface()
    // getlatestCollectables is asyncronous so needs a callback function
    // this is the expectation handler for this
    let getLatestCollectablesExpectation = XCTestExpectation(description: "getLatestCollectablesExpectation")
    //TODO get this from apiInterface
    let numCollectibles = 30
    
    // test getLatestCollectables
    func testGetLatestCollectables() {
        // run funnction, it needs the name of the callback
        // todo put in closure
        iut.getLatestCollectables(completionHandler: getLatestCollectablesCompletionHandler)
        //the function will call getLatestCollectablesCompletionHandler, which will fulfill the expectation
        wait(for: [getLatestCollectablesExpectation], timeout: 5)
        // check JSON is not nil
        XCTAssertNotNil(iut.getNumEntries())
        // loop through all items
        for itemNum in 0..<numCollectibles{
            //theck that this is a limited item
            XCTAssertTrue(iut.getIsLimitedUnique(index : itemNum) == "true" || iut.getIsLimited(index : itemNum) == "true")
            //check the other getters
            //TODO add missing getter tests
            XCTAssertNotNil(iut.getName(index : itemNum))
            XCTAssertNotNil(iut.getUpdated(index : itemNum))
   //         print iut.getRemaining(index: itemNum)
        }
        iut.printJson()
    }
    
    //TODO look at closures and tidy up
    // the callback for testGetLatestCollectablesList
    func getLatestCollectablesCompletionHandler(catalog : [String]) {
        print("callback successful, recieved \(catalog)")
        // fulfill expectation in testGetLatestCollectablesList
        getLatestCollectablesExpectation.fulfill()
    }
    
    func testSetLatestCollectables(){
        testGetLatestCollectables()
        if let testJson = iut.getLatestCollectablesData(){
            iut.jsonLatestCollectables = nil
            iut.setLatestCollectablesData(latestCollectablesData: testJson)
            XCTAssertTrue(iut.getIsLimitedUnique(index : 0) == "true" || iut.getIsLimited(index : 0) == "true")
        }
        else {
            XCTFail()
        }
        
    }
    
}
