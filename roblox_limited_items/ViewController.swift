//  Created by David New on 23/01/2019.
//  Copyright © 2019 David New. All rights reserved.

import UIKit

//handle nils
//code recieve in other class
//update text in username text box when view is going to be displayed


// protocol for recieving username and id in a struct
protocol RecieveIdentifierDelegate {
    func RecieveIdentifier(identifier: Identifier)
}

class ViewController: UIViewController, RecieveIdentifierDelegate {
    
    // struct containing username and Id
    var identifier = Identifier()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Set username view controller sends back username and Id in 'identifier'
    func RecieveIdentifier(identifier: Identifier) {
        self.identifier = identifier
        print("ViewController : username set to : \(identifier.username!)")
        print("ViewController : id set to : \(identifier.id!)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setUsername" {
            // set this view controller to be delegate for setUsername function, called from setUsernameController
            let destinationVC = segue.destination as! SetUsernameController
            destinationVC.recieverIdentifierDelegate = self
        }
        else if segue.identifier == "showCollectables" {
            // UserCollectablesController is a delegate for this VC so it can be sent the identifier struct
            let destinationVC = segue.destination as! UserCollectablesController
            destinationVC.RecieveIdentifier(identifier: identifier)
        }
        
        
    }
}

