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
        let numCollectibles = iut.numLatestCollectables
        for itemNum in 0..<numCollectibles{
            //check that this is a limited item
            XCTAssertTrue(iut.getIsLimitedUnique(index : itemNum) == "true" || iut.getIsLimited(index : itemNum) == "true")
            //other getter tests
            XCTAssertNotNil(iut.getAssetId(index : itemNum))
            XCTAssertNotNil(iut.getIsForSale(index : itemNum))
            XCTAssertNotNil(iut.getIsLimitedUnique(index : itemNum))
            XCTAssertNotNil(iut.getIsLimited(index : itemNum))
            XCTAssertNotNil(iut.getName(index : itemNum))
            XCTAssertNotNil(iut.getDescription(index : itemNum))
            XCTAssertNotNil(iut.getUpdated(index : itemNum))
            XCTAssertNotNil(iut.getRemaining(index : itemNum))
            XCTAssertNotNil(iut.getSales(index : itemNum))
            XCTAssertNotNil(iut.getLimitedAltText(index : itemNum))
            XCTAssertNotNil(iut.getPrice(index : itemNum))
            XCTAssertNotNil(iut.getThumbnailUrl(index : itemNum))
        }
       // print (iut.jsonLatestCollectables)
    }
    
    // test the functions that pass data between the view controllers
    func testSetLatestCollectablesData(){
        //Need to get a JSON as test data
        testRetrieveLatestCollectablesData()
        let testData = iut.getLatestCollectablesData()
        if testData.data != nil {
            // clear the JSON data to intialise the test
            iut.jsonLatestCollectables = nil
            //call the function under test
            iut.setLatestCollectablesData(latestCollectablesData: testData)
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
