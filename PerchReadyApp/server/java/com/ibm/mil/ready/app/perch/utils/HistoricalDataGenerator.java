/*
 * Licensed Materials - Property of IBM © Copyright IBM Corporation 2015. All
 * Rights Reserved. This sample program is provided AS IS and may be used,
 * executed, copied and modified without royalty payment by customer (a) for its
 * own instruction and study, (b) in order to develop applications designed to
 * run with an IBM product, either for customer's own internal use or for
 * redistribution by customer, as part of such an application, in customer's own
 * products.
 */

/**
 *
 */
package com.ibm.mil.ready.app.perch.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import com.ibm.mil.ready.app.perch.model.HistoricalData;

/**
 * HistoricalDataGenerator() this class uses a random number generator to create
 * fake historical sensor data. This data is used for demo purposes in the asset
 * detail portion of our app which displays a historical graph with a day, week,
 * and month tab for the specific sensor data.
 *
 * @author tannerpreiss
 *
 */
public final class HistoricalDataGenerator {

	private HistoricalDataGenerator() {
		throw new AssertionError("Utilities is non-instantiable");
	}

	/**
	 * setIds() takes a list of historical data and sets cloudant '._id' and
	 * 'type' so that the HistoricalData can be a valid cloudant object.
	 *
	 * @param allData
	 *            the list of historical data.
	 * @param deviceClassId
	 *            the deviceClassId corresponding to the list of data passed in.
	 * @param startId
	 *            the start ._id for the list of data.
	 * @return allData the list of historical data but now with valid ._id,
	 *         type, and deviceClassId.
	 */
	public static List<List<HistoricalData>> setIds(List<List<HistoricalData>> allData,
			String deviceClassId, int startId) {

		int curId = startId;
		for (int i = 0; i < allData.size(); i++) {
			for (HistoricalData cur : allData.get(i)) {
				cur.setId("" + curId + "");
				cur.setType("historical_data");
				cur.setDeviceClassId(deviceClassId);
				curId++;
			}
		}
		return allData;
	}

	/**
	 * createRandomData() creates a list of three lists of historical data. The
	 * first list contains historicaldata that represent hours in a day. the
	 * second list stores the average value for each day. The third list
	 * represents the average value for a given week. This method creates
	 * historicalData for demo purposes and does so by generating random data
	 * that would mock a real IoT sensor.
	 *
	 * @param totalDays
	 *            the total number of days of random data to create.
	 * @param pointsPerDay
	 *            the total number of points in a day.
	 * @param maxThreshold
	 *            the maximum threshold for the given sensor.
	 * @param baseValue
	 *            the starting value for the sensor data.
	 * @return a list containing three lists which represent historical data for
	 *         hours, days, and weeks.
	 */
	public static List<List<HistoricalData>> createRandomData(int totalDays, int pointsPerDay,
			int maxThreshold, int baseValue) {
		List<List<HistoricalData>> allRandomData = new ArrayList<List<HistoricalData>>();

		List<HistoricalData> allDayPoints = new ArrayList<HistoricalData>();
		List<HistoricalData> allWeekPoints = new ArrayList<HistoricalData>();
		List<HistoricalData> allMonthPoints = new ArrayList<HistoricalData>();

		Random rand = new Random();
		int prevY = baseValue;
		int runningDayAvg = 0;
		int runningWeekAvg = 0;

		for (int x = 0; x < (totalDays * pointsPerDay); x++) {

			HistoricalData newPoint = HistoricalDataGenerator.createRandomPoint(x, prevY,
					baseValue, maxThreshold, rand);
			newPoint.setTimeUnit("hour");

			/** calculate day average */
			if ((x + 1) % Constants.POINTS_PER_DAY == 0) {
				int currentDayIndex = x / Constants.POINTS_PER_DAY;

				HistoricalData newDay = new HistoricalData(currentDayIndex, runningDayAvg
						/ (Constants.POINTS_PER_DAY));
				newDay.setTimeUnit("day");

				allWeekPoints.add(newDay);
				runningWeekAvg += runningDayAvg;
				runningDayAvg = 0;
			}
			/** calculate week average */
			if ((x + 1) % (Constants.POINTS_PER_WEEK) == 0) {
				int currentWeekIndex = x / Constants.POINTS_PER_WEEK;
				HistoricalData newWeek = new HistoricalData(currentWeekIndex, runningWeekAvg
						/ Constants.POINTS_PER_WEEK);
				newWeek.setTimeUnit("week");
				allMonthPoints.add(newWeek);
				runningWeekAvg = 0;
			}

			allDayPoints.add(newPoint);
			runningDayAvg += newPoint.getValue();
			prevY = (int) newPoint.getValue();
		}

		allRandomData.add(allDayPoints);
		allRandomData.add(allWeekPoints);
		allRandomData.add(allMonthPoints);

		return allRandomData;
	}

	/**
	 * createRandomPoint() creates a random HistoricalData point but it ensures
	 * that the new point is either increasing up to the maxThreshold or
	 * decreasing randomly to the baseValue. This means that we have a graph
	 * that increases and decreases at random increments.
	 *
	 * @param curX
	 *            the current x value for for the HistoricalData point. This
	 *            value is used as the timeDelta when storing in cloudant.
	 * @param prevY
	 *            the previous sensorData value which is used to determine
	 *            whether to increase or decrease the point that will be
	 *            returned in this method.
	 * @param baseValue
	 *            the baseValue for the given sensor, this is the value at which
	 *            the sensordata starts and should not decrement below. For
	 *            instance the sensor data for sewer system usage should never
	 *            go below 0% and so the baseValue would be 0.
	 * @param maxThreshold
	 * @param rand
	 * @return
	 */
	public static HistoricalData createRandomPoint(int curX, int prevY, int baseValue,
			int maxThreshold, Random rand) {
		int max = 0;
		int min = 0;
		int y = 0;

		if (prevY < maxThreshold) {
			min = prevY;
			max = (int) (1.6 * prevY);
		} else {
			min = baseValue;
			max = prevY;
		}

		y = min + rand.nextInt(max - min + 1);

		return new HistoricalData(curX, y);
	}

	/**
	 * For testing only
	 *
	 * @param args
	 */
	public static void main(String... args) {
		List<List<HistoricalData>> xbox = HistoricalDataGenerator.createRandomData(120, 8, 6, 2);
		HistoricalDataGenerator.setIds(xbox, "10003", 62194);
		System.out.println(xbox.get(0));
		System.out.println(xbox.get(1));
		System.out.println(xbox.get(2));
		System.out.println("done!");
	}
}
