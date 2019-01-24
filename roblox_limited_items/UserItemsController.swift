//
//  UserLimitedItems.swift
//  roblox_limited_items
//
//  Created by David New on 23/01/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserLIController: UIViewController {
    
    @IBOutlet weak var jsonView: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        jsonView.text = "I am here"
        let url : String = "https://inventory.roblox.com/v1/users/44993610/assets/collectibles?sortOrder=Asc&limit=10"
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                print("assets JSON response is success")
                let valueJSON : JSON = JSON(response.result.value!)
                print (valueJSON)
                
            }
            else {
                print("Error assets JSON response is not success")
            }
        }
        
    }
    
    
    
}
