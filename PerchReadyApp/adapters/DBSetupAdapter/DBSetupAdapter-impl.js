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

var dbSetupAdapter = com.ibm.mil.ready.app.perch.DBSetupAdapter.getInstance();
var constants = com.ibm.mil.ready.app.perch.utils.Constants;
var defaultLocale = 'en_US';
var appRealmName = 'ReadyAppPerchAuthRealm';

function saveTipsToDB() {
	dbSetupAdapter.saveToDB(constants.TIP_JSONFILENAME, com.ibm.mil.ready.app.perch.model.Tip);
}

/**
 * getDataAndParseToJson() creates a JSON response by invoking the
 * callbackFunction.
 * 
 * @param callbackFunction
 *            the function a user wishes to return the results of; in the
 *            response.result
 * @returns response containing "isSuccessful" if "isSuccessful" is true then
 *          response will include "result". if "isSuccessful" is false then
 *          resposne will contain "errorMsg".
 * 
 */
function getDataAndParseToJson(callbackFunction) {
	var response = {
		isSuccessful : true
	};

	try {
		var data = callbackFunction();
		response.result = JSON.parse(data);
	} catch (err) {
		response.isSuccessful = false;
		response.errorMsg = err.message;
		// Log error to MFP logs
		WL.Logger.error(err.message);
	}

	return response;
}
