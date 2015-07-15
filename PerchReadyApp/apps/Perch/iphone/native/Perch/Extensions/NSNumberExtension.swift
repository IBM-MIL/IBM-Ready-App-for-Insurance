/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

extension NSNumber {
    
    /**
    Converts an NS Number into a currency string with 0 decimal points
    
    :returns: a currency String
    */
    func getCurrencyString() -> String {
        var numFormatter = NSNumberFormatter()
        numFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numFormatter.maximumFractionDigits = 0
        if let currString = numFormatter.stringFromNumber(self) {
            return currString
        }
        MQALogger.log("WARNING: Could not format the NSNumber into a currency formatted string in InsuranceCoverageItem...", withLevel: MQALogLevelWarning)
        return ""
    }
}
