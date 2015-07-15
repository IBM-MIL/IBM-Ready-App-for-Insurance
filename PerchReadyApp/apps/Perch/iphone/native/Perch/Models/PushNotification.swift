/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Model class for a push notification that is received from APNs
*/
class PushNotification: NSObject {
    
    var title: String?
    var message: String?
    var status: Int?
    var badgeNumber: Int?
    var callback: (()->Void)?
    
    init(title: String, message: String, status: Int, callback: ()->Void) {
        self.title = title
        self.message = message
        self.status = status
        self.callback = callback
    }
    
    /**
    Push notification data comes in the following json structure:
    [
        {
            "SN": "0xpdj",
            "text": "this is text",
            "title": "this is title",
            "detail": "this is detail",
            "status": 2,
            "deviceClassId": "10003",               // tells you which kind of sensor sent the push notification
            "aps": {
                "alert": {
                    "action-loc-key": null,
                    "body": "this is the message"
                },
                "badge": 1,
                "sound": "default.caf"
            }
        }
    ]
    */
    
    /**
    Method for parsing a push notification dictionary and converting it into a PushNotification object
    
    :param: jsonDict The dictionary to parse
    
    :returns: The PushNotification model object created
    */
    class func fromJsonDict(jsonDict: [NSObject: AnyObject]) -> PushNotification {
        var localTitle = ""
        var localMessage = ""
        var localBadgeNumber = 0
        var localDeviceClassId = ""
        var localStatus = 2
        
        // Parse title from top level json object
        if let title = jsonDict["title"] as? String {
            localTitle = title
        }
        
        // Parse device so know which screen to go to on a push notification tap
        if let deviceClassId = jsonDict["deviceClassId"] as? String {
            localDeviceClassId = deviceClassId
        }
        
        // Parse status so we know if this is a critical alert
        if let status = jsonDict["status"] as? String {
            localStatus = status.toInt()!
        }
        
        // Need to parse to a deeper level to get the message
        if let notificationDict: [NSObject: AnyObject] = jsonDict["aps"] as? Dictionary {
            
            // Parse for the alert info
            if let alertDict: [NSObject: AnyObject] = notificationDict["alert"] as? Dictionary {
                
                // Finally this is the actual message
                if let message = alertDict["body"] as? String {
                    localMessage = message
                }
            }
            
            // Parse for the badge number and set the home screen icon to show that badge number
            if let badgeNumber = notificationDict["badge"] as? Int {
                UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber
            }
        }
        
        // Pass the sensor type to the callback, so it knows what sensor to show
        let localCallback = callbackForPushNotification(localDeviceClassId)
        
        return PushNotification(title: localTitle, message: localMessage, status: localStatus, callback: localCallback)
    }
    
    /**
    Method for setting up the callback on a push notification tap
    
    :param: device The type of sensor/device to show when going to detail of the alert
    */
    class func callbackForPushNotification(device: String) -> (()->Void) {
        return {
            let currentVC = UIViewController.currentViewController()
            
            // Don't proceed to detail of alert if we haven't logged in yet
            if currentVC.isKindOfClass(LoginViewController) {
                let alert = UIAlertController(title: "Log In", message: "Please log in before viewing alert details.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                currentVC.presentViewController(alert, animated: true, completion: nil)
            } else {
                currentVC.view.window?.layer.addAnimation(Utils.customTransitionFromDirection(kCATransitionFromRight), forKey: nil)
                var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                var detailVC = storyboard.instantiateViewControllerWithIdentifier("AlertDetailViewController") as? AlertDetailViewController
                detailVC?.currentSensor = device
                currentVC.presentViewController(detailVC!, animated: false, completion: nil)
            }
        }
    }
}
