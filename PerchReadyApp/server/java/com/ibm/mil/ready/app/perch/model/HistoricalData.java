package com.ibm.mil.ready.app.perch.model;

import com.google.gson.Gson;
import com.ibm.mil.cloudant.model.CloudantObject;

public class HistoricalData extends CloudantObject {
	private long timeDelta;
	private long value;
	private String deviceClassId;
	private String timeUnit;
	private long timestamp;

	public HistoricalData(int timeDelta, int value) {
		this.timeDelta = timeDelta;
		this.value = value;
	}

	public long getTimeDelta() {
		return timeDelta;
	}

	public void setTimeDelta(long timeDelta) {
		this.timeDelta = timeDelta;
	}

	public long getValue() {
		return value;
	}

	public void setValue(long value) {
		this.value = value;
	}

	public String getDeviceClassId() {
		return deviceClassId;
	}

	public void setDeviceClassId(String deviceClassId) {
		this.deviceClassId = deviceClassId;
	}

	public String getTimeUnit() {
		return timeUnit;
	}

	public void setTimeUnit(String timeUnit) {
		this.timeUnit = timeUnit;
	}

	public long getTimestamp() {
		return timestamp;
	}

	public void setTimestamp(long timestamp) {
		this.timestamp = timestamp;
	}

	/** converts this to a string JSON */
	@Override
	public String toString() {
		return new Gson().toJson(this);
	}

}
