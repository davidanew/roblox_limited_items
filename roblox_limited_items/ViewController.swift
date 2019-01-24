//  Created by David New on 23/01/2019.
//  Copyright © 2019 David New. All rights reserved.

import UIKit

class ViewController: UIViewController, SetUsernameDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Set username view controller sends back username
    func userSetUsername(username: String) {
        print("ViewController : username set to : \(username)")
    }
    
    // set this view controller to be delegate for setUsername function, called from set username view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setUsername" {
            let destinationVC = segue.destination as! SetUsernameController
            destinationVC.delegate = self
        }
    }
}

