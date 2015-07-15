/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Data model to hold Incentive or Product data on a Tip object, if available
*/
class TipAction: JsonObject {
    
    var iconName: String!
    var message: String!
    var title: String!
    var type: String!
    
    /// Computed icon name based on mapping
    var actualIconName: String {
        return TipDataManager.sharedInstance.incentiveImageMapping(iconName)
    }
   
}
