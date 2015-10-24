/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import UIKit

/**
*  Useful methods related to UIViewControllers
*/
extension UIViewController {
    
    /**
    Find the best candidate for being the current view controller
    
    - parameter vc: Initially the root viewcontroller, then passed in recursively as the previous vc's presented view controller
    
    - returns: The current view controller
    */
    private class func findBestViewController(vc: UIViewController) -> UIViewController {
        
        // If the vc passed in has presented another vc, then dive into that presented vc by calling this method with it recursively
        if (vc.presentedViewController != nil) {
            return UIViewController.findBestViewController(vc.presentedViewController!)
        }
        
        // If the vc passed in has not presented another vc, but it is a split view controller, determine the current vc from the split vc
        else if vc.isKindOfClass(UISplitViewController) {
            let svc = vc as! UISplitViewController
            if svc.viewControllers.count > 0 {
                return UIViewController.findBestViewController(svc.viewControllers.last as UIViewController!)
            } else {
                return vc
            }
        }
        
        // If the vc passed in has not presented another vc, but it is a navigation controller, determine the current vc from the nav controller
        else if vc.isKindOfClass(UINavigationController) {
            let nvc = vc as! UINavigationController
            if nvc.viewControllers.count > 0 {
                return UIViewController.findBestViewController(nvc.topViewController!)
            } else {
                return vc
            }
        }
        
        // If the vc passed in has not presented another vc, but it is a tab bar controller, determine the current vc from the tab controller
        else if vc.isKindOfClass(UITabBarController) {
            let tvc = vc as! UITabBarController
            if tvc.viewControllers?.count > 0 {
                return UIViewController.findBestViewController(tvc.selectedViewController!)
            } else {
                return vc
            }
        }
            
        // The view controller passed in has not presented another view controller and is not of a more interesting (complicated) type, so we have found the current vc
        else {
            return vc
        }
    }
    
    /**
    Public facing method for finding the current view controller by stepping through all view controllers presented since the root view
    
    - returns: The current view controller
    */
    class func currentViewController() -> UIViewController {
        let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        return UIViewController.findBestViewController(viewController!)
    }
    
    /**
    App specific for digging down through view hierarchy and finding asset overview if it exists.
    Needed so we can tell the asset overview to reload when a push notification comes in.
    
    - parameter vc: The initial view controller, then recursively the previous vc's presented vc
    
    - returns: The asset overview reference
    */
    private class func findAssetOverviewReference(vc: UIViewController) -> UIViewController {
        if vc.isKindOfClass(PageHandlerViewController) {
            let phvc = vc as! PageHandlerViewController
            if let navHandlerVC = phvc.navHandlerViewController {
                if navHandlerVC.assetsViewController != nil {
                    return navHandlerVC.assetsViewController
                } else {
                    return vc
                }
            } else {
                return vc
            }
        } else if vc.presentedViewController != nil {
            return UIViewController.findAssetOverviewReference(vc.presentedViewController!)
        } else {
            return vc
        }
    }
    
    /**
    App specific for digging down through view hierarchy and finding pagehandler if it exists.
    Needed for clearing out a reference this view has to the alert history vc.
    
    - parameter vc: The initial view controller, then recursively the previous vc's presented vc
    
    - returns: The page handler reference
    */
    private class func findPageHandlerReference(vc: UIViewController) -> UIViewController {
        if vc.isKindOfClass(PageHandlerViewController) {
            return vc
        } else if vc.presentedViewController != nil {
            return UIViewController.findPageHandlerReference(vc.presentedViewController!)
        } else {
            return vc
        }
    }
    
    /**
    Public facing method for finding the asset overview reference
    
    - returns: The asset overview vc reference
    */
    class func assetOverviewReference() -> UIViewController {
        let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        return UIViewController.findAssetOverviewReference(viewController!)
    }
    
    /**
    Public facing method for finding the page handler reference
    
    - returns: The page handler vc reference
    */
    class func pageHanderReference() -> UIViewController {
        let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        return UIViewController.findPageHandlerReference(viewController!)
    }
}