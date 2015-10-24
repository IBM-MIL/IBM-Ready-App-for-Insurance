/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Cordova View Controller used to display our hybrid view
*/
class HybridViewController: CDVViewController {
    
    var deviceID: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.startPage = WL.sharedInstance().mainHtmlFilePath()
    }
    
    /**
    When the hybridViewController is first loaded, the cordova view controller sets the start page
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.scrollView.bounces = false
    }
    
}

extension HybridViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
