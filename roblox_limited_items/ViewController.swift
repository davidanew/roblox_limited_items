//  Created by David New on 23/01/2019.
//  Copyright © 2019 David New. All rights reserved.

import UIKit

//next
//do structure


// protocol for recieving username

protocol SetUsernameDelegate {
    func setUsername(username: String)
}

class ViewController: UIViewController, SetUsernameDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Set username view controller sends back username
    func setUsername(username: String) {
        print("ViewController : username set to : \(username)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setUsername" {
            // set this view controller to be delegate for setUsername function, called from set username view controller
            let destinationVC = segue.destination as! SetUsernameController
            destinationVC.setUsernameDelegate = self
        }
        else if segue.identifier == "showCollectables" {
            // UserCollectablesController is a delegate for this VC so it can be sent the username
            let destinationVC = segue.destination as! UserCollectablesController
            destinationVC.setUsername(username: "my test string")
        }
        
        
    }
}

