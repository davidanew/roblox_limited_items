//  Copyright © 2019 David New. All rights reserved.

import Foundation
import SwiftyJSON

//Used buy item detail VC
//the item data needs to be set
//it would be good if ther was a way of abstracting the datatype
//could use a struct with single entry
protocol setLatestCollectablesDelegate {
        func setLatestCollectablesData (latestCollectablesData : ApiInterfaceData , detailsForRow: Int)
}



