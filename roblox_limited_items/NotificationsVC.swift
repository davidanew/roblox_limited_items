//
//  ViewController.swift
//  roblox_limited_items
//
//  Created by David New on 05/03/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import UIKit
import UserNotifications
import AWSCore
import AWSSNS
import AWSCognito


class NotificationsVC: UIViewController {
    
    let SNSPlatformApplicationArn = "https://eu-west-1.console.aws.amazon.com/sns/v2/home?region=eu-west-1#/applications/arn:aws:sns:eu-west-1:168606352827:app/APNS_SANDBOX/robloxCollectiblesSNS"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
