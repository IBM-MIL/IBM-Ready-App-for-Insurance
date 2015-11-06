/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/ 

import UIKit
import Foundation

/**
*  Entering a pin screen. Mainly responsible for all the animations associated with the screen.
*/
class PinViewController: PerchViewController {
    // MARK: IBOutlets
    /** Outlets from storyboard. A lot of these are constraint outlets for animating view position changes for things like when the keyboard pops up. */

    @IBOutlet weak var pinContainerView: UIView!
    @IBOutlet weak var stayConnectedLabel: UILabel!
    @IBOutlet weak var stayConnectedBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var stayConnectedHeight: NSLayoutConstraint!
    @IBOutlet weak var perchLogoHeight: NSLayoutConstraint!
    @IBOutlet weak var perchTextImageView: UIImageView!
    @IBOutlet weak var fillOrangeViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var perchLogoImageView: UIImageView!
    @IBOutlet weak var syncingWithSensorsLabel: UILabel!
    @IBOutlet weak var middleLineBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var syncButtonBottomSpace: NSLayoutConstraint!
    
    // MARK: Animation Related Instance Variables
    /** Setup variables/constants for the timers that will drive the bird flying loading animation */
    let flyInImageCount = 75
    let flyInAnimationTime = 2.5
    var flyInTimer: NSTimer!
    let circleImageCount = 15
    let circleAnimationTime = 0.5
    var circleTimer: NSTimer!
    let flyOutImageCount = 30
    let flyOutAnimationTime = 1.0
    var flyOutTimer: NSTimer!
    let flyOutNoShrinkImageCount = 14
    let flyOutNoShrinkAnimationTime = 0.466
    var flyOutNoShrinkTimer: NSTimer!
    var loadingFinished = false
    var animationActive = false
    var pendingTransition = false
    var pendingError = false
    /** We don't really want to include the first 25 frames of flyIn animation xcasset, because they don't actually start to show the bird flying in yet */
    var flyInCurrentImageNum = 26
    var circleCurrentImageNum = 0
    var flyOutCurrentImageNum = 0
    var flyOutNoShrinkCurrentImageNum = 0
    /** End animation setup variables */
    
    // MARK: Instance Variables
    /** Constant for determining if "perch" text should be shown below logo when keyboard animated up. Screens with less than this height don't have quite enough room to show the logo and text with keyboard up. */
    let maximumScreenHeightForKeepingPerchLogo: CGFloat = 600
    
    // Used to start the query for asset data
    var assetDataMgr: AssetOverviewDataManager? = AssetOverviewDataManager.sharedInstance
    weak var enterPinVC: EnterPinViewController?
    
    /** Made class var so can quickly access from test without needing to instantiate this view controller */
    class var requiredPinLength: Int { return 4 }
    
    /** Used for determining how much to animate view changes up/down for things like keyboard popping up */
    let screenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    let statusBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
    
    /** This needs to be accessed from flyOut animation ending so not local to syncButtonTapped */
    var currentErrorMessage = ""
    
    var loginCallback: (()->())!
    var loginVC: LoginViewController?
    
    // MARK: View Controller Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Set up initial state for perch logo UI */
        self.setInitialPerchLogoState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /** Register for keyboard notifications */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        /** Reset these alphas and image when coming back to screen from another screen.
        They are changed to a different state when leaving the screen, so make sure to set the back to initial state here. */
        self.perchTextImageView.alpha = 1
        self.stayConnectedLabel.alpha = 1
        self.perchLogoImageView.image = UIImage(named: "perch_logo")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /** If we are coming back to this screen after a successful pin registration (which animates an orange view taking over the screen), hide the orange view that overtook the screen */
        if self.fillOrangeViewHeight.constant > 0 {
            self.hideOrange()
        }
        
