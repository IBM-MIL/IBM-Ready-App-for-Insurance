/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Data manager class to handle Tip data from Worklight
*/
public class TipDataManager: NSObject {
    
    let currentUser = CurrentUser.sharedInstance
    var tips: [Tip] = [Tip]()
    var callback: ((Bool)->())!
    var queryInProgress = false
    
    // computes unread count
    var unreadCount: Int {
        get {
            var count: Int = 0
            for tip in tips {
                count += (!tip.read ? 1 : 0)
            }
            return count
        }

    }
    
    public class var sharedInstance: TipDataManager {
        struct Singleton {
            static let instance = TipDataManager()
        }
        return Singleton.instance
    }
    
    // MARK: Data retrieval
    
    /**
    Method to kick off worklight call to grab all tip data
    
    - parameter callback: method to call when complete
    */
    public func getTipData(callback: ((Bool)->())!) {
        self.callback = callback
        let adapterName : String = "PerchAdapter"
        let procedureName : String = "getAllTips"
        let caller = WLProcedureCaller(adapterName : adapterName, procedureName: procedureName)
        let params = [currentUser.userPin]
        
        caller.invokeWithResponse(self, params: params)
        queryInProgress = true
    }
    
    /**
    Simply retrys to fetch tip data
    */
    func retryTipFetch() {
        getTipData(callback)
    }
    
    // MARK: Tip Utility Methods
    
    /**
    Utility method to mark a message as read for current app session
    
    - parameter index: index for Tip to mark as read
    */
    func markMessageRead(index: Int) {
        
        let myTip = self.tips[index] as Tip
        if !myTip.read {
            myTip.read = true
        }
        
    }
    
    /**
    Utility method to map image name from server to local image for incentive UI
    
    - parameter iconName: icon image name from server
    
    - returns: local image name for icon
    */
    func incentiveImageMapping(iconName: String) -> String {
        
        if iconName == "electricalPanel" {
            return "electrical_panel"
        } else if iconName == "airConditioner" {
            return "rhino_casedcoil_icon"
        } else if iconName == "garageDoor" {
            return "garagedoor_icon"
        }
        // no match found
        return iconName
    }
    
    /**
    Method to parse json dictionary received from backend
    
    - parameter worklightResponseJson: json dictionary
    
    - returns: an array of Tip objects
    */
    func parseAllTipsResponse(worklightResponseJson: NSDictionary) -> [Tip] {

        var tipArray = [Tip]()
        // println("Tips: \(worklightResponseJson)")
        if let serverTips = worklightResponseJson["result"] as? NSArray {
            for tip in serverTips {
                if let tipDictionary = tip as? NSDictionary {
                    
                    if let tipObject = Tip(dictionary: tipDictionary, shouldValidate: false) {
                        tipArray.append(tipObject)
                    }
                }
            }
        }
        
        return tipArray
    }
    
    /**
    Sorting method based on differnt categories
    
    - parameter sortCategory: category to sort by
    - parameter callback:     callback method to update tableview with
    */
    func sortTipDataBy(sortCategory: String, callback: (()->())?) {
        
        switch sortCategory {
        case "MOST RECENT":
            self.tips.sortInPlace({
                $0.date!.compare($1.date!) == NSComparisonResult.OrderedDescending
            })
        case "HIGHEST PRIORITY":
            self.tips.sortInPlace({
                $0.highPriority == true && $1.highPriority != true
            })
        case "UNREAD":
            self.tips.sortInPlace({
                $0.read != true && $1.read == true
            })
        default:
            break
        }
        
        if let callbackMethod = callback {
            callbackMethod()
        }
    }

}

// MARK: WLDataDelegate

extension TipDataManager: WLDataDelegate {
    
    /**
    Delgate method for WorkLight. Called when connection and return is successful
    
    - parameter response: Response from WorkLight
    */
    public func onSuccess(response: WLResponse!) {
        MQALogger.log("Tip Fetch Success Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        queryInProgress = false
        let responseJson = response.getResponseJson() as NSDictionary
        
        tips = parseAllTipsResponse(responseJson)
        
        callback(true)
    }
    
    /**
    Delgate method for WorkLight. Called when connection or return is unsuccessful
    
    - parameter response: Response from WorkLight
    */
    public func onFailure(response: WLFailResponse!) {
        MQALogger.log("Tip Fetch Failure Response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        queryInProgress = false
        if (response.errorCode.rawValue == 0) && (response.errorMsg != nil) {
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
