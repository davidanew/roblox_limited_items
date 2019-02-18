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
    //buffer for latest collectables
    var jsonLatestCollectables : JSON?
    
    //construct full url for collectables
    init() {
        urlLatestCollectables = urlLatestCollectablesBase + String(numLatestCollectables)
    }
    
    // Function to get the latest collectables list from roblox
    // this function is called externally to the class. the call must include a handler that handles the return
    // of this function. Most lightly this handler will run gui update.
    // currently the callback is sent a string, this will likley have to change as it is not needed
    // TODO = remove redundant string in completion handler - should be a bool?
    // bool would be good as refresh won't be run
    func getLatestCollectables(completionHandler : @escaping ([String]) -> Void ) {
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
            completionHandler([""])
        }
    }
    
    func printJson() {
        //this just for debugging
        if let json = jsonLatestCollectables {
            print(json)
        }
    }
    
    //TODO, funtion to return sinf entry JSON and also to set JSON
    // this is needed for abstaction of passing data to detail VC
    
    // returns "true" or "false" optional sting based on JSON
    // value of isForSale for  given index
    func getIsForSale(index : Int) -> String?{
        let isForSale : String?
        isForSale = jsonLatestCollectables?[index]["IsForSale"].stringValue
        return isForSale
    }
    
    
    // returns "true" or "false" optional sting based on JSON
    // value of isLimitedUnique for  given index
    func getIsLimitedUnique(index : Int) -> String?{
        let isLimitedUnique : String?
        isLimitedUnique = jsonLatestCollectables?[index]["IsLimitedUnique"].stringValue
        return isLimitedUnique
    }
    
    // returns "true" or "false" optional sting based on JSON
    // value of isLimited for given index
    func getIsLimited(index : Int) -> String?{
        let isLimited : String?
        isLimited = jsonLatestCollectables?[index]["IsLimited"].stringValue
        return isLimited
    }
    
    // returns item name Name optional sting based on JSON
    // value of Name for given index
    func getName(index : Int) -> String?{
        let name : String?
        name = jsonLatestCollectables?[index]["Name"].stringValue
        return name
    }
    
    // returns updated time optional sting based on JSON
    // value of Updated for given index
    func getUpdated(index : Int) -> String?{
        let updated : String?
        updated = jsonLatestCollectables?[index]["Updated"].stringValue
        return updated
    }
    
    
    // returns updated time optional sting based on JSON
    // value of Remaining for given index
    func getRemaining(index : Int) -> String?{
        let remaining : String?
        remaining = jsonLatestCollectables?[index]["Remaining"].stringValue
        return remaining
    }
    
    // returns updated time optional sting based on JSON
    // value of Price for given index
    func getPrice(index : Int) -> String?{
        let price : String?
        price = jsonLatestCollectables?[index]["Price"].stringValue
        return price
    }
    
    //Get number on entries (optional) in jsonLatestCollectables buffer
    func getNumEntries() -> Int?{
        let numEntries : Int?
        numEntries = jsonLatestCollectables?.count
        return numEntries
    }
    
    // returns Thumbnail URL optional sting based on JSON
    // value of thumbnailUrl for given index
    func getThumbnailUrl(index : Int) -> String?{
        let thumbnailUrl : String?
        thumbnailUrl = jsonLatestCollectables?[index]["ThumbnailUrl"].stringValue
        return thumbnailUrl
    }
}

