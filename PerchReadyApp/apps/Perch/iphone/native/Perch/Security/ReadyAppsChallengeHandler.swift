/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import UIKit

/**
This class interacts with the MobileFirst Server to authenticate the user upon login. If the user has been timed out,
it will present the user with the login view controller, so they can login.
*/
public class ReadyAppsChallengeHandler : ChallengeHandler {
    
    public var loginViewController : LoginViewController!
    private var isFirstAuth = true
    
    override init(){
        
        let configManager = ConfigManager.sharedInstance
        super.init(realm: configManager.perchRealm)

    }
    
    // Resets variables to original values in the case of a logout
    public func reset() {
        isFirstAuth = true
    }
    
    /**
    Callback method for MobileFirst platform authenticator which determines if the user has been timed out.
    - parameter response:
    */
    override public func isCustomResponse(response: WLResponse!) -> Bool {
        MQALogger.log("--------- isCustomResponse in readyapps------")
        //check for bad token here

        if (response != nil && response.getResponseJson() != nil) {
            let jsonResponse = response.getResponseJson() as NSDictionary
            let authRequired = jsonResponse.objectForKey("authRequired") as! Bool?
            if authRequired != nil {
                return authRequired!
            }
        }
        return false
    }
    
    /**
    Callback method for MobileFirst platform which handles the success scenario
    - parameter response:
    */
    override public func onSuccess(response: WLResponse!) {
        MQALogger.log("Challenge Handler Success: \(response)")
        submitSuccess(response)
        
        let responseJson = response.getResponseJson() as NSDictionary
        LoginDataManager.sharedInstance.parseLoginResponse(responseJson)
        
        if loginViewController != nil {
            loginViewController.setKeychainCredentials()
            loginViewController.loginSuccess()
            loginViewController = nil
        }
    }
    
    /**
    Callback method for MobileFirst platform which handles the failure scenario
    - parameter response:
    */
    override public func onFailure(response: WLFailResponse!) {
        MQALogger.log("Challenger Handler failure: \(response)");
        submitFailure(response)
        
        if loginViewController != nil {
            loginViewController.loginFailed()
        }
    }
    
    /**
    Callback method for MobileFirst platform which handles challenge presented by the server, It shows the login view controllers, so the user
    can re-authenticate.
    - parameter response:
    */
    override public func handleChallenge(response: WLResponse!) {
        // Tell the Pin View controller that auth is required. Pass the Pin VC a callback for when the pin vc is ready for login to be presented
        if isFirstAuth {
            isFirstAuth = false
            
            var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
            while (topVC?.presentedViewController != nil) {
                topVC = topVC!.presentedViewController
            }
            
            if let pinVC = topVC as? PinViewController {
                pinVC.authRequired({[unowned self] in self.presentLogin()})
            }
        } else {
            // In this case, we just need to re-authenticate, so just present the login view controller as normal
            if loginViewController == nil {
                let loginStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                loginViewController = loginStoryboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
            }
            // Present login view controller
            var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
            while (topVC?.presentedViewController != nil) {
                topVC = topVC!.presentedViewController
            }
            
            loginViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            topVC?.presentViewController(loginViewController, animated: true, completion: nil)
        }

    }

    // Function is called by the Pin view controller when the login vc is ready to be presented
    public func presentLogin() {
        if loginViewController == nil {
            let loginStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            loginViewController = loginStoryboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
            
            // Present login view controller
            var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
            while (topVC?.presentedViewController != nil) {
                topVC = topVC!.presentedViewController
            }
            
            loginViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            topVC?.presentViewController(loginViewController, animated: false, completion: nil)
        }
    }
}

