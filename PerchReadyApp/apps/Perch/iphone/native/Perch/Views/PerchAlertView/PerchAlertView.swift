/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Custom alert view that can take several forms.
*  Pin Alert View - This will have a text prompt, a text field to enter a pin, and two buttons
*  Simple Alert View Two Buttons - This will have a text prompt and two buttons
*  Simple Alert View Single Button - This will have a text prompt and one button
*/
class PerchAlertView: UIView {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var pinContainerView: UIView!
    @IBOutlet weak var fullWidthButton: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingText: UILabel!
    
    var leftCallback : (()->())!
    var rightCallback : (()->())!
    var simpleCallback : (()->())!
    
    // These bools are used to make sure that two animations to not occur at the same time.
    var offScreenAnimationInProgress = false
    var showAnimationNeeded = false
    
    var screenBounds: CGRect!
    var rightButtonDismisses: Bool = false
    
    var initialAlertHeight: CGFloat!
    let currentUser: CurrentUser = CurrentUser.sharedInstance
    
    /**
    Initializer for PerchAlertView
    
    - returns: And instance of PerchAlertView
    */
    class func instanceFromNib() -> PerchAlertView {
        // NOTE: Reference bundle this way so test target doesn't look in the test target bundle.
        // This is a more agnostic solution so any target can create this view.
        // That said, this is a temporary solution until Apple provides a better way
        let bundle = NSBundle(forClass: self)
        return UINib(nibName: "PerchAlertView", bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as! PerchAlertView
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        
        userInteractionEnabled = true
        screenBounds = UIScreen.mainScreen().bounds
        pinTextField.delegate = self
        pinTextField.setPlaceholderTextColor(UIColor.perchOrange())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        
        loadingImageView.image = UIImage(named: "white_perch_loading0")
        loadingImageView.alpha = 0.0
        loadingText.alpha = 0.0
        
        initialAlertHeight = alertView.size.height
        topConstraint.constant = -alertView.size.height
        self.setNeedsUpdateConstraints()
        self.layoutIfNeeded()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let keyboardFrameEnd: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            // If alertview and keyboard intersect, move alert view 20 pixels above keyboard
            if CGRectIntersectsRect(keyboardFrameEnd, self.frame) {
                topConstraint.constant = topConstraint.constant - 20
                self.setNeedsUpdateConstraints()
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: Create the alerts (set the text, callbacks, etc)
    
    /**
    Create an instance of the pin alert with a text field. This shows/hides the appropriate views and resizes the view as necessary
    */
    func makePinAlert(alertText: String, rightButtonText: String?, leftButtonText: String?, rightButtonCallback: (()->())?, leftButtonCallback: (()->())?) {
        alertLabel.text = alertText
        
        if let rightText = rightButtonText {
            rightButton.setTitle(rightText.capitalizedString, forState: .Normal)
        }
        if let _ = leftButtonText {
            leftButton.setTitle(leftButtonText?.capitalizedString, forState: .Normal)
        }
        rightCallback = rightButtonCallback
        leftCallback = leftButtonCallback
        fullWidthButton.hidden = true
        leftButton.hidden = false
        rightButton.hidden = false
        pinContainerView.hidden = false
        pinAlertResize()
    }
    
    /**
    Create an instance of the pin alert with just text and two buttons. This shows/hides the appropriate views and resizes the view as necessary
    */
    func makeSimpleAlertTwoButtons(alertText: String, leftButtonText: String, rightButtonText: String, leftButtonCallback: (()->())?, rightButtonCallback: (()->())?) {
        alertLabel.text = alertText
        leftButton.setTitle(leftButtonText.capitalizedString, forState: .Normal)
        rightButton.setTitle(rightButtonText.capitalizedString, forState: .Normal)
        leftCallback = leftButtonCallback
        rightCallback = rightButtonCallback
        fullWidthButton.hidden = true
        leftButton.hidden = false
        rightButton.hidden = false
        pinContainerView.hidden = true
        simpleAlertResize()
    }
    
    /**
    Create an instance of the pin alert with just text and a single button. This shows/hides the appropriate views and resizes the view as necessary
    */
    func makeSimpleAlertSingleButton(alertText: String, buttonText: String, buttonCallback: (()->())?) {
        alertLabel.text = alertText
        fullWidthButton.setTitle(buttonText.capitalizedString, forState: .Normal)
        simpleCallback = buttonCallback
        fullWidthButton.hidden = false
        leftButton.hidden = true
        rightButton.hidden = true
        pinContainerView.hidden = true
        simpleAlertResize()
    }
    
    // MARK: Methods for show, hiding the alert view, show animation, etc
    
    /**
    This animates the alert view to come on screen from the top of the screen.
    */
    func show() {
        dispatch_async(dispatch_get_main_queue(), {
            self.showAnimationNeeded = true
            if !self.offScreenAnimationInProgress {
                self.loadingImageView.image = UIImage(named: "white_perch_loading0")
                self.moveAlertOnScreen()
                UIView.animateWithDuration(0.3, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.layoutIfNeeded()
                    self.loadingImageView.alpha = 0.0
                    self.loadingText.alpha = 0.0
                }, completion: { finished -> Void in
                    if finished {
                        self.loadingImageView.alpha = 1.0
                        self.loadingText.alpha = 1.0
                        self.showAnimationNeeded = false
                    }
                })
            }
        })
    }
    
    /**
    This animates the alert view off the screen to the bottoma and then shows a loading animation
    */
    func showSyncingAnimation(loadingLabelText: String?) {
        self.offScreenAnimationInProgress = true
        dispatch_async(dispatch_get_main_queue(), {
            if let text = loadingLabelText {
                self.loadingText.text = text
            }
            
            self.loadingImageView.image = UIImage.animatedImageNamed("white_perch_loading", duration: 3.0)
            self.moveAlertOffScreenBottom()
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.layoutIfNeeded()
            }, completion: { finished -> Void in
                self.offScreenAnimationInProgress = false
                self.moveAlertOffScreenTop()
                self.layoutIfNeeded()
                if self.showAnimationNeeded {
                    self.show()
                }
            })
        })
    }
    
