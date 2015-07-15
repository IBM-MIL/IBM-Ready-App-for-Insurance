/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class TipDetailViewController: UIViewController {
    
    // MARK: UI Variables
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowView: UIView!
    @IBOutlet weak var upArrowButton: UIButton!
    @IBOutlet weak var downArrowButton: UIButton!
    @IBOutlet weak var largeTextLabel: UILabel!
    @IBOutlet weak var backArrow: UIButton!
    @IBOutlet weak var forwardArrowView: UIView!
    @IBOutlet weak var forwardArrowButton: UIButton!
    
    // MARK: Incentive UI
    @IBOutlet weak var incentiveView: UIView!
    @IBOutlet weak var incentiveType: UILabel!
    @IBOutlet weak var iconBackgroundView: UIImageView!
    @IBOutlet weak var incentiveTitle: UILabel!
    @IBOutlet weak var addSensorLabel: UILabel!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var incentiveBottomConstraint: NSLayoutConstraint!
    
    // MARK: Data variables
    
    /// index of current tip in array of tips
    var selectedIndex: Int!
    let minimizedBottomConstraint: CGFloat = -90
    
    /// Records bottom incentive constraint constant when switching tips
    var visibilityOnHide: CGFloat = 0
    var alreadyHitBottom = false
    var panningInProgress = false
    
    /// Used in determining space to move over when down arrow is the only arrow present
    let downArrowOffsetX: CGFloat = 13.0
    
    // If just loading one tip, these variables are used
    var justOneTip = false
    var singleTipData: Tip?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // position arrows to look correct
        self.arrowView.bounds = CGRectOffset(self.arrowView.bounds, 6, 0)
        self.downArrowButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, downArrowOffsetX)
        self.forwardArrowButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        self.backArrow.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        
        self.populateUI()
        if !justOneTip { TipDataManager.sharedInstance.markMessageRead(selectedIndex) }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.determineArrowEnablement()
        
        // Minimize incentive view if we haven't already scrolled to the bottom in 2.5 seconds
        Utils.delay(5) {
            if !self.alreadyHitBottom {
                self.minimizeBottomIncentiveView()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    Manually sets line spacing on the largeTextLabel text because custom font line spacing has issues in Storyboard
    */
    func formatAttributedTextOnLabel() {
        // Manually set line spacing and font of attributed label
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        var attrs = [NSFontAttributeName :  UIFont.merriweather(17.0), NSParagraphStyleAttributeName: style]
        var result = NSMutableAttributedString(string: self.largeTextLabel.text!, attributes: attrs)
        self.largeTextLabel.attributedText = result
    }
    
    // MARK: Data Injecting and Tip navigation
    
    /**
    Helper method to reload the UI with new data, taking into account if there is just one Tip to load
    */
    func populateUI() {
        
        // determine if just loading a single Tip
        var tipData: Tip!
        if let singleTip = singleTipData {
            tipData = singleTip
            self.justOneTip = true
        } else {
            tipData = TipDataManager.sharedInstance.tips[selectedIndex] as Tip
            self.justOneTip = false
        }
        
        // Set new label data
        self.dateLabel.text = tipData.date!.perchTableCellStringFormat()
        self.titleLabel.text = tipData.title
        self.largeTextLabel.text = tipData.detail
        self.formatAttributedTextOnLabel()
        
        // loads and shows incentive data if available
        if let tipAction = tipData.tipAction {
            self.incentiveType.text = tipAction.type
            self.iconBackgroundView.image = UIImage(named: tipAction.actualIconName)
            self.incentiveTitle.text = tipAction.title
            self.addSensorLabel.text = tipAction.message
            self.addSensorLabel.setKernAttribute(1.5)
            
            // reset to last value of a shown incentive
            self.incentiveBottomConstraint.constant = self.visibilityOnHide
        } else {
            // move incentive view off screen
            self.incentiveBottomConstraint.constant = -(self.incentiveView.frame.size.height)
        }
    }
    
    /**
    Action to perform when down arrow is pressed, which involves navigating to next tip
    */
    @IBAction func previousTip(sender: AnyObject) {
        
        if self.selectedIndex > 0 {
            
            self.determineIncentiveVisibility()
            self.selectedIndex = self.selectedIndex - 1
            self.determineArrowEnablement()
            self.populateUI()
            TipDataManager.sharedInstance.markMessageRead(selectedIndex)
        }
    }
    
    /**
    Action to perform when up arrow is pressed, which involves navigating to previous tip
    */
    @IBAction func nextTip(sender: AnyObject) {
        
        if self.selectedIndex < TipDataManager.sharedInstance.tips.count - 1 {
            
            self.determineIncentiveVisibility()
            self.selectedIndex = self.selectedIndex + 1
            self.determineArrowEnablement()
            self.populateUI()
            TipDataManager.sharedInstance.markMessageRead(selectedIndex)
        }
    }
    
    /**
    Anytime there is a transition in tip, remember the amount of visibility the incentive view has
    */
    func determineIncentiveVisibility() {
        
        var tipObject = TipDataManager.sharedInstance.tips[self.selectedIndex] as Tip
        if let tipAction = tipObject.tipAction {
            self.visibilityOnHide = self.incentiveBottomConstraint.constant
        }
    }
    
    /**
    Simple method to check whether the up and down arrows should be able to progress to another tip
    */
    func determineArrowEnablement() {
        
        self.upArrowButton.hidden = true
        self.downArrowButton.hidden = true
        
        if !justOneTip {
            // if we are on the first tip
            if self.selectedIndex != 0 {

                // move downarrow back to original position if necessary
                if self.downArrowButton.frame.origin.x == (self.upArrowButton.frame.origin.x + self.downArrowOffsetX) {
                    UIView.animateWithDuration(0.25, animations: {
                        self.downArrowButton.frame = CGRectOffset(self.downArrowButton.frame, (self.upArrowButton.frame.size.width - self.downArrowOffsetX), 0)
                    }, completion: { finished -> Void in
                    self.upArrowButton.hidden = false })
                } else {
                    self.upArrowButton.hidden = false
                }
                
            } else {
                // move to hidden uparrows location in order to not look awkward
                UIView.animateWithDuration(0.25) { self.downArrowButton.frame = CGRectOffset(self.downArrowButton.frame, (-self.upArrowButton.frame.size.width + self.downArrowOffsetX), 0) }
            }
            
            // if we are on the last tip
            if self.selectedIndex != TipDataManager.sharedInstance.tips.count-1 {
                self.downArrowButton.hidden = false
            }
        } else {
            self.backArrow.hidden = false
            self.forwardArrowView.hidden = true
        }
    }
    
    // MARK: Bottom Incentive View Transitions
    
    /**
    Minimize the incentive view bottom constraint down, bottom space to superview being -90px
    */
    func minimizeBottomIncentiveView() {

        if self.incentiveBottomConstraint.constant > minimizedBottomConstraint {
            
            self.incentiveBottomConstraint.constant = minimizedBottomConstraint
            self.view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(0.25) {
                self.toggleIncentiveVisibility(0.0)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    /**
    Maximize the incentive view bottom constraint to original position, bottom space to superview being 0px
    */
    func maximizeBottomIncentiveView() {
        
        if self.incentiveBottomConstraint.constant == minimizedBottomConstraint || self.incentiveBottomConstraint.constant >= minimizedBottomConstraint/2 {
            
            self.incentiveBottomConstraint.constant = 0
            self.view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(0.25) {
                self.toggleIncentiveVisibility(1.0)
                self.view.layoutIfNeeded()
            }
          
        }
    }
    
    /**
    Method to gradually show and hide incentive UI components
    
    :param: alpha alpha value to apply to incentive UI components, 0 to 1
    */
    func toggleIncentiveVisibility(alpha: CGFloat) {
        self.incentiveType.alpha = alpha
        self.iconBackgroundView.alpha = alpha
        self.incentiveTitle.alpha = alpha
        self.addSensorLabel.alpha = alpha
        self.pullUpView.alpha = 1.0 - alpha // do the opposite
        
    }

    /**
    Method to dismiss view controller from right or left depending on number of tips handling
    */
    @IBAction func dismissView(sender: AnyObject) {
        if justOneTip {
            self.view.window?.layer.addAnimation(Utils.customTransitionFromDirection(kCATransitionFromLeft), forKey: nil)
        } else {
            self.view.window?.layer.addAnimation(Utils.customTransitionFromDirection(kCATransitionFromRight), forKey: nil)
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }

}

extension TipDetailViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}

// MARK: UIScrollViewDelegate methods

extension TipDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        // determines if we have scrolled to the bottom and if incentive view is not being panned
        if bottomEdge >= scrollView.contentSize.height && !panningInProgress {
            self.alreadyHitBottom = true
            self.maximizeBottomIncentiveView()
        }
    }
    
}

// MARK: UIPanGestureRecognizerDelegate for Incentive view

extension TipDetailViewController: UIGestureRecognizerDelegate {
    
    @IBAction func panning(sender: UIPanGestureRecognizer) {
        self.alreadyHitBottom = true
        
        if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
            self.panningInProgress = true
            
            var translatedPoint = sender.translationInView(self.view)
            var constraintCandidate = self.incentiveBottomConstraint.constant - translatedPoint.y

            // keeps constraint value between allowed values
            if constraintCandidate >= minimizedBottomConstraint && constraintCandidate <= 0 {
                
                self.incentiveBottomConstraint.constant = constraintCandidate
                self.view.setNeedsUpdateConstraints()
                self.view.layoutIfNeeded()
                
                // create a slow transition of incentive UI components appearance
                var alphaVal = (90 + constraintCandidate) * 0.01
                self.toggleIncentiveVisibility(alphaVal)
                
                // reset translation after every change, so movement is reasonable
                sender.setTranslation(CGPointMake(0, 0), inView: self.view)
            }
        
        } else if sender.state == UIGestureRecognizerState.Ended {
            if self.incentiveBottomConstraint.constant != 0 && self.incentiveBottomConstraint.constant != minimizedBottomConstraint {
                
                self.incentiveView.userInteractionEnabled = false
                
                if self.incentiveBottomConstraint.constant < minimizedBottomConstraint/2 {
                    self.minimizeBottomIncentiveView()
                } else {
                    self.maximizeBottomIncentiveView()
                }
                self.incentiveView.userInteractionEnabled = true

            }
            self.panningInProgress = false
        }

    }
}
