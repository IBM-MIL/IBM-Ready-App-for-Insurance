/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
This class manages the Perch Alert View. Anywhere that an alert view needs to be displayed, this manager is what should be used to display it.
*/
public class PerchAlertViewManager: NSObject {
    
    private var perchAlertView: PerchAlertView!
    private var alertDisplayed = false
    
    /**
    Create the singleton instance of the manager
    */
    public class var sharedInstance : PerchAlertViewManager {
        
        struct Singleton {
            static let instance = PerchAlertViewManager()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
    }
    
    /**
    Creates an instance of the alert and sets the appropriate frame
    */
    private func createAlert() {
        if let alertView = perchAlertView {
            return
        }
        perchAlertView = PerchAlertView.instanceFromNib() as PerchAlertView
        perchAlertView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        perchAlertView.alpha = 0.0
    }
    
    /**
    If the alert currently isn't shown, animate the alpha to 0 and then animate the alert on screen
    */
    private func showAlert() {
        if !alertDisplayed {
            UIApplication.sharedApplication().keyWindow?.addSubview(perchAlertView)
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.perchAlertView.alpha = 1.0
                }, completion: { (completed) -> Void in
                    if completed {
                        self.perchAlertView.show()
                        self.alertDisplayed = true
                    }
            })
        } else {
            perchAlertView.show()
        }
    }
    
    /**
    Creates the default instance of the Pin Alert which has a text prompt, textField, and two buttons
    */
    func displayDefaultPinAlert() {
        createAlert()
        self.displayPinAlert(NSLocalizedString("Unable to connect to sensors. \nTry again or sync with a new pin.", comment: ""), rightButtonText: nil, leftButtonText: nil, rightButtonCallback: perchAlertView.syncNewPin, leftButtonCallback: perchAlertView.retrySync)
    }
    
    /**
    Creates an instance of the Pin Alert which has a text prompt, textField, and two buttons
    */
    func displayPinAlert(alertText: String, rightButtonText: String?, leftButtonText: String?, rightButtonCallback: (()->())?, leftButtonCallback: (()->())?) {
        createAlert()
        perchAlertView.makePinAlert(alertText, rightButtonText: rightButtonText, leftButtonText: leftButtonText, rightButtonCallback: rightButtonCallback, leftButtonCallback: leftButtonCallback)
        showAlert()

    }
    
    /**
    Creates a default simple alert with text and two buttons.
    */
    func displayDefaultSimpleAlertTwoButtons(leftButtonCallback: (()->())?, rightButtonCallback: (()->())?) {
        var alertText = NSLocalizedString("Unable to connect with the server, please try again", comment: "")
        var leftButtonText = NSLocalizedString("Try Again", comment: "")
        var rightButtonText = NSLocalizedString("Dismiss", comment: "")
        createAlert()
        self.displaySimpleAlertTwoButtons(alertText, leftButtonText: leftButtonText, rightButtonText: rightButtonText, leftButtonCallback: leftButtonCallback, rightButtonCallback: rightButtonCallback)
    }
    
    /**
    Creates a simple alert with text and two buttons
    */
    func displaySimpleAlertTwoButtons(alertText: String, leftButtonText: String, rightButtonText: String, leftButtonCallback: (()->())?, rightButtonCallback: (()->())?) {
        createAlert()
        perchAlertView.makeSimpleAlertTwoButtons(alertText, leftButtonText: leftButtonText, rightButtonText: rightButtonText, leftButtonCallback: leftButtonCallback, rightButtonCallback: rightButtonCallback)
        showAlert()
    }
    
    /**
    Creates a simple alert with text and a single button
    */
    func displaySimpleAlertSingleButton(alertText: String, buttonText: String, callback: (()->())?) {
        createAlert()
        if let providedCallback = callback {
            perchAlertView.makeSimpleAlertSingleButton(alertText, buttonText: buttonText, buttonCallback: callback)
        } else {
            perchAlertView.makeSimpleAlertSingleButton(alertText, buttonText: buttonText, buttonCallback: hideAlertView)
        }
        showAlert()
    }
    
    /**
    Tells the alert view to animate off screen and show the loading icon
    */
    func showLoadingScreen(loadingText: String) {
        perchAlertView.showSyncingAnimation(loadingText)
    }
    
    /**
    Removes the alertview from the screen and sets to nil
    */
    func hideAlertView() {
        if alertDisplayed {
            alertDisplayed = false
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.perchAlertView.alpha = 0.0
            }, completion: { (completed) -> Void in
                if completed {
                    self.perchAlertView.removeFromSuperview()
                    self.perchAlertView.leftCallback = nil
                    self.perchAlertView.rightCallback = nil
                    self.perchAlertView.simpleCallback = nil
                    self.perchAlertView = nil
                    //self.perchAlertView.resetAlert()
                }
            })
        }
    }
    
}
