/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/** 
PageHandlerViewController handles all the control and interaction with the UIPageViewController
*/
class PageHandlerViewController: PerchViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController?
    
    /// Represents the number of pages the UIPageViewController is aware of
    let numOfPages = 3
    
    /// Represents if we are in the bottom set of pages
    var inDetailView = false
    var currentIndex = 1
    
    // Reference to various view controllers used in page view controller
    var navHandlerViewController: NavHandlerViewController?
    var tipsViewController: TipsViewController?
    var historyViewController: HistoryViewController?
    var profileViewController: ProfileViewController?
    
    /// Computed value to disable and enable scrolling of UIPageViewController as a form of navigation
    var disabledPaging = false {
        willSet(newVal) {
            for view in self.pageViewController!.view.subviews {
                if let scrollView = view as? UIScrollView {
                    scrollView.scrollEnabled = !newVal
                }
            }
        }
    }

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
        setupPageControlAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    // MARK: UIPageViewController setup
    
    /**
    Configure UIPageViewController and setting it as the main view
    */
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        pageController.delegate = self
        
        // Only needs to be aware of 1 view controller to start out
        let firstController = getPageController(1)!
        let startingViewControllers: NSArray = [firstController]
        pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: .Forward, animated: false, completion: nil)
        
        // In order for PageHandler to handle the UIPageViewController, we need to set it as a child
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    private func setupPageControlAppearance() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let pageController = viewController as! PageItemViewController

        // Check if we can navigate left
        if pageController.pageIndex > 0 {
            return getPageController(pageController.pageIndex - 1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let pageController = viewController as! PageItemViewController

        // Check if we can navigate right
        if pageController.pageIndex + 1 < self.numOfPages {
            return getPageController(pageController.pageIndex + 1)
        }
        
        return nil
    }
    
    // MARK: UIPageViewControllerDelegate
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard let currentVC = pageViewController.viewControllers?[0] else {
            return
        }

        // Method used to keep a current index of the page view controller
        if inDetailView {
            
            if var _ = currentVC as? NavHandlerViewController {
                currentIndex = 1
            } else if var _ = currentVC as? HistoryViewController {
                currentIndex = 2
            }
            
        } else {
            
            if var _ = currentVC as? TipsViewController {
                currentIndex = 0
            } else if var _ = currentVC as? NavHandlerViewController {
                currentIndex = 1
            } else if var _ = currentVC as? ProfileViewController {
                currentIndex = 2
            }
            
        }
    }
    
    /**
    Method that displays 2 different layouts, one with asset overview and one with asset detail view
    
    - parameter pageIndex: index in page view controller to load
    
    - returns: A PageItemViewController instance from storyboard
    */
    private func getPageController(pageIndex: Int) -> PageItemViewController? {
        
        // View controllers are saved when possible to avoid recreation
        if inDetailView {
            
            switch (pageIndex) {
            case 1:
                // return already created view controller or set up a new one
                if let vc = self.navHandlerViewController {
                    return vc
                } else {
                    self.navHandlerViewController = self.storyboard!.instantiateViewControllerWithIdentifier("NavHandlerViewController") as? NavHandlerViewController
                    self.navHandlerViewController?.pageIndex = 1
                    self.navHandlerViewController?.pageHandlerViewController = self
                    return self.navHandlerViewController
                }
            case 2:
                if let vc = self.historyViewController {
                    return vc
                } else {
                    self.historyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("History") as? HistoryViewController
                    self.historyViewController?.pageIndex = 2
                    self.historyViewController?.pageHandlerViewController = self
                    return self.historyViewController
                }
            default:
                return nil
            }
            
        } else {

        
            switch (pageIndex) {
                case 0:
                    if let vc = self.tipsViewController {
                        return vc
                    } else {
                        self.tipsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TipsViewController") as? TipsViewController
                        self.tipsViewController?.pageIndex = 0
                        self.tipsViewController?.pageHandlerViewController = self
                        return self.tipsViewController
                    }
                case 1:
                    if let vc = self.navHandlerViewController {
                        return vc
                    } else {
                        self.navHandlerViewController = self.storyboard!.instantiateViewControllerWithIdentifier("NavHandlerViewController") as? NavHandlerViewController
                        self.navHandlerViewController?.pageIndex = 1
                        self.navHandlerViewController?.pageHandlerViewController = self
                        return self.navHandlerViewController
                    }
                case 2:
                    if let vc = self.profileViewController {
                        return vc
                    } else {
                        self.profileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController
                        self.profileViewController?.pageIndex = 2
                        self.profileViewController?.pageHandlerViewController = self
                        return self.profileViewController
                    }
                default:
                    return nil
            }
        }
        
    }
    
    /**
    Method to manually navigate to a page in code
    
    - parameter index:     page index to go to
    - parameter fromIndex: page index coming from
    */
    func navigateToIndex(index: Int, fromIndex: Int, animated: Bool) {
        
        // disable view when doing a manual transition to avoid weird UIPageViewController behavior
        self.pageViewController?.view.userInteractionEnabled = false
        
        // need to set manually when manually navigating
        self.currentIndex = index
        
        let viewController = getPageController(index)!
        let selectedViewControllers: NSArray = [viewController]
        self.pageViewController!.setViewControllers(selectedViewControllers as? [UIViewController], direction: (index > fromIndex ? .Forward : .Reverse), animated: animated, completion: { (done: Bool) -> Void in
                self.pageViewController?.view.userInteractionEnabled = true
        })
    }

}
