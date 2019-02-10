//  Created by David New on 23/01/2019.
//  Copyright © 2019 David New. All rights reserved.

import UIKit
import Alamofire
import SwiftyJSON

class SetUsernameController : UIViewController, UITextFieldDelegate {
    // this class passes identifier date to a RecieveIdentifierDelegate
    var recieverIdentifierDelegate : RecieveIdentifierDelegate?
    // Identifier is a struct containing username and id
    var identifier = Identifier()
    
    // for user to enter their username
    @IBOutlet weak var setUsernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUsernameTextField.delegate = self
    }
    
    // system function called when 'done' key pressed on keyboard. This funtion hides the keybourd
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // system funtion called when 'ok' button is pressed
    @IBAction func okButtonPressed(_ sender: Any) {
        // hide keyboard when 'done' button is pressed
        setUsernameTextField.resignFirstResponder()
        if let username : String = setUsernameTextField.text?.lowercased() {
            //check username, return to main view contoller on success, otherwise display error
            checkUsernameAndReturn(username: username)
        }
        else {
            print("username null error")
            // TODO error pop up
        }
    }
    
    // cancel button hides keybourd and returns to the main view controller, no changes in username
    @IBAction func cancelButtonPresed(_ sender: Any) {
        setUsernameTextField.resignFirstResponder()
        self.dismiss(animated: false, completion: nil)
    }
    
    //check username, return to main view contoller on success, otherwise display error
    func checkUsernameAndReturn (username : String)  {
        if username == "" {
            print("blank username entered")
        }
        else {
            //from https://developer.roblox.com/articles/Web-APIs
            let url : String = "https://api.roblox.com/users/get-by-username?username=\(username)"
            //use Alomofire to get the JSON
            Alamofire.request(url, method: .get).responseJSON {
                response in
                if response.result.isSuccess {
                    print("checkUsername JSON response is success")
                    // use swiftyJSON to get the responce data
                    let valueJSON : JSON = JSON(response.result.value!)
                    // on success the first value will be user Id
                    if let id : Int = valueJSON["Id"].int  {
                        print("Id is \(id)")
                        // Extract the username sting which is part of the JSON
                        let returnedUsername : String = valueJSON["Username"].stringValue
                        // compare returned username with the set username. Success if they are the same
                        if returnedUsername == username {
                            print("returned username : \(returnedUsername)")
                            //fill identifier with username and Id
                            self.identifier.username=username
                            self.identifier.id=id
                            // set username in main view controller using delegate
                            self.recieverIdentifierDelegate?.RecieveIdentifier(identifier: self.identifier)
                            // return to main view controller
                            self.dismiss(animated: false, completion: nil)
                        }
                        else {
                            print("returned username comparison error")
                            self.usernameErrorAlert()
                        }
                    }
                    else {
                        print("JSON Id unwrapping error")
                        self.usernameErrorAlert()
                    }
                }
                else {
                    print("Error checkUsername JSON response is not success")
                    self.usernameErrorAlert()
                }
            }
        }
    }
    
    func usernameErrorAlert (){
        let alert = UIAlertController(title: "Username error", message: "Are you connected to the internet?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}



