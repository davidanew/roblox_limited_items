//  Copyright © 2019 David New. All rights reserved.

import UIKit
import SwiftyJSON

class ItemDetailVC: UIViewController, setLatestCollectablesDelegate{
    var apiInterface = ApiInterface()
    var rowInData : Int?
    
    func setLatestCollectablesData (latestCollectablesData: JSON, detailsForRow: Int) {
        apiInterface.setLatestCollectablesData(latestCollectablesData: latestCollectablesData)
        rowInData = detailsForRow
    }
    


}
