//  Copyright © 2019 David New. All rights reserved.

import Foundation
import Alamofire
import SwiftyJSON

class ApiInterface {
    // don't know if this is needed. but for now stote this as needed for table view
    // update - this will be a json object
    var tempData : [String]
    init() {
        tempData = ["a","b"]
    }
    
    // Function to get the latest collectables list from roblox
    // this function is called externally to the class. the call must include a handler that handles the return
    // of this function. most lightly this handler will runa gui update.
    //currently the callback is sent a string, this will likeley have to change
    func getLatestCollectables(getLatestCollectablesCompletionHandler : @escaping ([String]) -> Void ) {
        // just put this simple bitcoin url in for now for testing
        let url = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
        jsonAlamofire(url: url, jsonHandler: processLatestCollectablesJSON, rootCompletionHandler: getLatestCollectablesCompletionHandler)
    }
    
    // generic funtion to get a json object from a URL.
    // this is a confusing setup
    // A json handler is sent becuase the return is asyncronous. The json handler needs tp be sent the the root completion handler,
    // hence the nested statements
    // the root completion handler needs to be sent so it can be sent to the json handler!
    // the root completion handler is optional as in testing we don't need the root completion handler
    func jsonAlamofire(url : String , jsonHandler : @escaping (JSON?, (([String]) -> Void)?) -> Void , rootCompletionHandler : (([String]) -> Void)? ) {
        Alamofire.request(url, method: .get).responseJSON { response in
            let success : Bool = response.result.isSuccess
            // this variable holds the JSON to be returned. it also is used as a flag to show if there was success
            // when not successful this will be nil
            var valueJSON : JSON?
            // if alamofire says the operation is successful
            if success {
                // set the JSON value
                if let value = response.result.value {
                    valueJSON = JSON(value)
                }
            }
            // TODO look at  seans video on memory and referencing
            // call back to json handler, also needs root callback function
            jsonHandler(  valueJSON ,rootCompletionHandler)
        }
    }

    func processLatestCollectablesJSON(json : JSON? , getLatestCollectablesCompletionHandler : (([String]) -> Void)? ) {
        
        //TODO dont pass back the data, just a flag to say data is updated in this class
        // call root callback funtion
        getLatestCollectablesCompletionHandler?(tempData)
    }
}

