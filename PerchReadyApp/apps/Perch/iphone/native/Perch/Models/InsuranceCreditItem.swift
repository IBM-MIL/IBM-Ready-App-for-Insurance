/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/
import UIKit

/**
*  This is an item that makes up the insurance coverage plan.
*/
class InsuranceCreditItem: NSObject {
    var creditName = ""
    var creditSavingsString = ""
    var creditSavings: Float = 0 {
        didSet {
            creditSavingsString = NSNumber(float: creditSavings).getCurrencyString()
        }
    }
    
    init(name: String, savings: Float) {
        super.init()
        
        self.creditName = name
        self.creditSavings = savings
        self.creditSavingsString = NSNumber(float: creditSavings).getCurrencyString()
    }
}
