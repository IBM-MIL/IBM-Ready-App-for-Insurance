/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2014, 2015. All Rights Reserved.
*/

import Foundation
import UIKit

/**
This class handles the success/failures relating to the user logout
*/
class ReadyAppsLogoutListener : NSObject, WLDelegate {
    
    /**
    Handles the logout user success scenario
    */
    func onSuccess(response: WLResponse!) {
    
        MQALogger.log("onSuccess in LogoutListener")
        MQALogger.log("Successfully logged out of MobileFirst Server. Response: \(response)");
        
        // Clear user's credentials from the keychain if they exist
        let configManager = ConfigManager.sharedInstance
        if KeychainWrapper.hasValueForKey(configManager.UsernameKey) {
            KeychainWrapper.removeObjectForKey(configManager.UsernameKey)
        }
        if KeychainWrapper.hasValueForKey(configManager.PasswordKey) {
            KeychainWrapper.removeObjectForKey(configManager.PasswordKey)
        }
        
        // Reset some key variabels to ensure a smooth pin/login process
        LoginDataManager.sharedInstance.resetChallengeHandler()
        CurrentUser.sharedInstance.demoMode = false
        CurrentUser.sharedInstance.hasBeenAskedToEnterDemoMode = false
        CurrentUser.sharedInstance.userPin = ""
        
        // Unsubscribe from the pin
        PushServiceManager.sharedInstance.unsubscribeFromAllTags(transistionToLogin)
    }
    
    /**
    Handles the logout user failure scenario
    */
    func onFailure(response: WLFailResponse!) {
        MQALogger.log("onFailure in LogoutListener")
        MQALogger.log("Failed logging out of MobileFirst Server. Response: \(response)");
    }
    
    func onPreExecute(){
        
    }
    
    /**
    This is the function that performs the animation back to the initial controller (Pin View Controller)
    */
    func transistionToLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            // Go back to the initial view of the application. Will require a
            // reentry of the pin, as well as logging in again
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = storyboard.instantiateInitialViewController() as? PinViewController {
                
                // get the top VC
                var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
                while (topVC?.presentedViewController != nil) {
                    topVC = topVC!.presentedViewController
                }
                
                // Apply a transistion to the window
                let transistion = CATransition()
                transistion.duration = 0.4
                transistion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut )
                transistion.type = kCATransitionReveal
                transistion.subtype = kCATransitionFromBottom
                appDelegate.window?.layer.addAnimation(transistion, forKey: kCATransition)
                
                // Transistion!
                UIView.transitionWithView(appDelegate.window!, duration: 0.4, options: [], animations: { () -> Void in
                    appDelegate.window?.rootViewController = viewController
                    }, completion: { (completed) -> Void in
                        topVC!.dismissViewControllerAnimated(false, completion: nil)
                })
            }
        })
    }
}