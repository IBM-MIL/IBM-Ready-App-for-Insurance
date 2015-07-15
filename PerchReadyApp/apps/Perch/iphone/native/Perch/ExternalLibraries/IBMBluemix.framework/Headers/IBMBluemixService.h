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

#import <Foundation/Foundation.h>

/**
  IBMBluemix Services should extend this class. This class should be implemented as a singleton and have the
  following 2 static methods. Application developers will be expected to call your initializeService method and it
  should perform the initialization for your service. The getService() method is for convenience to
  the application developer if she needs to access the service in other parts of her code. This method should throw an
  exception if the initializeService method was not called.
 
  <pre>
  +(IBMYourServiceClass*) initializeService;
  +(IBMYourServiceClass*) getService;
  </pre>
 */
@interface IBMBluemixService : NSObject
{
@protected
    NSDictionary *params;
}

/**
  This service version is derived from the service.properties file and the version.properties
  file. The service.properties file is a template that should be placed in the same package as
  your service. The version.properties file has the major, minor and service versions. You
  would update these according to API changes made. The build will read the values from the
  version.properties file and update the service.properties files with these versions and the
  build-label.

 The version of the service in the format v(major).(minor).(service).(build-label).
 For example, 1.3.4.20140311_1500
 */
@property(nonatomic, readonly) NSString *version;

/**
 The name of the service
 */
@property(nonatomic, readonly) NSString *name;

/**
 Services can call this to print a standardized message for Jane that indicates the service was successfully initialized.
 */
-(void) logInitSuccess;

/**
    The default value is YES.  Override this value if you want DataPower to not rewrite the domain for your service.
 */
-(BOOL) shouldRewriteDomain;

/**
 This constructor must be called by extenders.  Calling init will fail.
 @param version The version for the IBMBluemixService.  This version should be set by the build.
 */
-(instancetype)initWithVersion: (NSString*)version;


@end
