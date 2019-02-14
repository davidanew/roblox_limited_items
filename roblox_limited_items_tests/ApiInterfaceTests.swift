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
    let urlLatestCollectables =  "https://search.roblox.com/catalog/json?SortType=RecentlyUpdated&IncludeNotForSale=false&Category=Collectibles&ResultsPerPage=30"
    let urlLatestAll =  "https://search.roblox.com/catalog/json?SortType=RecentlyUpdated&IncludeNotForSale=false&ResultsPerPage=30"
    let urlBitcoin = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
    
    func testJsonAlamofire() {
        print("Running testJsonAlamofire")
        let url = urlLatestCollectables
        iut.jsonAlamofire(url: url, jsonHandler: didJsonAlamofire, rootCompletionHandler: nil)
        // wait for callback didJsonAlamofire
        wait(for: [jsonAlamofireExpectation], timeout: 5)
    }
    
    // callback for testJsonAlamofire
    func didJsonAlamofire(json : JSON? , getLatestCollectablesCompletionHandler : (([String]) -> Void)? ) {
        //unwrap json
        if let thisJson = json {
            let numItems = thisJson.count
            // this just for looking at the output, not needed for testing?
            for itemNum in 0..<numItems{
                print (" \(  thisJson[itemNum]["Updated"].stringValue) \(  thisJson[itemNum]["IsLimitedUnique"].stringValue) \(  thisJson[itemNum]["IsLimited"].stringValue) \(  thisJson[itemNum]["Name"].stringValue)")
            }
        }
        else {
            print ("JSON error")
        }
        // TODO check isLimited or isLimitedUnique true
        jsonAlamofireExpectation.fulfill()
    }
    
    // test getLatestCollectables in ApiInterface
    // need to look at this test again
    func testGetLatestCollectables() {
        print("Running testGetLatestCollectablesList")
        // run funnction, it needs the name of the callback
        iut.getLatestCollectables(getLatestCollectablesCompletionHandler: getLatestCollectablesCompletionHandler)
        //the funtion will call getLatestCollectablesCompletionHandler, which will fulfill the expectation
        wait(for: [getLatestCollectablesExpectation], timeout: 5)
    }
    
    // the callback for testGetLatestCollectablesList
    func getLatestCollectablesCompletionHandler(catalog : [String]) -> Void {
        print("callback successful, recieved \(catalog)")
        // fulfill expectation in testGetLatestCollectablesList
        getLatestCollectablesExpectation.fulfill()
    }
}
