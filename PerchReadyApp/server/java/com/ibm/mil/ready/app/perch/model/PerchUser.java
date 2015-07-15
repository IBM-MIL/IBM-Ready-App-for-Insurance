/*
 * Licensed Materials - Property of IBM © Copyright IBM Corporation 2015. All
 * Rights Reserved. This sample program is provided AS IS and may be used,
 * executed, copied and modified without royalty payment by customer (a) for its
 * own instruction and study, (b) in order to develop applications designed to
 * run with an IBM product, either for customer's own internal use or for
 * redistribution by customer, as part of such an application, in customer's own
 * products.
 */

package com.ibm.mil.ready.app.perch.model;

import java.util.List;

import com.google.gson.Gson;
import com.ibm.mil.cloudant.model.User;

/**
 * Pojo to represent a User
 */
public class PerchUser extends User {

	private List<String> deviceClassIds;

	public List<String> getDeviceClassIds() {
		return deviceClassIds;
	}

	public void setDeviceClassIds(List<String> deviceClassIds) {
		this.deviceClassIds = deviceClassIds;
	}

	/**
	 * converts this to a string JSON
	 */
	@Override
	public String toString() {
		return new Gson().toJson(this);
	}
}
