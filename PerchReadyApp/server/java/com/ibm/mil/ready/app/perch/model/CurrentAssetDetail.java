package com.ibm.mil.ready.app.perch.model;

import com.google.gson.Gson;

/**
 * Pojo to represent an the the information that is sent while polling on the
 * asset detail for current sensor data. This class contains the current sensor
 * data information and the current alert(notification). The alert is set if the
 * sensor data has a status of 2 indicating that the sensor is in a warning
 * state and an alert should accompany the information that the asset detail
 * will receive.
 *
 * NOTE: This class is only used as a serializable class by Gson, and this is
 * why there are no getters or setters. Gson creates JSON objects from the
 * fields of an object.
 */
public class CurrentAssetDetail {
	public Notification alert;

	public long status;
	public long curValue;
	public String units;

	public CurrentAssetDetail(Notification notification, SensorData sensorData) {
		this.alert = notification;

		this.status = sensorData.getStatus();
		this.curValue = sensorData.getValue();
		this.units = sensorData.getUnits();
	}

	/** converts this to a string JSON object using Gson */
	@Override
	public String toString() {
		return new Gson().toJson(this);
	}
}
