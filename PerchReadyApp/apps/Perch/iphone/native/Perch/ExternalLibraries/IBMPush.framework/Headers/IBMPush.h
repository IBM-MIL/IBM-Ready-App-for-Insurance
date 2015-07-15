//-------------------------------------------------------------------------------
// Licensed Materials - Property of IBM
// XXXX-XXX (C) Copyright IBM Corp. 2013,2014. All Rights Reserved.
// US Government Users Restricted Rights - Use, duplication or
// disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

#import <IBMBluemix/IBMBluemixService.h>
#import <IBMBluemix/BFTask.h>

/*!
 * @class Operations supported by the Push Notification SDK
 *
 */
@interface IBMPush : IBMBluemixService{
	
	NSString* deviceToken;
    NSString* endpoint;
    NSInteger defaultTimeout;
}

/*!
 * Gets all the available Tags for the backend mobile application
 *
 */
- (BFTask*) getTags;

/*!
 * Gets the Tags that are subscribed by the device
 *
 */
- (BFTask*) getSubscriptions;

/*!
 * Registers the device on to the Push Notification Server
 *
 * @param alias - the alias of the device that needs to be registered.
 * @param consumerId - the consumerId of the user.
 * @param devToken - the device token received from APNS.
 */
- (BFTask*) registerDevice : (NSString*) alias withConsumerId : (NSString*) consumerId withDeviceToken : (NSString*) devToken;

/*!
 * Subscribes to a particular backend mobile application Tag
 *
 * @param tag - The Tag name to subscribe to.
 */
- (BFTask*) subscribeToTag :(NSString*) tag;

/*!
 * Unsubscribes from an backend mobile application Tag
 *
 * @param tag - The Tag name to unsubscribe from.
 */
- (BFTask*) unsubscribeFromTag :(NSString*) tag;

/*!
 * This method initializes the singleton instance of the IBMPush Service for this application.
 *
 * @return The instance of the initialized IBMPush Service
 *
 */
+(instancetype) initializeService;

/*!
 * This method returns the singleton instance of the IBMPush Service for this application.
 *
 * @return The instance of IBMPush service
 *
 */
+(instancetype) service;


@end