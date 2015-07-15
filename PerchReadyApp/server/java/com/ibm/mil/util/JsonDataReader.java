package com.ibm.mil.util;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

@SuppressWarnings("rawtypes")
public final class JsonDataReader {
	// Gson instance
	private static Gson gson = new Gson();

	// Logger
	private final static Logger LOGGER = Logger.getLogger(JsonDataReader.class.getName());

	private JsonDataReader() {
		throw new AssertionError("Utilities is non-instantiable");
	}

	/**
	 * Returns all those JSON data records that can be processed (i.e. inserted
	 * into the db) without the need to know the _rev value of a parent record.
	 *
	 * @return
	 */
	public static List<List<Map>> getAllJsonData(String... jsonFiles) {
		List<List<Map>> jsonData = new ArrayList<List<Map>>();
		for (String jsonFile : jsonFiles) {
			List<Map> records = getMapCollection(jsonFile);
			jsonData.add(records);
		}
		return jsonData;
	}

	/**
	 *
	 * @param jsonFile
	 * @return
	 */
	public static List<Map> getMapCollection(String jsonFile) {
		TypeToken<List<Map>> typeToken = new TypeToken<List<Map>>() {
		};
		return getCollection(typeToken, jsonFile);
	}

	/**
	 * castDoublesToLongs is a method that takes a jsonFile and casts all of the
	 * keys in the json objects that match a value in keysToCast to longs. This
	 * method is necessary because when saving to cloudant the documents were
	 * being saved as doubles and this was causing errors.
	 *
	 * @param jsonFile
	 *            the filename of the json file to scan.
	 * @param keysToCast
	 *            the list of keys which need to be changed to longs.
	 * @return a List<Map> objects representing the new json objects that have
	 *         been cast in this method.
	 */
	@SuppressWarnings("unchecked")
	public static List<Map> castDoublesToLongs(String jsonFile, List<String> keysToCast) {
		List<Map> newMaps = JsonDataReader.getMapCollection(jsonFile);
		if (keysToCast.isEmpty()) {
			return newMaps;
		}

		for (Map oldMap : newMaps) {
			for (String keyToCast : keysToCast) {
				Object objectToChange = oldMap.get(keyToCast);
				if (objectToChange != null) {
					// System.out.println(oldMap.get(keyToCast).getClass().getSimpleName());
					Long newValue = ((Number) oldMap.get(keyToCast)).longValue();
					oldMap.put(keyToCast, newValue);
					// System.out.println(oldMap.get(keyToCast).getClass().getSimpleName());
				}
			}
		}
		return newMaps;
	}

	/**
	 * Generic method for parsing a JSON data file and returning a collection of
	 * data objects. The type of object in the collection is determined by the
	 * typeToken parameter. The file to be read is specifie in the jsonFile
	 * parameter. If an error occurs while processing the JSON file, an empty
	 * collection is returned.
	 *
	 * @param typeToken
	 * @param jsonFile
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public static <T extends List<U>, U> T getCollection(TypeToken<T> typeToken, String jsonFile) {
		T collection;
		try {
			URL url = JsonDataReader.class.getClassLoader().getResource(jsonFile);
			BufferedReader br = new BufferedReader(new FileReader(url.getFile()));
			collection = gson.fromJson(br, typeToken.getType());
		} catch (IOException ioe) {
			collection = (T) new ArrayList<U>();
			LOGGER.severe("Could not load JSON data file: " + jsonFile);
			LOGGER.severe(ioe.getMessage());
		}
		return collection;
	}
}
