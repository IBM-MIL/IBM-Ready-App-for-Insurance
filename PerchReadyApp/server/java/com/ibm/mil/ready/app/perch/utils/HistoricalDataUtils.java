package com.ibm.mil.ready.app.perch.utils;

import java.util.Calendar;
import java.util.List;
import java.util.logging.Logger;

import com.ibm.mil.ready.app.perch.model.HistoricalData;

public final class HistoricalDataUtils {

	private final static Logger LOGGER = Logger.getLogger(HistoricalDataUtils.class.getName());

	private HistoricalDataUtils() {
		throw new AssertionError("Utilities is non-instantiable");
	}

	/**
	 * timestampHistoricalData() takes a given list of historical data and
	 * timestamps all of the values using the current time and decrementing the
	 * time by the timeDelta stored in the historical data objects and the
	 * timeUnit.
	 *
	 * @param pointsPerDay
	 * @return
	 */
	public static List<List<HistoricalData>> timestampHistoricalData(int pointsPerDay,
			List<List<HistoricalData>> allData) {

		List<List<HistoricalData>> timestampedData = allData;

		long startTime = HistoricalDataUtils.roundTime(System.currentTimeMillis());
		long timeDecrement = 10800000;

		for (List<HistoricalData> curList : timestampedData) {
			for (HistoricalData curData : curList) {
				long newTimestamp = 0;
				int curTimeDelta = (int) curData.getTimeDelta();
				switch (curData.getTimeUnit()) {
				case "hour":
					newTimestamp = startTime - (curTimeDelta * timeDecrement);
					curData.setTimestamp(newTimestamp);
					break;
				case "day":
					newTimestamp = startTime
					- ((curTimeDelta + 1) * timeDecrement * Constants.POINTS_PER_DAY);
					curData.setTimestamp(newTimestamp);
					break;
				case "week":
					newTimestamp = startTime
					- ((curTimeDelta + 1) * timeDecrement * Constants.POINTS_PER_WEEK);
					curData.setTimestamp(newTimestamp);
					break;
				default:
					LOGGER.info("timestampHistoricalData() : There was a historical data that did "
							+ "not have a timeUnit that matched the allowed timeUnits.");
					break;
				}
			}
		}

		return timestampedData;
	}

	/**
	 * printPoints is a method that prints just the timeDelta and value. It is
	 * used for debugging purposes when creating random data. It prints in the
	 * format: "timeDelta , value"
	 *
	 * @param pointDescription
	 *            the description printed before the list of points.
	 * @param points
	 *            the list of historical data to print in the format
	 *            "timeDelta , value"
	 */
	public static void printPoints(String pointDescription, List<HistoricalData> points) {
		System.out.println("----------" + pointDescription + "----------");
		for (HistoricalData cur : points) {
			System.out.println(cur.getTimeDelta() + " , " + cur.getValue());
		}
		System.out.println("--------------------");

	}

	/**
	 * roundTime() takes a timestamp and rounds the time back to the nearest 3,
	 * 6, 9, 12 interval in the day. For instance if a timestamp for 11:17am was
	 * passed in this method would return the timestamp 9:00am.
	 *
	 * @param currentTime
	 *            the current time the user wishes to round down.
	 * @return the nearest 3,6,9,12 hr interval from the currentTime passed
	 *         time.
	 */
	public static long roundTime(long currentTime) {
		System.out.println("HistoricalDataUtils : currentTime " + currentTime);

		Calendar cal = Calendar.getInstance();
		cal.setTimeInMillis(currentTime);
		cal.set(Calendar.MINUTE, 0);
		cal.set(Calendar.SECOND, 0);

		int hoursToSubtract = (cal.get(Calendar.HOUR)) % 3;
		long roundedTime = cal.getTimeInMillis() - (hoursToSubtract * 3600000);

		cal.setTimeInMillis(roundedTime);
		return cal.getTimeInMillis();
	}

	/**
	 * For testing only
	 *
	 * @param args
	 */
	public static void main(String... args) {
		System.out.println("done!");
	}
}
