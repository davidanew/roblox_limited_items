//  Copyright © 2019 David New. All rights reserved.

import XCTest
//import SwiftyJSON
@testable import roblox_limited_items

//class to test ApiInterface
class ApiInterfaceTests: XCTestCase {
    // create object of class under test
    let iut = ApiInterface()
    // getlatestCollectables is asyncronous so needs a callback function
    // this is the expectation handler for this
    let retrieveLatestCollectablesDataExpectation = XCTestExpectation(description: "retrieveLatestCollectablesDataExpectation")
    // also need expectation for retrieveLargeThumbnailData
    let retrieveLargeThumbnailDataExpectation = XCTestExpectation(description: "retrieveLargeThumbnailDataExpectation")
    //TODO get this from apiInterface
    let numCollectibles = 30
    
    // test getLatestCollectablesData
    func testRetrieveLatestCollectablesData() {
        iut.retrieveLatestCollectablesData { (success) in
            if success {
                // if closure flagged success then fulfill the expectation
                self.retrieveLatestCollectablesDataExpectation.fulfill()
            }
        }
        // wait for the expectation fulfilled by the closure
        // the data should now be valid
        wait(for: [retrieveLatestCollectablesDataExpectation], timeout: 5)
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
            //TODO could call image interface to see if image is recieved
        }
    }
    
    // test the functions that pass data between the view controllers
    func testSetLatestCollectablesData(){
        //Need to get a JSON as test data
        testRetrieveLatestCollectablesData()
        if let testJson = iut.getLatestCollectablesData(){
            // clear the JSON data to intialise the test
            iut.jsonLatestCollectables = nil
            //call the function under test
            iut.setLatestCollectablesData(latestCollectablesData: testJson)
            //make sure we can extract data
            XCTAssertTrue(iut.getIsLimitedUnique(index : 0) == "true" || iut.getIsLimited(index : 0) == "true")
        }
        else {
            //If getting the initial test data fails
            XCTFail()
        }
    }
    
    // test retrieveLargeThumbnailData
    func testRetrieveLargeThumbnailData () {
        //need the collectables data first
        //TODO - shoudl this run the test or the function?
        testRetrieveLatestCollectablesData()
        //just get the first row for the test
        let row = 0
        iut.retrieveLargeThumbnailData(index: row) { (success) in
        // if closure flagged success then fulfill the expectation
           self.retrieveLargeThumbnailDataExpectation.fulfill()
        }
        // wait for the expectation fulfilled by the closure
        // the data should now be valid
        wait(for: [retrieveLargeThumbnailDataExpectation], timeout: 5)
        // if there is a value fo thumbnil url
        if let url = iut.getLargeThumbnailUrl() {
            //test to see if url is not empty
            XCTAssertFalse(url == "")
        }
        else {
            // fail if thumbnail url is nil
            XCTFail()
        }
    }
}
