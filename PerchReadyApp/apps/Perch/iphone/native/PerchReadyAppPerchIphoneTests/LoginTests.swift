/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest

class LoginTests: XCTestCase {

    var vc: LoginViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        self.vc = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as? LoginViewController
        self.vc.loadView()
    }
    
    /**
    Test that the important views of the Login View Controller are setup correctly
    */
    func testViewController() {
        // Test the important views on the login VC
        XCTAssertNotNil(vc.usernameTextField, "Username text field is nil in Login View Controller")
        XCTAssertNotNil(vc.passwordTextField, "Password text field is nil in Login View Controller")
        XCTAssertNotNil(vc.loginButton, "Login button is nil in Login View Controller")
    }
    
    /**
    Test the implementation of the UITextField protocol
    */
    func testTextFieldDelegate() {
        XCTAssertTrue(vc.conformsToProtocol(UITextFieldDelegate), "Login View Controller does not conform to UITextField protocol")
        XCTAssertNotNil(vc.usernameTextField.delegate, "Username text field's delegate in Login View Controller is nil")
        XCTAssertNotNil(vc.passwordTextField.delegate, "Password text field's delegate in Login View Controller is nil")
    }
    
    /**
    Test that if either the username or password text fields are empty, that the credentials are not valid
    */
    func testTextEntry() {
        // Test both empty fields
        vc.usernameTextField.text = ""
        vc.passwordTextField.text = ""
        XCTAssertFalse(vc.isValidCredentials(), "Empty username and password should return NOT valid credentials")
        
        // Test just password empty
        vc.usernameTextField.text = "user1"
        vc.passwordTextField.text = ""
        XCTAssertFalse(vc.isValidCredentials(), "Empty password should return NOT valid credentials")
        
        // Test just username empty
        vc.usernameTextField.text = ""
        vc.passwordTextField.text = "password1"
        XCTAssertFalse(vc.isValidCredentials(), "Empty username should return NOT valid credentials")
        
        // Test neither empty
        vc.usernameTextField.text = "user1"
        vc.passwordTextField.text = "password1"
        XCTAssertTrue(vc.isValidCredentials(), "Empty username should return NOT valid credentials")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
