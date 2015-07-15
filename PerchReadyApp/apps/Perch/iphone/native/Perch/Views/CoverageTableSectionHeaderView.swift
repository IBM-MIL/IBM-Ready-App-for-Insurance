/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2014, 2015. All Rights Reserved.
*/

import UIKit

/**
*  This is the section header view that is displayed in the middle of the table view on the Coverage View Controller
*/
class CoverageTableSectionHeaderView: UIView {

    var suggestedHeight: CGFloat!
    let configManager = ConfigManager.sharedInstance
    
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        suggestedHeight = self.frame.size.height
        
        // Change some of the margins if on the 6+
        if UIScreen.mainScreen().bounds.size.height == 736 {
            suggestedHeight = suggestedHeight + 20
            topMargin.constant = topMargin.constant + 10
            leftMargin.constant = configManager.largeMargin
            rightMargin.constant = configManager.largeMargin
            self.updateConstraintsIfNeeded()
        }
    }

}
