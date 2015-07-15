/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import LocalAuthentication

/**
*  This view controller presents the user with the Login screen.
*/
public class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var containingView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftUsernameConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightUsernameConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftPasswordConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightPasswordConstraint: NSLayoutConstraint!
    
    
    var loggingInView: PerchLoadView!
    
    let loginManager = LoginDataManager.sharedInstance
    let configManager = ConfigManager.sharedInstance
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide everything for now, will reveal once view appears
        containingView.alpha = 0.0
        loginButton.alpha = 0.0
        
        // Listen for when the keyboard will appear so that we can change the screen when it happens
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Apply kerning to the login button
        var loginString = NSAttributedString(string: NSLocalizedString("ENTER", comment: ""), attributes: [NSKernAttributeName:5.0, NSForegroundColorAttributeName: UIColor.whiteColor()])
        self.loginButton.setAttributedTitle(loginString, forState: UIControlState.Normal)
        
        // Set placeholder text to orange
        var attrUsername = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        usernameTextField.attributedPlaceholder = attrUsername
        var attrPassword = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.attributedPlaceholder = attrPassword
        
        // Create logging in view
        loggingInView = UINib(nibName: "PerchLoadView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PerchLoadView
        loggingInView.frame = view.frame
        loggingInView.alpha = 0.0
        self.view.addSubview(loggingInView)

    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check touch ID, also dont present touch ID login when in demo mode
        if configManager.useTouchID() && !CurrentUser.sharedInstance.demoMode {
            touchID()
        }
        
        // if iPhone 6, squish the username and password fields
        if UIScreen.mainScreen().bounds.size.height == 736 {
            leftUsernameConstraint.constant = 50
            rightUsernameConstraint.constant = 20
            leftPasswordConstraint.constant = 50
            rightPasswordConstraint.constant = 20
        }
        view.updateConstraints()
    }
    
    /**
    Once the view appears, fade in the UI Elements. If demo mode has been selected, auto-fill the username and login and sign in.
    */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.containingView.alpha = 1.0
            self.loginButton.alpha = 1.0
        }, completion: { (completed) -> Void in
            if completed {
                if CurrentUser.sharedInstance.demoMode {
                    self.usernameTextField.text = "user1"
                    self.passwordTextField.text = "password1"
                    self.attempLogin(self.loginButton)
                } else {
                    self.usernameTextField.becomeFirstResponder()
                }
            }
        })
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /**
    Processes what to do if touch ID is enabled and called. This handles if the touch id succeeds, fails, or is not enabled on the device.
    */
    func touchID(){
        // Get the local authentication context:
        var context = LAContext()
        var error : NSError?
        
        // Test if TouchID fingerprint authentication is available on the device and a fingerprint has been enrolled.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:&error) {
            
            // evaluate
            var reason = NSLocalizedString("Authenticate to login", comment: "Touch ID authentication message")
            
            context.localizedFallbackTitle = ""
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: {
                (success: Bool, authenticationError: NSError?) -> Void in
                
                // check whether evaluation of fingerprint was successful
                if success {
                    // fingerprint validation was successful
                    MQALogger.log("Fingerprint validated.")
                    if let username: String? = KeychainWrapper.stringForKey(self.configManager.UsernameKey){
                        if let password: String? = KeychainWrapper.stringForKey(self.configManager.PasswordKey){
                            dispatch_async(dispatch_get_main_queue(), {
                                self.usernameTextField.text = username
                                self.passwordTextField.text = password
                                self.attempLogin(self.loginButton)
                            })
                        }
                        
                    }
                } else {
                    // fingerprint validation failed
                    // get the reason for validation failure
                    var failureReason = "unable to authenticate user"
                    switch authenticationError!.code {
                    case LAError.AuthenticationFailed.rawValue:
                        failureReason = "authentication failed"
                    case LAError.UserCancel.rawValue:
                        failureReason = "user canceled authentication"
                    case LAError.UserFallback.rawValue:
                        failureReason = "user chose password"
                    case LAError.SystemCancel.rawValue:
                        failureReason = "system canceled authentication"
                    case LAError.PasscodeNotSet.rawValue:
                        failureReason = "passcode not set"
                    default:
                        failureReason = "unable to authenticate user"
                    }
                    
                    MQALogger.log("Fingerprint validation failed: \(failureReason).");
                }
            })
        } else {
            //get more information
            var reason = "Local Authentication not available"
            switch error!.code {
            case LAError.TouchIDNotAvailable.rawValue:
                reason = "Touch ID not available on device"
            case LAError.TouchIDNotEnrolled.rawValue:
                reason = "Touch ID is not enrolled yet"
            case LAError.PasscodeNotSet.rawValue:
                reason = "Passcode not set"
            default: reason = "Authentication not available"
            }
            
            MQALogger.log("Error: Touch ID fingerprint authentication is not available: \(reason)");
        }
    }
    
    /**
    When the keyboard is displayed, move the text fields up and move the login fields up
    */
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                loginBottomConstraint.constant = keyboardHeight
                view.layoutIfNeeded()
            }
        }
    }
    
    /**
    When the keyboard is dismissed, move the textfields back down
    */
    func keyboardWillHide(sender: NSNotification) {
        loginBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    /**
    Check if there is text entered in both text fields. If not, shake and show an error
    */
    func isValidCredentials() -> Bool {
        if usernameTextField.text == "" && passwordTextField.text == "" {
            usernameTextField.shakeView()
            passwordTextField.shakeView()
            return false
        } else if usernameTextField.text != "" && passwordTextField.text == "" {
            passwordTextField.shakeView()
            return false
        } else if usernameTextField.text == "" && passwordTextField.text != "" {
            usernameTextField.shakeView()
            return false
        }
        return true
    }
    
    
    /**
    Called when the Login button is pressed. Presents a loading view while logging in and syncing with sensors
    */
    @IBAction func attempLogin(sender: AnyObject) {
        
        // Check for empty text fields
        if !isValidCredentials() {
            return
        }
        
        // Resign first responder
        if usernameTextField.isFirstResponder() {
            usernameTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder() {
            passwordTextField.resignFirstResponder()
        }
        
        // Fade out the UI elements, show the loading screen with the animation.
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.containingView.alpha = 0.0
            self.loginButton.alpha = 0.0
        }, completion: { (completed: Bool) -> Void in
            self.loggingInView.alpha = 1.0
            self.loggingInView.startAnimation()
            
            // Start the login call after loading screen is displayed
            self.loginManager.submitAuthentication(self.usernameTextField.text, password: self.passwordTextField.text)
        })
    }
    
    /**
    If the login fails, hide the loading view and redisplay the login fields
    */
    public func loginFailed() {
        var loginString = NSAttributedString(string: NSLocalizedString("TRY AGAIN", comment: ""), attributes: [NSKernAttributeName:5.0, NSForegroundColorAttributeName: UIColor.whiteColor()])
        self.loginButton.setAttributedTitle(loginString, forState: UIControlState.Normal)
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.loggingInView.alpha = 0.0
            self.containingView.alpha = 1.0
            self.loginButton.alpha = 1.0
        }, completion: { (completed: Bool) -> Void in
            self.loggingInView.stopAnimation()
            self.usernameTextField.becomeFirstResponder()
        })

    }
    
    /**
    If the login succeeds, change the loading text.
    */
    public func loginSuccess() {
        loggingInView.loadingTextLabel.text = "Syncing with sensors..."
    }
    
    /**
    The Pin VC will call this function when the syncing has completed. When that happens, make the PageHandlerViewController the root view controller.
    This should cause the Pin View Controller and Login View Controller to be destroyed.
    */
    public func syncSensorsFinished() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var pageHandlerVC = storyboard.instantiateViewControllerWithIdentifier("PageHandlerViewController") as? PageHandlerViewController
    
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var transistion = CATransition()
        transistion.duration = 0.4
        transistion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut )
        transistion.type = kCATransitionReveal
        transistion.subtype = kCATransitionFromBottom
        self.view.window?.layer.addAnimation(transistion, forKey: kCATransition)
        UIView.transitionWithView(appDelegate.window!, duration: 0.5, options: nil, animations: { () -> Void in
            appDelegate.window?.rootViewController = pageHandlerVC
        }, completion: { (completed) -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }

    /**
    Saves the username and password in keychain and sets the flag to use touch ID to true. This is called by the challenge handler
    */
    public func setKeychainCredentials(){
        let usernameString = usernameTextField.text
        let passwordString = passwordTextField.text
        
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: ConfigManager.sharedInstance.touchIDKey)
        KeychainWrapper.setString(usernameString, forKey: self.configManager.UsernameKey)
        KeychainWrapper.setString(passwordString, forKey: self.configManager.PasswordKey)
    }
}


// MARK: UITextField Delegate
extension LoginViewController: UITextFieldDelegate {
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if loginButton.attributedTitleForState(UIControlState.Normal)?.string == NSLocalizedString("TRY AGAIN", comment: "") {
            if string != "" {
                var loginString = NSAttributedString(string: NSLocalizedString("ENTER", comment: ""), attributes: [NSKernAttributeName:5.0, NSForegroundColorAttributeName: UIColor.whiteColor()])
                self.loginButton.setAttributedTitle(loginString, forState: UIControlState.Normal)
            }
        }
        return true
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}
