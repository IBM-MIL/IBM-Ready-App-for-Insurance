/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import QuartzCore

/**
*  View Controller to display a user's different home sensor assets that are connected with the app
*/
class AssetsViewController: UIViewController {
    
    @IBOutlet weak var assetCollectionView: UICollectionView!

    /// edge insets for all iPhones, iPad has more padding
    let standardEdgeInsets = UIEdgeInsetsMake(8, 20, 0, 20)
    
    /// Boolean checked when a new notification has come in
    var isVisible = false
    
    weak var navDelegate: NavHandlerDelegate?
    let perchAlertManager = PerchAlertViewManager.sharedInstance
    let assetOverviewDataManager = AssetOverviewDataManager.sharedInstance
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // No need to query asset data on view did load. Asset data should have been queried from Pin VC to get to this point
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
        
        // Make sure to set the callback in case it has been changed elsewhere
        self.assetOverviewDataManager.callback = {[unowned self] in self.assetDataReturned($0)}
        
        if AssetOverviewDataManager.sharedInstance.shouldReload {
            getAllAssetData()
        } else {
            assetCollectionView.reloadData()
        }
        
        // If we didn't get any data, show the alert view. Have to add a delay because of a weird UI bug.
        if assetOverviewDataManager.sensors.count == 0 {
            _ = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("callPerch"), userInfo: nil, repeats: false)
        }
    }
    
    func callPerch() {
        self.perchAlertManager.displayDefaultPinAlert()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.isVisible = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Worklight calls for asset data
    
    /**
    Method to query AssetOverviewDataManager for all asset data
    */
    func getAllAssetData() {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            self.assetOverviewDataManager.getAllAssetData({[unowned self] in self.assetDataReturned($0)})
            
        }
        
    }
    
    /**
    Callback method passed into worklight call. Method takes action based on backend query success or failure
    
    - parameter success: Bool representing status of worklight response
    */
    func assetDataReturned(success: Bool) {
        
        dispatch_async(dispatch_get_main_queue()) {
            if success {
                let manager = AssetOverviewDataManager.sharedInstance
                if manager.sensors.count != 0 {
                    self.assetCollectionView.reloadData()
                    self.perchAlertManager.hideAlertView()
                } else {
                    MQALogger.log("Asset Overview data query was successful, but found no data", withLevel: MQALogLevelWarning)
                    self.perchAlertManager.displayDefaultPinAlert()
                }
                
            } else {
                MQALogger.log("Asset Overview data query was unsuccessful", withLevel: MQALogLevelWarning)
                self.perchAlertManager.displayDefaultPinAlert()
            }
        }
    }
    
    /**
    Method that kicks off assetDetail animation
    
    - parameter assetID: ID for asset to load
    */
    func presentViewControllerFromBottom(assetStatus: Int) {
        if let del = navDelegate {
            del.assetSelected(assetStatus)
        }
        
    }

    /**
    Helper method for reloading the asset overview page to stay in sync with simulator values.
    Called when the app comes back into foreground or when a push notification comes in.
    */
    class func reload() {
        if UIViewController.assetOverviewReference().isKindOfClass(AssetsViewController) {
            let assetOverviewVC = UIViewController.assetOverviewReference() as! AssetsViewController
            if assetOverviewVC.isVisible {
                MQALogger.log("Reloading asset overview because push notification")
                AssetOverviewDataManager.sharedInstance.getAllAssetData(assetOverviewVC.assetDataReturned)
            } else {
                AssetOverviewDataManager.sharedInstance.shouldReload = true
            }
        } else {
            AssetOverviewDataManager.sharedInstance.shouldReload = true
        }
    }
    
    /**
    Method to add a sensor, currently is is not implemented so it throws up an alert
    
    - parameter sender: the sending object
    */
    @IBAction func addSensor(sender: AnyObject) {
        perchAlertManager.displaySimpleAlertSingleButton(NSLocalizedString("This feature is not implemented.", comment: ""), buttonText: NSLocalizedString("DISMISS", comment: ""), callback: nil)
    }
    
}


extension AssetsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let manager = AssetOverviewDataManager.sharedInstance
        if manager.sensors.count > 0 {
            return manager.sensors.count
        }
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("assetCell", forIndexPath: indexPath) as! AssetCollectionViewCell
        
        if AssetOverviewDataManager.sharedInstance.sensors.count > 0 {
            let sensorData = AssetOverviewDataManager.sharedInstance.sensors[indexPath.row] as SensorData
            cell.swapAssetState(sensorData.status)
            cell.setIconForDevice(sensorData.deviceType!, sensorStatus: sensorData.status)
            cell.typeLabel.text = sensorData.name
        } else {
            // Enables gray circles to show up as placeholders
            cell.swapAssetState(0)
            cell.assetIconImageView.image = nil
        }
        
        return cell
    }
    
    // MARK: CollectionView delegate and layout methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var totalCellWidth: CGFloat!
        
        // If on iPad, have tighter spacing
        if UIScreen.mainScreen().bounds.size.width >= 768 {
            // subtracting 300 so cells are not gigantic on iPad
            totalCellWidth = collectionView.frame.size.width - 300
        } else {
            
            // Allows cells to increase in size on larger devices
            let horizontalSpacing = self.standardEdgeInsets.left * 3
            totalCellWidth = collectionView.frame.size.width - horizontalSpacing
        }
        
        // Using available cell width, divide by 2 for single cell width and then multiple by aspect ratio for height
        let size = CGSizeMake(totalCellWidth/2, (totalCellWidth/2)*1.03)
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        // if on iPad, increase collectionview padding essentially
        if UIScreen.mainScreen().bounds.size.width >= 768 {
            return UIEdgeInsetsMake(8, 110, 0, 110)
        }
        return self.standardEdgeInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        // Without changing the layout a lot, this is a working solution to space items correctly
        let bounds = UIScreen.mainScreen().bounds
        if bounds.size.height <= 568 {
            return 35
        } else if bounds.size.height <= 667 {
            return 48
        } else {
            return 64
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if AssetOverviewDataManager.sharedInstance.sensors.count > 0 {
            let sensorData = AssetOverviewDataManager.sharedInstance.sensors[indexPath.row] as SensorData
            
            // If sensor not enabled, display alert explaining that
            if !sensorData.enabled {
                self.addSensor(self.view)
            } else {
                
                // set route for selected asset
                CurrentSensorDataManager.sharedInstance.lastSelectedAsset = sensorData.deviceClassId
                let specificRoute = ["route":"sensorDetail/\(sensorData.deviceClassId)"]
                WL.sharedInstance().sendActionToJS("changePage", withData: specificRoute)
                
                // start off equal so we can detect change later
                CurrentSensorDataManager.sharedInstance.prevSensorStatus = sensorData.status
                CurrentSensorDataManager.sharedInstance.currentSensorStatus = sensorData.status
                
                // set device ID so we can begin polling in NativeViewController
                let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
                appDel.hybridViewController.deviceID = sensorData.deviceClassId
                self.presentViewControllerFromBottom(sensorData.status)
            }
        }
    }
    
}
