//-------------------------------------------------------------------------------
// Licensed Materials - Property of IBM
// (C) Copyright IBM Corp. 2013,2014. All Rights Reserved.
// US Government Users Restricted Rights - Use, duplication or
// disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class IBMBluemixService;

/**
IBMHttpRequest contains all the information that is needed in order to invoke an HTTP request to a secured endpoint
*/
@interface IBMHttpRequest : NSObject

/**
  The HTTP method for the request
 */
@property (readonly, nonatomic) NSString* method;

/**
 The target URL for the HTTP request
 */
@property (readonly, nonatomic) NSURL* url;


/**
 The IBMBluemixService making the HTTP request
 */
@property (readonly, nonatomic) IBMBluemixService *service;

/**
 The HTTP request headers
 */
@property (readonly, nonatomic) NSDictionary *headers;

@end
