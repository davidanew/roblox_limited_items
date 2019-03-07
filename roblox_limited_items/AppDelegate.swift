//  Copyright © 2019 David New. All rights reserved.

import UIKit
import UserNotifications
//import AWSCore
//import AWSSNS
//import AWSCognito

//https://medium.com/@thabodavidnyakalloklass/ios-push-with-amazons-aws-simple-notifications-service-sns-and-swift-made-easy-51d6c79bc206


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    let SNSPlatformApplicationArn = "https://eu-west-1.console.aws.amazon.com/sns/v2/home?region=eu-west-1#/applications/arn:aws:sns:eu-west-1:168606352827:app/APNS_SANDBOX/robloxCollectiblesSNS"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if (success) {
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
                    print ("User allowed settings \(settings)")
                })
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            print (success)
//            print (error)
        }
        return true
    }
    
    /*
    
    func registerForPushNotifications(application: UIApplication) {
        /// The notifications settings
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted)
                {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                else{
                    //Do stuff if unsuccessful...
                }
            })
        } else {
            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
 
 */
 
 
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //https://github.com/thaboklass/SpreebieSNSExample/blob/master/SpreebieSNSExample/AppDelegate.swift
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print ("didRegisterForRemoteNotificationsWithDeviceToken")
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError")
    }
        
 
/*
        /// Attach the device token to the user defaults
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        print(token)
        
        UserDefaults.standard.set(token, forKey: "deviceTokenForSNS")
        
        /// Create a platform endpoint. In this case,  the endpoint is a
        /// device endpoint ARN
        let sns = AWSSNS.default()
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.token = token
        request?.platformApplicationArn = SNSPlatformApplicationArn
        sns.createPlatformEndpoint(request!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
                if let endpointArnForSNS = createEndpointResponse.endpointArn {
                    print("endpointArn: \(endpointArnForSNS)")
                    UserDefaults.standard.set(endpointArnForSNS, forKey: "endpointArnForSNS")
                }
            }
        })
    }
*/

}

