/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  UITableViewCell that handles a tip's status and UI
*/
class TipsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusIndicatorView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    /**
    Method to set a tip message status indicator based on if it has been read or is high priority
    
    :param: readStatus     boolean representing if message has been read
    :param: priorityStatus boolean representing if message is high priority
    */
    func updateTipStatus(readStatus: Bool, priorityStatus: Bool) {
        
        if !readStatus && !priorityStatus {
            self.statusIndicatorView.backgroundColor = UIColor.unreadStatusOrange(alpha: 1.0)
        } else if priorityStatus {
            self.statusIndicatorView.backgroundColor = UIColor.unreadStatusYellow(alpha: 1.0)
        } else {
            self.statusIndicatorView.backgroundColor = UIColor.clearColor()
        }
        
    }
    
}
