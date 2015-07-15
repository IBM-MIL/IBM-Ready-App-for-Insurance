/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/** 
View Controller to display a list of tips, from your agent, in a UITableView
*/
class TipsViewController: PageItemViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var tipsTextLabel: UILabel!
    @IBOutlet weak var tipCountView: UIView!
    @IBOutlet weak var tipCountLabel: UILabel!
    @IBOutlet weak var tipsTableView: UITableView!
    @IBOutlet weak var topButtonImageView: UIImageView!
    @IBOutlet weak var middleButtonImageView: UIImageView!
    @IBOutlet weak var bottomButtonImageView: UIImageView!
    
    @IBOutlet weak var buttonBackgroundView: UIView!
    @IBOutlet weak var topButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var recentButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var unreadButton: UIButton!
    
    /// Tuple with sorting buttons, top constraint for each button, and selected status imageview beside button text
    var buttonPairings: [(UIButton!, NSLayoutConstraint!, UIImageView!)]!
    var selectedButtonIndex: Int = 0
    var originalFrame: CGRect!
    
    /// Determines if all sorting buttons are visible
    var isSortMenuVisible = false
    
    /// Used to have data sorted by Unread originally
    var isFirstDataCall = true
    var oldList = [Tip]()
    let perchAlertManager = PerchAlertViewManager.sharedInstance
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAllTipData()

        self.tipCountView.layer.cornerRadius = tipCountView.frame.size.width/2
        // using aspectFit so we don't have to change imageview size when made a circle
        self.topButtonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.middleButtonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.bottomButtonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.pageIndex = 0
        
        buttonPairings = [(unreadButton, topButtonConstraint, topButtonImageView), (priorityButton, middleButtonConstraint, middleButtonImageView), (recentButton, bottomButtonConstraint, bottomButtonImageView)]
        self.tipsTableView.registerNib(UINib(nibName: "TipsTableViewCell", bundle: nil), forCellReuseIdentifier: "tipCell")
        self.applyKerning()

    }
    
    /**
    Helper method to apply kerning to sorting buttons
    */
    func applyKerning() {
        for pair in buttonPairings {
            pair.0.setKernAttribute(2.0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.originalFrame = self.tipsTableView.frame
        
        // Update unread count if necessary
        if TipDataManager.sharedInstance.tips.count != 0 {
            self.tipCountUpdate()

        } else {
            if !TipDataManager.sharedInstance.queryInProgress {
                // if view is visible and there is no data, provide option to retry
                self.loadAlert(NSLocalizedString("Unable to connect with the server, please try again", comment: ""))
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        //dismiss sort menu if open
        if isSortMenuVisible {
            self.sortButtonPressed(self.view)
        }
    }
    
    /**
    Helper method to update tip count label or hide it if there are no unread tips
    */
    func tipCountUpdate() {
        if self.tipCountLabel.text != "\(TipDataManager.sharedInstance.unreadCount)" {
            if TipDataManager.sharedInstance.unreadCount == 0 {
                self.tipCountView.hidden = true
                self.tipsTableView.reloadData() // reload to update unread status
            } else {
                self.tipCountLabel.text = "\(TipDataManager.sharedInstance.unreadCount)"
                self.tipCountView.hidden = false
                self.tipsTableView.reloadData()
            }
        }
    }

    @IBAction func navigateRightToAssets(sender: AnyObject) {
        self.pageHandlerViewController.navigateToIndex(1, fromIndex: self.pageIndex, animated: true)
    }
    
    // MARK: Worklight calls and callbacks
    
    /**
    Method to query TipDataManager for all tip data
    */
    func getAllTipData() {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            var tipDataManager = TipDataManager.sharedInstance
            tipDataManager.getTipData({[unowned self] in self.tipDataReturned($0)})
            
        }
        
    }
    
    /**
    Callback method passed into worklight query and it called after worklight response
    
    :param: success Bool representing status of worklight response
    */
    func tipDataReturned(success: Bool) {
        
        dispatch_async(dispatch_get_main_queue()) {
            if success {
                var manager = TipDataManager.sharedInstance
                if manager.tips.count != 0 {
                    
                    if self.isFirstDataCall {
                        self.isFirstDataCall = false
                        TipDataManager.sharedInstance.sortTipDataBy("UNREAD", callback: nil)
                    }
                    // ensure tip count label gets updated
                    self.tipCountLabel.text = "\(TipDataManager.sharedInstance.unreadCount)"
                    self.tipsTableView.reloadData()
                    self.perchAlertManager.hideAlertView()
                } else {
                    
                    MQALogger.log("Tip data query was successful, but found no data", withLevel: MQALogLevelWarning)
                    // check to see if this view is actually the visible one
                    if self.pageHandlerViewController.currentIndex == self.pageIndex {
                        self.loadAlert(NSLocalizedString("Unable to connect with the server, please try again", comment: ""))
                    }
                }
            } else {
                MQALogger.log("Tip data query was unsuccessful", withLevel: MQALogLevelWarning)
                if self.pageHandlerViewController.currentIndex == self.pageIndex {
                    self.loadAlert(NSLocalizedString("Unable to connect with the server, please try again", comment: ""))
                }
            }
        }
        
    }
    
    /**
    Helper method to simply load up the alert view initially with retry or dismiss options
    
    :param: text text to be displayed in the alert
    */
    func loadAlert(text: String) {
    
        perchAlertManager.displayDefaultSimpleAlertTwoButtons({[unowned self] in self.retryGetTips()}, rightButtonCallback: perchAlertManager.hideAlertView)
    }
    
    /**
    Retry get tip data from the alert popup
    */
    func retryGetTips( ) {
        self.getAllTipData()
        self.perchAlertManager.showLoadingScreen("Retrieving tips...")
    }
    
    // MARK: Sorting UI and functionality
    
    /**
    Method handles the sort menu opening and buttons being selected.
    
    :param: sender sending object of type UIButton
    */
    @IBAction func sortButtonPressed(sender: AnyObject) {

        if isSortMenuVisible {
            
            var chosenConstraint: NSLayoutConstraint!
            var chosenIndex: Int = self.selectedButtonIndex
            
            // The following block of code determines if sorting needs to happen or just dismissing sortMenu
            if var tappedButton = sender as? UIButton {
                // if not equal, then a swap needs to happen
                if tappedButton != buttonPairings[selectedButtonIndex].0 {
                    for (index, pair) in enumerate(buttonPairings) {
                        // find constraint to change top button to
                        if pair.0 == tappedButton {
                            chosenConstraint = pair.1
                            chosenIndex = index
                        }
                    }
                }
                
                // Sort and reload data
                self.oldList = TipDataManager.sharedInstance.tips
                TipDataManager.sharedInstance.sortTipDataBy(self.buttonPairings[chosenIndex].0.titleLabel!.text!, callback: self.reloadWithAnimation)

            }
            
            // Make current selection have an arrow dropdown
            
            self.swapIconLook(self.buttonPairings[chosenIndex].2, isArrow: false)
            
            UIView.animateWithDuration(0.35, animations: {
                self.buttonBackgroundView.frame = CGRectOffset(self.buttonBackgroundView.frame, 0, -15)
                self.tipsTableView.frame = CGRectOffset(self.tipsTableView.frame, 0, -110)
                self.tipsTableView.setHeight(self.originalFrame.size.height)
                
                // animate button swap
                if chosenConstraint != nil {
                    self.buttonPairings[self.selectedButtonIndex].1.constant = chosenConstraint.constant
                    chosenConstraint.constant = 0
                    self.selectedButtonIndex = chosenIndex
                    self.view.layoutIfNeeded()
                }
                
            })
            isSortMenuVisible = false
            
        } else {
            
            // just animate tableview down and change the orange arrow to a dot
            self.swapIconLook(self.buttonPairings[self.selectedButtonIndex].2, isArrow: true)
            UIView.animateWithDuration(0.35, animations: {
                self.buttonBackgroundView.frame = CGRectOffset(self.buttonBackgroundView.frame, 0, 15)
                self.tipsTableView.frame = CGRectOffset(self.tipsTableView.frame, 0, 110)
                self.tipsTableView.setHeight(self.originalFrame.size.height - 110)
            })
            isSortMenuVisible = true
            
        }
    }
    
    /**
    Method to change imageview to a rounded elipse and back to a dropdown arrow image
    
    :param: imageView imageView to be altered
    :param: isArrow   check to see what imageView is currently
    */
    func swapIconLook(imageView: UIImageView, isArrow: Bool) {
        // make into elipse
        if isArrow {
            imageView.layer.cornerRadius = imageView.frame.size.width/2
            imageView.backgroundColor = UIColor.perchOrange(alpha: 1.0)
        } else {
            self.buttonPairings[self.selectedButtonIndex].2.hidden = true
            imageView.layer.cornerRadius = 0.0
            imageView.backgroundColor = UIColor.clearColor()
        }
        imageView.hidden = false
    }

    // Method used to dismiss sort menu when tableview is scrolled
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if isSortMenuVisible {
            self.sortButtonPressed(self.view)
        }
    }
    
    /**
    Method to reload certain rows based on if they are different after sorting
    */
    func reloadWithAnimation() {

        var rowsToReload = [NSIndexPath]()
        for (index, tip) in enumerate(TipDataManager.sharedInstance.tips) {
            if tip != oldList[index] {
                rowsToReload.append(NSIndexPath(forRow: index, inSection: 0))
            }
        }
        self.tipsTableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
}

extension TipsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableView Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TipDataManager.sharedInstance.tips.count > 0 {
            return TipDataManager.sharedInstance.tips.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("tipCell", forIndexPath: indexPath) as! TipsTableViewCell
        
        var tipData = TipDataManager.sharedInstance.tips[indexPath.row] as Tip
        cell.titleLabel.text = tipData.title
        cell.descriptionLabel.text = tipData.plainDetail
        cell.typeLabel.text = tipData.tipType.uppercaseString
        cell.typeLabel.setKernAttribute(1.5)
        cell.updateTipStatus(tipData.read, priorityStatus: tipData.highPriority)
        cell.dateLabel.text = tipData.date!.perchTableCellStringFormat()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.view.window?.layer.addAnimation(Utils.customTransitionFromDirection(kCATransitionFromLeft), forKey: nil)
        
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        var detailVC = storyboard.instantiateViewControllerWithIdentifier("TipDetailViewController") as? TipDetailViewController
        detailVC?.selectedIndex = indexPath.row
        self.presentViewController(detailVC!, animated: false, completion: nil)
        
    }
    
}

extension TipsViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}
