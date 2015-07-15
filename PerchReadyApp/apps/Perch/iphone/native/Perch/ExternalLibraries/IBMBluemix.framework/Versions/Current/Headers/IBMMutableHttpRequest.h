//-------------------------------------------------------------------------------
// Licensed Materials - Property of IBM
// (C) Copyright IBM Corp. 2013,2014. All Rights Reserved.
// US Government Users Restricted Rights - Use, duplication or
// disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//-------------------------------------------------------------------------------


#import <Foundation/Foundation.h>
#import "IBMBluemixService.h"
#import "BFTask.h"


typedef enum IBMHttpMethod{
    IBMHttpMethod_GET, IBMHttpMethod_POST, IBMHttpMethod_PUT, IBMHttpMethod_DELETE
}IBMHttpMethod;

/**
 IBMMutableHttpRequest provides the ability to configure and make HTTP requests.
 */
@interface IBMMutableHttpRequest : NSObject

/**
 The HTTP method for the request
 */
@property (nonatomic) IBMHttpMethod method;

/**
 The URI relative to the baseUrl for the HTTP request
 */
@property (nonatomic, copy) NSURL *url;

/**
 The IBMBluemixService making the HTTP request
 */
@property (nonatomic) IBMBluemixService *service;

/** 
 The data to be sent in the request (if applicable).  Use by POST/PUT
 */
@property (nonatomic, copy) NSData* contentStreamData;

/**
 The timeout for the HTTP request
 */
@property (nonatomic) NSTimeInterval timeout;

/**
The HTTP cache policy for the request.
 */
@property (nonatomic) NSURLRequestCachePolicy requestCachePolicy;

/**
 Make the HTTP request and return a BFTask to handle the response.
 @return The BFTask with a result of IBMHttpResponse
 */
-(BFTask*) sendRequest;

/**
 This is a convenience method for converting between the enum and an NSString of the IBMHttpMethod
 @param method The IBMHttpMethod which will be converted to a string.
 @return The string representation of the method
 */
+(NSString*) httpMethodAsString: (IBMHttpMethod) method;

/**
 Headers
 */
- (NSDictionary *)justHeaders;

/**
 @param service The IBMBluemixService that will be making HTTP requests.
 @return The newly created IBMMutableHttpRequest
 */
-(id) initWithService: (IBMBluemixService*) service;

/**
 Adds an HTTP header.  If the header name exists, it will be converted in a comma separated list.
 @param name The name of the header to add
 @param value The value of the header to add
 */
-(void) addHeaderWithName: (NSString*) name andValue: (NSString*) value;

/**
 Removes the HTTP header from the request.
 @param name The name of the header to remove
 */
-(void) removeHeaderWithName: (NSString*) name;

/**
 Sets an HTTP header.  If the header name is already present, it will replace the current header value.
 @param name The name of the header to set
 @param value The name of the value to set
 */
-(void) setHeaderWithName: (NSString*) name andValue: (NSString*) value;

@end
