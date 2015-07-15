//-------------------------------------------------------------------------------
// Licensed Materials - Property of IBM
// (C) Copyright IBM Corp. 2013,2014. All Rights Reserved.
// US Government Users Restricted Rights - Use, duplication or
// disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//-------------------------------------------------------------------------------


#import <Foundation/Foundation.h>
#import "IBMHttpRequest.h"

/**
 The IBMHttpError class is a provisional API.  APIs that are marked provisional are evolving and might change or be removed in future releases.

 An error class used to report failures for IBMHttpRequest requests
 */
@interface IBMHttpError : NSError

/**
 The IBMHttpRequest that caused this error
 */
@property (readonly, nonatomic) IBMHttpRequest *request;

/**
 The NSError that caused this error (if any)
 */
@property (readonly, nonatomic) NSError *cause;


@end
