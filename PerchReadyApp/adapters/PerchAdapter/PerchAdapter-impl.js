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

var perchJavaAdapter = com.ibm.mil.ready.app.perch.PerchAdapter.getInstance();
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
 * This method returns a list of current asset data to be displayed on the asset
 * overview. It queries every asset a user owns and returns a list containing
 * the current information for each asset.
 * 
 * @returns assets A list of the current data for each asset in the user's asset
 *          list.
 */
function getAllCurrentAssetData(devicePin) {
	var locale = getUserLocale();
	var user = WL.Server.getActiveUser(appRealmName);

	return getDataAndParseToJson(function() {
		var assets = perchJavaAdapter.getAssetOverview(
				user.attributes._id, user.attributes.deviceClassIds, devicePin,
				locale);
		return assets;
	});
}

/**
 * This method returns a list of current asset data to be displayed on the asset
 * overview. It queries every asset a user owns and returns a list containing
 * the current information for each asset.
 * 
 * @returns assets A list of the current data for each asset in the user's asset
 *          list.
 */
function getCurrentAssetDetail(deviceClassId, devicePin) {
	var locale = getUserLocale();
	var user = WL.Server.getActiveUser(appRealmName);

	return getDataAndParseToJson(function() {
		var assetDetail = perchJavaAdapter.getCurrentAssetDetail(deviceClassId,
				devicePin);

		assetDetail = JSON.parse(assetDetail);
		
		if (assetDetail.status === 0) {
			assetDetail.alert = '';
			delete assetDetail.alert;
		}

		return JSON.stringify(assetDetail);
	});
}

function getCurrentNotification(devicePin, deviceClassId) {

	return getDataAndParseToJson(function() {
		var curNotification = perchJavaAdapter.getCurrentNotification(
				deviceClassId, devicePin);

		curNotification = JSON.parse(curNotification);
		delete curNotification._id;
		delete curNotification._rev;
		delete curNotification.deviceClassId;
		delete curNotification.type;

		return JSON.stringify(curNotification);
	});
}

function getAllNotifications(devicePin, deviceClassId) {
	var locale = getUserLocale();
	var user = WL.Server.getActiveUser(appRealmName);

	return getDataAndParseToJson(function() {
		var notifications = perchJavaAdapter.getAllNotifications(devicePin,
				deviceClassId);

		notifications = JSON.parse(notifications);
		for ( var index in notifications) {
			delete notifications[index]._id;
			delete notifications[index].deviceClassId;
			delete notifications[index]._rev;
			delete notifications[index].type;
			delete notifications[index].timeDelta;
		}
		return JSON.stringify(notifications);

	});
}

function getAllHistoricalData(deviceClassId) {
	var locale = getUserLocale();
	var user = WL.Server.getActiveUser(appRealmName);

	return getDataAndParseToJson(function() {
		var historicalData = perchJavaAdapter
				.getAllHistoricalData(deviceClassId);

		historicalData = JSON.parse(historicalData);

		for ( var timeUnitIndex in historicalData) {
			var timeUnitArray = historicalData[timeUnitIndex];

			for ( var index in timeUnitArray) {
				delete timeUnitArray[index]._id;
				delete timeUnitArray[index].deviceClassId;
				delete timeUnitArray[index].timeDelta;
				delete timeUnitArray[index]._rev;
				delete timeUnitArray[index].type;
			}
			WL.Logger.info(timeUnitArray[0]);
			historicalData[timeUnitIndex] = timeUnitArray;
		}

		return JSON.stringify(historicalData);
	});
}

function getAllTips() {
	var locale = getUserLocale();
	var user = WL.Server.getActiveUser(appRealmName);

	return getDataAndParseToJson(function() {
		var tips = perchJavaAdapter.getAllTips(user.attributes._id);

		tips = JSON.parse(tips);
		for ( var index in tips) {
			delete tips[index]._id;
			delete tips[index].timeDelta;
			delete tips[index]._rev;
			delete tips[index].type;
			delete tips[index].userId;
		}
		WL.Logger.info(tips);
		return JSON.stringify(tips);
	});
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

/**
 * Helper method to return the current user locale.
 * 
 * @returns locale
 */
function getUserLocale() {
	var user = WL.Server.getActiveUser(appRealmName);
	WL.Logger.debug(user);
	return user.locale;
	// result : user.locale
	// };
}
