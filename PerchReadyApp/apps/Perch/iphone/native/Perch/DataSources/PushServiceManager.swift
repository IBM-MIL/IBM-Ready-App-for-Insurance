/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Class for handling all Bluemix Push API calls.
*/
public class PushServiceManager: NSObject {
    
    let currentUser = CurrentUser.sharedInstance
    
    /// Push response error codes
    let pinDoesNotExistErrorCode = "FPWSE0001E"
    let alreadySubscribedToPinErrorCode = "FPWSE0002E"
    let noDeviceId = "FPWSE0005E"
    
    public class var sharedInstance: PushServiceManager {
        struct Singleton {
            static let instance = PushServiceManager()
        }
        return Singleton.instance
    }
    
    /**
    Unsubscribe from all tags the device is currently subscribed to.
    
    - parameter completion: what to do after unsubscribing from all tags finishes
    */
    func unsubscribeFromAllTags(completion: () -> Void) {
        
        /**
        *  The first thing to do is get all the tags the device is currently subscribed to.
        */
        /*pushService!.getSubscriptions().continueWithBlock { (task: BFTask!) in
            if let error = task.error() {
                
                /// If Push couldn't give us back the currently subscribed tags, carry own with completion passed in, because we can't continue unsubscribing if we don't know what tags to unsubscribe from.
                completion()
                MQALogger.log("Failure during getSubscriptions operation")
                MQALogger.log(error.description)
                
            } else {
                
                /// We have the list of tags to unsubscribe from so parse the data and loop through unsubscribing from each one.
                let dictResult = task.result() as? NSDictionary
                let subscriptions = dictResult?["subscriptions"] as? NSArray
                if subscriptions?.count > 0 {
                    if let subscriptions = subscriptions {
                        
                        /// We use a counter to know when we have unsubscribed from the last tag
                        var counter = 0
                        
                        /// Loop through every tag and unsubscribe from it.
                        subscriptions.enumerateObjectsUsingBlock { item, index, stop in
                            let pin = item as! String
                            pushService!.unsubscribeFromTag(pin).continueWithBlock { (task: BFTask!) in
                                counter++
                                
                                if let _ = task.error() {
                                    MQALogger.log("Could not unsubscribe from \(pin)")
                                } else {
                                    MQALogger.log("Successfully unsubscribed from \(pin)")
                                }
                                
                                // Only want to call completion block after all tags have been unsubscribed. As opposed to calling completion block after each tag is unsubscribed.
                                if counter == subscriptions.count {
                                    completion()
                                }
                                
                                return nil
                            }
                        }
                    } else {
                        ///  subscriptions was nil, so can't unsubscribe. Just carry on with completion block without unsubscribing.
                        completion()
                    }
                } else {
                    /// subscriptions came back empty, so since we aren't subscribed to any tags, carry on with completion block
                    completion()
                }
            }
            return nil
        }*/
    }
    
    /**
    Subscribe to a pin the user entered in the pin text field
    
    - parameter pin:        The pin to subscribe to
    - parameter completion: What to do after the pin subscription completes
    */
    func subscribe(pin: String, completion: (error: Bool, errorMsg: String?) -> Void) {
        /*if let pushService: AnyObject = pushService {
            
            /// First we want to unsubscribe from all tags before subscring to our desired tag. This ensures that salesmen
            /// who are demoing the app don't accidentally keep an old tag around that another salesman is using actively
            self.unsubscribeFromAllTags { () -> Void in
                MQALogger.log("Completed unsubscribing from all tags. Now starting the subscription to new tag (\(pin)).")
                
                /// Once unsubscring has finished (either successfully or unsuccesfully) proceed with subscribing to the tag
                pushService.subscribeToTag(pin).continueWithBlock { (task: BFTask!) in
                    
                    /// Determine if there was an error with the subscription
                    if let error = task.error() {
                        let userInfo = error.userInfo as! [String:AnyObject]
                        let code = userInfo["code"] as? String
                        if let code = code {
                            // If initial push registration didn't work (maybe because internet wasn't on when the app started), try again here
                            if code == self.noDeviceId { self.registerForBluemixPush() }
                            completion(error: true, errorMsg: self.translateErrorCodeIntoReadableMessage(code))
                        } else {
                            completion(error: true, errorMsg: self.translateErrorCodeIntoReadableMessage("UnknownError"))
                        }
                    } else {
                        // Successfuly completed subscribing, so set the current user's pin
                        self.currentUser.userPin = pin
                        completion(error: false, errorMsg: nil)
                    }
                    
                    return nil
                }
            }
        } else {
            completion(error: true, errorMsg: NSLocalizedString("Application has not been initialized properly with Bluemix Push in AppDelegate", comment: ""))
        }*/
    }
    
