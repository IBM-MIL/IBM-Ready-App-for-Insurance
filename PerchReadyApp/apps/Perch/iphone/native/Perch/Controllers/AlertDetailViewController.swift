/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class AlertDetailViewController: UIViewController {
    
    // MARK: Instance Variables
    
    // The position we want the bottom ad view to be when it is minimized
    let minimizedBottomAdViewPosition = -90
    
    let alertCriticalStatus = 2
    let perchAlertManager = PerchAlertViewManager.sharedInstance
    
    @IBOutlet weak var bottomAdViewBottomPosition: NSLayoutConstraint!
    @IBOutlet weak var recommendedLabel: UILabel!
    @IBOutlet weak var recommendedCompanyImage: UIImageView!
    @IBOutlet weak var recommendedCompanyNameLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var upAndDownArrowsInNavBar: UIView!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var bottomAdView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentMeasurementValueLabel: UILabel!
    @IBOutlet weak var currentMeasurementTextLabel: UILabel!
    @IBOutlet weak var averageMeasurementValueLabel: UILabel!
    @IBOutlet weak var averageMeasurementTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var navBarTitleLabel: UILabel!
    @IBOutlet weak var alertIconImage: UIImageView!
    
    var originalBottomAdViewPosition: CGFloat!
    var currentSensor: String!
    var alert: Alert!
    var comingFromHistoryList = false
    var currentAlertIndexInList: Int?
    var previousPanYPosition: CGFloat = 0
    var draggingBottomView = false
    var userHasBeenToBottomOfScrollView = false
    var originalUpArrowFrame: CGRect!
    var pendingMinimizeCounter = 0
    
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Just clear the red badge circle on app icon as soon as the user views a notification, since backend is not keeping track of badge numbers
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        // Initially hide the expand button, because company info will show first
        self.expandButton.alpha = 0
        
        // Remember the original setting from storyboard, because we will come back to this setting later when maximizing the view after it has been minimized
        self.originalBottomAdViewPosition = bottomAdViewBottomPosition.constant
        
        // Remember the original setting from storyboard, because we will come back to it after down arrow appears and pushes over up button
        self.originalUpArrowFrame = self.upButton.frame
        
        // Storyboard is filled with fake static data to visualize what screen will look like. Empty that fake data here.
        self.emptyFakeTextFromStoryboard()
        
        // Need to make call to get the alert if we don't already have it passed in from previous screen
        if alert == nil {
            self.getCurrentAlert()
        } else {
            self.insertDataIntoView()
        }
        
        // Only want users to have the quick up and down navigation if they are coming from the history list
        if comingFromHistoryList {
            self.upAndDownArrowsInNavBar.hidden = false
        } else {
            self.upAndDownArrowsInNavBar.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If coming into detail from alert history list, and starting with bottom notification, the frames aren't set in viewdidload yet
        // so need to set them in viewDidAppear
        if currentAlertIndexInList == (AlertHistoryDataManager.sharedInstance.alerts.count-1) {
            self.downButton.hidden = true
            self.upButton.hidden = false
            
            UIView.animateWithDuration(0.25) {
                self.upButton.frame = self.downButton.frame
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK Worklight calls and callbacks
    
    /**
    Method for starting a worklight query for getting info about the most recent alert.
    */
    func getCurrentAlert() {
        
        self.activityIndicator.startAnimating()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            var alertDetailDataManager = AlertDetailDataManager.sharedInstance
            alertDetailDataManager.getCurrentNotification(self.currentAlertInfoReturned, currentDeviceId: self.currentSensor)
        }
    }
    
    /**
    Callback method for after the get current alert query finishes.
    
    :param: success Whether or not the query was successful
    */
    func currentAlertInfoReturned(success: Bool) {
        
        // Called from asynchronous action, so get back on main queue before performing UI
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            
            if success {
                self.alert = AlertDetailDataManager.sharedInstance.alert
                self.insertDataIntoView()
            } else {
                MQALogger.log("Current Alert data query was unsuccessful", withLevel: MQALogLevelWarning)
                self.loadAlert(NSLocalizedString("Unable to connect with the server, please try again", comment: ""))
            }
            
        }
    }
    
    // MARK: Helper Methods
    
    /**
    Helper method for setting alpha of all the Company UI elements
    
    :param: alpha The alpha to set for all the elements
    */
    func setCompanyElementsAlpha(alpha: CGFloat) {
        self.recommendedLabel.alpha = alpha
        self.recommendedCompanyImage.alpha = alpha
        self.recommendedCompanyNameLabel.alpha = alpha
        self.phoneButton.alpha = alpha
        self.emailButton.alpha = alpha
        self.mapButton.alpha = alpha
    }
    
    /**
    Method for updating UI with data received from asset overview query instead of the get current alert query
    */
    func decideAvgAndUnits() {
        
        for sensor in AssetOverviewDataManager.sharedInstance.sensors {
            if sensor.deviceClassId == self.currentSensor {
                self.averageMeasurementValueLabel.text = sensor.averageUsage
                self.averageMeasurementTextLabel.text = sensor.averageUsageUnit
                self.currentMeasurementValueLabel.text = "\(self.alert.value)\(sensor.units!)"
                self.navBarTitleLabel.text = sensor.name
            }
        }
        
    }
    
    /**
    Helper method to simply load up the alert view initially with retry or dismiss options
    
    :param: text text to be displayed in the alert
    */
    func loadAlert(text: String) {
        
        perchAlertManager.displayDefaultSimpleAlertTwoButtons({ () -> () in
            self.getCurrentAlert()
            self.perchAlertManager.hideAlertView()
            }, rightButtonCallback: { () -> () in
                self.perchAlertManager.hideAlertView()
        })
    }
    
    /**
    Hide all the fake UI from storyboard while loading
    */
    func emptyFakeTextFromStoryboard() {
        self.titleLabel.text = ""
        self.detailLabel.text = ""
        self.currentMeasurementValueLabel.text = ""
        self.currentMeasurementTextLabel.text = ""
        self.averageMeasurementValueLabel.text = ""
        self.averageMeasurementTextLabel.text = ""
        self.timestampLabel.text = ""
        self.navBarTitleLabel.text = ""
        self.recommendedLabel.text = ""
        self.recommendedCompanyImage.hidden = true
        self.recommendedCompanyNameLabel.text = ""
        self.phoneButton.hidden = true
        self.emailButton.hidden = true
        self.mapButton.hidden = true
        self.alertIconImage.hidden = true
    }
    
    /**
    When navigating to a new alert detail via top right up/down arrows, we need to reset the bottom advertisement view
    */
    func resetBottomAdView() {
        self.bottomAdViewBottomPosition.constant = self.originalBottomAdViewPosition
        self.showCompanyInfo()
        self.minimizeBottomAdViewAfterDelay()
    }
    
    /**
    Helper method for minimizing the bottom advertisement view
    */
    func minimizeBottomAdViewAfterDelay() {
        
        // Use a counter to make sure we don't minimize the current alert's advertisment because of a previous alert's timer
        self.pendingMinimizeCounter++
        
        Utils.delay(5) {
            
            // When the timer finishes, decrement counter so we can check how many pending minimizes we have right now
            self.pendingMinimizeCounter--
            
            // Don't minimize if the user has already scrolled to the bottom because of strange UI behavior in that case since the view is supposed to expand when the user scrolls to the bottom
            // Don't minimize if the user actively dragging the view, because this would be bad UX
            // Don't minimize if the pendingMinimizeCounter > 0, because that means the minimize that is attempting is associated with another screen
            if !self.userHasBeenToBottomOfScrollView && !self.draggingBottomView && self.pendingMinimizeCounter == 0 {
                self.minimizeBottomAdView()
            }
        }
    }
    
    /**
    Main method for populating the UI with all of the data about the alert/sensor
    */
    func insertDataIntoView() {
        
        // Since the user can potentially swap views with up/down arrows, reset if they have scrolled to bottom or not every time new data inserted
        self.userHasBeenToBottomOfScrollView = false
        
        // Starting to fill in data now so start countdown to minimize bottom ad view
        self.minimizeBottomAdViewAfterDelay()
        
        // We only want to show some UI elements if the alert is critical
        if alert.status != alertCriticalStatus {
            self.bottomAdView.hidden = true
            self.alertIconImage.hidden = true
            self.bottomAdViewBottomPosition.constant = -bottomAdView.height
        } else {
            self.bottomAdView.hidden = false
            self.alertIconImage.hidden = false
            self.resetBottomAdView()
        }
        
        // Make sure to only show next/previous arrows in navigation if there is a next/previous alert to show
        if comingFromHistoryList {
            self.handleUpDownArrowEnabledness()
        }
        
        // This text was emptied out in emptyFakeTextFromStoryboard method, so reinsert it
        self.currentMeasurementTextLabel.text = "Measurement Exceeded"
        
        // This data is gotten from the alert passed in (pulled down when calling getAllNotifications or getMostRecentNotification)
        self.titleLabel.text = self.alert.message
        self.detailLabel.text = self.alert.detail
        self.formatDetailLabel()
        self.timestampLabel.text = self.alert.date!.perchTableCellStringFormat()
        
        // This data is pulled down and stored on asset overview call
        self.decideAvgAndUnits()
        
        // Insert data into bottom partner view if the alert has an associated partner
        if let partner = self.alert.partner {
            self.phoneButton.hidden = false
            self.emailButton.hidden = false
            self.mapButton.hidden = false
            self.recommendedCompanyNameLabel.text = partner.name
            self.recommendedCompanyImage.hidden = false
            self.recommendedCompanyImage.image = UIImage(named: partner.iconName)
            self.recommendedLabel.text = "Recommended Partner"
        }
        
        // Mark alert as read
        if let currentalertIndex = self.currentAlertIndexInList {
            AlertHistoryDataManager.sharedInstance.alerts[currentalertIndex].read = true
        }
    }
    
    /**
    Properly format the detail label in code, because Storyboard wasn't showing correct font
    */
    func formatDetailLabel() {
        // Manually set line spacing and font of attributed label, storyboard didn't recognize font
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        var attrs = [NSFontAttributeName : UIFont(name: "Merriweather", size: 17.0)!, NSParagraphStyleAttributeName: style]
        var result = NSMutableAttributedString(string: self.detailLabel.text!, attributes: attrs)
        self.detailLabel.attributedText = result
    }
    
    /**
    Helper method for handling if the up and down arrows are enabled and what position they should be in
    */
    func handleUpDownArrowEnabledness() {
        
        // Diable up button (can't go to previous notification)
        if currentAlertIndexInList == 0 {
            self.upButton.hidden = true
            self.downButton.hidden = false
        }
        // Diabling down button (there is not another notification to navigate to)
        else if currentAlertIndexInList == (AlertHistoryDataManager.sharedInstance.alerts.count-1) {
            self.downButton.hidden = true
            self.upButton.hidden = false
            
            // animate up button over to down button position so it doesn't look out of place
            UIView.animateWithDuration(0.25) {
                self.upButton.frame = self.downButton.frame
            }
            
        }
        // Both arrows should be shown because we can navigate up or down
        else {
            self.upButton.hidden = false
            
            // Animate the up button back over to its normal position if it was previously moved over to be in the down button position
            if self.upButton.frame == self.downButton.frame {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.upButton.frame = self.originalUpArrowFrame
                }, completion: { (finished) -> Void in
                    if finished {
                        self.downButton.hidden = false
                    }
                })
            }
        }
    }
    
    /**
    Helper method for hiding the elements related to the company info
    */
    func hideCompanyInfo() {
        self.setCompanyElementsAlpha(0)
        self.expandButton.alpha = 1
    }
    
    /**
    Helper method for showing the company info elements
    */
    func showCompanyInfo() {
        self.setCompanyElementsAlpha(1)
        self.expandButton.alpha = 0
    }
    
    /**
    Helper method for minimizing the bottom advertisement view
    */
    func minimizeBottomAdView() {
        self.hideCompanyInfo()
        
        // If we are currently maximized
        if self.bottomAdViewBottomPosition.constant == 0 {
            self.bottomAdViewBottomPosition.constant = CGFloat(minimizedBottomAdViewPosition)
            
            // Update all other constraints that depend on the constraint that was just updated
            self.view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    /**
    Helper method for expanding the bottom advertisement view
    */
    func expandBottomAdView() {
        self.showCompanyInfo()
        
        // If we are currently minimized
        if self.bottomAdViewBottomPosition.constant == CGFloat(minimizedBottomAdViewPosition) {
            self.bottomAdViewBottomPosition.constant = self.originalBottomAdViewPosition
            
            // Update all other constraints that depend on the constraint that was just updated
            self.view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: IBActions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.view.window?.layer.addAnimation(Utils.customTransitionFromDirection(kCATransitionFromLeft), forKey: nil)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func expandButtonTapped(sender: AnyObject) {
        self.expandBottomAdView()
    }
    
    
    @IBAction func upButtonTapped(sender: AnyObject) {
        currentAlertIndexInList!--
        self.alert = AlertHistoryDataManager.sharedInstance.alerts[currentAlertIndexInList!]
        self.insertDataIntoView()
    }
    
    @IBAction func downButtonTapped(sender: AnyObject) {
        currentAlertIndexInList!++
        self.alert = AlertHistoryDataManager.sharedInstance.alerts[currentAlertIndexInList!]
        self.insertDataIntoView()
    }
    
    @IBAction func phoneButtonTapped(sender: AnyObject) {
        Utils.openPhone(self.alert.partner!.phone)
    }
    
    @IBAction func emailButtonTapped(sender: AnyObject) {
        Utils.openEmail(self.alert.partner!.email)
    }
    
    @IBAction func mapButtonTapped(sender: AnyObject) {
        Utils.openMaps(self.alert.partner!.location)
    }
    
    /**
    Method for determining the botton advertisement view position/alpha based on the user dragging it
    
    :param: recognizer The gesture recognizer
    */
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        
        // Notify we are currently dragging the view (so don't auto minimize the view from timer while dragging)
        self.draggingBottomView = true
        
        // Move the bottom view with a pan of a finger
        var currentPositionY = recognizer.locationInView(self.view).y
        
        // Decide how much we should move the view based on where the user has dragged his finger compared to the user's last finger position
        var sum = self.previousPanYPosition - currentPositionY
        
        // When coming back to the pan for the first time this number can be very low, so this is a way of basically ignoring the first pan back since it can cause the view to be hidden
        if sum < -50 { sum = -1 }
        
        // Update the position of the view based on the sum
        self.bottomAdViewBottomPosition.constant += CGFloat(sum)
        
        // Set the previous pan position for next time this method fires
        self.previousPanYPosition = currentPositionY
        
        // Don't allow dragging the view up past maximum or down past minimum
        if self.bottomAdViewBottomPosition.constant < CGFloat(minimizedBottomAdViewPosition) {
            self.bottomAdViewBottomPosition.constant = CGFloat(minimizedBottomAdViewPosition)
        } else if self.bottomAdViewBottomPosition.constant > CGFloat(originalBottomAdViewPosition) {
            self.bottomAdViewBottomPosition.constant = CGFloat(originalBottomAdViewPosition)
        }
        
        // Every time this method fires from a finger drag, update the alpha of all the components based on the position of the drag
        self.mapBottomPositionToAlpha()
        
        // Snap box to top or bottom position once the user stops dragging their finger
        if recognizer.state == UIGestureRecognizerState.Ended {
            self.draggingBottomView = false
            self.previousPanYPosition = 0
            self.snapIntoPlace()
        }
    }
    
    /**
    Map the position of the bottom view to the alpha of UI components.
    The farther down the view is dragged, the more hidden the company elements should become,
    and the more visible the expand button should come.
    */
    func mapBottomPositionToAlpha() {
        let bottomPos = self.bottomAdViewBottomPosition.constant
        
        // A way to map the appropriate alphas based on the curent position of the bottom view
        var expandButtonAlpha = -bottomPos * 0.01
        var companyElementsAlpha = 1 - (-bottomPos * 0.01)
        
        self.expandButton.alpha = expandButtonAlpha
        self.setCompanyElementsAlpha(companyElementsAlpha)
    }
    
    /**
    Helper method for snapping the bottom advertisement into place when the user stops dragging his finger
    */
    func snapIntoPlace() {
        if self.bottomAdViewBottomPosition.constant < CGFloat(minimizedBottomAdViewPosition/2) {
            self.bottomAdViewBottomPosition.constant = CGFloat(minimizedBottomAdViewPosition)
            self.hideCompanyInfo()
        } else {
            self.bottomAdViewBottomPosition.constant = CGFloat(originalBottomAdViewPosition)
            self.showCompanyInfo()
        }
        
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: UINavigationBarDelegate

extension AlertDetailViewController: UINavigationBarDelegate {
    
    /**
    Extend the navigation bar color to the status bar
    
    :param: bar Unused
    
    :returns: Position of navigation bar in relation to status bar
    */
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
}

// MARK: UIScrollViewDelegate

extension AlertDetailViewController: UIScrollViewDelegate {
    
    /**
    Pop up the bottom advertisement if the user scrolls to the bottom
    
    :param: scrollView The scrollview that fired the delegate method
    */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.atBottomOfScrollView() {
            
            // Used to determine bottom advertisement view should actually minimize.
            userHasBeenToBottomOfScrollView = true
            
            // Want to expand the bottom advertisement view once the user scrolls to the bottom
            if !draggingBottomView && !self.bottomAdView.hidden {
                self.expandBottomAdView()
            }
        }
    }
    
    /**
    Helper method for determining if user is at bottom of scroll view
    
    :returns: If the user has scrolled to the bottom
    */
    func atBottomOfScrollView() -> Bool {
        let bottomEdge = self.scrollView.contentOffset.y + self.scrollView.frame.size.height
        if bottomEdge >= self.scrollView.contentSize.height {
            return true
        }
        
        return false
    }
    
}