        /** Allow sales rep to quickly show off simple version of app by entering demo mode */
        if !CurrentUser.sharedInstance.hasBeenAskedToEnterDemoMode {
            CurrentUser.sharedInstance.hasBeenAskedToEnterDemoMode = true
            let demoAlert = UIAlertController(title: NSLocalizedString("Would you like to use \"Perch\" in demo mode?", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.Alert)
            let actionNo = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
            let actionYes = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
                CurrentUser.sharedInstance.demoMode = true
                self.enterPinVC!.pinTextField.text = "0000"
                self.enterPinVC!.fakePinSync()
            })
            demoAlert.addAction(actionNo)
            demoAlert.addAction(actionYes)
            self.presentViewController(demoAlert, animated: true, completion: nil)
        }
    }
    
    /** Remove keyboard notification observer in viewWillDisappear */
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedPinSegue" {
            if let destVC = segue.destinationViewController as? EnterPinViewController {
                enterPinVC = destVC
                enterPinVC!.delegate = self
            }
        }
    }
    
    /** Make sure status bar text black */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    // MARK: UI Related
    /** Animation time of the orange view taking over the screen on successful sync */
    let coverAnimationTime = 0.4
    
    /** Animate the orange view taking over the screen on successful sync */
    func coverOrange() {
        self.view.endEditing(true)
        
        /** Make the height of the orange view twice the screen height to ensure the view fills the entire screen no matter where it originates from. */
        self.fillOrangeViewHeight.constant = screenHeight
        
        /** Update any other constraints associated with the constraint(s) just updated */
        self.view.setNeedsUpdateConstraints()
        
        /** Once screen covered in orange segue to asset overview */
        UIView.animateWithDuration(NSTimeInterval(coverAnimationTime), animations: { () -> Void in
            /** Animate the constraint changes (make sure they don't happen immediately) */
            self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            if finished {
                // When finished, call the callback so that the login view controller can be presented by the Challenge Handler
                self.loginCallback()
            }
        }
    }
    
    /** Animate the orange view down to invisible again */
    func hideOrange() {
        self.fillOrangeViewHeight.constant = 0

        /** Update any other constraints associated with the constraint(s) just updated */
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(NSTimeInterval(coverAnimationTime), animations: { () -> Void in
            /** Animate the constraint changes (make sure they don't happen immediately) */
            self.view.layoutIfNeeded()
        })
    }
    
    /** Start the sequence of timers that are responsible for swapping out the image view to show the bird flying for loading */
    func showLoading() {
        /** Set the time each frame should appear. This is the division of the desired total animation time by the total image count for the animation. */
        let flyInEachImageTime = flyInAnimationTime / Double(flyInImageCount)
        
        /** Start a timer that will call a selector for updating the image view image with each fire of the timer */
        flyInTimer = NSTimer.scheduledTimerWithTimeInterval(flyInEachImageTime, target: self, selector: Selector("flyIn"), userInfo: nil, repeats: true)
        
        /** Don't want other buttons causing other animation changes during our loading animation so disable other buttons */
        enterPinVC?.buttonsEnabled(false)
        
        /** Other changes in the UI happen other than just loading animation, so make those changes */
        self.prepareScreenUIForLoading()
    }
    

    
    /** These are the UI changes that need to take place when loading starts.
    Design wants birdhouse logo to become centered vertically and other things on UI to disappear.
    Also wanted to display text to user telling them what was happening. */
    func prepareScreenUIForLoading() {
        /** Design wanted keyboard dismissed on loading starting */
        self.view.endEditing(true)
        
        /** Center the birdhouse logo vertically */
        self.middleLineBottomSpace.constant = (screenHeight + pinContainerView.height - self.perchLogoHeight.constant) / 2
        
        /** Update any other constraints associated with the constraint(s) just updated */
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.perchTextImageView.alpha = 0
            self.stayConnectedLabel.alpha = 0
            self.syncingWithSensorsLabel.alpha = 1
            
            /** Animate the constraint changes (make sure they don't happen immediately) */
            self.view.layoutIfNeeded()
        })
    }
    
    /** These are the UI changes that need to take place when loading is finished. Basically undoing things done in prepareScreenUIForLoading() */
    func prepareScreenUIForLoadingFinished() {
        self.setInitialPerchLogoState()
        
        /** Update any other constraints associated with the constraint(s) just updated */
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            /** Only animate views back in if we aren't about to transition to other screen.
            Design thought this looked better. */
            if !self.pendingTransition {
                self.perchTextImageView.alpha = 1
                self.stayConnectedLabel.alpha = 1
            }
            
            /** Animate the constraint changes (make sure they don't happen immediately) */
            self.view.layoutIfNeeded()
        })
    }
    
    /** Helper method for restoring perch logo to its initial state when view controller loaded */
    func setInitialPerchLogoState() {
        self.syncingWithSensorsLabel.alpha = 0
        self.middleLineBottomSpace.constant = (screenHeight + self.stayConnectedBottomSpace.constant + stayConnectedHeight.constant - statusBarHeight - (self.perchLogoHeight.constant/2)) / 2
    }
    
    // MARK: Keyboard Notifications
    /** Call the update ui method when receiving a keyboard notification */
    func keyboardWillShow(notification: NSNotification) {
        self.moveViewWithKeyboard(notification)
    }
    
    /** Call the update ui method when receiving a keyboard notification */
    func keyboardWillHide(notification: NSNotification) {
        self.moveViewWithKeyboard(notification)
    }
    
    /** Helper method for determining which direction the keyboard is animating */
    func keyboardAnimatingDown(keyboardFrameEnd: CGRect) -> Bool {
        return screenHeight == keyboardFrameEnd.origin.y
    }
    
    /** Update the UI when the keyboard appears or disappears */
    func moveViewWithKeyboard(notification: NSNotification) {
        if let info = notification.userInfo {
            
            /** Get information about the keyboard that is popping up or minimizing */
            let keyboardFrameEnd: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            let keyboardAnimationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
            let keyboardHeight = screenHeight - keyboardFrameEnd.origin.y
            
            /** If the keyboard is animating down (dismissing), then reset the perch logo position */
            if self.keyboardAnimatingDown(keyboardFrameEnd) {
                self.setInitialPerchLogoState()
            } else {
                /** Since we keep perch text if on screen big enough to keep it. This means the centering of perch logo shifts a little to center better with text below. */
                if self.screenHeight >= self.maximumScreenHeightForKeepingPerchLogo {
                    /** Set up the constraint to be centered based on the view available (factor in all things on screen like keyboard, bottom enter button). Divide by 2 because you want it centered on screen. Add things below the middle line, subtract things above the middle line. Subtracting moves the line down, adding moves the line up. The subtraction of the perch logo divided by 2 is to account for the logo being taller than the text label below it. */
                    self.middleLineBottomSpace.constant = (screenHeight + pinContainerView.height + keyboardHeight - (self.perchLogoHeight.constant/2)) / 2
                } else {
                    self.middleLineBottomSpace.constant = (screenHeight + pinContainerView.height + keyboardHeight - self.perchLogoHeight.constant) / 2
                }
            }
            
            /** Animate the moving of the sync button to be on top of keyboard if keyboard present, otherwise put it on bottom of screen. */
            self.syncButtonBottomSpace.constant = keyboardHeight
            
            /** Update any other constraints associated with the constraint(s) just updated */
            self.view.setNeedsUpdateConstraints()
            
            /** Show and hide UI elements based on keyboard animating or dismissing */
            UIView.animateWithDuration(keyboardAnimationDuration.doubleValue, animations: {
                
                /** Animate the constraint changes (make sure they don't happen immediately) */
                self.view.layoutIfNeeded()
                
                if self.keyboardAnimatingDown(keyboardFrameEnd) {
                    self.stayConnectedLabel.alpha = 1
                    self.perchTextImageView.alpha = 1
                } else {
                    self.stayConnectedLabel.alpha = 0
                    
                    /** Hide perch text if not on screen big enough to keep it */
                    if self.screenHeight < self.maximumScreenHeightForKeepingPerchLogo {
                        self.perchTextImageView.alpha = 0
                    }
                }
            })
        }
    }
    
    // MARK: ASSET DATA METHODS
    
    /**
    Starts the query for asset data. This occurs after subscribing to the pin channel finishes.
    */
    func startAssetDataQuery() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let assetOverviewDataManager = AssetOverviewDataManager.sharedInstance
            assetOverviewDataManager.getAllAssetData({[unowned self] in self.assetQueryFinished($0)})
        }
    }
    
    /**
    This is called by the Challenge Handler if authentication is required. This will stop the loading animation, and start the cover orange animation
    */
    func authRequired(callback: (()->())!) {
        loadingFinished = true
        loginCallback = callback
        if !self.animationActive {
            self.coverOrange()
        } else {
            self.pendingTransition = true
        }
    }
    
    // This is called when the query for asset data finishes. Once finished and succesful, tells the login view that it was succesful.
    func assetQueryFinished(success: Bool) {
        if let loginVC = self.presentedViewController as? LoginViewController {
            self.loginVC = loginVC
        }

        if success {
            self.loginVC?.syncSensorsFinished()
        } else {
            loadingFinished = true
            pendingError = true
            self.loginVC?.dismissViewControllerAnimated(true, completion: nil)
            enterPinVC?.shakeAndShowError("Failed to sync with sensors. Try again or enter a new pin.")
        }
    }
}

