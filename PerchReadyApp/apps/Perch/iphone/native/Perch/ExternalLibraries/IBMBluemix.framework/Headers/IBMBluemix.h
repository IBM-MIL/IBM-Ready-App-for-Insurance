//-------------------------------------------------------------------------------
// Licensed Materials - Property of IBM
// (C) Copyright IBM Corp. 2013,2014. All Rights Reserved.
// US Government Users Restricted Rights - Use, duplication or
// disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//-------------------------------------------------------------------------------

typedef enum IBMSecurityProvider{
    IBMSecurityProvider_GOOGLE, IBMSecurityProvider_WORKLIGHT
}IBMSecurityProvider;

#import <Foundation/Foundation.h>
#import <IBMBluemix/IBMBluemixService.h>
#import <IBMBluemix/IBMHttpError.h>
#import <IBMBluemix/IBMHttpRequest.h>
#import <IBMBluemix/IBMMutableHttpRequest.h>
#import <IBMBluemix/IBMHttpResponse.h>
#import <IBMBluemix/IBMCurrentUser.h>
#import <IBMBluemix/IBMCurrentDevice.h>


/**
 Your iOS application must initialize the Mobile Cloud Services SDK and all services that are used by the application.  A common place to put the initialization code is in the Application Delegate for the iOS application.  The *applicationId* value is the unique key that is assigned to the Mobile Cloud application that you created on BlueMix.  The *applicationSecret* is revokable key that is assigned to the Mobile Cloud application that you created on Bluemix.  The *applicationRoute* value is the route that is assigned to the Mobile Cloud application that you created on BlueMix.
 
 <pre>
 // Initialize the IBMBluemix SDK
 [IBMBluemix initializeWithApplicationId: applicationId
 andApplicationSecret: applicationSecret
 andApplicationRoute: applicationRoute];
 </pre>
 */
@interface IBMBluemix : NSObject

#pragma mark SDK Initialization API
/** This must be the first method called.  It initializes the IBMBluemix SDK framework.
 
 @param applicationId The IBM Mobile Cloud Services application's ID
 @param applicationSecret The IBM Mobile Cloud Services application's secret
 @param applicationRoute  The IBM Mobile Cloud Services application's route
 */
+(void) initializeWithApplicationId: (NSString*) applicationId andApplicationSecret: (NSString*) applicationSecret andApplicationRoute: (NSString*) applicationRoute;

/**
 The setSecurityToken:fromProvider method is a provisional API.  APIs that are marked provisional are evolving and might change or be removed in future releases.
 
 Sets the security token and the provider used to obtain and validate it.  The token will be validated and decoded on the MAS service. 
 <pre>
 [[IBMBluemix setSecurityToken: google_token fromProvider: IBMSecurityProvider_GOOGLE] continueWithBlock:^id(BFTask *task) {
    if(task.error){
        // Security token was not valid and rejected by the MAS service.
    }else{
        // Security token was successfully set with the MAS service.
        // The IBMCurrentUser for the currently authenticated user is the result
        IBMCurrentUser *currentUser = task.result;
 }
 
 return nil;
 }];
 </pre>
 
 @param provider The security provider used to obtain and validate the token
 @param token The user's security token received from the provider
 @return A BFTask that will indicate the status of the authentication.  The task.result will be an IBMCurrentUser.
 */
+(BFTask*) setSecurityToken: (NSString *) token fromProvider: (IBMSecurityProvider) provider;

/**
 The clearSecurityToken method is a provisional API.  APIs that are marked provisional are evolving and might change or be removed in future releases.

 Resets the security context to nil.  
 <pre>
 // To clear the security context, use the following
 [[IBMBluemix clearSecurityToken] continueWithBlock:^id(BFTask *task) {
    if(task.error){
        // Security token was not valid and rejected by the MAS service.
    }else{
        // Security token was successfully set with the MAS service
    }
 
    return nil;
 }];
 </pre>
 
 @return The BFTask result will be the IBMCurrentUser object that was just cleared.  A call to IBMBluemix.currentUser will return nil following this call.
 */
+(BFTask*) clearSecurityToken;

/**
 The current version of the Bluemix SDK
 @return The SDK version. Format vMajor.Minor.Service.Qualifier
 */
+(NSString*) version;

/**
 The currentUser method is a provisional API.  APIs that are marked provisional are evolving and might change or be removed in future releases.

 @return The current user that is logged in (if any)
 */
+(IBMCurrentUser*) currentUser;

/**
 The currentDevice method is a provisional API.  APIs that are marked provisional are evolving and might change or be removed in future releases.

 @return The current iOS device using the SDK.
 */
+(IBMCurrentDevice*) currentDevice;

@end
