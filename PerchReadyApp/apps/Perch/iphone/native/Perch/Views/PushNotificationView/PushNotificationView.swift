/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Class for setting up view of a push notification in app
*/
public class PushNotificationView: UIView {
    
    let criticalStatus = 2
    
    var callback: (()->())!
    var isLoading = false
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet weak var alertIcon: UIImageView!
    
    
    /**
    Initializer for PushNotificationView

    :returns: An instance of PushNotificationView
    */
    class func instanceFromNib() -> PushNotificationView {
        return UINib(nibName: "PushNotificationView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PushNotificationView
    }
    
    /**
    Sets the title on the PushNotificationView's title label

    :param: title The title to be displayed
    */
    func setTitle(title: String!) {
        if title != nil {
            self.titleLabel.text = title
        }
    }
    
    /**
    Sets the message on the PushNotificationView's message label

    :param: message The message to be displayed
    */
    func setMessage(message: String!) {
        if message != nil {
            self.messageLabel.text = message
        }
    }
    
    func setColor(status: Int!) {
        if status != criticalStatus {
            self.titleLabel.textColor = UIColor.whiteColor()
            self.messageLabel.textColor = UIColor.whiteColor()
            self.alertIcon.hidden = true
        }
    }
    
    /**
    Sets the callback for the View Alert button
    
    :param: callback The callback function that is to be executed when the View Alert button is tapped
    */
    func setNotificationCallback(callback: (()->())!) {
        self.callback = callback
    }
    
    @IBAction func dismissButtonTapped(sender: AnyObject) {
        PushNotificationViewManager.sharedInstance.hide()
    }
    
    /**
    Execute the action associated with this notification
    
    :param: sender The UI element that triggered the action
    */
    @IBAction func viewAlertButtonTapped(sender: AnyObject) {
        PushNotificationViewManager.sharedInstance.hideImmediately()
        
        if callback != nil {
            callback()
        }
    }
}