// MARK: Pin Entry Delegate
extension PinViewController: PinEntryDelegate {
    // Once a pin has been entered, show the loading animation
    func didEnterPin() {
        self.showLoading()
    }
    
    /**
    Once the pin syn finishs, either stop the animation becaues of an error, or start the asset data query
    */
    func pinSyncFinished(error: Bool, errorMessage: String?) {
        if error {
            loadingFinished = true
            self.pendingError = true
        } else {
            self.startAssetDataQuery()
        }
    }
    
    /**
    If doing a fake sync, start the asset data query
    */
    func fakePinSyncFinished() {
        self.showLoading()
        self.animationActive = true
        self.startAssetDataQuery()
    }
}

// MARK: Bird flying loading animation
extension PinViewController {
    /** This is the method that is called for each time the flyInTimer fires. It is responsible for updating the logo image view every x seconds
    so it appears as though a bird is flying in from the edge of the screen. */
    func flyIn() {
        /** As soon as we start the animation, let all other areas of the view controller know by setting this variable */
        animationActive = true
        enterPinVC?.animationActive = true
        
        /** This statement entered for last frame of the animation. Used to kick off the next animaiton and stop this one. */
        if flyInCurrentImageNum == flyInImageCount {
            
            /** Reset the current image to the initial one so if need to start the animation again later, it will start at correct location. */
            flyInCurrentImageNum = 26
            
            /** Stop the timer that is responsible for doing the fly in animaiton */
            flyInTimer.invalidate()
            
            /** If networking call has already finished by the time the fly in animation is done, go ahead and start the fly out animation to wrap up the loading animation */
            if loadingFinished {
                /** Reset loadingFinished, so next time animation is run it won't immediately finish */
                loadingFinished = false
                
                /** Decide which fly out animation to do based on if there was an error with the networking call */
                self.doFlyOutAnimationBasedOnErrorState()
                
            } else {
                
                /** If loading still going on when fly in finishes, start the flying around circles animation */
                let circleEachImageTime = circleAnimationTime / Double(circleImageCount)
                circleTimer = NSTimer.scheduledTimerWithTimeInterval(circleEachImageTime, target: self, selector: Selector("circle"), userInfo: nil, repeats: true)
            }
            
        } else {
            /** This is what normall happens each time the timer is fired - the image view's image is updated with the next image of the bird flying. */
            self.perchLogoImageView.image = UIImage(named: "pech_fly_in\(flyInCurrentImageNum)")
        }
        
        /** Update the current image so the next pass through of the timer firing will update to the next image */
        flyInCurrentImageNum++
    }
    
