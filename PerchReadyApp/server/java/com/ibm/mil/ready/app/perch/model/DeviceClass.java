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
 * Pojo to represent a internet of things device class. The device class
 * represents all of the static information about a sensor/device.
 */
public class DeviceClass extends CloudantObject {
	private String name;
	private String partName;
	private String serialNumber;
	private long maxThreshold;
	private String maxMessage;
	private long minThreshold;
	private String minMessage;
	private String normalMessage;
	private long age;
	private boolean enabled;
	private String averageUsage;
	private String averageUsageUnit;

	private RecommendedPartner partner;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPartName() {
		return partName;
	}

	public void setPartName(String partName) {
		this.partName = partName;
	}

	public String getSerialNumber() {
		return serialNumber;
	}

	public void setSerialNumber(String serialNumber) {
		this.serialNumber = serialNumber;
	}

	public long getMaxThreshold() {
		return maxThreshold;
	}

	public void setMaxThreshold(long maxThreshold) {
		this.maxThreshold = maxThreshold;
	}

	public String getMaxMessage() {
		return maxMessage;
	}

	public void setMaxMessage(String maxMessage) {
		this.maxMessage = maxMessage;
	}

	public long getMinThreshold() {
		return minThreshold;
	}

	public void setMinThreshold(long minThreshold) {
		this.minThreshold = minThreshold;
	}

	public String getMinMessage() {
		return minMessage;
	}

	public void setMinMessage(String minMessage) {
		this.minMessage = minMessage;
	}

	public String getNormalMessage() {
		return normalMessage;
	}

	public void setNormalMessage(String normalMessage) {
		this.normalMessage = normalMessage;
	}

	public long getAge() {
		return age;
	}

	public void setAge(long age) {
		this.age = age;
	}

	public boolean isEnabled() {
		return enabled;
	}

	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public String getAverageUsage() {
		return averageUsage;
	}

	public void setAverageUsage(String averageUsage) {
		this.averageUsage = averageUsage;
	}

	public String getAverageUsageUnit() {
		return averageUsageUnit;
	}

	public void setAverageUsageUnit(String averageUsageUnit) {
		this.averageUsageUnit = averageUsageUnit;
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
