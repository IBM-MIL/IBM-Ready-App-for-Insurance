/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Data manager class to handle data from Worklight for the currently selected Sensor/Asset
*/
public class CurrentSensorDataManager: NSObject {
    
    /// private reference to selected device class ID
    private var deviceClassID: String!
    var callback: ((Bool)->())!
    let currentUser = CurrentUser.sharedInstance
    
    /// Record of selected asset's device class ID
    var lastSelectedAsset: String?
    
    /// Record of previously selected sensor's status (0 or 2)
    var prevSensorStatus: Int!
    
    /// Record of currently selected sensor's status (0 or 2)
    var currentSensorStatus: Int!
    
    public class var sharedInstance: CurrentSensorDataManager {
        struct Singleton {
            static let instance = CurrentSensorDataManager()
        }
        return Singleton.instance
    }
    
    // MARK: Data retrieval
    
    /**
    Method to kick off worklight call to grab current sensor data
    
    - parameter callback: method to call when complete
    */
    public func getCurrentAssetDetail(deviceClassID: String, callback: ((Bool)->())!) {

        self.deviceClassID = deviceClassID
        self.callback = callback
        let adapterName : String = "PerchAdapter"
        let procedureName : String = "getCurrentAssetDetail"
        let caller = WLProcedureCaller(adapterName : adapterName, procedureName: procedureName)
        let params = [deviceClassID, currentUser.userPin]
        
        caller.invokeWithResponse(self, params: params)
    }
    
    /**
    Simple retrys to get current sensor data
    */
    func retryGetAssetData() {
        self.getCurrentAssetDetail(self.deviceClassID, callback: self.callback)
    }
    
    // MARK: Hybrid Action Sending
    
    /**
    Method to send data to UpdateSensor function in hybrid
    
    - parameter worklightResponseJson: json received from worklight
    */
    func sendSensorData(worklightResponseJson: NSDictionary) {

        MQALogger.log("Attempt to send current sensor data to Hybrid WL")
        
        if let currentSensorData = worklightResponseJson["result"] as? Dictionary<NSObject, AnyObject> {
            // println("Sending Data to JS: \(currentSensorData)")
            
            // Save record of current status to check elsewhere and update native UI
            self.currentSensorStatus = currentSensorData["status"] as? Int
            WL.sharedInstance().sendActionToJS("UpdateSensor", withData: currentSensorData)
        } else {
            MQALogger.log("No data was returned from the server")
        }
        
    }
   
}

// MARK: WLDataDelegate

extension CurrentSensorDataManager: WLDataDelegate {
    
    /**
    Delgate method for WorkLight. Called when connection and return is successful
    
    - parameter response: Response from WorkLight
    */
    public func onSuccess(response: WLResponse!) {
        MQALogger.log("Current Sensor Success Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        let responseJson = response.getResponseJson() as NSDictionary

        self.sendSensorData(responseJson)
        callback(true)
    }
    
    /**
    Delgate method for WorkLight. Called when connection or return is unsuccessful
    
    - parameter response: Response from WorkLight
    */
    public func onFailure(response: WLFailResponse!) {
        MQALogger.log("Current Sensor Failure Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        if (response.errorCode.rawValue == 0) && (response.errorMsg != nil) {
            MQALogger.log("Current Sensor Failed with error: \(response.errorMsg)", withLevel: MQALogLevelError)
        }
        
        callback(false)
        
    }
    
    /**
    Delgate method for WorkLight. Task to do before executing a call.
    */
    public func onPreExecute() {
    }
    
    /**
    Delgate method for WorkLight. Task to do after executing a call.
    */
    public func onPostExecute() {
    }
    
}
