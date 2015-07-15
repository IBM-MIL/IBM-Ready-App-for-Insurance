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

public class Constants {
	/******* Constants for the CloudantService class ******/
	public final static String ACCOUNT_KEY = "CLOUDANT_ACCOUNT";
	public final static String USERNAME_KEY = "CLOUDANT_USERNAME";
	public final static String PASSWORD_KEY = "CLOUDANT_PASSWORD";
	public final static String DB_KEY = "CLOUDANT_DB_NAME";
	public final static String MAIN_DESIGN_DOC = "library";
	// an empty string will sort before any string with any actual characters in
	// it.
	public final static String LOWER_STRING_BOUND = "";

	public final static String DEFAULT_LOCALE = "DEFAULT_LOCALE";

	/******* Constants for Utilities ******/
	public final static String MSG1_KEY = "MSG0001";
	public final static String MSG2_KEY = "MSG0002";
	public final static String MSG3_KEY = "MSG0003";
	public final static String MSG4_KEY = "MSG0004";
	public final static String MSG5_KEY = "MSG0005";

	public final static int DEVICE_PIN_LENGTH = 4;
	public final static int DEVICE_CLASS_ID_LENGTH = 5;

	public final static long ONE_HOUR_INMILLIS = 3600000;

	public final static long NORMAL_STATUS = 0;

	// JSON data files
	public static final String DESIGN_DOCUMENTS_JSONFILENAME = "resources/db/design_document.json";
	public static final String USER_JSONFILENAME = "resources/db/perch_users.json";
	public static final String DEVICECLASS_JSONFILENAME = "resources/db/perch_device_classes.json";
	public static final String DEVICEINSTANCE_JSONFILENAME = "resources/db/perch_device_instances.json";
	public static final String SENSORDATA_JSONFILENAME = "resources/db/perch_sensor_data.json";
	public static final String TIP_JSONFILENAME = "resources/db/perch_tips.json";
	public static final String HISTORICALNOTIFICATION_JSONFILENAME = "resources/db/perch_historical_notifications.json";
	public static final String HISTORICALDATA_10001_JSONFILENAME = "resources/db/perch_historical_data_10001.json";
	public static final String HISTORICALDATA_10002_JSONFILENAME = "resources/db/perch_historical_data_10002.json";
	public static final String HISTORICALDATA_10003_JSONFILENAME = "resources/db/perch_historical_data_10003.json";

	/** For HistoricalDataUtils and HistoricalDataGenerator */
	public static final int DAYS_PER_WEEK = 7;
	public static final int POINTS_PER_DAY = 8;
	public static final int POINTS_PER_WEEK = POINTS_PER_DAY * DAYS_PER_WEEK;

}
