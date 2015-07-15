/*
 * Licensed Materials - Property of IBM © Copyright IBM Corporation 2015. All
 * Rights Reserved. This sample program is provided AS IS and may be used,
 * executed, copied and modified without royalty payment by customer (a) for its
 * own instruction and study, (b) in order to develop applications designed to
 * run with an IBM product, either for customer's own internal use or for
 * redistribution by customer, as part of such an application, in customer's own
 * products.
 */

package com.ibm.mil.ready.app.perch;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import com.ibm.mil.ready.app.perch.model.Asset;
import com.ibm.mil.ready.app.perch.model.CurrentAssetDetail;
import com.ibm.mil.ready.app.perch.model.DeviceClass;
import com.ibm.mil.ready.app.perch.model.HistoricalData;
import com.ibm.mil.ready.app.perch.model.Notification;
import com.ibm.mil.ready.app.perch.model.SensorData;
import com.ibm.mil.ready.app.perch.model.Tip;
import com.ibm.mil.ready.app.perch.service.PerchDBService;
import com.ibm.mil.ready.app.perch.utils.Constants;
import com.ibm.mil.ready.app.perch.utils.HistoricalDataUtils;
import com.ibm.mil.ready.app.perch.utils.Utilities;

/**
 * PerchAdapter is a class that contains methods to manage multiple services
 * provided in the Mobile First Platform suite. Currently the PerchAdapter is
 * using a PerchDBService class to query a cloudant database. The methods in
 * this class will be accessed by the javascript PerchAdapter.
 *
 * @author tannerpreiss
 *
 */
public final class PerchAdapter {
	private static PerchAdapter perchAdapter;
	private final PerchDBService perchDBService;

	public static PerchAdapter getInstance() {
		synchronized (PerchAdapter.class) {
			if (perchAdapter == null) {
				perchAdapter = new PerchAdapter();
			}
		}
		return perchAdapter;
	}

	// private constructor to ensure it remains a singleton.
	private PerchAdapter() {
		perchDBService = new PerchDBService();
	}

	/**
	 * getCurrentSensorData() returns the current data for a particular sensor,
	 * given the deviceClassId and the devicePin.
	 *
	 * @param deviceClassId
	 *            the deviceClassId refers to the id associate with the "type"
	 *            or class of device. (ie. deviceClassId : 10001 is a Water
	 *            Meter class)
	 * @param devicePin
	 *            the devicePin refers to the pin given by the IoT simulator.
	 * @return sensorData the current sensor data from the requested sensor.
	 */
	private SensorData getCurrentSensorData(String deviceClassId, String devicePin) {
		SensorData currentSensorData = new SensorData();

		if (Utilities.checkDeviceClassId(deviceClassId) && Utilities.checkDevicePin(devicePin)) {
			currentSensorData = perchDBService.getCurrentSensorData(deviceClassId, devicePin);
		}

		return currentSensorData;
	}

	/**
	 * getAllCurrentSensorData() returns a list of the current sensorData for
	 * each device associated with the given devicePin.
	 *
	 * @param devicePin
	 *            the devicePin is the unique pin associated with the user's
	 *            device instance.
	 * @param locale
	 *            the locale of the user, currently this does not have an
	 *            effect, but could be used to change the sensor data values
	 *            units of measurement.
	 * @return
	 */
	private List<SensorData> getAllCurrentSensorData(String devicePin, String locale) {
		return perchDBService.getAllCurrentSensorData(devicePin, locale);
	}

	/**
	 * getCurrentNotification()
	 *
	 * @param deviceClassId
	 *            the deviceClassId refers to the id associate with the "type"
	 *            or class of device. (ie. deviceClassId : 10001 is a Water
	 *            Meter class)
	 * @param devicePin
	 *            the devicePin is the unique pin associated with the user's
	 *            device instance.
	 * @return a list of the current sensorData for each device associated with
	 *         the given devicePin.
	 */
	public Notification getCurrentNotification(String deviceClassId, String devicePin) {
		Notification curNotif = perchDBService.getCurrentNotification(deviceClassId, devicePin);
		List<Notification> curNotifications = new ArrayList<Notification>();
		curNotifications.add(curNotif);
		List<DeviceClass> deviceClasses = perchDBService.getDeviceClasses(null);

		Utilities.setRecommendedPartners(curNotifications, deviceClasses);

		return curNotifications.get(0);
	}

