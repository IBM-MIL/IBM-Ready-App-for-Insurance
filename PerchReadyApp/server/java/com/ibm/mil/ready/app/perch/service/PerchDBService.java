/*
 * Licensed Materials - Property of IBM © Copyright IBM Corporation 2015. All
 * Rights Reserved. This sample program is provided AS IS and may be used,
 * executed, copied and modified without royalty payment by customer (a) for its
 * own instruction and study, (b) in order to develop applications designed to
 * run with an IBM product, either for customer's own internal use or for
 * redistribution by customer, as part of such an application, in customer's own
 * products.
 */
package com.ibm.mil.ready.app.perch.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;
import com.ibm.mil.cloudant.CloudantService;
import com.ibm.mil.ready.app.perch.model.DeviceClass;
import com.ibm.mil.ready.app.perch.model.HistoricalData;
import com.ibm.mil.ready.app.perch.model.Notification;
import com.ibm.mil.ready.app.perch.model.SensorData;
import com.ibm.mil.ready.app.perch.model.Tip;
import com.ibm.mil.ready.app.perch.utils.Utilities;

public class PerchDBService {

	private final static CloudantService cloudantService = CloudantService.getInstance();
	Gson gson;

	/**
	 * creates a PerchDBService() and instantiates a gson instance.
	 */
	public PerchDBService() {
		super();
		gson = new Gson();
	}

	/**
	 * getDeviceClasses() returns a list of deviceClass objects associated with
	 * the deviceClassIdFilter. If no filter is provided, all deviceClass
	 * objects are returned.
	 *
	 * @param deviceClassIdFilter
	 *            a valid deviceClassId to get the record for that deviceClass
	 *            object. If deviceClassIdFilter is null this method will return
	 *            all deviceClass objects.
	 * @return The deviceClass object or all of the deviceClass objects if no
	 *         filter is specified.
	 */
	public List<DeviceClass> getDeviceClasses(String deviceClassIdFilter) {
		boolean shouldFilter = deviceClassIdFilter == null ? false : Utilities
				.isSanitary(deviceClassIdFilter);

		List<DeviceClass> deviceClasses = shouldFilter ? cloudantService.getDatabase()
				.view("library/device_classes").key(deviceClassIdFilter).reduce(false)
				.includeDocs(true).query(DeviceClass.class) : cloudantService.getDatabase()
				.view("library/device_classes").reduce(false).includeDocs(true)
				.query(DeviceClass.class);

				return deviceClasses;
	}

	/**
	 * getCurrentNotification() returns the current notifcation for a given
	 * deviceClassId and devicePin. For demo purposes, if no notification exists
	 * then this method returns the first historical notification for the given
	 * deviceClassId.
	 *
	 * @param deviceClassIdFilter
	 *            the deviceClassId refers to the id associate with the "type"
	 *            or class of device. (ie. deviceClassId : 10001 is a Water
	 *            Meter class)
	 * @param devicePinFilter
	 *            the devicePin is the unique pin associated with the user's
	 *            device instance.
	 * @param locale
	 *            the locale of the user.
	 * @return notification the current notification for a specified sensor, or
	 *         if no current notification is available then the latest
	 *         historical static notification will be returned.
	 */
	public Notification getCurrentNotification(String deviceClassIdFilter, String devicePinFilter) {
		boolean validDeviceIdAndPin = Utilities.checkDeviceClassId(deviceClassIdFilter)
				&& Utilities.checkDevicePin(devicePinFilter);

		Notification notification = new Notification();

		if (validDeviceIdAndPin) {
			List<Notification> notificationList = cloudantService.getDatabase()
					.view("library/notifications").endKey(devicePinFilter, deviceClassIdFilter, 0)
					.startKey(devicePinFilter, deviceClassIdFilter, new Object()).reduce(false)
					.descending(true).limit(1).includeDocs(true).query(Notification.class);

			if (notificationList.isEmpty()) {
				notification = this.getAllStaticNotifications(deviceClassIdFilter).get(0);
				notification.setTimestamp(System.currentTimeMillis());
			} else {
				notification = notificationList.get(0);
			}
		}

		return notification;
	}