    /**
    Subscribe to a pin the user entered in the pin text field without unsubscribing all pins. This is used when changing the pin in the ChangePinVC
    
    - parameter pin:        The pin to subscribe to
    - parameter completion: What to do after the pin subscription completes
    */
    func subscribeWithoutUnsubscribing(pin: String, completion: (error: Bool, errorMsg: String?) -> Void) {
        /*if let pushService: AnyObject = pushService {

            /// Proceed with subscribing to the tag
            pushService.subscribeToTag(pin).continueWithBlock { (task: BFTask!) in
                
                /// Determine if there was an error with the subscription
                if let error = task.error() {
                    let userInfo = error.userInfo as! [String:AnyObject]
                    let code = userInfo["code"] as? String
                    if let code = code {
                        // If initial push registration didn't work (maybe because internet wasn't on when the app started), try again here
                        if code == self.noDeviceId { self.registerForBluemixPush() }
                        completion(error: true, errorMsg: self.translateErrorCodeIntoReadableMessage(code))
                    } else {
                        completion(error: true, errorMsg: self.translateErrorCodeIntoReadableMessage("UnknownError"))
                    }
                } else {
                    // Successfuly completed subscribing, so set the current user's pin and unsubscribe from all other pins
                    self.currentUser.userPin = pin
                    self.unsubscribeExcludingCurrentPin() { () -> Void in
                        completion(error: false, errorMsg: nil)
                    }
                }
                
                return nil
            }
        } else {
            completion(error: true, errorMsg: NSLocalizedString("Application has not been initialized properly with Bluemix Push in AppDelegate", comment: ""))
        }*/
    }
    
    /**
    Unsubscribe from all pins except for the user's current pin. This is used when the user changes their pin.
    
    - parameter completion: What to do after the pin subscription completes
    */
    func unsubscribeExcludingCurrentPin(completion: () -> Void) {
        /**
        *  The first thing to do is get all the tags the device is currently subscribed to.
        */
        /*pushService!.getSubscriptions().continueWithBlock { (task: BFTask!) in
            if let error = task.error() {
                
                /// If Push couldn't give us back the currently subscribed tags, carry own with completion passed in, because we can't continue unsubscribing if we don't know what tags to unsubscribe from.
                completion()
                MQALogger.log("Failure during getSubscriptions operation")
                MQALogger.log(error.description)
                
            } else {
                
                /// We have the list of tags to unsubscribe from so parse the data and loop through unsubscribing from each one.
                let dictResult = task.result() as? NSDictionary
                let subscriptions = dictResult?["subscriptions"] as? NSArray
                if subscriptions?.count > 0 {
                    if let subscriptions = subscriptions {
                        
                        /// We use a counter to know when we have unsubscribed from the last tag
                        var counter = 0
                        
                        /// Loop through every tag and unsubscribe from it, except for the user's current pin
                        subscriptions.enumerateObjectsUsingBlock { item, index, stop in
                            let pin = item as! String
                            if pin != self.currentUser.userPin {
                                pushService!.unsubscribeFromTag(pin).continueWithBlock { (task: BFTask!) in
                                    counter++
                                    
                                    if let _ = task.error() {
                                        MQALogger.log("Could not unsubscribe from \(pin)")
                                    } else {
                                        MQALogger.log("Successfully unsubscribed from \(pin)")
                                    }
                                    
                                    // Only want to call completion block after all tags have been unsubscribed. As opposed to calling completion block after each tag is unsubscribed.
                                    if counter == subscriptions.count {
                                        completion()
                                    }
                                    
                                    return nil
                                }
                            } else {
                                counter++
                                // Only want to call completion block after all tags have been unsubscribed. As opposed to calling completion block after each tag is unsubscribed.
                                if counter == subscriptions.count {
                                    completion()
                                }
                            }
                        }
                    } else {
                        ///  subscriptions was nil, so can't unsubscribe. Just carry on with completion block without unsubscribing.
                        completion()
                    }
                } else {
                    /// subscriptions came back empty, so since we aren't subscribed to any tags, carry on with completion block
                    completion()
                }
            }
            return nil
        }*/
    }
    
    /**
    Helper method for displaying user friendly strings based on the error code returned from Bluemix Push
    
    - parameter code: The error code returned from Bluemix Push
    
    - returns: Human readable error string
    */
    func translateErrorCodeIntoReadableMessage(code: String) -> String {
        switch code {
        case pinDoesNotExistErrorCode:
            return NSLocalizedString("The specified pin does not exist", comment: "")
        case alreadySubscribedToPinErrorCode:
            return NSLocalizedString("You are already subscribed to that pin", comment: "")
        default:
            return NSLocalizedString("An unknown error occurred", comment: "")
        }
    }
    
    /**
    Helper method for registering to the Bluemix Push service
    */
    func registerForBluemixPush() {
        // These values are not actually used for anything, but could potentially be used to target a certain user (all of that user's devices)
        let consumerId = "perchConsumer"
        let alias = "perchAlias"
        
        MQALogger.log("Registering device...")
        MQALogger.log("Consumer Id :: \(consumerId)\nAlias :: \(alias)")
        
        /*if let pushService: AnyObject = pushService {
            
            // Register the device with Bluemix Push. Pass in the push token received from apns in app delegate.
            pushService.registerDevice(alias, withConsumerId: consumerId, withDeviceToken: pushToken).continueWithBlock { (task: BFTask!) in
                if let error = task.error() {
                    MQALogger.log("Failure registering device...")
                    MQALogger.log(error.description)
                } else {
                    MQALogger.log("Successfully registered device...")
                }
                
                return nil
            }
        } else {
            MQALogger.log("Push service is nil. Possibly wrong class name.")
        }*/
    }
   
}
