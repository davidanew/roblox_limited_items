//  Copyright © 2019 David New. All rights reserved.

import Foundation
import Alamofire
import SwiftyJSON

//handle calls to api and store resultant JSON objects
class ApiInterface {
    
    //Roblox search API instructions https://developer.roblox.com/articles/Catalog-API
    let urlLatestCollectablesBase =  "https://search.roblox.com/catalog/json?SortType=RecentlyUpdated&IncludeNotForSale=false&Category=Collectibles&ResultsPerPage="
    //number of collectables to load in one go, max is 30
    let numLatestCollectables = 30
    //this to be constucted in initialiser
    var urlLatestCollectables = ""
    //for getting the URL of the large thumbnail
    //TODO is this actually a thumbnail - may need to rename
    //This has a placeholder _ASSETID_ which is substitituted in retrieveLargeThumbnailData
    let largeThumbnailURLTemplate = "https://thumbnails.roblox.com/v1/assets?assetIds=_ASSETID_&size=420x420&format=Png"

    //buffer for latest collectables
    var jsonLatestCollectables : JSON?
    //buffer for large thumbnail
    var jsonLargeThumbnail : JSON?
    
    //construct full url for collectables
    init() {
        urlLatestCollectables = urlLatestCollectablesBase + String(numLatestCollectables)
    }
    
    // this function is used to set the collectables data when the detail VC is loaded
    func setLatestCollectablesData(latestCollectablesData : JSON){
        jsonLatestCollectables = latestCollectablesData
    }
    
    // Function to get the latest collectables list from roblox
    // this function is called externally to the class. the call must include a handler that handles the return
    // of this function. Most lightly this handler will run gui update.
    func retrieveLatestCollectablesData(closure : @escaping (Bool) -> Void ) {
        let url = urlLatestCollectables
        Alamofire.request(url, method: .get).responseJSON { response in
            let success : Bool = response.result.isSuccess
            // if alamofire says the operation is successful
            if success {
                // set the jsonLatestCollectables buffer to the response
                if let value = response.result.value {
                    self.jsonLatestCollectables = JSON(value)
                }
            }
            // TODO - it woul be good if alamofire has a timeout so w can tell the user there is a networl
            // problem
            // this completion handler signals that the JSON retrieval is done and buffer
            // has results or is nil
            closure(success)
        }
    }
    
    func retrieveLargeThumbnailData(index : Int, closure : @escaping (Bool) -> Void)  {
        if let assetId = getAssetId(index: index){
            //put asset in request
            let url = largeThumbnailURLTemplate.replacingOccurrences(of: "_ASSETID_", with: "\(assetId)")
 //           print ("large thumbnail url")
 //           print(url)
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
                if !jsonSuccess {
                    self.jsonLargeThumbnail = nil
                }
                // TODO same comments as retrieveLatestCollectablesData
                closure(jsonSuccess)
            }
        }
    }
    
    //TODO: fold all these functions into single lines
    
    func getLargeThumbnailUrl() -> String?{
        var thumbnailUrl : String?
        thumbnailUrl = jsonLargeThumbnail?["data"][0]["imageUrl"].stringValue
        return thumbnailUrl
    }
    
    func getAssetId(index : Int) -> String? {
        var assetId : String?
        assetId = jsonLatestCollectables?[index]["AssetId"].stringValue
        return assetId
    }
   
    //get JSON to pass during segue
    func getLatestCollectablesData() -> JSON? {
        return jsonLatestCollectables
    }
    
    // returns "true" or "false" optional sting based on JSON
    // value of isForSale for  given index
    func getIsForSale(index : Int) -> String?{
        var isForSale : String?
        isForSale = jsonLatestCollectables?[index]["IsForSale"].stringValue
        return isForSale
    }
    
    // returns "true" or "false" optional sting based on JSON
    // value of isLimitedUnique for  given index
    func getIsLimitedUnique(index : Int) -> String?{
        var isLimitedUnique : String?
        isLimitedUnique = jsonLatestCollectables?[index]["IsLimitedUnique"].stringValue
        return isLimitedUnique
    }
    
    // returns "true" or "false" optional sting based on JSON
    // value of isLimited for given index
    func getIsLimited(index : Int) -> String?{
        var isLimited : String?
        isLimited = jsonLatestCollectables?[index]["IsLimited"].stringValue
        return isLimited
    }
    
    // returns item name Name optional sting based on JSON
    // value of Name for given index
    func getName(index : Int) -> String?{
        var name : String?
        name = jsonLatestCollectables?[index]["Name"].stringValue
        return name
    }
    
    func getDescription(index : Int) -> String?{
        return jsonLatestCollectables?[index]["Description"].stringValue
    }
    
    // returns updated time optional sting based on JSON
    // value of Updated for given index
    func getUpdated(index : Int) -> String?{
        var updated : String?
        updated = jsonLatestCollectables?[index]["Updated"].stringValue
        return updated
    }
    
    // returns updated time optional sting based on JSON
    // value of Remaining for given index
    func getRemaining(index : Int) -> String?{
        var remaining : String?
        remaining = jsonLatestCollectables?[index]["Remaining"].stringValue
        return remaining
    }
    
    // returns updated time optional sting based on JSON
    // value of Price for given index
    func getPrice(index : Int) -> String?{
        var price : String?
        price = jsonLatestCollectables?[index]["Price"].stringValue
        return price
    }
    
    //Get number on entries (optional) in jsonLatestCollectables buffer
    func getNumEntries() -> Int?{
        var numEntries : Int?
        numEntries = jsonLatestCollectables?.count
        return numEntries
    }
    
    // returns Thumbnail URL optional sting based on JSON
    // value of thumbnailUrl for given index
    func getThumbnailUrl(index : Int) -> String?{
        var thumbnailUrl : String?
        thumbnailUrl = jsonLatestCollectables?[index]["ThumbnailUrl"].stringValue
        return thumbnailUrl
    }
}

