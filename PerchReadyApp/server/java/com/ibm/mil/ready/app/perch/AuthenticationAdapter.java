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

import java.util.List;

import com.ibm.mil.cloudant.CloudantService;
import com.ibm.mil.ready.app.perch.model.PerchUser;
import com.ibm.mil.ready.app.perch.utils.Constants;
import com.ibm.mil.ready.app.perch.utils.Utilities;
import com.ibm.mil.util.AppPropertiesReader;

/**
 *
 * @author tannerpreiss
 *
 */
public final class AuthenticationAdapter {
	private static AuthenticationAdapter perchAdapter;
	private final CloudantService cloudantService;

	public static AuthenticationAdapter getInstance() {
		synchronized (AuthenticationAdapter.class) {
			if (perchAdapter == null) {
				perchAdapter = new AuthenticationAdapter();
			}
		}
		return perchAdapter;
	}

	// private constructor to ensure it remains a singleton.
	private AuthenticationAdapter() {
		cloudantService = CloudantService.getInstance();
	}

	/**
	 *
	 * getUser() returns a user object associated with the provided username, if
	 * not user is found for the username then null is returned.
	 *
	 * @param usernameFilter
	 *            null to return all users or a valid user to get the record for
	 *            that user.
	 * @return user if valid username : user = the User object associated with
	 *         the given usernameFilter if invalid username : user = null
	 */
	public PerchUser getUser(String usernameFilter, String locale) {
		PerchUser user = null;

		boolean validFilter = usernameFilter == null ? false : Utilities.isSanitary(usernameFilter);

		if (validFilter) {
			List<PerchUser> userList = cloudantService.getDatabase().view("library/users")
					.key(usernameFilter).reduce(false).includeDocs(true).query(PerchUser.class);
			if (userList != null && !userList.isEmpty()) {
				user = userList.get(0);
			}
		}
		return user;
	}

	/**
	 * getAllUsers() returns a list of all users in the database.
	 *
	 * @return users a list of all users in the database.
	 */
	public List<PerchUser> getAllUsers() {
		return cloudantService.getDatabase().view("library/users").query(PerchUser.class);
	}

	/**
	 * verifyUser() gets the User object associated with the username and then
	 * returns the user if the password is valid, if the username is invalid or
	 * the password is invalid, then verifyUser returns null;
	 *
	 * @param username
	 *            the username of the user to verify.
	 * @param password
	 *            the password of the user to verify.
	 * @return retUser valid username and password : retUser is the User object
	 *         associated with the now verified user. invalid username or
	 *         password : retUser is null.
	 *
	 */
	public PerchUser verifyUser(String username, String password) {
		// Sanity check for: null, empty, sql query, etc
		boolean sanityVerificationforUsername = Utilities.isSanitary(username,
				AppPropertiesReader.getStringProperty(Constants.DEFAULT_LOCALE));

		boolean sanityVerificationforPassword = Utilities.isSanitary(password,
				AppPropertiesReader.getStringProperty(Constants.DEFAULT_LOCALE));

		PerchUser retUser = null;
		if (sanityVerificationforUsername && sanityVerificationforPassword) {
			PerchUser user = this.getUser(username,
					AppPropertiesReader.getStringProperty(Constants.DEFAULT_LOCALE));

			// check if the query returned a user (null check)
			// if a user is returned, then validate the password for the user.
			if (user != null && validateUserPassword(user, password)) {
				retUser = user;
			}

		}
		return retUser;
	}

	/**
	 * validateUserPassword() checks if the password provided matches the
	 * password in the User object provided.
	 *
	 * @param u1
	 *            the user object to check the password against.
	 * @param password
	 *            the password to check against the user object.
	 * @return returns true : user is validated. false : password is incorrect,
	 *         user is not validated.
	 */
	public boolean validateUserPassword(PerchUser u1, String password) {
		return u1.getPassword() != null && u1.getPassword().equals(password);
	}

	public static void main(String... args) {
		System.out.println(AuthenticationAdapter.getInstance().getUser("testUser1", "en_US")
				.getId());
	}
}
