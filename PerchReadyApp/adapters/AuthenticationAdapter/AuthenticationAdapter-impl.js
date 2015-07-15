/**
 * Licensed Materials - Property of IBM © Copyright IBM Corporation 2015. All
 * Rights Reserved. This sample program is provided AS IS and may be used,
 * executed, copied and modified without royalty payment by customer (a) for its
 * own instruction and study, (b) in order to develop applications designed to
 * run with an IBM product, either for customer's own internal use or for
 * redistribution by customer, as part of such an application, in customer's own
 * products.
 */

'use strict';

var authenticationAdapter = com.ibm.mil.ready.app.perch.AuthenticationAdapter.getInstance();
var defaultLocale = 'en_US';
var appRealmName = 'ReadyAppPerchAuthRealm';

/**
 * Test method so the client side folks can ensure MFP client is configured
 * properly.
 */
function test() {
	return {
		isSuccessful : true,
		result : 'Success!'
	};
}

/**
 * Ensures the user is properly authenticated. Callback for protected adapter
 * procedures
 * 
 * @param headers
 * @param errorMessage
 * @return true if user is not authenticated
 */
function onAuthRequired(headers, errorMessage) {
	errorMessage = errorMessage ? errorMessage
			: 'Authentication required to invoke this procedure!';

	return {
		authRequired : true,
		errorMessage : errorMessage
	};
}

/**
 * Exposed procedures to authenticate the user on initial login and subsequent
 * logins
 * 
 * @param username
 * @param password
 * @returns true/false depending on the credentials provided.
 */
function submitAuthentication(username, password) {
	var userIdentity = authenticationAdapter.verifyUser(username, password);
	
	if (userIdentity != null) {
		var activeUser = {
				userId: userIdentity._id,
				displayName: (userIdentity.firstName + ' ' + userIdentity.lastName), 
				attributes: userIdentity
		};
		WL.Server.setActiveUser(appRealmName, activeUser);
		return {
			isSuccessful : true,
			result : JSON.parse(userIdentity),
			authRequired : false
		};
	} else {
		return {
			onAuthRequired : onAuthRequired(null, 'Invalid Credentials'),
			isSuccessful : false
		};
	}
}

/**
 * Logs out the user due to inactivity or app termination.
 */
function onLogout() {
	WL.Server.setActiveUser(appRealmName, null);
	WL.Logger.info('User was logged out.');
}

/**
 * Helper method to return the current user ID.
 * 
 * @returns userId
 */
function getUserId() {
	var user = WL.Server.getActiveUser(perchAppRealm);
	WL.Logger.debug(user);
	return {
		result : user.userId
	};
}

/**
 * Helper method to return the current username.
 * 
 * @returns username
 */
function getUsername() {
	var user = WL.Server.getActiveUser(perchAppRealm);
	WL.Logger.debug(user);
	return {
		result : user.username
	};
}

