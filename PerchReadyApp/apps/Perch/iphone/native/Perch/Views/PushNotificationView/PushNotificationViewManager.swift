/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Class for handling actions related to showing/interacting with a push notification while app in foreground
*/
public class PushNotificationViewManager: NSObject {
    
    private var pushNotificationView : PushNotificationView!
    var callback : (()->())!
    
    
    public class var sharedInstance : PushNotificationViewManager{
        
        struct Singleton {
            static let instance = PushNotificationViewManager()
        }
        return Singleton.instance
    }
    
    /**
    Function that builds and displays a MILAlertView
    
    :param: text     Text to display on the MILAlertView
    :param: callback Callback function to execute when the View Alert button is tapped
    */
    func show(title: String!, message: String!, status: Int!, callback: (()->())!) {
        
        // We want the notification to be shown above the status bar
        self.showViewAboveStatusBar()
        
        // Remove any previous notification
        if self.pushNotificationView != nil{
            self.remove()
        }
        
        self.callback = callback
        self.pushNotificationView = self.buildAlert(title, message: message, status: status, callback: callback)

        UIApplication.sharedApplication().keyWindow?.addSubview(self.pushNotificationView)
        
        // Animate the push notification coming down from the top
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.pushNotificationView.setBottom(self.pushNotificationView.height)
            }, completion: { finished -> Void in
                if finished{
                    self.pushNotificationView.userInteractionEnabled = true
                    NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "hide", userInfo: nil, repeats: false)
                }
        })
        
    }
    
    /**
    Builds a MILAlertView that is initialized with the appropriate data
    
    :param: text     Text to display on the MILAlertView
    :param: callback Callback function to execute when the View Alert button is tapped
    
    :returns: An initialized MILAlertView
    */
    private func buildAlert(title: String!, message: String!, status: Int!, callback: (()->())!)-> PushNotificationView{
        var pushNotificationView : PushNotificationView = PushNotificationView.instanceFromNib() as PushNotificationView
        pushNotificationView.setOriginX(0)
        pushNotificationView.setWidth(UIScreen.mainScreen().bounds.width)
        pushNotificationView.setBottom(0)
        pushNotificationView.setTitle(title)
        pushNotificationView.setMessage(message)
        pushNotificationView.setColor(status)
        pushNotificationView.userInteractionEnabled = false
        pushNotificationView.setNotificationCallback(callback)
        
        return pushNotificationView
    }
    
    /**
    Hides the MILAlertView with an animation
    */
    public func hide() {
        if self.pushNotificationView != nil{
            self.pushNotificationView.userInteractionEnabled = false
            UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.pushNotificationView.setBottom(0)
                }, completion: { finished -> Void in
                    if finished {
                        self.remove()
                    }
            })
        }
        
    }
    
    /**
    Hides the MILAlertView without an animation. Used when the user taps the notification to view the detail.
    */
    public func hideImmediately() {
        if self.pushNotificationView != nil {
            self.pushNotificationView.userInteractionEnabled = false
            self.pushNotificationView.setBottom(0)
            self.remove()
        }
    }
    
    /**
    Removes the MILAlertView from its superview and sets it to nil
    */
    func remove(){
        self.showStatusBarAgain()
        if self.pushNotificationView != nil{
            self.pushNotificationView.removeFromSuperview()
            self.pushNotificationView = nil
        }
    }
    
    /**
    Make sure to show the push notification view over the status bar while in app
    */
    func showViewAboveStatusBar() {
        UIApplication.sharedApplication().delegate?.window??.windowLevel = UIWindowLevelStatusBar
    }
    
    /**
    Helper method to show the status bar again after push notification finishes
    */
    func showStatusBarAgain() {
        UIApplication.sharedApplication().delegate?.window??.windowLevel = UIWindowLevelNormal
    }
   
}
