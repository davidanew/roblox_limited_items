//
//  ApiInterface.swift
//  roblox_limited_items
//
//  Created by David New on 11/02/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import Foundation

class ApiInterface {
    var recieveCatalogDelegate : RecieveCatalogDelegate?
    

    func getLatestCollectablesList() -> [String] {
        return ["a","b"]
    }
    
    func getLatestCollectablesListWithProtocol() {
        
        if let delegateReturn = recieveCatalogDelegate?.recieveCatalog(catalog: ["a","b"]) {
            if delegateReturn == false {
                print("delagate returned false")
            }
        }
        else {
            print("delegateReturn nil error")
        }
    }
}
