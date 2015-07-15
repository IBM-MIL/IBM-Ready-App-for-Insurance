package com.ibm.mil.ready.app.perch.tests.utils;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import com.ibm.mil.cloudant.model.CloudantObject;
import com.ibm.mil.ready.app.perch.model.Asset;
import com.ibm.mil.ready.app.perch.model.DeviceClass;
import com.ibm.mil.ready.app.perch.model.PerchUser;
import com.ibm.mil.ready.app.perch.model.SensorData;
import com.ibm.mil.ready.app.perch.model.Tip;
import com.ibm.mil.ready.app.perch.model.TipAction;

public final class TestUtilities {

	private TestUtilities() {
		throw new AssertionError("Utilities is non-instantiable");
	}

	public static void assertDeviceClassesEqual(DeviceClass d1, DeviceClass d2) {
		assertNotNull(d1);
		assertNotNull(d2);
		assertEquals(d1.getId(), d2.getId());
		assertEquals(d1.getName(), d2.getName());
		assertEquals(d1.getPartName(), d2.getPartName());
		assertEquals(d1.getType(), d2.getType());
		assertEquals(d1.getSerialNumber(), d2.getSerialNumber());
		if (d1.getMaxMessage() != null && d2.getMaxMessage() != null) {
			assertEquals(d1.getMaxThreshold(), d2.getMaxThreshold());
			assertEquals(d1.getMaxMessage(), d2.getMaxMessage());
		}
		if (d1.getMinMessage() != null && d2.getMinMessage() != null) {
			assertEquals(d1.getMinThreshold(), d2.getMinThreshold());
			assertEquals(d1.getMinMessage(), d2.getMinMessage());
		}
		assertEquals(d1.getNormalMessage(), d1.getNormalMessage());
		assertEquals(d1.isEnabled(), d2.isEnabled());
		assertEquals(d1.getAverageUsage(), d1.getAverageUsage());
		assertEquals(d1.getAverageUsageUnit(), d2.getAverageUsageUnit());
	}

	public static void assertSensorDataEqual(SensorData s1, SensorData s2) {
		assertNotNull(s1);
		assertNotNull(s2);
		assertEquals(s1.getDeviceClassId(), s2.getDeviceClassId());
		assertEquals(s1.getDevicePin(), s2.getDevicePin());
		assertEquals(s1.getId(), s2.getId());
		assertEquals(s1.getStatus(), s2.getStatus());
		assertEquals(s1.getTime(), s2.getTime());
		assertEquals(s1.getType(), s2.getType());
		assertEquals(s1.getUnits(), s2.getUnits());
		assertEquals(s1.getValue(), s2.getValue());
	}

	public static void assertUsersEqual(PerchUser u1, PerchUser u2) {
		assertNotNull(u1);
		assertNotNull(u2);
		assertEquals(u1.getId(), u2.getId());
		assertEquals(u1.getFirstName(), u2.getFirstName());
		assertEquals(u1.getLastName(), u2.getLastName());
		assertEquals(u1.getLocale(), u2.getLocale());
		assertEquals(u1.getUsername(), u2.getUsername());
		assertEquals(u1.getPassword(), u2.getPassword());
		assertTrue(u1.getDeviceClassIds().get(0).equals(u2.getDeviceClassIds().get(0)));
		assertTrue(u1.getDeviceClassIds().get(1).equals(u2.getDeviceClassIds().get(1)));
		assertEquals(u1.getType(), u2.getType());
	}

	public static void assertAssetsEqual(Asset a1, Asset a2) {
		assertNotNull(a1);
		assertNotNull(a2);
		assertEquals(a1.deviceClassId, a2.deviceClassId);
		assertEquals(a1.devicePin, a2.devicePin);
		assertEquals(a1.name, a2.name);
		assertEquals(a1.serialNumber, a2.serialNumber);
		assertEquals(a1.status, a2.status);
		assertEquals(a1.time, a2.time);
		assertEquals(a1.units, a2.units);
		assertEquals(a1.value, a2.value);
		assertEquals(a1.age, a2.age);
		assertEquals(a1.enabled, a2.enabled);
		assertEquals(a1.partName, a2.partName);
		assertEquals(a1.maxThreshold, a2.maxThreshold);
		assertEquals(a1.averageUsage, a2.averageUsage);
		assertEquals(a1.averageUsageUnit, a2.averageUsageUnit);
	}

	public static void assertTipsEqual(Tip t1, Tip t2) {
		assertNotNull(t1);
		assertNotNull(t2);
		TestUtilities.assertCloudantObjectsEquals(t1, t2);
		assertEquals(t1.getTitle(), t2.getTitle());
		assertEquals(t1.getDetail(), t2.getDetail());
		assertEquals(t1.getTipType(), t2.getTipType());
		assertEquals(t1.isRead(), t2.isRead());
		assertEquals(t1.isHighPriority(), t2.isHighPriority());
		assertEquals(t1.getTimeDelta(), t2.getTimeDelta());
		assertEquals(t1.getUserId(), t2.getUserId());
		assertEquals(t1.getDeviceClassId(), t2.getDeviceClassId());
		TestUtilities.assertTipActionsEquals(t1.getTipAction(), t2.getTipAction());
	}
	
	public static void assertCloudantObjectsEquals(CloudantObject c1, CloudantObject c2) {
		assertEquals(c1.getId(), c2.getId());
		assertEquals(c1.getType(), c2.getType());
	}
	
	public static void assertTipActionsEquals(TipAction t1, TipAction t2) {
		
	}

	/**
	 * 
	 * @param allSensorData
	 * @param totalDeviceClasses
	 * @return
	 */
	public static List<SensorData> getCurrentSensorDataForEachDeviceClass(
			List<SensorData> allSensorData, int totalDeviceClasses) {

		// Sort the list of assets by status.
		Collections.sort(allSensorData, new Comparator<SensorData>() {
			public int compare(SensorData s1, SensorData s2) {
				if (s1.getTime() == s2.getTime())
					return 0;
				return s1.getTime() < s2.getTime() ? 1 : -1;
			}
		});

		List<SensorData> currentSensorData = new ArrayList<SensorData>();
		for (int i = 0; i < totalDeviceClasses; i++) {
			currentSensorData.add(allSensorData.get(i));
		}

		return currentSensorData;
	}

}
