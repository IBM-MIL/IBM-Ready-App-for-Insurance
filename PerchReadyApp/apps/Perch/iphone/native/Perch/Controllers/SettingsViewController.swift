/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  This view controller provides the option for the user to change their PIN number to connect with a different instance of the IoT sensors.
*  It also provides the option to logout from the app (which will delete the user's credentials from Keychain)
*  This view controller embeds the EnterPinViewController.
*/
class SettingsViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentPinView: UIView!
    @IBOutlet weak var currentPinLabel: UILabel!
    @IBOutlet weak var perchLoadingView: UIView!
    @IBOutlet weak var perchLogoImageView: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    weak var enterPinVC: EnterPinViewController?
    var assetDataMgr: AssetOverviewDataManager? = AssetOverviewDataManager.sharedInstance
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var currentUser = CurrentUser.sharedInstance
        setPinLabel(currentUser.userPin)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /** Register for keyboard notifications */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    /** Remove keyboard notification observer in viewWillDisappear */
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
    We embed the EnterPinViewController in this VC, get a pointer to it so we can change things later
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedPinSegue" {
            if let destVC = segue.destinationViewController as? EnterPinViewController {
                enterPinVC = destVC
                enterPinVC!.delegate = self
                enterPinVC!.changingPin = true
            }
        }
    }
    
    /**
    Navigates the PageHandlerViewController back to the AssetOverview page. This is called if a Pin change is successful and the animation has finished.
    */
    func goToAssetOverview() {
        if let vc = self.presentingViewController as? PageHandlerViewController {
            vc.navigateToIndex(1, fromIndex: 2, animated: false)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    /**
    Updates the pin label with the user's current pin
    */
    func setPinLabel(currentPin: String) {
        var pinString = NSLocalizedString("Current PIN: ", comment: "") + currentPin
        currentPinLabel.text = pinString
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
    
    /** 
    These are the UI changes that need to take place when loading starts. We want to move the 
    nav bar off the screen, and then hide the current pin label, and show the loading label
    */
    func prepareScreenUIForLoading() {
        
        navBarTopConstraint.constant = -(UIApplication.sharedApplication().statusBarFrame.size.height + navBar.frame.size.height)
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.currentPinView.alpha = 0
            self.perchLoadingView.alpha = 1
        })
    }
    
    /** These are the UI changes that need to take place when loading is finished. Basically undoing things done in prepareScreenUIForLoading() */
    func prepareScreenUIForLoadingFinished() {

        navBarTopConstraint.constant = 0
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            /** Only animate views back in if we aren't about to transition to other screen.
            Design thought this looked better. */
            if !self.pendingTransition {
                self.currentPinView.alpha = 1
                self.perchLoadingView.alpha = 0
            }
        })
    }
    
    /**********************************************************/
    // MARK: Keyboard animations
    /**********************************************************/
    /** Call the update ui method when receiving a keyboard notification */
    func keyboardWillShow(notification: NSNotification) {
        self.moveViewWithKeyboard(notification)
    }
    
    /** Call the update ui method when receiving a keyboard notification */
    func keyboardWillHide(notification: NSNotification) {
        self.moveViewWithKeyboard(notification)
    }
    
    /** Update the UI when the keyboard appears or disappears */
    func moveViewWithKeyboard(notification: NSNotification) {
        if let info = notification.userInfo {
            
            /** Get information about the keyboard that is popping up or minimizing */
            let keyboardFrameEnd: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            let keyboardAnimationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
            let keyboardHeight = UIScreen.mainScreen().bounds.height - keyboardFrameEnd.origin.y
            
            bottomConstraint.constant = keyboardHeight
            self.view.setNeedsUpdateConstraints()
            
            /** Show and hide UI elements based on keyboard animating or dismissing */
            UIView.animateWithDuration(keyboardAnimationDuration.doubleValue, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    /**********************************************************/
    // MARK: IBActions
    /**********************************************************/
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    When logout is pressed, show a full screen Loading Screen, then tell the App Delegate to logout
    */
    @IBAction func logoutPressed(sender: AnyObject) {
        
        // Create logging out view
        var loggingInView = UINib(nibName: "PerchLoadView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PerchLoadView
        loggingInView.frame = view.frame
        loggingInView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        loggingInView.loadingTextLabel.text = NSLocalizedString("Logging out...", comment: "")
        self.view.addSubview(loggingInView)
        loggingInView.animateWithoutShaking()
        
        // Log out!
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.logout()
    }
    
    /**********************************************************/
    // MARK: Asset Data Query
    /**********************************************************/
    /**
    Starts the query for asset data. This occurs after subscribing to the pin channel finishes.
    */
    func startAssetDataQuery() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            var assetOverviewDataManager = AssetOverviewDataManager.sharedInstance
            assetOverviewDataManager.getAllAssetData({[unowned self] in self.assetQueryFinished($0)})
        }
    }
    
    // This is called when the query for asset data finishes. Once finished and succesful, we want to navigate back to the Asset Overview page.
    func assetQueryFinished(success: Bool) {
        loadingFinished = true
        if success {
            if assetDataMgr?.sensors.count > 0 {
                pendingTransition = true
            } else {
                pendingError = true
                enterPinVC?.shakeAndShowError("Failed to sync with sensors. Try again or enter a new pin.")
            }
        } else {
            pendingError = true
            enterPinVC?.shakeAndShowError("Failed to sync with sensors. Try again or enter a new pin.")
        }
    }
}

/**********************************************************/
// MARK: Pin Entry Delegate
/**********************************************************/
extension SettingsViewController: PinEntryDelegate {
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
        self.startAssetDataQuery()
    }
}

/**********************************************************/
// MARK: Bird flying loading animation
/**********************************************************/

extension SettingsViewController {
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
                self.goToAssetOverview()
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


// Extends the nav bar behind the status bar
extension SettingsViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}
