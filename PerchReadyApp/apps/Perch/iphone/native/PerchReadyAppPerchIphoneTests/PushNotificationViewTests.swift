/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest

class PushNotificationViewTests: XCTestCase {
    
    let labelTestString = "Hello"

    func testWindowLevel() {
        if let windowLevel = UIApplication.sharedApplication().delegate?.window??.windowLevel {
            XCTAssertEqual(windowLevel, UIWindowLevelNormal, "Window should be at normal level before push notfication shown.")
        }
        
        PushNotificationViewManager.sharedInstance.showViewAboveStatusBar()
        
        if let windowLevel = UIApplication.sharedApplication().delegate?.window??.windowLevel {
            XCTAssertEqual(windowLevel, UIWindowLevelStatusBar, "Window should be above status bar when push notification shown.")
        }
        
        PushNotificationViewManager.sharedInstance.showStatusBarAgain()
        
        if let windowLevel = UIApplication.sharedApplication().delegate?.window??.windowLevel {
            XCTAssertEqual(windowLevel, UIWindowLevelNormal, "Window should be at normal level after push notfication finishes showing.")
        }
    }
    
    func testSetTitle() {
        let pushNotificationView = PushNotificationView()
        pushNotificationView.titleLabel = UILabel()
        pushNotificationView.setTitle(labelTestString)
        XCTAssertEqual(pushNotificationView.titleLabel.text!, labelTestString, "setTitle is not setting title of label properly")
    }
    
    func testSetMessage() {
        let pushNotificationView = PushNotificationView()
        pushNotificationView.messageLabel = UILabel()
        pushNotificationView.setMessage(labelTestString)
        XCTAssertEqual(pushNotificationView.messageLabel.text!, labelTestString, "setMessage is not setting message of label properly")
    }

}
