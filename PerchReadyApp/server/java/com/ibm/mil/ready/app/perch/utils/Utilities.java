/*
 * Licensed Materials - Property of IBM © Copyright IBM Corporation 2015. All
 * Rights Reserved. This sample program is provided AS IS and may be used,
 * executed, copied and modified without royalty payment by customer (a) for its
 * own instruction and study, (b) in order to develop applications designed to
 * run with an IBM product, either for customer's own internal use or for
 * redistribution by customer, as part of such an application, in customer's own
 * products.
 */

package com.ibm.mil.ready.app.perch.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.ibm.mil.ready.app.perch.model.Asset;
import com.ibm.mil.ready.app.perch.model.DeviceClass;
import com.ibm.mil.ready.app.perch.model.Notification;
import com.ibm.mil.ready.app.perch.model.SensorData;
import com.ibm.mil.service.MessageService;
import com.ibm.mil.util.AppPropertiesReader;

public final class Utilities {
	private static final MessageService messages = MessageService.getInstance();
	private static final Logger LOGGER = Logger.getLogger(Utilities.class.getSimpleName());

	private Utilities() {
		throw new AssertionError("Utilities is non-instantiable");
	}

	private enum IllegalArgs {
		SPACE(" "), SHOW("show"), UPDATE("update"), DB("db"), INSERT("insert"), SAVE("save"), REMOVE(
				"remove"), DROP("drop"), COLLECTION("collection");

		private final String illegalArg;

		IllegalArgs(String illegalArg) {
			this.illegalArg = illegalArg;
		}

		public String getIllegalArg() {
			return illegalArg;
		}
	}

	public static boolean isSanitary(String argument) {
		return isSanitary(argument, AppPropertiesReader.getStringProperty(Constants.DEFAULT_LOCALE));
	}

	/**
	 * isSanitary() ensures that some sanity checking is done against the
	 * arguments passed in from the client to the back end. This method returns
	 * false if one of the "bad" strings is found, basically checking for sql
	 * injections, etc.
	 *
	 * @param argument
	 *            The parameter passed in from the client
	 * @param locale
	 *            The locale of the client user
	 * @return True if the client argument is sanitary, or false if it contains
	 *         basd strings.
	 */
	public static boolean isSanitary(String argument, String locale) {
		boolean sanitary = true;
		// check for null, empty, sql query, etc
		try {
			String lowered = argument == null ? null : argument.toLowerCase(new Locale(locale));
			boolean throwsException = false;
			String message = Constants.MSG1_KEY;

			if (argument == null) {
				throwsException = true;
			} else if (argument.length() == 0) {
				throwsException = true;
				message = Constants.MSG2_KEY;
			} else {
				for (IllegalArgs arg : IllegalArgs.values()) {
					if (lowered.contains(arg.getIllegalArg())) {
						throwsException = true;
						message = Constants.MSG4_KEY;
						break;
					}
				}
			}
			if (throwsException) {
				throw new IllegalArgumentException(messages.getMessage(message, locale));
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			LOGGER.log(Level.SEVERE, messages.getMessage(Constants.MSG5_KEY, locale,
					new Object[] { ex.getMessage() }));
			sanitary = false;
		}

		return sanitary;
	}

	/**
	 * checkDevicePin checks the device pin for length and sanitary values.
	 *
	 * @param devicePin
	 *            the devicePin to check.
	 * @return boolean true : devicePin is ok. false: devicePin is invalid.
	 */
	public static boolean checkDevicePin(String devicePin) {
		return Utilities.isSanitary(devicePin) && devicePin.length() == Constants.DEVICE_PIN_LENGTH;
	}

	/**
	 * checkDeviceClassId() checks the device class id for length and sanitary
	 * values.
	 *
	 * @param deviceClassId
	 *            the devicePin to check.
	 * @return true : deviceClassId is ok. false: deviceClassId is invalid.
	 */
	public static boolean checkDeviceClassId(String deviceClassId) {
		return Utilities.isSanitary(deviceClassId)
				&& deviceClassId.length() == Constants.DEVICE_CLASS_ID_LENGTH;
	}

	/**
	 *
	 * @param deviceClassList
	 * @param sensorDataList
	 * @return
	 */
	public static List<Asset> createAssetList(List<DeviceClass> deviceClassList,
			List<SensorData> sensorDataList) {

		List<Asset> assetList = new ArrayList<Asset>();
		for (DeviceClass device : deviceClassList) {
			if (!sensorDataList.isEmpty() && !device.isEnabled()) {
				assetList.add(new Asset(device));
				continue;
			}
			for (SensorData currentSensorData : sensorDataList) {
				if (currentSensorData.getDeviceClassId().equals(device.getId())) {
					assetList.add(new Asset(device, currentSensorData));
					break;
				}
			}
		}

		return assetList;
	}

	public static List<Notification> combineLiveAndStaticNotifications(
			List<Notification> liveNotifications, List<Notification> staticNotifications) {
		List<Notification> allNotifications = new ArrayList<Notification>();

		// If there are no live notifications, then timestamp and return only
		// the historical static notifications.
		long curTime = 0;
		if (liveNotifications.isEmpty()) {
			curTime = System.currentTimeMillis();
		}
		// else there are live notifications so return a list of live
		// notifications followed by historical static notifications.
		else {
			for (Notification liveNotif : liveNotifications) {
				allNotifications.add(liveNotif);
			}
			curTime = liveNotifications.get(liveNotifications.size() - 1).getTimestamp()
					- Constants.ONE_HOUR_INMILLIS;
		}

		for (Notification histNotif : staticNotifications) {
			histNotif
			.setTimestamp(curTime - histNotif.getTimeDelta() * Constants.ONE_HOUR_INMILLIS);
			allNotifications.add(histNotif);
		}
		return allNotifications;
	}

	public static void setRecommendedPartners(List<Notification> notifications,
			List<DeviceClass> deviceClasses) {
		for (Notification notif : notifications) {
			for (DeviceClass device : deviceClasses) {
				if (notif.getStatus() > 0 && notif.getDeviceClassId().equals(device.getId())) {
					notif.setPartner(device.getPartner());
				}
			}
		}
	}
}
