/**************************************
*
*  Licensed Materials - Property of IBM
*  © Copyright IBM Corporation 2015. All Rights Reserved.
*  This sample program is provided AS IS and may be used, executed, copied and modified without royalty payment by customer
*  (a) for its own instruction and study, (b) in order to develop applications designed to run with an IBM product,
*  either for customer's own internal use or for redistribution by customer, as part of such an application, in customer's
*  own products.
*
***************************************/
import UIKit

public class MILLoadViewManager: NSObject {
    
    private var milLoadView : MILLoadView!
    private var timer : NSTimer!
    private var enableHide = false
    
    public class var sharedInstance : MILLoadViewManager{
        
        struct Singleton {
            static let instance = MILLoadViewManager()
        }
        return Singleton.instance
    }
    
    /**
    Function that builds and displays a MILLoadView
    */
    public func show() {
        print("SHOWING LOADING VIEW")
        
            self.timer = NSTimer(timeInterval: 3, target: self, selector: "enableHideBool", userInfo: nil, repeats: false)
            
            // show alertview on main UI
            let milLoadView : MILLoadView = MILLoadView.instanceFromNib() as MILLoadView
            
            if self.milLoadView != nil{
                self.enableHide = true
                self.hide()
            }
            milLoadView.frame = UIApplication.sharedApplication().keyWindow!.frame
            
            milLoadView.showLoadingAnimation()
            
            self.milLoadView = milLoadView
            UIApplication.sharedApplication().keyWindow?.addSubview(milLoadView)
        
    }
    
    /**
    Sets the boolean to enable hide to true
    */
    func enableHideBool(){
        self.enableHide = true
    }
    
    /**
    Hides the MILLoadView
    */
    public func hide() {
        while true {
            if self.enableHide{
                self.enableHide = false
                    if self.milLoadView != nil{
                        print("HIDING LOADING VIEW")
                        self.milLoadView.removeFromSuperview()
                        self.milLoadView = nil
                    }
                break;
            }
        }
    }
    
}
