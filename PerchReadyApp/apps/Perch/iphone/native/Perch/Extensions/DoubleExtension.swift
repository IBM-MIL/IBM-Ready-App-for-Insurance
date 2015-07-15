/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/
import Foundation

extension Double {
    
    /**
    Method used to calculate correct timestamp to create an NSDate. NSDate needs a 10 digit unix timestamp, this method ensures that
    
    :returns: the updated Double, 10 digits long
    */
    func calculateTimestamp() -> Double {
        var stringVersion = String(format:"%.0f", self)
        var countNum = count(stringVersion)
        
        if countNum > 10 {
            // Means we are working with milliseconds
            return round(Double(self / 1000))
        } else {
            return self
        }
    }
}