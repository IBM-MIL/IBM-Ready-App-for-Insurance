/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Responsible for controlling the Alert history screen that shows a list of alerts for a given asset.
*/
class HistoryViewController: PageItemViewController {
    
    @IBOutlet weak var navBarTitleLabel: UILabel!
    @IBOutlet weak var alertHistoryTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let perchAlertManager = PerchAlertViewManager.sharedInstance
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavBarTitle()
        self.getAllHistoryAlertData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reloading here to reflect the read status when coming back from detail
        self.alertHistoryTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Helper Methods
    
    /**
    Helper method for setting the nav bar title based on the last selected asset
    */
    func setNavBarTitle() {
        if let deviceType = AssetOverviewDataManager.sharedInstance.deviceTypeForID(CurrentSensorDataManager.sharedInstance.lastSelectedAsset!)  {
            switch deviceType {
            case .AirConditioning:
                self.navBarTitleLabel.text = "Air Conditioner Alert History"
            case .WaterMeter:
                self.navBarTitleLabel.text = "Water Meter Alert History"
            case .SewerSystem:
                self.navBarTitleLabel.text = "Sewer System Alert History"
            default:
                self.navBarTitleLabel.text = "Sensor Alert History"
            }
        } else {
            self.navBarTitleLabel.text = "Sensor Alert History"
        }
    }
    
    /**
    Helper method to simply load up the alert view initially with retry or dismiss options
    
    - parameter text: text to be displayed in the alert
    */
    func loadAlert(text: String) {
        
        perchAlertManager.displayDefaultSimpleAlertTwoButtons({ () -> () in
            self.getAllHistoryAlertData()
            self.perchAlertManager.hideAlertView()
            }, rightButtonCallback: { () -> () in
                self.perchAlertManager.hideAlertView()
        })
    }
    
    // MARK: Worklight calls and callbacks
    
    /**
    Method for initiating worklight query for a list of alerts that have occurred for this asset
    */
    func getAllHistoryAlertData() {
        
        self.activityIndicator.startAnimating()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let alertHistoryDataManager = AlertHistoryDataManager.sharedInstance
            alertHistoryDataManager.getAlertHistory(self.alertHistoryReturned)
            
        }
    }
    
    /**
    Callback for when the worklight query returns
    
    - parameter success: Whether the query was successful or not
    */
    func alertHistoryReturned(success: Bool) {
        
        // Called from asynchronous action, so get back on main queue before performing UI
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            if success {
                self.alertHistoryTableView.reloadData()
            } else {
                MQALogger.log("Alert history data query was unsuccessful", withLevel: MQALogLevelWarning)
                self.loadAlert(NSLocalizedString("Unable to connect with the server, please try again", comment: ""))
            }
        }
    }
    
    // MARK: IBActions
    
    /**
    For navigating back to asset detail from alert history list
    
    - parameter sender: The UI object that triggered the action
    */
    @IBAction func navigateLeftToAssetDetail(sender: AnyObject) {
        self.pageHandlerViewController.navigateToIndex(1, fromIndex: self.pageIndex, animated: true)
        
        // Release this view controller from memory when going back.
        // This would happen automatically in a normal uinavigationcontroller,
        // but since we have a different setup we have to explicitly dismiss and
        // remove any reference of it manually
        if UIViewController.pageHanderReference().isKindOfClass(PageHandlerViewController) {
            let phvc = UIViewController.pageHanderReference() as! PageHandlerViewController
            phvc.historyViewController = nil
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
        // Clear out alerts when going back so next time we come to this screen, the list won't be pre-populated with old data
        AlertHistoryDataManager.sharedInstance.alerts = []
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlertHistoryDataManager.sharedInstance.alerts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AlertCell") as! AlertTableViewCell
        let alert = AlertHistoryDataManager.sharedInstance.alerts[indexPath.row]
        
        cell.titleLabel.text = alert.title
        cell.previewTextLabel.text = alert.message
        cell.unreadIndicatorView.hidden = alert.read
        cell.dateLabel.text = alert.date!.perchTableCellStringFormat()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Since this is not a normal navigation controller, we have to manually create the segue look
        self.view.window?.layer.addAnimation(Utils.customTransitionFromDirection(kCATransitionFromRight), forKey: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let detailVC = storyboard.instantiateViewControllerWithIdentifier("AlertDetailViewController") as? AlertDetailViewController
        detailVC?.alert = AlertHistoryDataManager.sharedInstance.alerts[indexPath.row]
        detailVC?.currentSensor = CurrentSensorDataManager.sharedInstance.lastSelectedAsset
        detailVC?.comingFromHistoryList = true
        detailVC?.currentAlertIndexInList = indexPath.row
        self.presentViewController(detailVC!, animated: false, completion: nil)
    }
}

// MARK: UINavigationBarDelegate

/**
*  Overriding this method so we can extend the navigation bar color to the status bar
*/
extension HistoryViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}
