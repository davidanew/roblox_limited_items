//  Copyright © 2019 David New. All rights reserved.

import XCTest
import SwiftyJSON
@testable import roblox_limited_items

class ApiInterfaceTests: XCTestCase {
    
    // greate object of class under test
    let iut = ApiInterface()
    // getlatestCollectables is asyncronous so needs a callback function
    // this is the expectation handler for this
    let getLatestCollectablesExpectation = XCTestExpectation(description: "getLatestCollectablesExpectation")
    // jsonAlamofire is asycncronous and needs a callback function
    let jsonAlamofireExpectation = XCTestExpectation(description: "jsonAlamofireExpectation")
    
    //instructions https://developer.roblox.com/articles/Catalog-API
    let numCollectibles = 30
    let urlLatestCollectables =  "https://search.roblox.com/catalog/json?SortType=RecentlyUpdated&IncludeNotForSale=false&Category=Collectibles&ResultsPerPage=30"
    let urlLatestAll =  "https://search.roblox.com/catalog/json?SortType=RecentlyUpdated&IncludeNotForSale=false&ResultsPerPage=30"
    let urlBitcoin = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
    
    var jsonLatestCollectables : JSON?
    
    func testJsonAlamofire() {
        print("Running testJsonAlamofire")
        let url = urlLatestCollectables
        iut.jsonAlamofire(url: url, jsonHandler: didJsonAlamofire, rootCompletionHandler: nil)
        // wait for callback didJsonAlamofire
        wait(for: [jsonAlamofireExpectation], timeout: 5)
        //unwrap json
        if let json = jsonLatestCollectables {
            //TODO this should not depend on count
            let numItems = json.count
            // this just for looking at the output, not needed for testing?
            for itemNum in 0..<numItems{
                print (" \(  json[itemNum]["Updated"].stringValue) \(  json[itemNum]["IsLimitedUnique"].stringValue) \(  json[itemNum]["IsLimited"].stringValue) \(  json[itemNum]["Name"].stringValue)")
            }
            for itemNum in 0..<5{
                XCTAssertTrue(json[itemNum]["IsLimitedUnique"].stringValue == "true" || json[itemNum]["IsLimited"].stringValue == "true")
            }
        }
        else {
            print ("JSON error")
            XCTFail()
        }
        // TODO check isLimited or isLimitedUnique true
        
    }
    
    // callback for testJsonAlamofire
    func didJsonAlamofire(json : JSON? , getLatestCollectablesCompletionHandler : (([String]) -> Void)? ) {

        jsonLatestCollectables = json
        jsonAlamofireExpectation.fulfill()
    }
    
    // test getLatestCollectables in ApiInterface
    func testGetLatestCollectables() {
        print("Running testGetLatestCollectablesList")
        // run funnction, it needs the name of the callback
        iut.getLatestCollectables(getLatestCollectablesCompletionHandler: getLatestCollectablesCompletionHandler)
        //the funtion will call getLatestCollectablesCompletionHandler, which will fulfill the expectation
        wait(for: [getLatestCollectablesExpectation], timeout: 5)
//        print(iut.jsonLatestCollectables)
        XCTAssertNotNil(iut.getNumEntries())
            for itemNum in 0..<numCollectibles{
//                XCTAssertTrue(json[itemNum]["IsLimitedUnique"].stringValue == "true" || json[itemNum]["IsLimited"].stringValue == "true")
                XCTAssertTrue(iut.getIsLimitedUnique(index : itemNum) == "true" || iut.getIsLimited(index : itemNum) == "true")
                XCTAssertNotNil(iut.getName(index : itemNum))
                XCTAssertNotNil(iut.getUpdated(index : itemNum))

                
//                print("testing item \(itemNum)")
//                print(iut.getIsLimitedUnique(index: itemNum))
                
            }
//        }
//        else {
//            print ("JSON error")
//            XCTFail()
//        }
    }
    
    // the callback for testGetLatestCollectablesList
    func getLatestCollectablesCompletionHandler(catalog : [String]) {
        print("callback successful, recieved \(catalog)")
        // fulfill expectation in testGetLatestCollectablesList
        getLatestCollectablesExpectation.fulfill()
    }
}
