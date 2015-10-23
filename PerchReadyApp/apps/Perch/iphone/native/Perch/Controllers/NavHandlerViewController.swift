/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Protocol to know when an asset was selected and we should transition to it's view
*/
protocol NavHandlerDelegate: class {
    func assetSelected(assetStatus: Int)
}

/**
*  View Controller that acts as a wrapper for asset overview and asset detail in order to have a smooth transition
*/
class NavHandlerViewController: PageItemViewController, NavHandlerDelegate {

    @IBOutlet weak var tipCountView: UIView!
    @IBOutlet weak var tipCountLabel: UILabel!
    @IBOutlet weak var navBarTitleImage: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var formerLeftBarButton: UIBarButtonItem!
    var formerRightBarButton: UIBarButtonItem!
    var assetsViewController: AssetsViewController!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tipCountView.layer.cornerRadius = tipCountView.frame.size.width/2
        self.navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.perchDarkGray(1.0)]
        
        // Used to make nav bar transparent
        self.navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navBar.shadowImage = UIImage()
        self.navBar.translucent = true
    }
    
    // Add self as an action receiver when the VC appears
    override func viewWillAppear(animated: Bool) {
        WL.sharedInstance().addActionReceiver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Update unread count if necessary
        if TipDataManager.sharedInstance.tips.count != 0 {
            self.tipCountUpdate()
        }
    }
    
    /**
    Helper method to update tip count label or hide it if there are no unread tips
    */
    func tipCountUpdate() {
        if self.tipCountLabel.text != "\(TipDataManager.sharedInstance.unreadCount)" {
            if TipDataManager.sharedInstance.unreadCount == 0 {
                self.tipCountView.hidden = true
            } else {
                self.tipCountLabel.text = "\(TipDataManager.sharedInstance.unreadCount)"
                self.tipCountView.hidden = false
            }
        }
    }
    
    // Remove self as an action receiver in case we need to deallocate this view controller (like on logout)
    override func viewDidDisappear(animated: Bool) {
        WL.sharedInstance().removeActionReceiver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Method to manually navigate pages in UIPageViewController
    @IBAction func navigateToTips(sender: AnyObject) {
        self.pageHandlerViewController.navigateToIndex(0, fromIndex:self.pageIndex, animated: true)
    }
    
    @IBAction func navigateRightFromMiddle(sender: AnyObject) {
        self.pageHandlerViewController.navigateToIndex(2, fromIndex:self.pageIndex, animated: true)
    }
    
    /**
    UI helper method to update the color of the 1px line under the nav bar
    
    - parameter status: status of the asset to determine color
    */
    func updateSepartorColor(status: Int) {
        if status == 0 {
            self.separatorView.backgroundColor = UIColor(red: 184/255, green: 174/255, blue: 174/255, alpha: 1.0)
        } else {
            self.separatorView.backgroundColor = UIColor.perchDarkYellow(1.0)
        }
    }
    
    /**
    Method to navigate to asset detail page with animation
    
    - parameter assetStatus: status value of asset to determine color of certain asset detail components
    */
    func assetSelected(assetStatus: Int) {
        
        let toVC = self.storyboard!.instantiateViewControllerWithIdentifier("AssetDetail") as! NativeViewController
        self.pageHandlerViewController.disabledPaging = true
        
        // disable buttons while in transition, enable when complete
        self.navItem.leftBarButtonItem?.enabled = false
        self.navItem.rightBarButtonItem?.enabled = false
        
        // prep view controller transition
        assetsViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toVC)
        toVC.view.frame = CGRectOffset(self.assetsViewController.view.frame, 0, self.assetsViewController.view.frame.size.height)

        // create values to update nav bar with
        
        let upButton = UIBarButtonItem(image: UIImage(named: "uparrow_icon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: "popToAssetOverview")
        let historyButton = UIBarButtonItem(image: UIImage(named: "history_icon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: "navigateRightFromMiddle:")
        
        self.transitionFromViewController(assetsViewController, toViewController: toVC, duration: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            // set new frames
            toVC.view.frame = self.assetsViewController.view.frame
            self.assetsViewController.view.frame = CGRectOffset(self.assetsViewController.view.frame, 0, -self.assetsViewController.view.frame.size.height)
            self.navBar.barTintColor = (assetStatus == 0 ? UIColor.perchWarmGray(1.0) : UIColor.unreadStatusYellow(1.0))
            self.updateSepartorColor(assetStatus)
            self.navBarTitleImage.alpha = 0.0
            
            }, completion: { (done: Bool) -> Void in
                
                // save bar button items for asset overview so we don't need to recreate
                self.formerLeftBarButton = self.navItem.leftBarButtonItem
                self.formerRightBarButton = self.navItem.rightBarButtonItem
                
                // update nav bar
                self.navBarTitleImage.hidden = true
                self.navItem.leftBarButtonItem = upButton
                self.navItem.rightBarButtonItem = historyButton
                self.navItem.leftBarButtonItem?.enabled = true
                self.navItem.rightBarButtonItem?.enabled = true
                
                // update child/parent relationship
                self.assetsViewController.removeFromParentViewController()
                toVC.didMoveToParentViewController(self)
                
                // Update page view controller to work with detail and history views
                if let parent = self.parentViewController as? UIPageViewController {
                    if let pageHandler = parent.parentViewController as? PageHandlerViewController {
                        
                        pageHandler.inDetailView = true
                        // These 2 lines essentially reset the UIPageViewController causing it to work properly
                        let startingViewControllers: NSArray = [self]
                        pageHandler.pageViewController!.setViewControllers(startingViewControllers as? [UIViewController], direction: .Forward, animated: false, completion: nil)
                    }
                }
        })
    }
    
    /**
    Method to return from asset detail view to asset overview with animation
    */
    func popToAssetOverview() {
        
        if let fromVC = self.childViewControllers.first as? NativeViewController {
            fromVC.leavingAssetDetailFlow = true
            self.navItem.leftBarButtonItem?.enabled = false
            self.navItem.rightBarButtonItem?.enabled = false
            
            // prep view controller transition
            fromVC.willMoveToParentViewController(nil)
            self.addChildViewController(self.assetsViewController)
            self.assetsViewController.view.frame = CGRectOffset(fromVC.view.frame, 0, -fromVC.view.frame.size.height)
            
            self.navBarTitleImage.hidden = false
            self.transitionFromViewController(fromVC, toViewController: self.assetsViewController, duration: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                // set new frames
                self.assetsViewController.view.frame = fromVC.view.frame
                fromVC.view.frame = CGRectOffset(fromVC.view.frame, 0, fromVC.view.frame.size.height)
                self.navBar.barTintColor = UIColor.whiteColor()
                self.separatorView.backgroundColor = UIColor.perchLightGray(1.0)
                self.navBarTitleImage.alpha = 1.0
                
                }, completion: { (done: Bool) -> Void in
                    
                    self.pageHandlerViewController.disabledPaging = false
                    
                    // update nav bar with saved values
                    self.navItem.leftBarButtonItem = self.formerLeftBarButton
                    self.navItem.rightBarButtonItem = self.formerRightBarButton
                    self.navItem.leftBarButtonItem?.enabled = true
                    self.navItem.rightBarButtonItem?.enabled = true
                    
                    fromVC.removeFromParentViewController()
                    self.assetsViewController.didMoveToParentViewController(self)
                    
                    // Update page view controller to work with detail and history views
                    if let parent = self.parentViewController as? UIPageViewController {
                        if let pageHandler = parent.parentViewController as? PageHandlerViewController {
                            
                            pageHandler.inDetailView = false
                            // These 2 lines essentially reset the UIPageViewController causing it to work properly
                            let startingViewControllers: NSArray = [self]
                            pageHandler.pageViewController!.setViewControllers(startingViewControllers as? [UIViewController], direction: .Forward, animated: false, completion: nil)
                        }
                    }
            })
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "assetsSegue" {
            assetsViewController = segue.destinationViewController as? AssetsViewController
            assetsViewController.navDelegate = self
        }
    }

}

extension NavHandlerViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}

/**
For Javascript sending actions to native
*/
extension NavHandlerViewController: WLActionReceiver {
    
    func onActionReceived(action: String!, withData data: [NSObject : AnyObject]!) {
        
        if action == "viewAlert" {
            dispatch_async(dispatch_get_main_queue()) {
                let deviceClassId = data["customData"] as! String
                let alert = Alert(dictionary: data, shouldValidate: false)
                alert?.computeOptionalProperties()
                alert?.status = 2
                self.view.window?.layer.addAnimation(Utils.customTransitionFromDirection(kCATransitionFromRight), forKey: nil)
                
                let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let detailVC = storyboard.instantiateViewControllerWithIdentifier("AlertDetailViewController") as? AlertDetailViewController
                detailVC?.currentSensor = deviceClassId
                if self.alertSuccessfullyPopulatedFromHybridData(alert!) {
                    detailVC?.alert = alert
                }
                self.presentViewController(detailVC!, animated: false, completion: nil)
            }
        } else if action == "viewIncentive" {
            
            dispatch_async(dispatch_get_main_queue()) {
                let deviceClassId = data["deviceClassId"] as! String
                
                // Ensure there is a sensor and a tip for this page to load, should always be true if hybrid logic is correct
                if let sensor = AssetOverviewDataManager.sharedInstance.findAssetById(deviceClassId) {
                    if let tip = sensor.tip {
                    
                        self.view.window?.layer.addAnimation(Utils.customTransitionFromDirection(kCATransitionFromRight), forKey: nil)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let detailVC = storyboard.instantiateViewControllerWithIdentifier("TipDetailViewController") as? TipDetailViewController
                        detailVC?.singleTipData = tip
                        self.presentViewController(detailVC!, animated: false, completion: nil)
                    }
                }
                
            }
        }
    }
    
    func alertSuccessfullyPopulatedFromHybridData(alert: Alert) -> Bool {
        if alert.message != "" && alert.detail != "" && alert.timestamp > 0 {
            return true
        }
        
        return false
    }
}