    /**
    Set constraints so that the alert view will be off screen to the top of the page
    */
    private func moveAlertOffScreenTop() {
        topConstraint.constant = -alertView.size.height
        setNeedsUpdateConstraints()
    }
    
    /**
    Sets constraints so that the alert view will be off screen to the bottom of the page
    */
    private func moveAlertOffScreenBottom() {
        topConstraint.constant = screenBounds.size.height
        setNeedsUpdateConstraints()
    }
    
    /**
    Sets constraints so that the alert view will be centered on the page
    */
    private func moveAlertOnScreen() {
        topConstraint.constant = (screenBounds.size.height / 2) - (alertView.size.height / 2)
        setNeedsUpdateConstraints()
    }
    
    /**
    Resizes the height of the alert
    */
    private func simpleAlertResize() {
        alertHeightConstraint.constant = alertHeightConstraint.constant - (pinContainerView.height - 20)
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }
    
    /**
    Resizes the height of the alert
    */
    private func pinAlertResize() {
        if alertHeightConstraint.constant != initialAlertHeight {
            alertHeightConstraint.constant = alertHeightConstraint.constant + pinContainerView.height
            setNeedsUpdateConstraints()
            layoutIfNeeded()
        }
    }
    
    // MARK: Button actions
    /**
    Calls the associated callback
    */
    @IBAction func leftButtonPressed() {
        leftCallback()
    }
    
    /**
    Calls the associated callback
    */
    @IBAction func rightButtonPressed() {
        rightCallback()
    }
    
    /**
    Calls the associated callback
    */
    @IBAction func fullWidthButtonPressed(sender: AnyObject) {
        simpleCallback()
    }
    
    // MARK: Functions for resyncing with Pin
    /**
    This tries to get the Asset Data again. Ideally this function would NOT be embedded in this class.
    */
    func retrySync() {
        if self.pinTextField.isFirstResponder() {
            self.pinTextField.resignFirstResponder()
        }
        self.showSyncingAnimation(nil)
        AssetOverviewDataManager.sharedInstance.retryGetAssetData()
    }
    
    /**
    This starts the process of syncing with a new pin. Ideally this function would NOT be embedded in this class
    */
    func syncNewPin() {
        if self.pinTextField.text!.length != PinViewController.requiredPinLength || Int(self.pinTextField.text!) == nil {
            self.pinTextField.shakeView()
            return
        }
        
        currentUser.userPin = pinTextField.text!
        self.pinTextField.resignFirstResponder()
        if UIDevice.currentDevice().model != "iPhone Simulator" {
            PushServiceManager.sharedInstance.subscribe(self.pinTextField.text!, completion: self.subscribeCallback)
        } else {
            // If on the simulator, fake the callback as if the subscribe function worked
            self.subscribeCallback(false, errorMsg: "No error")
        }
        
        showSyncingAnimation(nil)
    }
    
    /**
    Method to handle result of pin subscription method
    
    - parameter error:    error state if any
    - parameter errorMsg: error message if any
    */
    func subscribeCallback(error: Bool, errorMsg: String?) {
        if error {
            MQALogger.log(NSLocalizedString("Could not subscribe to a new pin", comment: ""), withLevel: MQALogLevelWarning)
            self.show()
        } else {
            AssetOverviewDataManager.sharedInstance.retryGetAssetData()
        }
    }
    
    // Remove keyboard notification observers just in case
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: UITextField Delegate
extension PerchAlertView: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= PinViewController.requiredPinLength
    }
}

