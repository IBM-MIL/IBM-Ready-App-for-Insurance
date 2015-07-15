/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/**
Device type enum to make values like '10001' more readable

- WaterMeter:      device is of type WaterMeter
- AirConditioning: device is of type AirConditioning
- SewerSystem:     device is of type SewerSystem
- Electrical:      device is of type Electrical
*/
enum DeviceType {
    case WaterMeter
    case AirConditioning
    case SewerSystem
    case Electrical
}

/**
*  Data manager class to handle Asset Overview data from Worklight
*/
public class AssetOverviewDataManager: NSObject {
    
    weak var loginVC: LoginViewController?
    var sensors: [SensorData] = [SensorData]()
    
    /// Used throughout app to know when to repull asset overview data
    var shouldReload = false {
        didSet {
            MQALogger.log("Should reload asset overview: \(shouldReload)")
        }
    }
    
    var callback: ((Bool)->())!
    let currentUser = CurrentUser.sharedInstance
    
    public class var sharedInstance: AssetOverviewDataManager {
        struct Singleton {
            static let instance = AssetOverviewDataManager()
        }
        return Singleton.instance
    }
    
    // MARK: Data retrieval
    
    /**
    Method to kick off worklight call to grab all asset data
    
    :param: callback method to call when complete
    */
    public func getAllAssetData(callback: ((Bool)->())!) {
        self.shouldReload = false
        self.callback = callback
        let adapterName : String = "PerchAdapter"
        let procedureName : String = "getAllCurrentAssetData"
        let caller = WLProcedureCaller(adapterName : adapterName, procedureName: procedureName)
        let params = [currentUser.userPin]

        caller.invokeWithResponse(self, params: params)
        var userExists = false
        
    }
    
    /**
    Simple retrys to get asset data
    */
    func retryGetAssetData() {
        getAllAssetData(callback)
    }
    
    // MARK: Asset Overview Utilities
    
    /**
    Utility method for asset overview to find a specific SensorData object with a certain deviceClassID
    
    :param: deviceClassID ID passed in to verify SensorData's existence
    
    :returns: SensorData object containing deviceClassID
    */
    func findAssetById(deviceClassID: String) -> SensorData? {
        
        for sensor in sensors {
            if sensor.deviceClassId == deviceClassID {
                return sensor
            }
        }
        return nil
    }
    
    /**
    Method to parse json dictionary received from backend
    
    :param: worklightResponseJson json dictionary
    
    :returns: an array of SensorData objects
    */
    func parseAllAssetsResponse(worklightResponseJson: NSDictionary) -> [SensorData] {

        var sensorArray = [SensorData]()
        
        if let serverSensors = worklightResponseJson["result"] as? NSArray {
            for sensor in serverSensors  {
                if let sensorDict = sensor as? NSDictionary {
                    
                    if let sensorData = SensorData(dictionary: sensorDict) {
                        sensorArray.append(sensorData)
                    }
                }
            }
        } else {
            MQALogger.log(NSLocalizedString("Asset Overview Json data could not be parsed", comment: ""), withLevel: MQALogLevelWarning)
        }
        
        return sensorArray
    }
    
    /**
    Method that creates a mapping between deviceClassID and DeviceType
    
    :param: deviceClassID ID returned from the server
    
    :returns: deviceType from enum
    */
    func deviceTypeForID(deviceClassID: String) -> DeviceType? {
        switch deviceClassID {
        case "10001":
            return .WaterMeter
        case "10002":
            return .AirConditioning
        case "10003":
            return .SewerSystem
        case "10004":
            return .Electrical
        default:
            return nil
        }
    }
    
    // MARK: Hybrid Action Sending
    
    /**
    Method to initSensors in the hybrid view
    
    :param: worklightResponseJson json received from Worklight
    */
    func sendSensorData(worklightResponseJson: NSDictionary) {
        
        MQALogger.log("Attempt to send asset detail data to Hybrid WL: \(sensors)")
        if let sensorArray = worklightResponseJson["result"] as? NSArray {
            
            // Format data by wrapping in a Dictionary
            var data: Dictionary<String, NSArray> = ["sensors": sensorArray]
            
            // println("Sending Data to JS: \(data)")
            WL.sharedInstance().sendActionToJS("InitSensors", withData: data)
        } else {
            MQALogger.log("No data was returned from the server")
        }
        
    }
   
}

// MARK: WLDataDelegate

extension AssetOverviewDataManager: WLDataDelegate {
    
    /**
    Delgate method for WorkLight. Called when connection and return is successful
    
    :param: response Response from WorkLight
    */
    public func onSuccess(response: WLResponse!) {
        MQALogger.log("Asset Overview Success Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        let responseJson = response.getResponseJson() as NSDictionary

        sensors = parseAllAssetsResponse(responseJson)
        
        // Execute the callback from the view controller that instantiated the dashboard call
        callback(true)
        
        sendSensorData(responseJson)

    }
    
    /**
    Delgate method for WorkLight. Called when connection or return is unsuccessful
    
    :param: response Response from WorkLight
    */
    public func onFailure(response: WLFailResponse!) {
        MQALogger.log("Asset Overview Failure Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        if (response.errorCode.value == 0) && (response.errorMsg != nil) {
            MQALogger.log("Response Failure with error: \(response.errorMsg)", withLevel: MQALogLevelError)
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
