/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest

class TimeFormatTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testTimestampConverter() {
        
        let miliseconds: Double = 1429650721359
        let miliDate = NSDate(timeIntervalSince1970: miliseconds.calculateTimestamp())
        
        let seconds: Double = 1429650721
        let secondsDate = NSDate(timeIntervalSince1970: seconds.calculateTimestamp())
        
        XCTAssertEqual(miliDate, secondsDate, "Dates do not match when they come from the same timestamp")
        
        let zero: Double = 0
        let zeroDate = zero.calculateTimestamp()
        
        XCTAssertEqual(zeroDate, 0, "Timestamp of 0 does not equal 0 after calculation")
        
    }
    
    func testTimestampFormat() {
        
        let seconds: Double = 1429650721
        let secondsDate = NSDate(timeIntervalSince1970: seconds.calculateTimestamp())
        let formattedSeconds = secondsDate.perchTableCellStringFormat()
        
        var containsToday = false
        if NSString(string: formattedSeconds).containsString("TODAY") {
            containsToday = true
        }
        XCTAssertFalse(containsToday, "Formatted seconds contains the word, TODAY, when it shouldn't")
        
        let formattedToday = NSDate().perchTableCellStringFormat()
        if NSString(string: formattedToday).containsString("TODAY") {
            containsToday = true
        }
        XCTAssertTrue(containsToday, "Cell dateLabel doesn't contain the word, TODAY, when it should")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
