## Ready App for Insurance IoT Simulator

The IBM Ready App for Insurance is dependent on data from an external IoT simulator in order to operate outside of demo mode. This simulator acts as a virtual IoT device, allowing the user to adjust the values of virtual household items, whereupon this data is transferred to the Ready App.

## Setup

Little setup is required to get the IoT Simulator running on BlueMix and connected to your application.

### Configuration

After downloading the project code, open `PerchSimulator/sensor_config/config.json`. This is the configuration file that contains the sensor definitions, as well as all of the connection data that will link the simulator to your instance of IBM Ready App for Insurance. The sensor definitions may be changed or left alone, but the connection information must be changed.

#### Sensor Information

The sensors themselves have the following fields that you may adjust without issue:

* `text` - The title that is displayed on the asset overview and asset detail pages.
* `units` - The units of measurement that will be stored on the backend.
* `displayUnit` - The units of measurement that will be displayed in the app (must be HTML compatible).
* `defaultValue` - The default numeric value to be displayed on the sensor when the app is started up.
* `absoluteMin` - The minimum selectable value for this sensor. At this value, attempts to decrease the sensor value any more will be ignored.
* `absoluteMax` - The maximum selectable value for this sensor.
* `minThreshold` - If the sensor value is at or below this number, an alert is sent.
* `maxThreshold` - If the sensor value is at or above this number, an alert is sent.

The name of each enclosing sensor object is hardcoded into the app, in order to link them to display icons. The `device_class_id` field is connected to the database as well as the app's source code, and is part of the navigation that allows asset detail pages to be displayed. It is not recommended that these fields be changed unless all of the appropriate frontend and backend code is changed as well.

#### Connection Information

The following connection fields must be changed in order for the simulator to work correctly:

* `iot.org`: This is the six-character organization code you obtained when you added the IoT Foundation service to your Bluemix project. In the "Configure the Node-RED app" step in the Getting Started docs, this is the same as the `iotOrganizationId` field you add to `functionGlobalContext`.
* `bluemix.user`: This is the API key for accessing the IoT Foundation service. This is the same as the `iotApiKey` field you add to `functionGlobalContext`.
* `bluemix.pass`: This is the authorization token for accessing the IoT Foundation service. This is the same as the `iotAuthToken` field you add to `functionGlobalContext`.
* `ws.host`: This is the websocket URL that you will use to connect the simulator to your instance of Node-RED. The specific endpoint is the one created by the `device_registration.json` file that you import into your Node-RED project.

### Installation

The IoT Simulator runs in a separate BlueMix application from the Ready App itself. From your BlueMix dashboard, click on "Create App" to create a new Cloud Foundry app. Select a Web app and start with "SDK for Node.js", then name the application however you like.

The application code is installed through the Cloud Foundry command line tool; if you don't have it already, the page that appears after naming your app will let you download and install it. Once you have it, navigate your terminal to the `PerchSimulator` folder and follow the instructions to push your code to the application.

Once the code is installed and built, you can access the simulator by going to the URL specified at the bottom of the Cloud Foundry instruction page (normally `http://<your-app-name>.mybluemix.net/`. The PIN that appears in the top-right corner is the PIN you should enter into your instance of IBM Ready App for Insurance. Once the sensors have been synced, you can start adjusting the virtual IoT sensors, and the data will be transferred to the Ready App.

## Testing

The IoT Simulator comes with a test page to verify that all connections are working correctly; these tests can be run by going to `http://<your-app-name>.mybluemix.net/test`. There are four connection tests and one disconnection test to be run. The connection tests are:

* Received init data: verifies that the HTML page can successfully receive messages from the `app.js` backend that handles the connection to Node-RED and other systems.
* Received register data: verifies that the simulator was able to register itself with the IoT Foundation as a new IoT device.
* Connection to IoT broker: verifies that the simulator was able to connect to the MQTT messaging service.
* Registration with IoT foundation: verifies again that the simulator was added to the list of currently registered IoT devices.

The disconnection test is:

* Unregistration with IoT foundation: verifies that this device was removed from the list of currently registered IoT devices.

All of these tests should be completed within a maximum of 30 seconds. If a response cannot be received from the IoT foundation, it is possible the second test will never return a "success" or "failure" response.

## License
The IBM Ready App for Insurance IoT Simulator is available under the IBM Ready Apps License Agreement. See the [License file](https://github.com/IBM-MIL/IBM-Ready-App-for-Banking/blob/master/License.txt) for more details.