    /** Selector method called each time the circle timer is fired. Animates the bird flying around in a circle aroung logo.
    See flyIn() method comments for more detailed high level overview of how it works. */
    func circle() {
        if circleCurrentImageNum == circleImageCount {
            circleCurrentImageNum = 0
            
            if loadingFinished {
                loadingFinished = false
                circleTimer.invalidate()
                
                self.doFlyOutAnimationBasedOnErrorState()
            }
            
        } else {
            self.perchLogoImageView.image = UIImage(named: "perch_circle\(circleCurrentImageNum)")
        }
        
        circleCurrentImageNum++
    }
    
    /** Selector method called each time the fly out timer is fired. Animates the bird flying into the logo.
    See flyIn() method comments for more detailed high level overview of how it works. */
    func flyOut() {
        if flyOutCurrentImageNum == flyOutImageCount {
            flyOutCurrentImageNum = 0
            flyOutTimer.invalidate()
            
            /** The buttons were disabled at beginning of loading starting to show, so enable them back here */
            enterPinVC?.buttonsEnabled(true)
            
            /** Reset UI to before loading */
            self.prepareScreenUIForLoadingFinished()
            
            /** Let everyone else in this view controller know the animation is not active anymore */
            animationActive = false
            enterPinVC?.animationActive = false
            
            /** Make sure transition pending (returned success from sync) before doning transition */
            if pendingTransition {
                pendingTransition = false
                self.coverOrange()
            }
            
        } else {
            self.perchLogoImageView.image = UIImage(named: "perch_fly_out\(flyOutCurrentImageNum)")
        }
        
        flyOutCurrentImageNum++
    }
    
    /** Selector method called each time the fly out (no shrink) timer is fired. Animates the bird flying into the logo.
    See flyIn() or flyOut() method comments for more detailed high level overview of how it works. */
    func flyOutNoShrink() {
        if flyOutNoShrinkCurrentImageNum == flyOutNoShrinkImageCount {
            flyOutNoShrinkCurrentImageNum = 0
            flyOutNoShrinkTimer.invalidate()
            enterPinVC?.buttonsEnabled(true)
            self.prepareScreenUIForLoadingFinished()
            animationActive = false
            enterPinVC?.animationActive = false
        } else {
            self.perchLogoImageView.image = UIImage(named: "perch_fly_out_noshrink\(flyOutNoShrinkCurrentImageNum)")
        }
        
        flyOutNoShrinkCurrentImageNum++
    }
    
    /** Helper method for determining which fly out animation to do based on error state.
    If there is an error, then we are not transitioning to next screen so we don't want to
    animate the birdhouse logo shrinking down. */
    func doFlyOutAnimationBasedOnErrorState() {
        if self.pendingError {
            self.pendingError = false
            let flyOutNoShrinkEachImageTime = flyOutNoShrinkAnimationTime / Double(flyOutNoShrinkImageCount)
            flyOutNoShrinkTimer = NSTimer.scheduledTimerWithTimeInterval(flyOutNoShrinkEachImageTime, target: self, selector: "flyOutNoShrink", userInfo: nil, repeats: true)
        } else {
            let flyOutEachImageTime = flyOutAnimationTime / Double(flyOutImageCount)
            flyOutTimer = NSTimer.scheduledTimerWithTimeInterval(flyOutEachImageTime, target: self, selector: "flyOut", userInfo: nil, repeats: true)
        }
    }
}
