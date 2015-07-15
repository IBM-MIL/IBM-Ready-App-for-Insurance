package com.ibm.mil.ready.app.perch.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.google.gson.reflect.TypeToken;
import com.ibm.mil.ready.app.perch.PerchAdapter;
import com.ibm.mil.ready.app.perch.model.Asset;
import com.ibm.mil.ready.app.perch.model.DeviceClass;
import com.ibm.mil.ready.app.perch.model.SensorData;
import com.ibm.mil.ready.app.perch.model.Tip;
import com.ibm.mil.ready.app.perch.tests.utils.TestUtilities;
import com.ibm.mil.ready.app.perch.utils.Constants;
import com.ibm.mil.ready.app.perch.utils.Utilities;
import com.ibm.mil.util.JsonDataReader;

public class PerchAdapterTest {

	PerchAdapter perchAdapter;
	List<SensorData> localCurrentSensorDataList;
	List<Asset> localCurrentAssetList;
	List<DeviceClass> localDeviceClassList;
	List<Tip> localTipList;

	@Before
	public void setUp() throws Exception {
		perchAdapter = PerchAdapter.getInstance();

		TypeToken<List<SensorData>> sensorDataToken = new TypeToken<List<SensorData>>() {
		};
		List<SensorData> allSensorData = JsonDataReader.getCollection(sensorDataToken,
				Constants.SENSORDATA_JSONFILENAME);

		TypeToken<List<DeviceClass>> deviceClassToken = new TypeToken<List<DeviceClass>>() {
		};

		localDeviceClassList = JsonDataReader.getCollection(deviceClassToken,
				Constants.DEVICECLASS_JSONFILENAME);

		localCurrentSensorDataList = TestUtilities.getCurrentSensorDataForEachDeviceClass(
				allSensorData, localDeviceClassList.size() - 1);

		localCurrentAssetList = Utilities.createAssetList(localDeviceClassList,
				localCurrentSensorDataList);

		TypeToken<List<Tip>> tipToken = new TypeToken<List<Tip>>() {
		};

		localTipList = JsonDataReader.getCollection(tipToken, Constants.TIP_JSONFILENAME);
	}

	@Test
	public void testGetAllTips() {
		assertNotNull(localTipList);
		// [1]
		List<Tip> remoteTips = perchAdapter.getAllTips("20001");
		assertTrue(!remoteTips.isEmpty());
		for (Tip localTip : localTipList) {
			assertNotNull(localTip);
			for (Tip remoteTip : remoteTips) {
				if (localTip.getId().equals(remoteTip.getId())) {
					TestUtilities.assertTipsEqual(localTip, remoteTip);
					break;
				}
			}
		}

	}

	// @Test
	// public void testGetAllCurrentAssetData() {
	// List<String> deviceClassIds = new ArrayList<String>();
	// for (DeviceClass localDeviceClass : localDeviceClassList) {
	// deviceClassIds.add(localDeviceClass.getId());
	// }
	//
	// List<Asset> remoteCurrentAssetData =
	// perchAdapter.getAllCurrentAssetData(deviceClassIds,
	// localCurrentSensorDataList.get(0).getDevicePin(),
	// Constants.DEFAULT_LOCALE);
	//
	// for (Asset localAsset : localCurrentAssetList) {
	// for (Asset remoteAsset : remoteCurrentAssetData) {
	// if (localAsset.deviceClassId.equals(remoteAsset.deviceClassId)) {
	// TestUtilities.assertAssetsEqual(localAsset, remoteAsset);
	// }
	// }
	// }
	// }

	// @Test
	// public void testGetAllCurrentAssetDataIsSorted() {
	// List<String> deviceClassIds = new ArrayList<String>();
	// for (DeviceClass localDeviceClass : localDeviceClassList) {
	// deviceClassIds.add(localDeviceClass.getId());
	// }
	//
	// List<Asset> remoteCurrentAssetData =
	// perchAdapter.getAllCurrentAssetData(deviceClassIds,
	// localCurrentSensorDataList.get(0).getDevicePin(),
	// Constants.DEFAULT_LOCALE);
	//
	// long prevStatus = 2;
	// for (Asset remoteAsset : remoteCurrentAssetData) {
	// assertTrue(remoteAsset.status <= prevStatus);
	// prevStatus = remoteAsset.status;
	// }
	// }

	// @Test
	// public void testNullParamsGetAllCurrentAssetData() {
	// List<Asset> assetList = perchAdapter.getAllCurrentAssetData(null, null,
	// null);
	// assertTrue(assetList.isEmpty());
	// }

}
