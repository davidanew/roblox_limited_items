//  Copyright © 2019 David New. All rights reserved.

import Foundation
import Alamofire

// handle calls to get image objects
class ImageInterface {
    // dictionary to act as cache for images
    var imageCache: [String:UIImage] = [:]

    func getImage(url : String, row : Int , callBack : @escaping (Int) -> Void) -> UIImage? {
        if let image = imageCache[url] {
 //           print("image in cache")
            return image
        }
        else {
 //           print("image not in cache")

            Alamofire.request(url).response{ response in
 //               print("alamofire cb")
                if let data = response.data{
                    let image = UIImage(data:data)
                    self.imageCache[url] = image
                    callBack(row)
                }
            }
            return nil
        }
    }
}
