//-------------------------------------------------------------------------------
// Licensed Materials - Property of IBM
// (C) Copyright IBM Corp. 2013,2014. All Rights Reserved.
// US Government Users Restricted Rights - Use, duplication or
// disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//-------------------------------------------------------------------------------


#import <Foundation/Foundation.h>

/**
 The IBMCurrentUser class is a provisional API.  APIs that are marked provisional are evolving and might change or be removed in future releases. 
 
 The IBMCurrentUser represents the current user (if one is available).  There does not need to be an end user, meaning they could be anonymous.
 */
@interface IBMCurrentUser : NSObject

/**
 The unique identifier from Mobile Application Security Service
 */
@property (readonly, nonatomic) NSString* uuid;

/**
 The security provider used to obtain and validate the token
 */
@property (readonly, nonatomic) IBMSecurityProvider securityProvider;

/**
 The security token for the user
 */
@property (readonly, nonatomic) NSString *securityToken;

@end
