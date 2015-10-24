/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
Class for handling backend Worklight queries for data
about the most recent notification for a given asset.
*/
public class AlertDetailDataManager: NSObject {
    let currentUser = CurrentUser.sharedInstance
    var alert: Alert?
    var callback: ((Bool)->())!
   
    public class var sharedInstance: AlertDetailDataManager {
        struct Singleton {
            static let instance = AlertDetailDataManager()
        }
        return Singleton.instance
    }
    
    /**
    Method to kick off worklight call to grab most recent notification data
    
    - parameter callback: method to call when complete
    */
    public func getCurrentNotification(callback: ((Bool)->())!, currentDeviceId: String) {
        self.callback = callback
        let adapterName = "PerchAdapter"
        let procedureName = "getCurrentNotification"
        let caller = WLProcedureCaller(adapterName: adapterName, procedureName: procedureName)
        let params = [currentUser.userPin, currentDeviceId]
        caller.invokeWithResponse(self, params: params)
    }
    
    /**
    Method to parse json dictionary received from backend
    
    - parameter worklightResponseJson: json dictionary
    
    - returns: an array of SensorData objects
    */
    func parseCurrentAlertResponse(worklightResponseJson: NSDictionary) -> Alert {
        var anAlert: Alert!
        if let serverAlert = worklightResponseJson["result"] as? NSDictionary {
            
            // This auto parsing into the object's properties is done through the JsonObject library
            anAlert = Alert(dictionary: serverAlert, shouldValidate: false)
            
            // Since our timestamp info was not passed in a human readable format, we need to call this method to set the format
            anAlert.computeOptionalProperties()
        }
        
        return anAlert
    }
    
}

extension AlertDetailDataManager: WLDataDelegate {
    
    /**
    Delgate method for WorkLight. Called when connection and return is successful
    
    - parameter response: Response from WorkLight
    */
    public func onSuccess(response: WLResponse!) {
        MQALogger.log("Current Alert Fetch Success Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        let responseJson = response.getResponseJson() as NSDictionary
        self.alert = parseCurrentAlertResponse(responseJson)
        callback(true)
    }
    
    /**
    Delgate method for WorkLight. Called when connection or return is unsuccessful
    
    - parameter response: Response from WorkLight
    */
    public func onFailure(response: WLFailResponse!) {
        MQALogger.log("Current Alert Fetch Failure Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        if (response.errorCode.rawValue == 0) && (response.errorMsg != nil) {
            MQALogger.log("Response Failure with error: \(response.errorMsg)", withLevel: MQALogLevelInfo)
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
