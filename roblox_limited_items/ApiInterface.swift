//  Copyright © 2019 David New. All rights reserved.

import Foundation
import Alamofire
import SwiftyJSON
import os.log

// Contianer for the data that is passed between view controllers
struct ApiInterfaceData {
    var data : JSON?
}

struct Log {
    static var general = OSLog(subsystem: "com.roblox_limited_items.ApiInterface", category: "general")
}

//handle calls to api and store resultant JSON objects
class ApiInterface {
    //Need alamofire manager so when can set a timeout
    var alamofireManager : SessionManager?
    let alamofireTimeout : TimeInterval = 10
    //Roblox search API instructions https://developer.roblox.com/articles/Catalog-API
    let urlLatestCollectablesBase =  "https://search.roblox.com/catalog/json?SortType=RecentlyUpdated&IncludeNotForSale=false&Category=Collectibles&ResultsPerPage="
    //number of collectables to load in one go, max is 30
    let numLatestCollectables = 30
    //this has to be constucted in initialiser
    var urlLatestCollectables = ""
    //for getting the URL of the large thumbnail
    //This has a placeholder _ASSETID_ which is substitituted in retrieveLargeThumbnailData
    let largeThumbnailURLTemplate = "https://thumbnails.roblox.com/v1/assets?assetIds=_ASSETID_&size=420x420&format=Png"
    //The data is held in two JSON buffers as the Alomofire calls are asyncronous
    //The closures for these fill the buffers
    //before this the buffers are invalid
    //buffer for latest collectables
    var jsonLatestCollectables : JSON?
    //buffer for large thumbnail
    var jsonLargeThumbnail : JSON?
    
    //construct full url for collectables
    init() {
        urlLatestCollectables = urlLatestCollectablesBase + String(numLatestCollectables)
    }
    
    //get data to pass during segue
    func getLatestCollectablesData() ->ApiInterfaceData {
        var apiInterFaceData = ApiInterfaceData()
        apiInterFaceData.data = jsonLatestCollectables
        return apiInterFaceData
    }
    
    // this function is used to set the collectables data when the detail VC is loaded
    func setLatestCollectablesData(latestCollectablesData : ApiInterfaceData){
        jsonLatestCollectables = latestCollectablesData.data
    }
    
    // Function to get the latest collectables list from roblox
    // this function is called externally to the class. the call must include a closure that handles the return
    // of this function. Most lightly this handler will run a gui update.
    func retrieveLatestCollectablesData(closure : @escaping (Bool) -> Void ) {
        let url = urlLatestCollectables
        //create alamofire configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = alamofireTimeout
        configuration.timeoutIntervalForResource = alamofireTimeout
        alamofireManager = Alamofire.SessionManager(configuration: configuration)
        //start alamofire request
        alamofireManager?.request(url, method: .get).responseJSON { response in
            let success : Bool = response.result.isSuccess
            var jsonSuccess : Bool = false
            // if alamofire says the operation is successful
            if success {
                // set the jsonLatestCollectables buffer to the response
                if let value = response.result.value {
                    self.jsonLatestCollectables = JSON(value)
                    jsonSuccess = true
                    os_log("retrieveLatestCollectablesData, Alamofire closure, set json", log: Log.general, type: .debug)
                }
                else {
                    os_log("retrieveLatestCollectablesData, Alamofire closure, response.result.value is nil", log: Log.general, type: .debug)

                }
            }
            else{
                os_log("retrieveLatestCollectablesData, Alamofire success is false", log: Log.general, type: .debug)
            }
            // this completion handler signals that the JSON retrieval is done and buffer
            // has results or is nil
            closure(jsonSuccess)
        }
    }
    
    //retrieves large thunmbnail url
    //index is for retrieveLargeThumbnailData. Closure is called during
    //alomofire closure
    func retrieveLargeThumbnailData(index : Int, closure : @escaping (Bool) -> Void)  {
        // need the asset Id from jsonLatestCollectables
        //Invalidate old data so the wrong icon is not shown
        self.jsonLargeThumbnail = nil
        if let assetId = getAssetId(index: index){
            // construct the URL to request the thumbnail URL
            let url = largeThumbnailURLTemplate.replacingOccurrences(of: "_ASSETID_", with: "\(assetId)")
            // Alamofire request to get the data
            Alamofire.request(url, method: .get).responseJSON { response in
                let alamofireSuccess : Bool = response.result.isSuccess
                var jsonSuccess : Bool = false
                // if alamofire says the operation is successful
                if alamofireSuccess {
                    // set the jsonLargeThumbnail buffer to the response
                    if let value = response.result.value {
                        self.jsonLargeThumbnail = JSON(value)
                        jsonSuccess = true
                    }
                }
                // this closure signals that the JSON retrieval is done and buffer
                // has results or is nil
                closure(jsonSuccess)
            }
        }
    }
    
    //Get number on entries in jsonLatestCollectables buffer
    func getNumEntries() -> Int?{ return jsonLatestCollectables?.count
    }
    
    //getters for various parameters in JSON
    func getLargeThumbnailUrl() -> String?{return jsonLargeThumbnail?["data"][0]["imageUrl"].stringValue}
    func getAssetId(index : Int) -> String? {return jsonLatestCollectables?[index]["AssetId"].stringValue}
    func getIsForSale(index : Int) -> String?{return jsonLatestCollectables?[index]["IsForSale"].stringValue}
    func getIsLimitedUnique(index : Int) -> String?{return jsonLatestCollectables?[index]["IsLimitedUnique"].stringValue}
    func getIsLimited(index : Int) -> String?{return jsonLatestCollectables?[index]["IsLimited"].stringValue}
    func getName(index : Int) -> String?{return jsonLatestCollectables?[index]["Name"].stringValue}
    func getDescription(index : Int) -> String?{return jsonLatestCollectables?[index]["Description"].stringValue}
    func getUpdated(index : Int) -> String?{return jsonLatestCollectables?[index]["Updated"].stringValue}
    func getRemaining(index : Int) -> String?{return jsonLatestCollectables?[index]["Remaining"].stringValue}
    func getSales(index : Int) -> String? { return jsonLatestCollectables?[index]["Sales"].stringValue}
    func getLimitedAltText(index : Int) -> String? {return jsonLatestCollectables?[index]["LimitedAltText"].stringValue}
    func getPrice(index : Int) -> String?{ return jsonLatestCollectables?[index]["Price"].stringValue}
    func getBestPrice(index : Int) -> String?{ return jsonLatestCollectables?[index]["BestPrice"].stringValue}
    func getThumbnailUrl(index : Int) -> String?{return jsonLatestCollectables?[index]["ThumbnailUrl"].stringValue }
}

