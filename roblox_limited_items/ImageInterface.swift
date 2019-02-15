//  Copyright © 2019 David New. All rights reserved.

import Foundation
import Alamofire

// handle calls to get image objects
class ImageInterface {
    func getImage(url : String, row : Int , callBack : (Int) -> Void) {
        print("will attempt to get image \(url)")
        callBack(row)
    }
    
    
}
