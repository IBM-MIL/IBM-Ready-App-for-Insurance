/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/**
*  This class holds the model for the User. Includes the insurance information as well as things like name, and their pin.
*/
public class CurrentUser: NSObject {
    
    var id : String!
    var locale : String!
    var username : String!
    var firstName : String!
    var lastName : String!
    var deviceClassIds : [String] = []
    var userPin = ""
    var insurance = InsuranceModel()
    var demoMode = false
    var hasBeenAskedToEnterDemoMode = false
    
    //Class variable that will return a singleton when requested
    public class var sharedInstance : CurrentUser {
        
        struct Singleton {
            static let instance = CurrentUser()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        
        insurance.generateFakeInsurance()
    }
}