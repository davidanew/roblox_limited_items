//
//  ApiInterface.swift
//  roblox_limited_items
//
//  Created by David New on 11/02/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiInterface {
    var tempData : [String]
    var getLatestCollectablesCompletionHandler : (([String]) -> Void )?
    
    //var completionHandler: ((Float)->Void)?
    //    var recieveCatalogDelegate : RecieveCatalogDelegate?
    
/*
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
 
 */
    init() {
        tempData = ["a","b"]
        
    }

    //TODO work out what escaping does
    
    func getLatestCollectables(completionHandler : @escaping ([String]) -> Void ) {
        getLatestCollectablesCompletionHandler = completionHandler
        //completionHandler(["a","b"])
        let url = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                print("Success! Got the bitcoin data")
                
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
            self.alamoFireLatestCollectablesCompletionHandler()
        }
        
    }
    
    func alamoFireLatestCollectablesCompletionHandler() {
        getLatestCollectablesCompletionHandler(tempData!)
        
    }
        
    
}


/*
 func classBFunction(_ completion: (String) -> Void) {
    completion("all working")
}
 */
