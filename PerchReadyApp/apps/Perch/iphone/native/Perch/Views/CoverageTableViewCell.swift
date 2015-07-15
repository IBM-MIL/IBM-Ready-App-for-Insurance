/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  This cell displays the itemized insurance information on the Coverage View Controller
*/
class CoverageTableViewCell: UITableViewCell {

    @IBOutlet weak var coverageType: UILabel!
    @IBOutlet weak var coverageLimit: UILabel!
    @IBOutlet weak var coveragePremium: UILabel!
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    let configManager = ConfigManager.sharedInstance
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Called by the containing table view to change margins if on the 6+
    func changeMargins() {
        leftConstraint.constant = configManager.largeMargin
        rightConstraint.constant = configManager.largeMargin
        self.updateConstraints()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
