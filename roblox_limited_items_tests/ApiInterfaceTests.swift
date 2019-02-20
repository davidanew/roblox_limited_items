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
    let retrieveLatestCollectablesDataExpectation = XCTestExpectation(description: "retrieveLatestCollectablesDataExpectation")
    let retrieveLargeThumbnailDataExpectation = XCTestExpectation(description: "retrieveLargeThumbnailDataExpectation")
    //TODO get this from apiInterface
    let numCollectibles = 30
    
    // test getLatestCollectables
    func testRetrieveLatestCollectablesData() {
        // run funnction, it needs the name of the callback
        // todo put in closure
//        iut.retrieveLatestCollectables(completionHandler: getLatestCollectablesCompletionHandler)
        iut.retrieveLatestCollectablesData { (success) in
//            print("callback successful, recieved \(catalog)")
            // fulfill expectation in testGetLatestCollectablesList
            if success {
                self.retrieveLatestCollectablesDataExpectation.fulfill()
            }
        }
        //update comment//the function will call getLatestCollectablesCompletionHandler, which will fulfill the expectation
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
            //could call image interface to see if image is recieved
 //           XCTAssertNotNil(iut.retrieveLargeThumbnailData(index: itemNum))
            
 //               print (iut.getLargeThumbnailUrl(index: itemNum))
        }
//        iut.printJson()
    }
    
    //TODO look at closures and tidy up
    // the callback for testGetLatestCollectablesList
/*    func getLatestCollectablesCompletionHandler(catalog : [String]) {
        print("callback successful, recieved \(catalog)")
        // fulfill expectation in testGetLatestCollectablesList
        getLatestCollectablesExpectation.fulfill()
    }
*/
    
    // test the functions that pass data between the view controllers
    func testSetLatestCollectablesData(){
        //Need to get a JSON as test data
        testRetrieveLatestCollectablesData()
        if let testJson = iut.getLatestCollectablesData(){
            // clear the JSON data sto intialise the test
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
    
    func testRetrieveLargeThumbnailData () {
        // may need to daisy chain with expectations
        //var url : String?
        
        testRetrieveLatestCollectablesData()
        let row = 0
        iut.retrieveLargeThumbnailData(index: row) { (success) in
           self.retrieveLargeThumbnailDataExpectation.fulfill()
        }
        wait(for: [retrieveLargeThumbnailDataExpectation], timeout: 5)
        //url = iut.getLargeThumbnailUrl()
        //print("large thumbnail url:")
        //print (url)
//        print (iut.jsonLargeThumbnail)
//        print (iut.jsonLatestCollectables)
        if let url = iut.getLargeThumbnailUrl() {
 //           print ("return from getlargethumbnail")
//            print (url)
            XCTAssertFalse(url == "")
        }
        else {
            XCTFail()
        }
    }
}
