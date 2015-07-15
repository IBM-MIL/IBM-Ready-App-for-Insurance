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

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import com.ibm.mil.cloudant.CloudantService;
import com.ibm.mil.cloudant.model.User;
import com.ibm.mil.ready.app.perch.model.DeviceClass;
import com.ibm.mil.ready.app.perch.model.HistoricalData;
import com.ibm.mil.ready.app.perch.model.Notification;
import com.ibm.mil.ready.app.perch.model.SensorData;
import com.ibm.mil.ready.app.perch.model.Tip;
import com.ibm.mil.ready.app.perch.utils.Constants;
import com.ibm.mil.ready.app.perch.utils.HistoricalDataGenerator;
import com.ibm.mil.util.JsonDataReader;

/**
 * PerchAdapter is a class that contains methods to manage multiple services
 * provided in the Mobile First Platform suite. Currently the PerchAdapter is
 * using a PerchDBService class to query a cloudant database. The methods in
 * this class will be accessed by the javascript PerchAdapter.
 *
 * @author tannerpreiss
 *
 */
public final class DBSetupAdapter {
	private static DBSetupAdapter dbSetupAdapter;
	private final static Logger LOGGER = Logger.getLogger(DBSetupAdapter.class.getName());

	public static DBSetupAdapter getInstance() {
		synchronized (DBSetupAdapter.class) {
			if (dbSetupAdapter == null) {
				dbSetupAdapter = new DBSetupAdapter();
			}
		}
		return dbSetupAdapter;
	}

	// private constructor to ensure it remains a singleton.
	private DBSetupAdapter() {
		// currently does nothing.
	}

	/**
	 * resetDatabase() connects to the cloudant instance specified in the
	 * app.properties file and first deletes all documents except for design
	 * documents. This method then adds all of the static documents stored in
	 * json files under /resources/db.
	 *
	 * @return (true) database reset was successful (false) reset was
	 *         unsuccessful
	 */
	public boolean resetDatabase() {
		CloudantService.getInstance().deleteRecords();
		boolean successful = true;
		List<String> keys = new ArrayList<String>();
		successful = DBSetupAdapter.getInstance().saveDataToDB(Constants.DESIGN_DOCUMENTS_JSONFILENAME, keys);
		successful = DBSetupAdapter.getInstance().saveToDB(Constants.SENSORDATA_JSONFILENAME,
				SensorData.class);
		successful = DBSetupAdapter.getInstance().saveToDB(
				Constants.HISTORICALNOTIFICATION_JSONFILENAME, Notification.class);
		successful = DBSetupAdapter.getInstance().saveToDB(Constants.DEVICECLASS_JSONFILENAME,
				DeviceClass.class);
		successful = DBSetupAdapter.getInstance().saveToDB(Constants.USER_JSONFILENAME, User.class);
		successful = DBSetupAdapter.getInstance().saveToDB(Constants.TIP_JSONFILENAME, Tip.class);
		successful = DBSetupAdapter.getInstance().saveToDB(
				Constants.HISTORICALDATA_10001_JSONFILENAME, HistoricalData.class);
		successful = DBSetupAdapter.getInstance().saveToDB(
				Constants.HISTORICALDATA_10002_JSONFILENAME, HistoricalData.class);
		successful = DBSetupAdapter.getInstance().saveToDB(
				Constants.HISTORICALDATA_10003_JSONFILENAME, HistoricalData.class);
		return successful;
	}

	/**
	 * generateNewHistoricalData() will generate all new historical static data
	 * and save it to the database. This method does not save the files locally.
	 *
	 * @return the total number of docs saved.
	 */
	public int generateNewHistoricalData() {
		int startId = 60000;
		int docsForDevice1 = DBSetupAdapter.getInstance().generateAndSaveHistoricalData("10001",
				120, 8, 90, 60000, 20);
		int docsForDevice2 = DBSetupAdapter.getInstance().generateAndSaveHistoricalData("10002",
				120, 8, 50, startId + docsForDevice1, 20);
		int docsForDevice3 = DBSetupAdapter.getInstance().generateAndSaveHistoricalData("10003",
				120, 8, 5, startId + docsForDevice1 + docsForDevice2, 1);

		return docsForDevice1 + docsForDevice2 + docsForDevice3;
	}

	/**
	 * generateAndSaveHistoricalData() generates historical data for a specific
	 * deviceClassId.
	 *
	 * @param deviceClassId
	 * @param totalDays
	 * @param pointsPerDay
	 * @param maxThreshold
	 * @return
	 */
	public int generateAndSaveHistoricalData(String deviceClassId, int totalDays, int pointsPerDay,
			int maxThreshold, int startId, int baseValue) {
		int totalDocsSaved = 0;
		List<List<HistoricalData>> allData = HistoricalDataGenerator.setIds(HistoricalDataGenerator
				.createRandomData(totalDays, pointsPerDay, maxThreshold, baseValue), deviceClassId,
				startId);
		for (List<HistoricalData> cur : allData) {
			CloudantService.getInstance().getDatabase().bulk(cur);
			totalDocsSaved += cur.size();
		}
		return totalDocsSaved;
	}

	/**
	 * saveToDB() takes a jsonFilename and a java object .class and saves all
	 * the json objects in the provided file to the current cloudant instance,
	 * as specified in app.properties.
	 *
	 * @param jsonFilename
	 *            the name of the local json file which all json objects in the
	 *            file will be saved as docs in cloudant. The json file must be
	 *            located under /resources directory of the java project
	 * @param castClass
	 * @return
	 */
	public <T> boolean saveToDB(String jsonFilename, Class<T> castClass) {
		return saveDataToDB(jsonFilename, this.getAllLongFields(castClass));
	}

	/**
	 * getAllLongFields() uses Java Reflection to find all the fields in a class
	 * of type long. When it finds a field of type long: the field name is added
	 * to the list of strings returned from the method.
	 *
	 * @param castClass
	 *            the .class of a java object. For example:
	 *            getAllLongFields(User.class)
	 * @return fieldsWithTypeLong a list of the field names for the fields of
	 *         type long.
	 */
	private <T> List<String> getAllLongFields(Class<T> castClass) {

		ArrayList<String> fieldsWithTypeLong = new ArrayList<String>();
		Field[] fields = castClass.getDeclaredFields();
		for (Field f : fields) {
			if (f.getType().equals(long.class)) {
				fieldsWithTypeLong.add(f.getName());
			}
		}
		return fieldsWithTypeLong;
	}

	/**
	 *
	 * @param filename
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	private boolean saveDataToDB(String filename, List<String> keysToCast) {
		List<Map> jsonObjectList = JsonDataReader.castDoublesToLongs(filename, keysToCast);

		if (jsonObjectList != null) {
			for (Map jsonObject : jsonObjectList) {
				String id = (String) jsonObject.get("_id");
				LOGGER.info("ADD: Record with the following _id was added: " + id);
				CloudantService.getInstance().getDatabase().save(jsonObject);
			}
			return true;
		}
		return false;
	}

	/**
	 * For testing only
	 *
	 * @param args
	 */
	public static void main(String... args) {
		if (DBSetupAdapter.getInstance().resetDatabase()) {
			LOGGER.info(DBSetupAdapter.class.getName() + ": RESET Database successful");
		} else {
			LOGGER.warning(DBSetupAdapter.class.getName() + ": RESET Database unsucessful");
		}

		System.out.println("done!");
	}
}
