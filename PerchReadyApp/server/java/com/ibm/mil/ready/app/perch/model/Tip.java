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
 * Tip is a model class for tips that an insurance agent would provide to their
 * customer. The tips can be for upcoming weather events, location based events,
 * and new incentives. Currently for demo purposes we have a static set of tips
 * each with a corresponding timeDelta, We use this timeDelta to compute a
 * timestamp from current time and working backwards. This way the demo seems as
 * though the data is recent.
 *
 * @author tannerpreiss
 *
 */
public class Tip extends CloudantObject {

	private String title;
	private String detail;
	private String tipType;
	private boolean read;
	private boolean highPriority;
	private long timeDelta;
	private long timestamp;
	private String userId;
	private String deviceClassId;
	private TipAction tipAction;

	/**
	 * @return title : This will be the title of the tip when displayed on the
	 *         client side. (ie. "Nearby Flood Warning"
	 */
	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	/**
	 * @return description : The description is the entire content of the tip.
	 *         (Should be limited to a few sentences.
	 */
	public String getDetail() {
		return detail;
	}

	public void setDetail(String detail) {
		this.detail = detail;
	}

	/**
	 * @return tipType : the type of the tip (Current we have weather, location,
	 *         or incentive)
	 */
	public String getTipType() {
		return tipType;
	}

	public void setTipType(String tipType) {
		this.tipType = tipType;
	}

	/**
	 * @return read : (true) if the user has read the tip on clientside. (false)
	 *         tip is unread. We are currently storing static values in cloudant
	 *         for read field, this will allow for demo purposes to show that
	 *         some tips are read and some are unread when first downloading the
	 *         static tips.
	 */
	public boolean isRead() {
		return read;
	}

	public void setRead(boolean read) {
		this.read = read;
	}

	/**
	 * @return highPriority : (true) tip is high priority, according to the
	 *         agent. (false) tip is not high priority.
	 */
	public boolean isHighPriority() {
		return highPriority;
	}

	public void setHighPriority(boolean highPriority) {
		this.highPriority = highPriority;
	}

	/**
	 * @return timeDelta : this value is for demo purposes only and provides a
	 *         value that the MFP server can use to dynamically calculate the
	 *         timestamp of the tip.
	 */
	public long getTimeDelta() {
		return timeDelta;
	}

	public void setTimeDelta(long timeDelta) {
		this.timeDelta = timeDelta;
	}

	/**
	 * timestamp : this value is not set in cloudant, rather it is calculated
	 * using timeDelta by the MFP server.
	 */
	public long getTimestamp() {
		return timestamp;
	}

	public void setTimestamp(long timestamp) {
		this.timestamp = timestamp;
	}

	/** @return userId : the id of the user that this tip is associated with. */
	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getDeviceClassId() {
		return deviceClassId;
	}

	public void setDeviceClassId(String deviceClassId) {
		this.deviceClassId = deviceClassId;
	}

	public TipAction getTipAction() {
		return tipAction;
	}

	public void setTipAction(TipAction tipAction) {
		this.tipAction = tipAction;
	}

	/**
	 * converts this to a string JSON
	 */
	@Override
	public String toString() {
		return new Gson().toJson(this);
	}

}
