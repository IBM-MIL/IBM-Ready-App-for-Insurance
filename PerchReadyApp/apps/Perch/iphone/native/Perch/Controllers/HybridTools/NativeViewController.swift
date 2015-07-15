/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  View Controller wrapper around the HybridViewController that smooths the transition to a hybrid view
*/
class NativeViewController: UIViewController {

    weak var appDelegate: AppDelegate!
    var pollingTimer: NSTimer!
    
    /// Allows only one request at a time to be sent to worklight for the getCurrentAssetDetail procedure
    var requestInProcess = false
    
    /// Allows hybrid view to essentially be reset when leaving the asset detail / asset history flow
    var leavingAssetDetailFlow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    // MARK: Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MQALogger.log("NativeViewController#viewWillAppear(Bool) invoked!")
        self.setUpContainer()
        
        if let sensorID = appDelegate.hybridViewController.deviceID {
            self.pollCurrentSensor()
            self.pollingTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "pollCurrentSensor", userInfo: nil, repeats: true)
            HistoricalDataManager.sharedInstance.getAllHistoricalData(sensorID, callback: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.pollingTimer.invalidate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if leavingAssetDetailFlow {
            var otherRoute = ["route":"loading"]
            WL.sharedInstance().sendActionToJS("changePage", withData: otherRoute)
            leavingAssetDetailFlow = false
            appDelegate.hybridViewController.deviceID = nil
        }
    }
    
    /**
    This method sets up the container to hold the hybridViewController within the nativeViewController.
    */
    func setUpContainer(){
        self.addChildViewController(appDelegate.hybridViewController)
        appDelegate.hybridViewController.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height)
        
        self.view.addSubview(appDelegate.hybridViewController.view)
        
        appDelegate.hybridViewController.didMoveToParentViewController(self)
    }
    
    // MARK: Perch specific methods
    
    /**
    Polling method called every 5 seconds to query server (on a background thread) for new sensor value
    */
    func pollCurrentSensor() {
        if let sensorID = appDelegate.hybridViewController.deviceID {
            if !requestInProcess {
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    self.requestInProcess = true
                    CurrentSensorDataManager.sharedInstance.getCurrentAssetDetail(sensorID, callback: {[weak self] in self?.sensorPollingResult($0)})
                }
            }
        }
    }
    
    /**
    CurrentSensorDataManager callback to inform native view controller if query worked, useful in detecting asset status change
    
    :param: success boolean representing if query succeeded
    */
    func sensorPollingResult(success: Bool) {
        
        dispatch_async(dispatch_get_main_queue()) {

            self.requestInProcess = false
            if success {
                if CurrentSensorDataManager.sharedInstance.prevSensorStatus != CurrentSensorDataManager.sharedInstance.currentSensorStatus {
                    // Update native separtor color and mark asset overview page to be updated on re-appearing
                    if let parentVC = self.parentViewController as? NavHandlerViewController {
                        parentVC.updateSepartorColor(CurrentSensorDataManager.sharedInstance.currentSensorStatus)
                    }
                    AssetOverviewDataManager.sharedInstance.shouldReload = true
                }
                // reset to detect future changesd
                CurrentSensorDataManager.sharedInstance.prevSensorStatus = CurrentSensorDataManager.sharedInstance.currentSensorStatus
            } else {
                MQALogger.log("Call to getCurrentAssetDetail has failed")
            }

        }
        
    }
    
}

extension NativeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
