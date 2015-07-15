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

/**
 * Pojo to represent an asset(sensor with all the name and other information) on
 * the asset overview page of things device sensor data. An Asset is a select
 * combination of DeviceClass and SensorData and provides the mobile clients
 * with only the information necessary. (ie. excludes some cloudant object
 * information)
 *
 *
 * NOTE: This class is only used as a serializable class by Gson, and hence why
 * there are no getters or setters because Gson creates JSON from the fields of
 * an object.
 */
@SuppressWarnings("PMD.TooManyFields")
public class Asset {
	public String name;
	public String partName;
	public String deviceClassId;
	public String serialNumber;
	public long age;
	public boolean enabled;
	public long maxThreshold;
	public String averageUsage;
	public String averageUsageUnit;

	public String devicePin;
	public long status;
	public long value;
	public long time;
	public String units;

	public Tip tip;

	public Notification alert;

	public Asset(DeviceClass deviceClass, SensorData sensorData) {
		this(deviceClass);

		this.devicePin = sensorData.getDevicePin();
		this.status = sensorData.getStatus();
		this.value = sensorData.getValue();
		this.time = sensorData.getTime();
		this.units = sensorData.getUnits();

	}

	public Asset(DeviceClass deviceClass) {
		this.name = deviceClass.getName();
		this.deviceClassId = deviceClass.getId();
		this.serialNumber = deviceClass.getSerialNumber();
		this.partName = deviceClass.getPartName();
		this.enabled = deviceClass.isEnabled();
		this.age = deviceClass.getAge();
		this.maxThreshold = deviceClass.getMaxThreshold();
		this.averageUsage = deviceClass.getAverageUsage();
		this.averageUsageUnit = deviceClass.getAverageUsageUnit();
	}

	public void setTip(Tip tip) {
		this.tip = tip;
	}

	public void setAlert(Notification alert) {
		this.alert = alert;
	}

	/** converts this to a string JSON */
	@Override
	public String toString() {
		return new Gson().toJson(this);
	}

}
