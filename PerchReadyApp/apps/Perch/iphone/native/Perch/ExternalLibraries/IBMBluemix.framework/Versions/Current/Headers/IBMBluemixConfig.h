//-------------------------------------------------------------------------------
// Licensed Materials - Property of IBM
// (C) Copyright IBM Corp. 2013,2014. All Rights Reserved.
// US Government Users Restricted Rights - Use, duplication or
// disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//-------------------------------------------------------------------------------

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////// INTERNAL IBM CODE - NOT API.  THIS CODE SHOULD BE USED WITH CAUTION AS IT CAN AND WILL CHANGE WITHOUT PUBLIC NOTICE ///////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "IBMBluemix.h"

/**
Provides access to the configuration for the IBMBluemix SDK.
*/
@interface IBMBluemixConfig : NSObject

/**
 @return The IBMBluemixConfig for the IBMBluemix SDK
 */
+(instancetype) instance;

#pragma mark - Mobile Cloud Services Configuration
/**
 The target baasUrl.  This can be used to override the target location for http requests.
 */
@property (readonly, nonatomic) NSString *baasUrl;

/**
 The applicationId used to communicate with MBaaS services.
 */
@property (readonly, nonatomic) NSString *applicationId;

/**
 The application host name for the Mobile Cloud Application.
 */
@property (readonly, nonatomic) NSString *applicationHostName;

#pragma mark - iOS Application Configuration
/**
 The application version.
 */
@property (readonly, nonatomic) NSString *applicationVersion;


/**
 The clientId is the bundleId of the application.
 */
@property (readonly, nonatomic) NSString *applicationBundleId;

/**
 @return The current user that is logged in (if any)
 */
@property (readonly, nonatomic) IBMCurrentUser *currentUser;

/**
 @return The current device using the SDK.
 */
@property (readonly, nonatomic) IBMCurrentDevice *currentDevice;

/**
 The current version of the SDK
 */
@property (readonly, nonatomic) NSString *version;

#pragma mark - Security
/**
 Sets the security token and the provider used to obtain and validate it
 @param provider The security provider used to obtain and validate the token
 @param token The user's security token received from the provider
 */
-(BFTask*) setSecurityToken: (NSString *) token fromProvider: (IBMSecurityProvider) provider;

/**
 Resets the security configuration to nil
 */
-(BFTask*) clearSecurityToken;


#pragma mark - Custom configuration settings (dev_config.json)
/**
 Provides the ability to set and retrieve arbitraty configuration in the form of key/value pairs.
@param key The key from the JSON configuration for the value that is being looked up.
@return The value associated with this JSON key
 */
-(id) getConfigurationSetting: (NSString*) key;

/**
 Provides the ability to retrieve all properties as a NSDictionary.
 @return NSDictionary
 */
-(NSDictionary*) getConfigurationSettings;

/**
 Provides access to a class based JSON configuration block
 
@param className the className to be looked up
@return the JSON configuration for the class
 */
-(NSDictionary*) getServiceConfigurationSettings: (NSString*) className;

@end
