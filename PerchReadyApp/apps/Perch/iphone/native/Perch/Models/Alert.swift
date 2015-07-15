/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Model class for an Alert from a sensor
*/
class Alert: JsonObject {
   
    var title = ""
    var message = ""
    var detail = ""
    var read = false
    var partner: RecommendedPartner?
    var timestamp: Double = 0
    
    // The JsonObject library requires Ints be initialized
    var value = 0
    var status = 0
    
    // Computed properties that aren't directly put in by JsonObject library
    var date: NSDate?
    
    func computeOptionalProperties() {
        self.date = NSDate(timeIntervalSince1970: self.timestamp.calculateTimestamp())
    }
    
}
