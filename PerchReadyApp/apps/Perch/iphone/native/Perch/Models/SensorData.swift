/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Data model to handle data associated with IoT Sensor Data
*/
class SensorData: JsonObject {
    
    var deviceClassId: String!
    var name: String!
    var status: Int = 0
    var value: Int = 0
    var time: Double = 0
    var enabled: Bool = false
    var tip: Tip?
    
    var averageUsage: String?
    var averageUsageUnit: String?
    var units: String?
    
    // Computed properties from Json
    
    var deviceType: DeviceType? {
        return AssetOverviewDataManager.sharedInstance.deviceTypeForID(self.deviceClassId)
    }
    var refreshedDate: NSDate {
        return NSDate(timeIntervalSince1970: self.time.calculateTimestamp())
    }
    
}