	/**
	 * getCurrentSensorData() returns the current sensor data information for a
	 * particular sensor.
	 *
	 * @param deviceClassIdFilter
	 *            the deviceClassId refers to the id associate with the "type"
	 *            or class of device. (ie. deviceClassId : 10001 is a Water
	 *            Meter class)
	 * @param devicePinFilter
	 *            the devicePin is the unique pin associated with the user's
	 *            device instance.
	 * @param locale
	 *            the locale of the user.
	 * @return sensorData the current sensorData for the specified device.
	 */
	public SensorData getCurrentSensorData(String deviceClassIdFilter, String devicePinFilter) {
		boolean validDeviceIdAndPin = Utilities.checkDeviceClassId(deviceClassIdFilter)
				&& Utilities.checkDevicePin(devicePinFilter);

		SensorData sensorData = new SensorData();

		if (validDeviceIdAndPin) {
			List<SensorData> sensorDataList = cloudantService.getDatabase()
					.view("library/sensor_data_for_device_instance")
					.endKey(deviceClassIdFilter, devicePinFilter, 0)
					.startKey(deviceClassIdFilter, devicePinFilter, new Object()).reduce(false)
					.descending(true).limit(1).includeDocs(true).query(SensorData.class);

			if (!sensorDataList.isEmpty()) {
				sensorData = sensorDataList.get(0);
			}
		}

		return sensorData;
	}

	/**
	 * getAllCurrentSensorDataForOneDevicePin() returns a list of current sensor
	 * data from each of the sensors associated with a given device pin.
	 *
	 * @param devicePinFilter
	 *            is the unique devicePin associated with the user's device
	 *            instance.
	 * @param locale
	 *            the locale of the user. This currently has no functionality
	 *            but is included in case, a developer wishes to provide sensor
	 *            data unit conversions to the user based on the user's locale.
	 * @return currentSensorData a list of the currentSensorData.
	 */
	@SuppressWarnings("rawtypes")
	public List<SensorData> getAllCurrentSensorData(String devicePinFilter, String locale) {
		List<SensorData> currentSensorData = new ArrayList<SensorData>();

		if (Utilities.checkDevicePin(devicePinFilter)) {
			List<Map> returnedMap = cloudantService.getDatabase()
					.view("library/current_sensor_data").startKey(devicePinFilter, 0, 0)
					.endKey(devicePinFilter, new Object(), new Object()).groupLevel(2)
					.query(Map.class);
			for (Map mapRecord : returnedMap) {
				// The line below has no type checking, and should be looked at
				// if database change occurs.
				currentSensorData.add(gson.fromJson(gson.toJson(mapRecord.get("value")),
						SensorData.class));
			}
		}
		return currentSensorData;
	}

	/**
	 * getHistoricalDataForDevices() returns a list of the historical data for a
	 * given timeUnit and deviceClassId.
	 *
	 * @param deviceClassId
	 *            the deviceClassId refers to the id associate with the "type"
	 *            or class of device. (ie. deviceClassId : 10001 is a Water
	 *            Meter class)
	 * @param timeUnit
	 *            a timeUnit in our use case can be 'hour', 'day', 'week' and
	 *            represents the historical data points' time between data
	 *            points. For example: a request for deviceClassId = 10001 and
	 *            timeUnit = day would return all of the historical data for a
	 *            water meter and each of the historical data points would be 1
	 *            day apart.
	 * @param minTimeDelta
	 *            the minimum timeDelta for the requested data. timeDelta is
	 *            used by the perchAdapter to calculate a timestamp from the
	 *            current time.
	 *
	 * @param maxTimeDelta
	 *            the maximum timeDelta.
	 * @return allHistoricalData the historical data in the given range of
	 *         timeDeltas.
	 */
	public List<HistoricalData> getHistoricalDataForDevice(String deviceClassId, String timeUnit,
			int minTimeDelta, int maxTimeDelta) {
		List<HistoricalData> allHistoricalData = new ArrayList<HistoricalData>();

		if (Utilities.isSanitary(deviceClassId)) {
			allHistoricalData = cloudantService.getDatabase().view("library/historical_data")
					.startKey(deviceClassId, timeUnit, minTimeDelta)
					.endKey(deviceClassId, timeUnit, maxTimeDelta).includeDocs(true)
					.query(HistoricalData.class);
		}
		return allHistoricalData;
	}

