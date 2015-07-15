/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
Class for handling backend Worklight queries for data
about all the notifications that have been generated
for a given asset.
*/
public class AlertHistoryDataManager: NSObject {
    let currentUser = CurrentUser.sharedInstance
    var alerts: [Alert] = []
    var callback: ((Bool)->())!
    var lastLoadedAlertHistory = ""
    
    public class var sharedInstance: AlertHistoryDataManager {
        struct Singleton {
            static let instance = AlertHistoryDataManager()
        }
        return Singleton.instance
    }
    
    /**
    Method to kick off worklight call to grab all alert history data

    :param: callback method to call when complete
    */
    public func getAlertHistory(callback: ((Bool)->())!) {
        self.callback = callback
        let adapterName = "PerchAdapter"
        let procedureName = "getAllNotifications"
        let caller = WLProcedureCaller(adapterName: adapterName, procedureName: procedureName)
        var params: [String]
        
        // if let to get currDevId
        if let currDevId = CurrentSensorDataManager.sharedInstance.lastSelectedAsset {
            self.lastLoadedAlertHistory = currDevId
            params = [currentUser.userPin, currDevId]
        } else {
            params = [currentUser.userPin, ""]
        }
        
        caller.invokeWithResponse(self, params: params)
    }
    
    /**
    Method to parse json dictionary received from backend
    
    :param: worklightResponseJson json dictionary
    
    :returns: an array of SensorData objects
    */
    func parseAlertHistoryResponse(worklightResponseJson: NSDictionary) -> [Alert] {
        var alertArray: [Alert] = []
        if let serverAlerts = worklightResponseJson["result"] as? NSArray {
            for alert in serverAlerts {
                if let alertDictionary = alert as? NSDictionary {
                    var alertObject: Alert!
                    
                    // This auto parsing into the object's properties is done through the JsonObject library
                    alertObject = Alert(dictionary: alertDictionary)
                    
                    // Since our timestamp info was not passed in a human readable format, we need to call this method to set the format
                    alertObject.computeOptionalProperties()
                    
                    alertArray.append(alertObject)
                }
            }
        }
        
        return alertArray
    }
}

extension AlertHistoryDataManager: WLDataDelegate {
    /**
    Delgate method for WorkLight. Called when connection and return is successful
    
    :param: response Response from WorkLight
    */
    public func onSuccess(response: WLResponse!) {
        MQALogger.log("Alert History Fetch Success Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        let responseJson = response.getResponseJson() as NSDictionary
        alerts = parseAlertHistoryResponse(responseJson)
        callback(true)
    }
    
    /**
    Delgate method for WorkLight. Called when connection or return is unsuccessful
    
    :param: response Response from WorkLight
    */
    public func onFailure(response: WLFailResponse!) {
        MQALogger.log("Alert History Fetch Failure Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        if (response.errorCode.value == 0) && (response.errorMsg != nil) {
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
