/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
This protocol is implemented by view controllers that embed this view controller
*/
protocol PinEntryDelegate: class {
    func didEnterPin()
    func pinSyncFinished(error: Bool, errorMessage: String?)
    func fakePinSyncFinished()
}

/**
This view controller is embedded into the PinViewController and SettingsViewController. This view controller handles the UI and logic of the user
entering a pin and then subscribing to that pin.
*/
class EnterPinViewController: UIViewController {
    
    @IBOutlet weak var pinContainerView: UIView!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var pinContainerToSyncButtonVerticalSpace: NSLayoutConstraint!
    @IBOutlet weak var needAPinButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var downArrow: UIButton!
    @IBOutlet weak var upArrow: UIButton!
    
    let screenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    weak var delegate: PinEntryDelegate?
    var syncInProgress = false
    var animationActive = false
    var changingPin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pinTextField.setPlaceholderTextColor(UIColor.perchOrange())
        
        /** Apply kerning (spacing between letters) to buttons */
        self.applyKerningToButtonText()
        
        /** The button for showing a url to access a pin should be initially shown. The "close" button for that section should initially be hidden since they appear to be the same button. */
        self.showNeedAPin()
        
        /** Initially hide the error label */
        self.errorLabel.hidden = true
    }
    
    /** Method for applying kerning to buttons specific to this view controller */
    func applyKerningToButtonText() {
        let syncString = NSAttributedString(string: syncButton.titleLabel!.text!, attributes: [NSKernAttributeName:5.0])
        self.syncButton.titleLabel?.attributedText = syncString
        
        let needAPinString = NSAttributedString(string: needAPinButton.titleLabel!.text!, attributes: [NSKernAttributeName:3.0])
        self.needAPinButton.titleLabel?.attributedText = needAPinString
    }
    

    /** Method for deciding which view should be shown in the pin area.
    Either the pin text field or the url for connecting with sensors. */
    func revealPinOrLink() {
        let animateSlidingViewTime = 0.25
        if self.pinTextFieldVisible() {
            self.showClose()
            
            /** Don't want to allow clicking sync if user can't even see pin text field */
            self.syncButton.enabled = false
            
            /** Push the pin container view down below the sync button */
            self.pinContainerToSyncButtonVerticalSpace.constant = -self.pinContainerView.height
            
            /** Update any other constraints associated with the constraint(s) just updated */
            self.view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(animateSlidingViewTime, animations: { () -> Void in
                /** Animate the constraint changes (make sure they don't happen immediately) */
                self.view.layoutIfNeeded()
            })
        } else {
            self.showNeedAPin()
            self.syncButton.enabled = true
            
            /** Animate the pin container back up above sync button */
            self.pinContainerToSyncButtonVerticalSpace.constant = 0
            
            /** Update any other constraints associated with the constraint(s) just updated */
            self.view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(animateSlidingViewTime, animations: { () -> Void in
                /** Animate the constraint changes (make sure they don't happen immediately) */
                self.view.layoutIfNeeded()
            })
        }
    }
    
    /** Helper method for showing an error message */
    func shakeAndShowError(msg: String?) {
        self.pinContainerView.shakeView()
        self.errorLabel.text = msg
        self.errorLabel.hidden = false
    }
    
    
    // MARK: Helper Methods
    /** Helper method for showing the "Need A Pin?" button instead of the "Close" button.
    These buttons appear to be the same button, but they actually are separate buttons
    that are shown/hidden. Making them the same button while also including an image in the
    button was not as straightforward as you'd think, so went for this solution. */
    func showNeedAPin() {
        self.downArrow.hidden = false
        self.upArrow.hidden = true
    }
    
    /** Helper method for showing the "Close" button instead of the "Need A Pin?" button.
    These buttons appear to be the same button, but they actually are separate buttons
    that are shown/hidden. Making them the same button while also including an image in the
    button was not as straightforward as you'd think, so went for this solution. */
    func showClose() {
        self.downArrow.hidden = true
        self.upArrow.hidden = false
    }
    
    /** Helper method for determining if the pin text field is currently visible. Assumes the pin container view is normally show directly on top of sync button. */
    func pinTextFieldVisible() -> Bool {
        return self.pinContainerToSyncButtonVerticalSpace.constant == 0
    }
    

    
    /** Helper method for determining which direction the keyboard is animating */
    func keyboardAnimatingDown(keyboardFrameEnd: CGRect) -> Bool {
        return screenHeight == keyboardFrameEnd.origin.y
    }
    
    /** Helper method for enabling/disabling all buttons */
    func buttonsEnabled(enabled: Bool) {
        self.syncButton.enabled = enabled
        self.needAPinButton.enabled = enabled
        self.upArrow.enabled = enabled
        self.downArrow.enabled = enabled
    }
    
    // MARK: IBActions
    /** Attempt to sync with pin entered in text field */
    @IBAction func syncButtonTapped(sender: AnyObject) {
        /** If there was a previous error, go ahead and hide it when trying a new pin */
        self.errorLabel.hidden = true
        
        /** Prevent networking call with an invalid pin length or non-numeric pin */
        if self.pinTextField.text!.length != PinViewController.requiredPinLength || Int(self.pinTextField.text!) == nil {
            shakeAndShowError(NSLocalizedString("The pin must be \(PinViewController.requiredPinLength) digits", comment: ""))
            return
        }
        
        // Prevent call if we are already subscribed to this pin
        if self.pinTextField.text == CurrentUser.sharedInstance.userPin && self.pinTextField.text != "0000"{
            shakeAndShowError(NSLocalizedString("You are already subscribed to that pin", comment: ""))
            return
        }
        
        syncInProgress = true
        pinTextField.resignFirstResponder()
        
        /** Only actually try to subscribe to bluemix push if not on simulator because won't work otherwise */
        if UIDevice.currentDevice().model != "iPhone Simulator" && pinTextField.text != "0000" {
            self.delegate?.didEnterPin()
            // If we are not changing the pin, then subscribe to the pin as normal
            if !changingPin {
                PushServiceManager.sharedInstance.subscribe(self.pinTextField.text!) { (error, errorMsg) -> Void in
                    var currentErrorMessage: String?
                    if error {
                        currentErrorMessage = errorMsg!
                        
                        dispatch_async(dispatch_get_main_queue()) { self.delegate?.pinSyncFinished(true, errorMessage: currentErrorMessage) }
                        self.shakeAndShowError(currentErrorMessage)

                    } else {
                        dispatch_async(dispatch_get_main_queue()) { self.delegate?.pinSyncFinished(false, errorMessage: nil) }
                    }
                }
            } else {
                // If we are changing the pin, we first want to try subscribing to the new pin before unsubscribing to all other pins
                PushServiceManager.sharedInstance.subscribeWithoutUnsubscribing(self.pinTextField.text!) { (error, errorMsg) -> Void in
                    var currentErrorMessage: String?
                    if error {
                        currentErrorMessage = errorMsg!
                        
                        dispatch_async(dispatch_get_main_queue()) { self.delegate?.pinSyncFinished(true, errorMessage: currentErrorMessage) }
                        self.shakeAndShowError(currentErrorMessage)
                        
                    } else {
                       dispatch_async(dispatch_get_main_queue()) { self.delegate?.pinSyncFinished(false, errorMessage: nil) }
                    }
                }
            }
        } else {
            /** We are on simulator so just show loading and set appropriate variables to auto transition to next screen after showing loading */
            self.fakePinSync()
        }
    }
    
    /** Since the up/down arrows couldn't be easily added to the same button as the text, just have them as separate buttons that implement the same action */
    @IBAction func arrowTapped(sender: AnyObject) {
        self.revealPinOrLink()
    }
    
    /** Since the up/down arrows couldn't be easily added to the same button as the text, just have them as separate buttons that implement the same action */
    @IBAction func needAPinTapped(sender: AnyObject) {
        self.revealPinOrLink()
    }
    
    /**
    Fakes a pin sync. Used when on the simulator
    */
    func fakePinSync() {
        CurrentUser.sharedInstance.userPin = self.pinTextField.text!
        self.delegate?.fakePinSyncFinished()
    }
}

// MARK: UITextFieldDelegate
extension EnterPinViewController: UITextFieldDelegate {
    /** Limit the number of characters in the text field to requiredPinLength */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= PinViewController.requiredPinLength
    }
    
    /** Don't allow keyboard to become activated during a loading animation or if text field hidden.
    Text field can become hidden if user clicks the "Need A Pin? button to reveal the simulator url */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if animationActive || !pinTextFieldVisible() {
            return false
        }
        return true
    }
}