	/**
	 * getCurrentAssetDetail() returns the current asset detail for a specific
	 * sensor. This data contains contains the current sensor data information
	 * and the current alert(notification). The alert is set if the sensor data
	 * has a status of 2 indicating that the sensor is in a warning state and an
	 * alert should accompany the information that the asset detail will
	 * receive.
	 *
	 * @param deviceClassId
	 *            the deviceClassId refers to the id associate with the "type"
	 *            or class of device. (ie. deviceClassId : 10001 is a Water
	 *            Meter class)
	 * @param devicePin
	 *            the devicePin is the unique pin associated with the user's
	 *            device instance.
	 * @return
	 */
	public CurrentAssetDetail getCurrentAssetDetail(String deviceClass, String devicePin) {
		Notification curNotif = this.getCurrentNotification(deviceClass, devicePin);
		SensorData curData = this.getCurrentSensorData(deviceClass, devicePin);
		return new CurrentAssetDetail(curNotif, curData);
	}

	/**
	 * /** getAllCurrentAssetData() builds and returns a sorted list of current
	 * asset information. The list is sorted by current asset status, where
	 * assets in a critical status are first in the list.
	 *
	 * An Asset includes 1) all DeviceClass information from the database 2)
	 * current sensor information (status, value, etc) An Asset may contain 3)
	 * alert which is the current Alert if a sensor has a critical status 4) Tip
	 * if a tip is associated with a specific asset then the tip information is
	 * included in the paylaod of the Asset.
	 *
	 * @param userId
	 *            is the id associated with the user. In this implementation,
	 *            the userId corresponds to the cloudant ._id of the document
	 *            representing the user.
	 * @param deviceClassIds
	 *            a list of all the user's deviceClassIds. A deviceClassId is
	 *            the classId associated with the specific device type. (i.e.
	 *            deviceClassId : "10001" is a Water Meter)
	 * @param devicePin
	 *            the devicePin is the unique pin associated with the user's
	 *            device instance.
	 * @param locale
	 *            the locale of the user, currently this does not have an
	 *            effect, but could be used to change the sensor data values
	 *            units of measurement.
	 * @return allCurrentAssets : a list of the current data for each asset in
	 *         the user's asset list, sorted by asset status.
	 */
	public List<Asset> getAssetOverview(String userId, List<String> deviceClassIds,
			String devicePin, String locale) {

		List<DeviceClass> allDevices = perchDBService.getDeviceClasses(null);
		List<SensorData> allCurrentSensorData = this.getAllCurrentSensorData(devicePin, locale);
		List<Tip> allTips = perchDBService.getAllIncentiveTips(userId);

		List<Asset> allCurrentAssets = Utilities.createAssetList(allDevices, allCurrentSensorData);
		for (Asset asset : allCurrentAssets) {
			if (asset.status > Constants.NORMAL_STATUS) {
				asset.setAlert(this.getCurrentNotification(asset.deviceClassId, asset.devicePin));
			}
			for (Tip tip : allTips) {
				if (asset.deviceClassId.equals(tip.getDeviceClassId())) {
					tip.setTimestamp(System.currentTimeMillis()
							- (tip.getTimeDelta() * Constants.ONE_HOUR_INMILLIS));
					asset.setTip(tip);

					continue;
				}
			}
		}

		// Sort the list of assets by status.
		Collections.sort(allCurrentAssets, new Comparator<Asset>() {
			@Override
			public int compare(Asset a1, Asset a2) {
				if (a1.status == a2.status)
					return 0;
				return a1.status < a2.status ? 1 : -1;
			}
		});

		return allCurrentAssets;

	}

