/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class Utils: NSObject {
    
    /**
    Gets a UIImage of a view aka a screenshot
    
    - parameter view: UIView to capture
    
    - returns: UIImage of the view
    */
    class func imageWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img;
    }
    
    /**
    Helper method for executing code after a delay
    
    - parameter delay:   The amount of time to delay in seconds
    - parameter closure: The code to execute after teh delay
    */
    class func delay(delay: Double, closure: ()->()) {
        // Dispatch the waiting period asynchronously
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            // Execute the code back on the main thread
            dispatch_get_main_queue(), closure)
    }
    
    /**
    Helper method for making a transition from one direction to the other.
    
    - parameter direction: The direction to make the transition
    
    - returns: The Core animation transition to use
    */
    class func customTransitionFromDirection(direction: String) -> CATransition {
        let customTransition = CATransition()
        customTransition.duration = 0.3
        customTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        customTransition.type = kCATransitionPush
        customTransition.subtype = direction
        return customTransition
    }
    
    /**
    Helper method for opening the phone with a default number
    */
    class func openPhone() {
        Utils.openPhone(CurrentUser.sharedInstance.insurance.phoneNumber)
    }
    
    /**
    Helper method for opening email with a default email
    */
    class func openEmail() {
        Utils.openEmail(CurrentUser.sharedInstance.insurance.emailAddress)
    }
    
    /**
    Helper method for opening maps with a default address
    */
    class func openMaps() {
        Utils.openMaps(CurrentUser.sharedInstance.insurance.location)
    }
    
    /**
    Helper method for opening the phone app
    
    - parameter phoneNumber: The phone number to open with
    */
    class func openPhone(phoneNumber: String) {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
    }
    
    /**
    Helper method for opening email app
    
    - parameter email: The email send address
    */
    class func openEmail(email: String) {
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto://\(email)")!)
    }
    
    /**
    Helper method for opening maps
    
    - parameter address: The address to open in maps
    */
    class func openMaps(address: String) {
        let encodedAddress = address.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?q=\(encodedAddress)")!)
    }
}