	/**
	 * getAllTips() is a cloudant query that returns a list of tips for the
	 * given userId.
	 *
	 * @return allTips a list of tips from an insurance agent for the given
	 *         userId.
	 */
	public List<Tip> getAllTips(String userId) {
		List<Tip> allTips = new ArrayList<Tip>();

		if (Utilities.isSanitary(userId)) {
			allTips = cloudantService.getDatabase().view("library/tips").startKey(userId, 0)
					.endKey(userId, new Object()).includeDocs(true).query(Tip.class);
		}

		return allTips;
	}

	/**
	 * getAllIncentiveTips() returns all of the tips of 'type' = "incentive".
	 *
	 * @param userId
	 *            is the id associated with the user. In this implementation,
	 *            the userId corresponds to the cloudant ._id of the document
	 *            representing the user.
	 * @return allIncentives a list of all the tips that are of type incentive.
	 */
	public List<Tip> getAllIncentiveTips(String userId) {
		List<Tip> allIncentives = new ArrayList<Tip>();

		if (Utilities.isSanitary(userId)) {
			allIncentives = cloudantService.getDatabase().view("library/incentives")
					.startKey(userId, 0).endKey(userId, new Object()).includeDocs(true)
					.query(Tip.class);
		}

		return allIncentives;
	}

	/**
	 * getAllStaticNotifications() returns a list of static notifications stored
	 * in the database. These static notifications are the same as normal
	 * notifications but are used for demo purposes and contain a timeDelta so
	 * that when this query is made the PerchAdapter can timestamp based on the
	 * timeDelta, all for demo purposes.
	 *
	 * @param deviceClassId
	 *            the deviceClassId refers to the id associate with the "type"
	 *            or class of device. (ie. deviceClassId : 10001 is a Water
	 *            Meter class)
	 * @return allHistoricalNotifications the list of historical notifications
	 *         stored in the database for the given deviceClassId.
	 */
	public List<Notification> getAllStaticNotifications(String deviceClassId) {
		List<Notification> allHistoricalNotifications = new ArrayList<Notification>();

		if (Utilities.isSanitary(deviceClassId)) {
			allHistoricalNotifications = cloudantService.getDatabase()
					.view("library/historical_notifications").startKey(deviceClassId, 0)
					.endKey(deviceClassId, new Object()).includeDocs(true)
					.query(Notification.class);
		}
		return allHistoricalNotifications;
	}

	/**
	 * getAllLiveNotifications() returns a list of all the current notifications
	 * for a given device. So if the sensor simulator goes into a warning state
	 * and then back to normal this method will return two notification; one for
	 * the warning state and one for the back to normal notification. These
	 * notifications are the same notifications that are sent through IBM Push,
	 * we are saving them in cloudant for a history of alerts on a sensor.
	 *
	 * @param deviceClassId
	 *            the deviceClassId refers to the id associate with the "type"
	 *            or class of device. (ie. deviceClassId : 10001 is a Water
	 *            Meter class)
	 * @param devicePin
	 *            the devicePin is the unique pin associated with the user's
	 *            device instance.
	 * @return allLiveNotifications a list of all of the current notifications
	 *         from a live IoT Sensor Simulator.
	 */
	public List<Notification> getAllLiveNotifications(String devicePin, String deviceClassId) {
		List<Notification> allLiveNotifications = new ArrayList<Notification>();

		if (Utilities.isSanitary(deviceClassId)) {
			allLiveNotifications = cloudantService.getDatabase().view("library/notifications")
					.startKey(devicePin, deviceClassId, new Object())
					.endKey(devicePin, deviceClassId, 0).includeDocs(true).descending(true)
					.query(Notification.class);
		}
		return allLiveNotifications;
	}

	/**
	 * For testing only
	 *
	 * @param args
	 */
	public static void main(String... args) {
		PerchDBService service = new PerchDBService();
		// System.out.println(service.getAllTips("20001"));
		System.out.println(service.getAllStaticNotifications("10001"));
		// System.out.println(service.getCurrentNotification("10001","0000"));
		System.out.println("done");
		// System.out.println(service.getAllTips("20001"));
	}

}
