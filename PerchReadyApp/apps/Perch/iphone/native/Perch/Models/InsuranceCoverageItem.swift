/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  This is an item that makes up the insurance coverage plan.
*/
class InsuranceCoverageItem: NSObject {
    var coverageName = ""
    var coverageLimitString = ""
    var coveragePremiumString = ""
    
    // When setting the coverage limit number value, also update the string value for use when displaying the insurance coverage info.
    var coverageLimit: Float = 0 {
        didSet {
            if coverageLimit > 0 {
                coverageLimitString = NSNumber(float: coverageLimit).getCurrencyString()
            } else {
                coverageLimitString = ""
            }
        }
    }
    
    // When setting the coverage premium number value, also update the string value for use when displaying the insurance coverage info.
    var coveragePremium: Float = 0 {
        didSet {
            if coveragePremium > 0 {
                coveragePremiumString = NSNumber(float: coveragePremium).getCurrencyString()
            } else {
                coveragePremiumString = "INCL"
            }
        }
    }
    
    init(coverage: String, coverageLimit: Float, coveragePremium: Float) {
        super.init()
        
        self.coverageName = coverage
        self.coverageLimit = coverageLimit
        self.coveragePremium = coveragePremium
        
        // Have to manually set strings in init method because didSet methods
        // not called when set in init()
        if coverageLimit > 0 {
            coverageLimitString = NSNumber(float: coverageLimit).getCurrencyString()
        }
        if coveragePremium > 0 {
            coveragePremiumString = NSNumber(float: coveragePremium).getCurrencyString()
        } else {
            coveragePremiumString = "INCL"
        }
        
    }
}