	/**
	 * getAllTips() returns a list of static tips stored in the database. These
	 * tips are a demo representation of tips which an insurance agent or
	 * insurance company would send out occasionally and include updates for
	 * weather, location, and incentive. This method timestamps the tips
	 * starting at the current time and moving back one hour per static tip.
	 * This is because the cloudant tips are stored with a timeDelta so for demo
	 * purposes we can always present tips that appear recent.
	 *
	 * @return allTips the list of static tips from the database timestamped
	 *         from the current time and decrementing by one hour per tip.
	 */
	public List<Tip> getAllTips(String userId) {
		List<Tip> allTips = perchDBService.getAllTips(userId);

		long curTime = System.currentTimeMillis();
		System.out.println(curTime);
		for (Tip tip : allTips) {
			// int rand = ThreadLocalRandom.current().nextInt(1,3);
			curTime = curTime - (tip.getTimeDelta() * Constants.ONE_HOUR_INMILLIS);
			tip.setTimestamp(curTime);
		}

		return allTips;
	}

	/**
	 * getAllHistoricalData() returns the historicalData (displayed in the asset
	 * detail) for a given deviceClassId. This method queries for the data using
	 * the PerchDBService, and then this method timestamps the data with the
	 * appropriate list.
	 *
	 * @param deviceClassId
	 *            is the classId associated with the specific device type. (i.e.
	 *            deviceClassId : "10001" is a Water Meter)
	 * @return allHistoricalData is a list of three lists index 0 : all of the
	 *         data for the day tab in the graph. The time unit for these data
	 *         points is hours, and each data point is 3 hours apart starting at
	 *         current tiallHistoricalData
	 */
	public List<List<HistoricalData>> getAllHistoricalData(String deviceClassId) {

		int hoursReturned = 16;
		int daysReturned = 14;
		int weeksReturned = 10;

		List<HistoricalData> hourHistoricalData = perchDBService.getHistoricalDataForDevice(
				deviceClassId, "hour", 0, hoursReturned);
		List<HistoricalData> dayHistoricalData = perchDBService.getHistoricalDataForDevice(
				deviceClassId, "day", 0, daysReturned);
		List<HistoricalData> weekHistoricalData = perchDBService.getHistoricalDataForDevice(
				deviceClassId, "week", 0, weeksReturned);

		List<List<HistoricalData>> allHistoricalData = new ArrayList<List<HistoricalData>>();
		allHistoricalData.add(hourHistoricalData);
		allHistoricalData.add(dayHistoricalData);
		allHistoricalData.add(weekHistoricalData);

		return HistoricalDataUtils.timestampHistoricalData(8, allHistoricalData);

	}

	/**
	 * getAllNotifications() returns a list of notifications for the given
	 * devicePin and deviceClassId. This method first queries for all of the
	 * live notifications and then queries for the static notifications stored
	 * in the database. We have the static notifications, for demo purposes.
	 *
	 * NOTE: If live notifications are available, then the static notifications
	 * will be timestamped one hour past the last notification and continue
	 * going back one hour each static notification.
	 *
	 * @param devicePin
	 *            is the 4 digit pin associated with the active IoT simulator.
	 * @param deviceClassId
	 *            is the classId associated with the specific device type. (i.e.
	 *            deviceClassId : "10001" is a Water Meter)
	 * @return If live notifications are available for the given devicePin then
	 *         the returned list contains all live notifications followed by
	 *         static notifications. If no live notifications are present for
	 *         the given devicePin, then the returned list contains static
	 *         notifications for demo purposes.
	 */
	public List<Notification> getAllNotifications(String devicePin, String deviceClassId) {

		List<Notification> liveNotifications = perchDBService.getAllLiveNotifications(devicePin,
				deviceClassId);
		List<Notification> staticNotifications = perchDBService
				.getAllStaticNotifications(deviceClassId);
		List<DeviceClass> deviceClasses = perchDBService.getDeviceClasses(null);

		List<Notification> allNotifications = Utilities.combineLiveAndStaticNotifications(
				liveNotifications, staticNotifications);
		Utilities.setRecommendedPartners(allNotifications, deviceClasses);

		return allNotifications;
	}

	/**
	 * For testing only
	 *
	 * @param args
	 */
	public static void main(String... args) {
		PerchAdapter adapter = PerchAdapter.getInstance();
		List<String> adfs = new ArrayList<String>();
		adfs.add("10001");
		adfs.add("10002");
		adfs.add("10003");
		System.out.println(adapter.getCurrentNotification("10001", "0000"));
		// System.out.println(adapter.getAssetOverview("20001", adfs, "0216",
		// "en_US"));
		// System.out.println(adapter.getAllTips("20001"));
		System.out.println("done");

	}
}
