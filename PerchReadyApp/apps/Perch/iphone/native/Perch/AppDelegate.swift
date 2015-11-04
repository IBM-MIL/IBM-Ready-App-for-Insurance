/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

var pushService: AnyObject?
var pushToken: String?

@UIApplicationMain
class AppDelegate: WLAppDelegate {
    var hybridViewController: HybridViewController!
    
    override func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        WL.sharedInstance().initializeWebFrameworkWithDelegate(self)
    
        
        let configManager = ConfigManager.sharedInstance
        if configManager.isDevelopment {
            
            MQALogger.settings().mode = MQAMode.QA
            
        }
        else{
             MQALogger.settings().mode = MQAMode.Market
        }
        
        // Starts a quality assurance session using a dummy key and QA mode
        MQALogger.startNewSessionWithApplicationKey(configManager.mqaApplicationKey)
        
        // Enables the quality assurance application crash reporting
        NSSetUncaughtExceptionHandler(exceptionHandlerPointer)

    
        
        // Set the logger level for Worklight
        OCLogger.setLevel(OCLogger_ERROR)
        
        
        // Choose which Bluemix app to initialize with. We have 2 because we can't simultaneously test sandbox and production push notifications.
        if configManager.isDevelopment {
            MQALogger.log("Initializing with Development Bluemix app", withLevel: MQALogLevelInfo)
            IBMBluemix.initializeWithApplicationId("83d8eed2-9768-41c6-9604-15e17ae564e9", andApplicationSecret: "f9eda4190eb07cbee9ab59fdaa22e2e00e24e887", andApplicationRoute: "RA-Perch.mybluemix.net")
        } else {
            MQALogger.log("Initializing with MQA Bluemix app", withLevel: MQALogLevelInfo)
            IBMBluemix.initializeWithApplicationId("641d1213-6bb3-4cf2-9e5f-c996a549af7e", andApplicationSecret: "82d76b555993f72725e4ecaaf79b7f697ae09862", andApplicationRoute: "Ready-App-4-Perch.mybluemix.net")
        }
    
        pushService = IBMPush.initializeService()
        
        // Only allow notifications on a physical device, this improves unit testing
        if UIDevice.currentDevice().model != "iPhone Simulator" {
            
            MQALogger.log("Registering for notifications")
            
            /// Register for notifications that can use alerts, badges, and sounds
            let notificationType: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        // Set initial status and nav bar attributes
        application.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        UINavigationBar.appearance().translucent = false
        let font = UIFont.karla(17)
        let titleColor = UIColor.perchNavBarGray(1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: titleColor]

        return true
    }
    
    override func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    override func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restorwe your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    override func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        AssetsViewController.reload()
    }
    
    override func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    override func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /**
    Override for being notified when the device has successfully registered for remote notifications.
    
    - parameter application: The application registered
    - parameter deviceToken: The device token provided by APNs
    */
    override func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        pushToken = deviceToken.description
        MQALogger.log("Received deviceToken from APNs: \(pushToken)")
        let pushServiceManager = PushServiceManager.sharedInstance
        
        // Once the device has been successfully registered with APNs, we can register it with Bluemix Push
        pushServiceManager.registerForBluemixPush()
    }
    
    /**
    Override for being notified when APNs registration failed.
    
    - parameter application: The application that failed to register
    - parameter error:       The error sent from APNs
    */
    override func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        MQALogger.log("Failed to get token from APNs, error: \(error)")
    }
    
    /**
    Called when either a push notification is received while app is in the foreground OR after a user taps a push notification that came in while outside the app
    
    - parameter application:       The application receiving the notification
    - parameter userInfo:          Dictionary containing the push notification data
    - parameter completionHandler: Method to call once you are finished fetching any extra data associated with notification
    */
    override func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        MQALogger.log("Received remote notification: \(userInfo.description)")
        
        // Parse out a PushNotification object from the userInfo dictionary
        let pushNotification = PushNotification.fromJsonDict(userInfo)
        
        // Brought here from user touching push notification OUTSIDE of app
        if application.applicationState == UIApplicationState.Inactive || application.applicationState == UIApplicationState.Background {
            
            // Immediately call the action associated with the push notification, because the user has already tapped the notification from outside the app
            pushNotification.callback?()
            
            // We should reload asset overview once we come back to it, because we have updated information about the state of the sensors
            AssetOverviewDataManager.sharedInstance.shouldReload = true
        }
            
        // The app was already in the foreground when notification came in
        else {
            PushNotificationViewManager.sharedInstance.show(pushNotification.title, message: pushNotification.message, status: pushNotification.status, callback: pushNotification.callback)
            
            // Keep asset overview page in sync with sensor statuses
            AssetsViewController.reload()
        }
        
        // Call the completion handler with nothing to avoid warning. We don't have any extra data to fetch associated with this notification at this time.
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    /**
    Invokes the Worklight logout procedure and shows the Perch loading screen.
    */
    func logout(){

        // Invoke Worklight logout procedure
        let configManager = ConfigManager.sharedInstance
        WLClient.sharedInstance().logout(configManager.perchRealm, withDelegate: ReadyAppsLogoutListener())
    }
}

// MARK: WLInitWebFrameworkDelegate

extension AppDelegate : WLInitWebFrameworkDelegate {
    
    func wlInitWebFrameworkDidCompleteWithResult(result: WLWebFrameworkInitResult) {
        if result.statusCode.rawValue == WLWebFrameworkInitResultSuccess.rawValue {
            self.wlInitDidCompleteSuccessfully()
        } else {
            self.wlInitDidFail(result)
        }
    }
    
    private func wlInitDidCompleteSuccessfully() {
        LoginDataManager.sharedInstance
        self.hybridViewController = HybridViewController(coder: NSCoder.empty())
        
        WL.sharedInstance().hideSplashScreen()
        // proceed to initial storyboard
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        self.window?.rootViewController = storyboard.instantiateInitialViewController() as UIViewController!
//        self.window?.makeKeyAndVisible()
    }
    
    private func wlInitDidFail(result: WLWebFrameworkInitResult) {
        let alertView = UIAlertView(title: "Worklight Init Error", message: result.message, delegate: self, cancelButtonTitle: "OK")
        alertView.show()
    }
    
}

