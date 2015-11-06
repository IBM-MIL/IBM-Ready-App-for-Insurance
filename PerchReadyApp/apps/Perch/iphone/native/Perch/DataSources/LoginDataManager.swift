/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/**
*  Handles the logging in process.
*/
class LoginDataManager: NSObject{
    var challengeHandler: ReadyAppsChallengeHandler!

    // User data from Worklight
    var currentUser : CurrentUser!
    
    typealias LogInCallback = (Bool, WLFailResponse!, WLResponse!)->Void
    var logInCallback: LogInCallback!
    
    //Class variable that will return a singleton when requested
    class var sharedInstance : LoginDataManager{
        
        struct Singleton {
            static let instance = LoginDataManager()
        }
        return Singleton.instance
    }
    
    override init() {
        challengeHandler = ReadyAppsChallengeHandler()
        WLClient.sharedInstance().registerChallengeHandler(challengeHandler)
    }
    
    /**
    Tells the challenge handler to reset to a default state. This is called when the user logs out.
    */
    func resetChallengeHandler() {
        challengeHandler.reset()
    }
    
    /**
    Submits the user name and password throught the challenge handler
    */
    func submitAuthentication(username: String!, password: String!){
        let adapterName : String = "AuthenticationAdapter"
        let procedureName : String = "submitAuthentication"
        let caller = WLProcedureInvocationData(adapterName : adapterName, procedureName: procedureName)
        caller.parameters = [username, password]
        self.challengeHandler.submitAdapterAuthentication(caller, options: nil)
    }
    
    /**
    Parses Worklight's login response and creates and fills out a current user.
    
    - parameter worklightResponseJson: JSON Response from Worklight
    */
    func parseLoginResponse(worklightResponseJson: NSDictionary) {
        let jsonResult = worklightResponseJson["result"] as! NSDictionary
        let currentUser = CurrentUser.sharedInstance

        currentUser.id = jsonResult["_id"] as! String!
        currentUser.locale = jsonResult["locale"] as! String!
        currentUser.username = jsonResult["username"] as! String!
        currentUser.firstName = jsonResult["firstName"] as! String!
        currentUser.lastName = jsonResult["lastName"] as! String!
        currentUser.deviceClassIds = jsonResult["deviceClassIds"] as! [String]
    }
    
}
