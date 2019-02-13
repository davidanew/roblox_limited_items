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
    // don't know ig this is needed. but for now stote this as needed for table view
    var tempData : [String]
    init() {
        tempData = ["a","b"]
    }
    
    // get the JSON and pass it to the latest collectables function. the call back for thr calling code is needed as the operation
    // is asyncronous
    func getLatestCollectables(getLatestCollectablesCompletionHandler : @escaping ([String]) -> Void ) {
        // just put this simple bitcoin url in for now for testing
        let url = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
//        Alamofire.request(url, method: .get).responseJSON { response in
//            let success : Bool = response.result.isSuccess
//            // this variable holds the JSON to be returned. it also i used as a flag to show if ther was success
//            // when not successful this will be nil
//            var valueJSON : JSON?
//            // if alamofire says the operation is successful
//            if success {
//                // set the JSON value
//                if let value = response.result.value {
//                    valueJSON = JSON(value)
//                }
//            }
//            // TODO look at weak self and seans video
//            // call back to json handler, also needs root callback function
//
//            self.processLatestCollectablesJSON(  value : valueJSON , getLatestCollectablesCompletionHandler : getLatestCollectablesCompletionHandler)
//        }
        jsonAlamofire(url: url, jsonHandler: processLatestCollectablesJSON, rootCompletionHandler: getLatestCollectablesCompletionHandler)
//        jsonAlamofire(url: url, rootCompletionHandler: getLatestCollectablesCompletionHandler)
    }
    
    func jsonAlamofire(url : String , jsonHandler : @escaping (JSON?, (([String]) -> Void)?) -> Void , rootCompletionHandler : (([String]) -> Void)? ) {
//      func jsonAlamofire(url : String , rootCompletionHandler : @escaping ([String]) -> Void ) {
        Alamofire.request(url, method: .get).responseJSON { response in
            let success : Bool = response.result.isSuccess
            // this variable holds the JSON to be returned. it also is used as a flag to show if ther was success
            // when not successful this will be nil
            var valueJSON : JSON?
            // if alamofire says the operation is successful
            if success {
                // set the JSON value
                if let value = response.result.value {
                    valueJSON = JSON(value)
                }
            }
            // TODO look at weak self and seans video
            // call back to json handler, also needs root callback function
            jsonHandler(  valueJSON ,rootCompletionHandler)
            
        }
    }

    func processLatestCollectablesJSON(value : JSON? , getLatestCollectablesCompletionHandler : (([String]) -> Void)? ) {
    //func processLatestCollectablesJSON( getLatestCollectablesCompletionHandler : @escaping ([String]) -> Void ) {
        //TODO dont pass back the data, just a flag to say data is updated in this class
        // call root callback funtion
        getLatestCollectablesCompletionHandler?(tempData)
    }
}

