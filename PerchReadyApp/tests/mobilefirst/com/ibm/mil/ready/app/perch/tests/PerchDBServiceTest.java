package com.ibm.mil.ready.app.perch.tests;

import java.util.ArrayList;
import java.util.List;

import junit.framework.TestCase;

import org.junit.Test;

import com.google.gson.reflect.TypeToken;
import com.ibm.mil.ready.app.perch.model.DeviceClass;
import com.ibm.mil.ready.app.perch.model.SensorData;
import com.ibm.mil.ready.app.perch.service.PerchDBService;
import com.ibm.mil.ready.app.perch.tests.utils.TestUtilities;
import com.ibm.mil.ready.app.perch.utils.Constants;
import com.ibm.mil.util.JsonDataReader;

public class PerchDBServiceTest extends TestCase {

	List<DeviceClass> localDBDeviceClasses;
	List<DeviceClass> remoteDBDeviceClasses;

	List<SensorData> allLocalSensorDataList;
	List<SensorData> allLocalCurrentSensorData;
	PerchDBService perchDBService;

	@Override
	public void setUp() {
		remoteDBDeviceClasses = new ArrayList<DeviceClass>();
		perchDBService = new PerchDBService();

		TypeToken<List<SensorData>> sensorDataToken = new TypeToken<List<SensorData>>() {
		};
		allLocalSensorDataList = JsonDataReader.getCollection(sensorDataToken,
				Constants.SENSORDATA_JSONFILENAME);

		TypeToken<List<DeviceClass>> deviceClassToken = new TypeToken<List<DeviceClass>>() {
		};
		localDBDeviceClasses = JsonDataReader.getCollection(deviceClassToken,
				Constants.DEVICECLASS_JSONFILENAME);

		allLocalCurrentSensorData = TestUtilities.getCurrentSensorDataForEachDeviceClass(
				allLocalSensorDataList, localDBDeviceClasses.size() - 1);
	}

	@Test
	public void testGetAllDeviceClasses() {
		// getDeviceClasses returns all the device classes if null is passed in.
		// Currently we have 3 sensors (water meter, air conditioner, and sewage
		// system.)
		// We should get a list of these 3 sensors.
		remoteDBDeviceClasses = perchDBService.getDeviceClasses(null);
		assertEquals(4, remoteDBDeviceClasses.size());

		// Make sure that what we got from the remote db is what we have in the
		// local db
		for (DeviceClass localDeviceClass : localDBDeviceClasses) {
			for (DeviceClass remoteDeviceClass : remoteDBDeviceClasses) {
				if (localDeviceClass.getId().equals(remoteDeviceClass.getId())) {
					TestUtilities.assertDeviceClassesEqual(localDeviceClass, remoteDeviceClass);
				}
			}
		}
	}

	@Test
	public void testGetSingleDeviceClass() {
		// getDeviceClasses returns a single device class given the device Id.
		// This test asserts that the method will return a single deviceClass if
		for (DeviceClass localDeviceClass : localDBDeviceClasses) {
			remoteDBDeviceClasses = perchDBService.getDeviceClasses(localDeviceClass.getId());
			assertEquals(remoteDBDeviceClasses.size(), 1);
			TestUtilities.assertDeviceClassesEqual(localDeviceClass, remoteDBDeviceClasses.get(0));
		}
	}

	@Test
	public void testGetDeviceClassesNull() {
		remoteDBDeviceClasses = perchDBService.getDeviceClasses(null);
		assertNotNull(remoteDBDeviceClasses);
	}

	@Test
	public void testGetCurrentSensorData() {
		for (DeviceClass localDeviceClass : localDBDeviceClasses) {
			if (localDeviceClass.isEnabled()) {
				for (SensorData localSensorData : allLocalCurrentSensorData) {
					if (localSensorData.getDeviceClassId().equals(localDeviceClass.getId())) {
						SensorData remoteSensorData = perchDBService.getCurrentSensorData(
								localDeviceClass.getId(), localSensorData.getDevicePin());
						TestUtilities.assertSensorDataEqual(localSensorData, remoteSensorData);
					}
				}
			}
		}
	}

	@Test
	public void testGetAllCurrentSensorData() {

		List<SensorData> remoteCurrentSensorData = perchDBService.getAllCurrentSensorData(
				allLocalCurrentSensorData.get(0).getDevicePin(), Constants.DEFAULT_LOCALE);

		for (SensorData localSensorData : allLocalCurrentSensorData) {
			for (SensorData remoteSensorData : remoteCurrentSensorData) {
				if (remoteSensorData.getId().equals(localSensorData.getId())) {
					TestUtilities.assertSensorDataEqual(localSensorData, remoteSensorData);
					break;
				}
			}
		}

	}

}
