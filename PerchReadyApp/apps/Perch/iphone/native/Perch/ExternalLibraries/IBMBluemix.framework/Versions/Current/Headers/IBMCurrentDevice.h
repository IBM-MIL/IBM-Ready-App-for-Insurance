//-------------------------------------------------------------------------------
// Licensed Materials - Property of IBM
// (C) Copyright IBM Corp. 2013,2014. All Rights Reserved.
// US Government Users Restricted Rights - Use, duplication or
// disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//-------------------------------------------------------------------------------


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 The IBMCurrentDevice class is a provisional API.  APIs that are marked provisional are evolving and might change or be removed in future releases. 
 
 The IBMCurrentDevice represents the current device using the iOS SDK.
 */
@interface IBMCurrentDevice : NSObject

/**
 The hardwareId is a unique id derived from the mobile devices hardware and is used to identify the device.
 */
@property (readonly, nonatomic) NSString *hardwareId;

/**
 The model of the device
 */
@property (readonly, nonatomic) NSString *model;

/**
 The platform is IOS
 */
@property (readonly, nonatomic) NSString *platform;

/**
 The platformVersion is the version of iOS running on the device
 */
@property (readonly, nonatomic) NSString *platformVersion;

/**
 The user defined device name.  Used to provide a human readable device name.
 */
@property (readonly, nonatomic) NSString *name;

/**
 The last location of the device. This can be nil if the location is not available.
 */
@property (readonly, nonatomic) CLLocation *lastLocation;

/**
 The unique identifier from Mobile Application Security Service
 */
@property (readonly, nonatomic) NSString *uuid;

@end
