/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest

class NumberFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testCurrencyFormatter() {
        
        let baseNumber: Double = 10
        let expectedValues: [String] = ["$1", "$10", "$100", "$1,000", "$10,000", "$100,000", "$1,000,000", "$10,000,000", "$100,000,000", "$1,000,000,000", "$10,000,000,000"]
        
        for index in 0...10 {
            let testNumber = pow(baseNumber, Double(index))
            let formattedCurrency = NSNumber(double: testNumber).getCurrencyString()
            XCTAssertEqual(formattedCurrency, expectedValues[index], "Formatted string at index \(index) is not the correct currency value")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
