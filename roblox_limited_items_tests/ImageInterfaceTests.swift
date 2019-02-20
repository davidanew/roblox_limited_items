//  Copyright © 2019 David New. All rights reserved.

import Foundation
import XCTest
@testable import roblox_limited_items

// test imageInteface class
class ImageInterfaceTest : XCTestCase {
    var image : UIImage?
    let iut = ImageInterface()
    // get image has a callback, this will fulfill the below expectation
    let getImageExpectation = XCTestExpectation(description: "getImageExpectation")
    
    // test getImage function
    func testGetImage () {
        // first call to getImage will return nothing as image is in the cache
        // TODO - we can move these brackets in the closure?
        _ = iut.getImage(url: "https://t5.rbxcdn.com/59fc630773d822e9330ccc6bb8daf02a", row: 1, closure: { (row) in
            print ("callback recived for row \(row)")
            // make sure row number was sent back
            XCTAssertEqual(row, 1)
            //getImage finished
            self.getImageExpectation.fulfill()
        })
        // wait for getImage callback
        wait(for: [getImageExpectation], timeout: 5)
        // now image should be in the cache
        image = iut.getImage(url: "https://t5.rbxcdn.com/59fc630773d822e9330ccc6bb8daf02a", row: 1, closure: { (row) in
            // if callabck is run then the image has been requested again
            // this should not happen as it should be in the cache
            XCTFail()
        })
        // check for image
        if let thisImage = image {
            print(thisImage as UIImage)
        }
        else {
            XCTFail()
        }
    }
    
}
