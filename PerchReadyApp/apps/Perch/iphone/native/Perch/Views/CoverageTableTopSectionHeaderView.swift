/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2014, 2015. All Rights Reserved.
*/

import UIKit

/**
*  This is the view that is displayed at the top of the Table View in the Coverage View controller
*/
class CoverageTableTopSectionHeaderView: UIView {
    
    var suggestedHeight: CGFloat!
    let configManager = ConfigManager.sharedInstance

    @IBOutlet weak var coverageLabel: UILabel!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        suggestedHeight = self.frame.size.height
        
        // if this is an iPhone 6+, change the margins some
        if UIScreen.mainScreen().bounds.size.height == 736 {
            var additionalMargin = configManager.largeMargin - coverageLabel.frame.origin.y
            
            // Have to fudge this a little to make it look correct
            suggestedHeight = suggestedHeight + additionalMargin - 4

            leftMargin.constant = configManager.largeMargin
            rightMargin.constant = configManager.largeMargin
            self.updateConstraints()
        }
    }
}
