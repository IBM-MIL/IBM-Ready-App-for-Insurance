/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import Foundation
import LocalAuthentication

/**
*  Singleton class that is used to hold configuration information
*/
public class ConfigManager: NSObject {
    /// MQA Application Key
    var mqaApplicationKey: String?
    /// Password Key for keychain
    let PasswordKey = "password"
    /// Username Key for keychain
    let UsernameKey = "username"
    /// TouchID Key for NSUserDefaults
    let touchIDKey = "touchIDBool"
    /// Says if the app is in development to hide some features
    var isDevelopment = true
    /// The side margin used for some screens when on the iPhone 6+
    let largeMargin: CGFloat = 30.0
    var perchRealm: String?
    
    public class var sharedInstance : ConfigManager{
        
        struct Singleton {
            static let instance = ConfigManager()
        }
        return Singleton.instance
    }
    
    override init(){
        
        super.init()
        
        // Read configurations from the Config.plist.
        var configurationPath = NSBundle.mainBundle().pathForResource("Config", ofType: "plist")
        
        var hasValidConfiguration = true
        var errorMessage = ""
        
        if((configurationPath) != nil){
            var configuration = NSDictionary(contentsOfFile: configurationPath!) as! [String: AnyObject]!
            
            isDevelopment = configuration["isDevelopment"] as! Bool
            if(configuration["isDevelopment"] == nil){
                hasValidConfiguration = false
                errorMessage = "Open the Config.plist file and set the isDevelopment boolean"
            }
            
            mqaApplicationKey = configuration["mqaApplicationKey"] as? String
            if(mqaApplicationKey == nil){
                hasValidConfiguration = false
                errorMessage = "Open the Config.plist file and set the mqaApplicationKey to the MQA application key"
            }
            
            perchRealm = configuration["perchRealm"] as? String
            if (perchRealm == nil){
                hasValidConfiguration = false
                errorMessage = "Open the Conflig.plist file and set the perchRealm"
            }
        }
        
        if(!hasValidConfiguration){
            NSException().raise()
        }
        
    }
    
    /**
    This method determines if TouchID should be used by examining the Keychain and touchID value in NSUserDefaults.
    
    :returns:
    */
    func useTouchID()->Bool{
        
        // Only enable touchID if enabled in user defaults and username/password are in the keychain
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if (userDefaults.objectForKey(touchIDKey) == nil){
            userDefaults.setObject(false, forKey: touchIDKey)
            userDefaults.synchronize()
        }
        let touchIDUserDefaultValue: Bool = userDefaults.objectForKey(touchIDKey)!.boolValue!
        
        let useTouchID: Bool = KeychainWrapper.hasValueForKey(UsernameKey)
            && KeychainWrapper.hasValueForKey(PasswordKey)
            && touchIDUserDefaultValue
        
        return useTouchID
    }
}
