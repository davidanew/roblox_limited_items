//  Copyright © 2019 David New. All rights reserved.

import Foundation
import Alamofire

// handle calls to get image objects
class ImageInterface {
    // dictionary to act as cache for images
    var imageCache: [String:UIImage] = [:]
    
    // This funtion returns the image if it is in the cache. Otherwise it calls alomofire with user supplied callback
    // this callback most likely will trigger a refresh
    func getImage(url : String, row : Int , closure : @escaping (Int) -> Void) -> UIImage? {
        if let image = imageCache[url] {
            // image at that URL is already in the cache
            return image
        }
        else {
            // Image is not in the cache
            Alamofire.request(url).response{ response in
 //             // alamofire callback
                if let data = response.data{
                    // data is not nil
                    let image = UIImage(data:data)
                    // put image in cache
                    self.imageCache[url] = image
                    // callBack to say data is valid
                    closure(row)
                }
                //TODO - some error checking, is there a timout from alomofire
                //Do we need this?
            }
            return nil
        }
    }
}
