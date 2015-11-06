/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  This view controller is embedded in the profile view controller. It displays the user's coverage information in an itemized form.
*/
class CoverageViewController: PerchViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var savingsButton: UIButton!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var topSectionHeaderView: CoverageTableTopSectionHeaderView?
    var midSectionHeaderView: CoverageTableSectionHeaderView?

    let currentUser = CurrentUser.sharedInstance
    let configManager = ConfigManager.sharedInstance
    let arrowImgTag = 99
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the savings button
        savingsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        savingsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        savingsButton.titleLabel?.minimumScaleFactor = 0.2
        savingsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        // Create the view that will be used in the table view
        topSectionHeaderView = UINib(nibName: "CoverageTableTopSectionHeader", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? CoverageTableTopSectionHeaderView
        midSectionHeaderView = UINib(nibName: "CoverageTableSectionHeader", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? CoverageTableSectionHeaderView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // if iPhone 6+, increase the margins of the elements on the screen
        if UIScreen.mainScreen().bounds.size.height == 736 {
            savingsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        }
        
        // If NOT an iPhone 5 or 5s, have an attributed title so we can have kerning
        if UIScreen.mainScreen().bounds.size.height > 568 {
            let attrString = NSAttributedString(string: savingsButton.titleLabel!.text!, attributes: [NSKernAttributeName:2.0, NSForegroundColorAttributeName: UIColor.perchOrange(1.0)])
            savingsButton.setAttributedTitle(attrString, forState: UIControlState.Normal)
        }
    }
}

// MARK: UITableView Data Source
extension CoverageViewController: UITableViewDataSource {
    
    // There are two sections (coverage items, and savings items)
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentUser.insurance.insuranceItems.count
        } else {
            return currentUser.insurance.creditItems.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 25
    }
    
    /**
    Populate the cells from the Current User object
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("coverageCell") as! CoverageTableViewCell
        
        if indexPath.section == 0{
            if indexPath.row < currentUser.insurance.insuranceItems.count {
                let insuranceItem = currentUser.insurance.insuranceItems[indexPath.row]
                cell.coverageType.text = insuranceItem.coverageName
                cell.coverageLimit.text = insuranceItem.coverageLimitString
                cell.coveragePremium.text = insuranceItem.coveragePremiumString
            }
        } else {
            if indexPath.row < currentUser.insurance.creditItems.count {
                let creditItem = currentUser.insurance.creditItems[indexPath.row]
                cell.coverageType.text = creditItem.creditName
                cell.coverageLimit.text = ""
                cell.coveragePremium.text = creditItem.creditSavingsString
            }
        }
        
        // If this is the 6+ tell the cell to layout differently
        if UIScreen.mainScreen().bounds.size.height == 736 {
            cell.changeMargins()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return topSectionHeaderView!.suggestedHeight
        }
        return midSectionHeaderView!.suggestedHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if topSectionHeaderView != nil {
                return topSectionHeaderView!
            }
        } else {
            if midSectionHeaderView != nil {
                return midSectionHeaderView!
            }
        }
        return nil
    }
}

// MARK: UITableView Delegate
extension CoverageViewController: UITableViewDelegate {
    
}
