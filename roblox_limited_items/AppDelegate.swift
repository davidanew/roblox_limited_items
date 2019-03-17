//  Copyright © 2019 David New. All rights reserved.

import UIKit
import UserNotifications
import AWSCore
import AWSSNS
import AWSCognito
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    //AWS SNS config
    let platformApplicationArn = "arn:aws:sns:eu-west-1:168606352827:app/APNS_SANDBOX/robloxCollectiblesSNS"
    let topicArn = "arn:aws:sns:eu-west-1:168606352827:robloxCollectiblesTopic"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //setup notfications when the app loads
        notificationCenterSetup()
        return true
    }
    
    func notificationCenterSetup(){
        //set AWS default service configuartion
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.EUWest1, identityPoolId: "eu-west-1:3be9d515-982a-40b5-bd65-d06a773de5bb")
        let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
        //request authorisation from local phone notification center
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if (success) {
                os_log("Notification center authorisation request success", log: Log.general, type: .debug)
                //If authorisation is given then resgister for notifications
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                os_log("Notification center authorisation request failed", log: Log.general, type: .debug)
            }
        }
    }
    

 
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        // Also run notification setup when returning form background, user may have changed settings
        notificationCenterSetup()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("Notifications registration failed", log: Log.general, type: .debug)
    }
    
    // On successful register for notifictions this function is run
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        os_log("Notifications registration success", log: Log.general, type: .debug)
        var tokenString = ""
        // convert device token to a string ready to send to aws
        for i in 0..<deviceToken.count {
            tokenString = tokenString + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        // create AWS SNS endpoint object and populate
        let endpointInput = AWSSNSCreatePlatformEndpointInput()
        endpointInput?.token = tokenString
        endpointInput?.platformApplicationArn = platformApplicationArn
        // attempt to create endpoint
        AWSSNS.default().createPlatformEndpoint(endpointInput!) { (endpointResponse, error) in
            if let error = error {
                os_log("Error in creating endpoint: %@", log: Log.general, type: .debug, error.localizedDescription)
            }
            else if let endpointResponse = endpointResponse, let endpointArn = endpointResponse.endpointArn{
                //endpoint sucessfully created
                os_log("created endpoint: %@", log: Log.general, type: .debug, endpointArn)
                //create subscription request object
                let subscriptionRequest = AWSSNSSubscribeInput()
                subscriptionRequest?.protocols = "application"
                subscriptionRequest?.topicArn = self.topicArn
                subscriptionRequest?.endpoint = endpointResponse.endpointArn
                if let subscriptionRequest = subscriptionRequest {
                    //do subscription request
                    let subscriptionResponse = AWSSNS.default().subscribe(subscriptionRequest)
                    if subscriptionResponse.error == nil {
                        //subscription request completed
                        //create confrim subscription input object to confirm subscription
                        let confirmSubscriptionInput = AWSSNSConfirmSubscriptionInput()
                        confirmSubscriptionInput?.token = endpointResponse.endpointArn
                        confirmSubscriptionInput?.topicArn = self.topicArn
                        if let confirmSubscriptionInput = confirmSubscriptionInput {
                            print("confirming subscription")
                            //do confirm subscription request
                            let confirmSubcriptionResponse = AWSSNS.default().confirmSubscription(confirmSubscriptionInput)
                            if confirmSubcriptionResponse.error == nil {
                                //subscrition confirmed
                                os_log("subscription confirmed", log: Log.general, type: .debug)
                            }
                        }
                    }
                }
            }
        }
    }
}

