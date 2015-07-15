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

import com.google.gson.Gson;
import com.ibm.mil.cloudant.model.CloudantObject;

/**
 * Pojo to represent a internet of things device sensor data.
 *
 */
public class SensorData extends CloudantObject {
	private String deviceClassId;
	private String devicePin;
	private long status;
	private long value;
	private long time;
	private String units;

	public String getUnits() {
		return units;
	}

	public void setUnits(String units) {
		this.units = units;
	}

	public String getDeviceClassId() {
		return deviceClassId;
	}

	public void setDeviceClassId(String deviceClassId) {
		this.deviceClassId = deviceClassId;
	}

	public String getDevicePin() {
		return devicePin;
	}

	public void setDevicePin(String devicePin) {
		this.devicePin = devicePin;
	}

	public long getStatus() {
		return status;
	}

	public void setStatus(long status) {
		this.status = status;
	}

	public long getValue() {
		return value;
	}

	public void setValue(long value) {
		this.value = value;
	}

	public long getTime() {
		return time;
	}

	public void setTime(long time) {
		this.time = time;
	}

	/**
	 * converts this to a string JSON
	 */
	@Override
	public String toString() {
		return new Gson().toJson(this);
	}
}
