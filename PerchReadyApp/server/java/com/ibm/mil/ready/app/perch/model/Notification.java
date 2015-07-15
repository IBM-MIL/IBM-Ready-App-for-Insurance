package com.ibm.mil.ready.app.perch.model;

import com.google.gson.Gson;
import com.ibm.mil.cloudant.model.CloudantObject;

public class Notification extends CloudantObject {

	private String deviceClassId;
	private String title;
	private String message;
	private String detail;
	private long timestamp;
	private boolean read;
	private long value;
	private long status;
	private long timeDelta;

	private RecommendedPartner partner;

	public String getDeviceClassId() {
		return deviceClassId;
	}

	public void setDeviceClassId(String deviceClassId) {
		this.deviceClassId = deviceClassId;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getDetail() {
		return detail;
	}

	public void setDetail(String detail) {
		this.detail = detail;
	}

	public long getTimestamp() {
		return timestamp;
	}

	public void setTimestamp(long timestamp) {
		this.timestamp = timestamp;
	}

	public boolean isRead() {
		return read;
	}

	public void setRead(boolean read) {
		this.read = read;
	}

	public long getValue() {
		return value;
	}

	public void setValue(long value) {
		this.value = value;
	}

	public long getStatus() {
		return status;
	}

	public void setStatus(long status) {
		this.status = status;
	}

	public long getTimeDelta() {
		return timeDelta;
	}

	public void setTimeDelta(long timeDelta) {
		this.timeDelta = timeDelta;
	}

	public RecommendedPartner getPartner() {
		return partner;
	}

	public void setPartner(RecommendedPartner partner) {
		this.partner = partner;
	}

	/**
	 * converts this to a string JSON
	 */
	@Override
	public String toString() {
		return new Gson().toJson(this);
	}

}
