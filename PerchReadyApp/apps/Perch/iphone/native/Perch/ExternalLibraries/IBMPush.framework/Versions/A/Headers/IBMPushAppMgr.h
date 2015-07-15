//-------------------------------------------------------------------------------
// Licensed Materials - Property of IBM
// XXXX-XXX (C) Copyright IBM Corp. 2013,2014. All Rights Reserved.
// US Government Users Restricted Rights - Use, duplication or
// disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//-------------------------------------------------------------------------------


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 * @class IBMPush application manager for Push Notification SDK.
 *
 */
@interface IBMPushAppMgr : NSObject {}

/*!
 * Creates an instance of IBMPush Application manager.
 *
 */
+(IBMPushAppMgr*)get;

/*!
 * Processes the received notification to collect message received, displayed and viewed metrics.
 *
 * @param notification - the notification message received from APNS.
 */
-(void) notificationReceived : (NSDictionary*)notification;

/*!
 * Collect metrics when the application runs on the background.
 *
 */
-(void) appEnterBackground;

/*!
 * Collect metrics when the application becomes active.
 *
 */
-(void) appEnterActive;

/*!
 * Collect metrics when the application runs on the foreground.
 *
 */
-(void) appEnterForeground;

/*!
 * Collect metrics when the application is opened by clicking on the notification.
 *
 * @param notification - the notification message received from APNS.
 */
-(void) appOpenedFromNotificationClick : (NSDictionary*)notification;

/*!
 * Collect metrics when the application is opened by clicking on the notification when the app is in the background
 *
 * @param notification - the notification message received from APNS.
 */
-(void) appOpenedFromNotificationClickInBackground : (NSDictionary*) notification;

@end
