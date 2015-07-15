/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/** 
PageItemViewController is an abstract class for items in a UIPageViewController
*/
class PageItemViewController: UIViewController {
    
    // Every item that subclasses PageItemViewController gets this property
    var pageIndex: Int!
    
    /// Reference to PageHandlerViewController so we can easily access it's methods
    weak var pageHandlerViewController: PageHandlerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
