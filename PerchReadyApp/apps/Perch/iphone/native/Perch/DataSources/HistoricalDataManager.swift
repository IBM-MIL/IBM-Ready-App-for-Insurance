/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Data manager class to handle Historical Graph data from Worklight
*/
public class HistoricalDataManager: NSObject {
    
    var deviceClassID: String!
    var callback: ((Bool)->())?
    
    public class var sharedInstance: HistoricalDataManager {
        struct Singleton {
            static let instance = HistoricalDataManager()
        }
        return Singleton.instance
    }
    
    // MARK: Data retrieval
    
    /**
    Method to kick off worklight call to grab historical data
    
    :param: callback method to call when complete
    */
    public func getAllHistoricalData(deviceClassID: String, callback: ((Bool)->())?) {
        
        self.deviceClassID = deviceClassID
        self.callback = callback
        let adapterName : String = "PerchAdapter"
        let procedureName : String = "getAllHistoricalData"
        let caller = WLProcedureCaller(adapterName : adapterName, procedureName: procedureName)
        let params = [deviceClassID]
        
        caller.invokeWithResponse(self, params: params)
        var userExists = false
        
    }
    
    /**
    Simply retries to get historical graph data
    */
    func retryGetHistoricalData() {
        self.getAllHistoricalData(self.deviceClassID, callback: self.callback)
    }
    
    // MARK: Hybrid Action Sending
    
    /**
    JS injection method to get historical graph data into the hybrid view
    
    :param: worklightResponseJson Json with an array of graph data
    */
    func sendHistoricalData(worklightResponseJson: NSDictionary) {
        
        MQALogger.log("Attempt to send historical graph data to Hybrid WL")
        if let graphDataArray = worklightResponseJson["result"] as? NSArray {
            
            // format data by wrapping in a Dictionary
            var data: Dictionary<String, NSArray> = ["historicalData": graphDataArray]
            
            // println("Sending Historical data to JS: \(data)")
            WL.sharedInstance().sendActionToJS("InitGraph", withData: data)
        } else {
            
            MQALogger.log("No data was returned from the server")
        }

    }
   
}

// MARK: WLDataDelegate

extension HistoricalDataManager: WLDataDelegate {
    
    /**
    Delgate method for WorkLight. Called when connection and return is successful
    
    :param: response Response from WorkLight
    */
    public func onSuccess(response: WLResponse!) {
        MQALogger.log("Current Sensor Success Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        let responseJson = response.getResponseJson() as NSDictionary
        
        if let theCallback = callback {
            theCallback(true)
        }
        self.sendHistoricalData(responseJson)
    }
    
    /**
    Delgate method for WorkLight. Called when connection or return is unsuccessful
    
    :param: response Response from WorkLight
    */
    public func onFailure(response: WLFailResponse!) {
        MQALogger.log("Current Sensor Failure Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        if (response.errorCode.value == 0) && (response.errorMsg != nil) {
            MQALogger.log("Current Sensor Failed with error: \(response.errorMsg)", withLevel: MQALogLevelError)
        }
        
        if let theCallback = callback {
            theCallback(false)
        }
        
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