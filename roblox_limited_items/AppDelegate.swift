//  Copyright © 2019 David New. All rights reserved.

//TODO: look at casting on segue

import UIKit
import UserNotifications
import AWSCore
import AWSSNS
import AWSCognito

//https://medium.com/@thabodavidnyakalloklass/ios-push-with-amazons-aws-simple-notifications-service-sns-and-swift-made-easy-51d6c79bc206


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
//    var authStatus : Bool?
    
    let platformApplicationArn = "arn:aws:sns:eu-west-1:168606352827:app/APNS_SANDBOX/robloxCollectiblesSNS"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        notificationCenterSetup()
        return true
    }
    
    func notificationCenterSetup(){
        //set AWS service configuartion
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.EUWest1, identityPoolId: "eu-west-1:3be9d515-982a-40b5-bd65-d06a773de5bb")
        let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
        //request authorisation from local phone notification center
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if (success) {
                print("Notification center authorisation request success")
                //If authorisation is given then resgister for notifications
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification center authorisation request failed")
            }
            
            DispatchQueue.main.async {
                if let navigationController = self.window?.rootViewController as? UINavigationController {
                    print ("set navigationController")
                    let viewControllers : Array = navigationController.viewControllers
                    //              if let firstViewController = viewControllers.first?.description {
                    //print (viewControllers.first?.nibName)
                    if let latestCollectablesVC = viewControllers.first as? LatestCollectablesVC {
                        print ("found LatestCollectablesVC")
                        latestCollectablesVC.notificationCenterAuthStatus = success
                    }
                }
            }
            
            
                    
                

          
            
           // var rootViewController : UINavigationController
            /*
            var rootViewController : UIViewController?

            
            rootViewController = self.window?.rootViewController
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "InstructionVC") as! InstructionVC
            rootViewController.pushViewController(profileViewController, animated: true)
            return true
            
            self.navigationController!.viewControllers.first
            
            self.window?

            */
            
            /*
            // assuming inital view is tabbar
            let tabBarController = self.window?.rootViewController as UITabBarController
            let tabBarRootViewControllers: Array = tabBarController.viewControllers!
            
            // assuming first tab bar view is the NavigationController with the DestinationsViewController
            let navView = tabBarRootViewControllers[0] as UINavigationController
            let destinationsViewController = navView.viewControllers[0] as DestinationsViewController
            
            if let label = destinationsViewController.label{
                label.text = "Super DUper!"
            }
            else{
                println("Not good 2")
            }
            */
            
            /*
            guard let tabBarController = window?.rootViewController as? UITabBarController,
                let viewControllers = tabBarController.viewControllers else {
                    return true
            }
            for (index, viewController) in viewControllers.enumerated() {
                if let navigationController = viewController as? UINavigationController,
                    let contactsViewController = navigationController.viewControllers.first as? ContactsViewController {
                    contactsViewController.stateController = stateController
                    contactsViewController.favoritesOnly = index == 1
                }
            }
 */
 
            
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
        notificationCenterSetup()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //https://github.com/thaboklass/SpreebieSNSExample/blob/master/SpreebieSNSExample/AppDelegate.swift
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Notifications registration failed")
    }
    
    // On successful register for notifictions this function is run
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print ("Notifications registration success")
        var tokenString = ""
        // convert device token to as string ready to send to aws
        for i in 0..<deviceToken.count {
            tokenString = tokenString + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print("device token \(tokenString)")
        // create AWS SNS endpoint object and populate
        let endpointInput = AWSSNSCreatePlatformEndpointInput()
        endpointInput?.token = tokenString
        endpointInput?.platformApplicationArn = platformApplicationArn
        // attempt to create endpoint
        AWSSNS.default().createPlatformEndpoint(endpointInput!) { (endpointResponse, error) in
            print ("Attempted to create endpoint, recieved \(String(describing: endpointResponse)) , \(String(describing: error))")
            //TODO: do topic subcription
        }
        
 
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

