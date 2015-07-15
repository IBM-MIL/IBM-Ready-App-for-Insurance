package com.ibm.mil.ready.app.perch.tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.util.List;

import org.junit.Before;
import org.junit.Test;

//import com.google.common.reflect.TypeToken;
import com.google.gson.reflect.TypeToken;
import com.ibm.mil.ready.app.perch.AuthenticationAdapter;
import com.ibm.mil.ready.app.perch.model.PerchUser;
import com.ibm.mil.ready.app.perch.tests.utils.TestUtilities;
import com.ibm.mil.ready.app.perch.utils.Constants;
import com.ibm.mil.util.JsonDataReader;

public class AuthenticationAdapterTest {

	AuthenticationAdapter authenticationAdapter;
	PerchUser remoteDBUser1;
	PerchUser remoteDBU1;

	PerchUser localDBUser1;
	PerchUser localDBU1;
	String defaultTestLocale = "en_US";

	List<PerchUser> localDBUserList;

	@Before
	public void setUp() throws Exception {
		authenticationAdapter = AuthenticationAdapter.getInstance();

		remoteDBUser1 = new PerchUser();
		remoteDBU1 = new PerchUser();

		TypeToken<List<PerchUser>> userToken = new TypeToken<List<PerchUser>>() {
		};
		localDBUserList = JsonDataReader.getCollection(userToken, Constants.USER_JSONFILENAME);

		localDBU1 = localDBUserList.get(0);
		localDBUser1 = localDBUserList.get(1);
	}

	@Test
	public void testGetUserNull() {
		// [1] test that getUser returns null if null is passed in.
		remoteDBUser1 = authenticationAdapter.getUser(null, defaultTestLocale);
		assertNull(remoteDBUser1);

		// [2] test that getUser returns null if a user does not exist.
		remoteDBUser1 = authenticationAdapter.getUser("thisUserDoesNotExist", defaultTestLocale);
		assertNull(remoteDBUser1);
	}

	@Test
	public void testGetUser1() {

		// [3] test use the authentication to query for the user that was just
		// inserted into the database.
		remoteDBUser1 = authenticationAdapter.getUser(localDBUser1.getUsername(),
				localDBUser1.getLocale());
		TestUtilities.assertUsersEqual(localDBUser1, remoteDBUser1);
	}

	@Test
	public void testGetU1() {
		// [1] test use the authentication to query for the user that was just
		// inserted into the database.
		remoteDBU1 = authenticationAdapter.getUser(localDBU1.getUsername(), localDBU1.getLocale());
		TestUtilities.assertUsersEqual(localDBU1, remoteDBU1);
	}

	@Test
	public void testValidateUserPassword() {

		// [1] test that the method returns true with a valid password.
		assertTrue(authenticationAdapter.validateUserPassword(localDBUser1,
				localDBUser1.getPassword()));

		// [2] test that the method returns false with an invalid password.
		assertFalse(authenticationAdapter.validateUserPassword(localDBUser1,
				"thisIsTheWrongPassword"));

		// [3] test that the method returns false if null is passed in.
		assertFalse(authenticationAdapter.validateUserPassword(localDBUser1, null));
	}

	@Test
	public void testVerifyUser() {
		// [1] use the authentication to query for the user
		remoteDBUser1 = authenticationAdapter.verifyUser(localDBUser1.getUsername(),
				localDBUser1.getPassword());
		TestUtilities.assertUsersEqual(localDBUser1, remoteDBUser1);
	}

	/**
	 * testGetAllUsers() asserts that all the remote users are also in the local
	 * resources files.
	 */
	@Test
	public void testGetAllUsers() {
		List<PerchUser> remoteDBUserList = authenticationAdapter.getAllUsers();
		for (PerchUser localUser : localDBUserList) {
			for (PerchUser remoteUser : remoteDBUserList) {
				if (localUser.getId().equals(remoteUser.getId())) {
					assertEquals(localUser, remoteUser);
					break;
				}
			}
		}
	}

}
