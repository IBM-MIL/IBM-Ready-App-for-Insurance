/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/** 
ProfileViewController displays the profile information of the current user. This includes their insurance agent info, as well as their policy number.
The CoverageViewController is also embedded in this view.
*/
class ProfileViewController: PageItemViewController {
    
    // Views on the screen
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var policyNumberLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var coverageButton: UIButton!
    var arrowImageView: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var agentName: UILabel!
    @IBOutlet weak var agentImageView: UIImageView!
    
    // Constraints for the agent info views. Changed when on the 6+
    @IBOutlet weak var agentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var agentViewLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var agentViewRightMargin: NSLayoutConstraint!
    @IBOutlet weak var topOfficeHoursMargin: NSLayoutConstraint!
    @IBOutlet weak var leftOfficeHoursMargin: NSLayoutConstraint!
    @IBOutlet weak var rightOfficeHoursMargin: NSLayoutConstraint!
    
    // Constraint to show and hide the converage view
    @IBOutlet weak var containedViewBottom: NSLayoutConstraint!
    
    var onLoad: Bool = true
    var coverageShown: Bool = false
    let currentUser = CurrentUser.sharedInstance
    let configManager = ConfigManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateInsuranceInfo()
        
        // Apply kerning to the coverage button
        var coverageString = NSAttributedString(string: NSLocalizedString("COVERAGE", comment: ""), attributes: [NSKernAttributeName:3.0, NSForegroundColorAttributeName: UIColor.perchOrange(alpha: 1.0)])
        coverageButton.setAttributedTitle(coverageString, forState: UIControlState.Normal)
        
        // Add arrow image view to the coverage button
        arrowImageView = UIImageView()
        arrowImageView.contentMode = UIViewContentMode.Center
        coverageButton.addSubview(arrowImageView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // if iPhone 6+, increase the margins of the elements on the screen
        if UIScreen.mainScreen().bounds.size.height == 736 {
            var newAgentViewHeight: CGFloat = 150
            agentViewHeight.constant = newAgentViewHeight
            agentViewLeftMargin.constant = configManager.largeMargin
            agentViewRightMargin.constant = configManager.largeMargin
            topOfficeHoursMargin.constant = configManager.largeMargin
            leftOfficeHoursMargin.constant = configManager.largeMargin
            rightOfficeHoursMargin.constant = configManager.largeMargin
            view.updateConstraints()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup the coverage button
        updateCoverageButton()
        
        if onLoad {
            // Make sure the 'hidden' table view is formatted correctly, then shrink and bring to front
            containedViewBottom.constant = containerView.frame.size.height - 1
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            view.bringSubviewToFront(containerView)
            onLoad = false
        }
    }
    
    /** Make sure status bar text black */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }

    // MARK: Button actions
    /**
    Goes back to the asset overview page
    */
    @IBAction func navigateLeftToAssets(sender: AnyObject) {
        self.pageHandlerViewController.navigateToIndex(1, fromIndex:self.pageIndex, animated: true)
    }
    
    /**
    When the coverage button is tapped, either show or hide the coverage info and update the button info
    */
    @IBAction func coverageButtonTapped(sender: AnyObject) {
        coverageShown = !coverageShown

        // Show/hide the coverage view but updating constraints
        if coverageShown {
            containedViewBottom.constant = 0
        } else {
            containedViewBottom.constant = containerView.frame.height - 1
        }
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.updateCoverageButton()
        })
    }
    
    /**
    Action that will open the Phone app and call the phone number associated with the insurance agent
    */
    @IBAction func phoneButtonTapped(sender: AnyObject) {
        Utils.openPhone()
    }
    
    /**
    Action that will open the default Mail app on the phone and inserts the agent's email address in the 'To' line in the email.
    */
    @IBAction func mailButtonTapped(sender: AnyObject) {
        Utils.openEmail()
    }
    
    /**
    Action that will open the default Maps app on the phone and finds the location of the insurance agent based on the address
    */
    @IBAction func mapButtonTapped(sender: AnyObject) {
        Utils.openMaps()
    }
    
    // MARK: Helper functions
    /**
    Updates the labels on the screen based on the info in the Current User object
    */
    func updateInsuranceInfo() {
        policyNumberLabel.text = currentUser.insurance.policyNumber
        companyName.text = currentUser.insurance.companyName
        agentName.text = currentUser.insurance.agentName
        agentImageView.image = currentUser.insurance.agentImage
    }
    
    /**
    Changes the text and the direction of the arrow image in the Coverage button on the screen
    */
    func updateCoverageButton() {
        
        var coverageString: NSAttributedString!
        
        // Update the button label and arrow image
        if coverageShown {
            arrowImageView.image = UIImage(named: "arrow_up_orange")
            coverageString = NSAttributedString(string: NSLocalizedString("CLOSE", comment: ""), attributes: [NSKernAttributeName:3.0, NSForegroundColorAttributeName: UIColor.perchOrange(alpha: 1.0)])
            coverageButton.setAttributedTitle(coverageString, forState: UIControlState.Normal)
        } else {
            arrowImageView.image = UIImage(named: "arrow_down_orange")
            coverageString = NSAttributedString(string: NSLocalizedString("COVERAGE", comment: ""), attributes: [NSKernAttributeName:3.0, NSForegroundColorAttributeName: UIColor.perchOrange(alpha: 1.0)])
            coverageButton.setAttributedTitle(coverageString, forState: UIControlState.Normal)
        }
        
        // Move the arrow image accordingly
        if let stringWidth = coverageButton.attributedTitleForState(UIControlState.Normal)?.size().width {
            var imageX: CGFloat = (coverageButton.frame.width / 2) + (stringWidth / 2) - 10
            arrowImageView.frame = CGRectMake(imageX, 0, coverageButton.frame.height, coverageButton.frame.height)
        }
    }
}

// Have the nav bar extend below the status bar
extension ProfileViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}
