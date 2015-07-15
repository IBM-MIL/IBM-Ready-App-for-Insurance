/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Data model containg data associated with a Tip, typically created by an insurance agent
*/
class Tip: JsonObject {
    
    var title: String!
    var detail: String!
    var tipType: String!
    var read: Bool = false
    var highPriority: Bool = false
    var timestamp: Double = 0
    var tipAction: TipAction?
    
    // modfied versions of Json data
    
    // Create value with newlines stripped out for easier formatting in list view
    var plainDetail: String? {
        return self.detail!.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    var date: NSDate? {
        return NSDate(timeIntervalSince1970: self.timestamp.calculateTimestamp())
    }
    
}