//
//  ImageInterfaceTests.swift
//  roblox_limited_items_tests
//
//  Created by David New on 15/02/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import Foundation
import XCTest
@testable import roblox_limited_items

class ImageInterfaceTest : XCTestCase {
    var image : UIImage?
    let iut = ImageInterface()
//    let getLatestCollectablesExpectation = XCTestExpectation(description: "getLatestCollectablesExpectation")
    let getImageExpectation = XCTestExpectation(description: "getImageExpectation")

    func testGetImage () {
        _ = iut.getImage(url: "https://t5.rbxcdn.com/59fc630773d822e9330ccc6bb8daf02a", row: 1, callBack: { (row) in
            print ("callback recived for row \(row)")
            XCTAssertEqual(row, 1)
            self.getImageExpectation.fulfill()
        })
        wait(for: [getImageExpectation], timeout: 5)
        image = iut.getImage(url: "https://t5.rbxcdn.com/59fc630773d822e9330ccc6bb8daf02a", row: 1, callBack: { (row) in
            XCTFail()
        })
        if let thisImage = image {
            print(thisImage as UIImage)
        }
        else {
            XCTFail()
        }
    }
    
}
