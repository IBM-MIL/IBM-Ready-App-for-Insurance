/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest

class PinRegistrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPinTextFieldCharacterLimit() {
        // Set up view controller and text field for testing
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        XCTAssertNotNil(storyboard, "The storyboard is nil")
        let pinViewController = storyboard.instantiateViewControllerWithIdentifier("EnterPinViewController") as? EnterPinViewController
        XCTAssertNotNil(pinViewController, "PinViewController is nil")
        pinViewController?.loadView()
        XCTAssertNotNil(pinViewController?.pinTextField, "The pin text field is not connected")
        
        // Test one character entered into text field
        let oneCharacterString = String(count: 1, repeatedValue: Character("a"))
        let oneCharacterOkResult = pinViewController?.textField(pinViewController!.pinTextField, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: oneCharacterString)
        XCTAssertTrue(oneCharacterOkResult!, "One character should be allowed to be entered into the text field.")
        
        // Test a string that is at the limit, but still in the acceptable range
        let atTheLimitString = String(count: PinViewController.requiredPinLength, repeatedValue: Character("a"))
        let limitStringOkResult = pinViewController?.textField(pinViewController!.pinTextField, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: atTheLimitString)
        XCTAssertTrue(limitStringOkResult!, "\(PinViewController.requiredPinLength) characters should be allowed to be entered into the text field.")
        
        // Test a string that is just over the acceptable range
        let overTheLimitString = String(count: PinViewController.requiredPinLength+1, repeatedValue: Character("a"))
        let overTheLimitBadResult = pinViewController?.textField(pinViewController!.pinTextField, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: overTheLimitString)
        XCTAssertFalse(overTheLimitBadResult!, "Pin text field should be limited to \(PinViewController.requiredPinLength) characters.")
    }

}
