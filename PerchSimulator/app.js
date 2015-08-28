var port = (process.env.VCAP_APP_PORT || 3000);
var express = require("express");

var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var https = require('https');
var fs = require('fs');
var ws = require('ws');

// All of the config data will be read in from file.
var configData = undefined;

var org, authStr, sensorDefinition, clientPacket, wsHost;
var deviceType = "simulatedSensor";

// Read in config data from a file and assign some variables.
function readConfig(filePath) {
	fs.readFile(filePath, 'utf8', function(err,data){
		if (!err) {
			configData = JSON.parse(data);
			org = configData.connection.iot.org;
            var iotUser = configData.connection.bluemix.user;
			var iotPass = configData.connection.bluemix.pass;
			authStr = "Basic " + (new Buffer(iotUser + ":" + iotPass).toString('base64'));
			sensorDefinition = configData.sensorDefinition;
			wsHost = configData.connection.ws.host;
			
			// Create a packet to send to connecting clients. Note that
			// we also convert the interval to milliseconds from seconds.
			clientPacket = {
				sensorDefinition: configData.sensorDefinition,
				connection: configData.connection.iot,
				interval: parseInt(configData.interval,10) * 1000
			};
		}
	});
}

// Read in the config data.
readConfig(__dirname + "/sensor_config/config.json");

// Initializing the socket.io connection and handling messages.
io.on('connection', function(socket){
	socket.on('request_init_data', function(){
		io.to(socket.id).emit('init_data', JSON.stringify(clientPacket));
	});
	
	socket.on('acquire_devices', function(){
		acquireDevices(socket.id);
	});
	
	socket.on('unregister_services', function(pin){
		unregisterDevice(pin);
		unregisterCloudant(pin);
	});
	
	socket.on('disconnect', function(){
		var pin = getSocketPin(socket.id);
		removeSocketPin(socket.id);
		unregisterDevice(pin);
		unregisterCloudant(pin);
	});
	
	socket.on('test_acquire_devices', function(msg) {
		test_acquireDevices(socket.id, msg);
	});
});

// defensiveness against errors parsing request bodies...
process.on('uncaughtException', function (err) {
	console.log('Caught exception: ' + err.stack);
});

// Configure the app web container
app.configure(function() {
	app.use(express.bodyParser());
	app.use(express.static(__dirname + '/public'));
});

app.get('/', function (req, res) {
	res.sendfile('public/sensor.html');
});

app.get('/test', function (req, res) {
	res.sendfile('public/test.html');
});

http.listen(port);
console.log("Server listening on port " + port);

// Now for device registration code.

// The workflow for this section:
// 1. 'init_data' message sent to all new connecting clients.
// 2. 'acquire_devices' message received.
// 3. acquireDevices() - a REST call is sent to the device service to
//    determine currently registered devices.
// 4. registerDevice() - a new and unique PIN is created, and a device
//    is registered with this PIN.
// 5. processDevice() - the registration information from the device
//    is sent to the client, so that they can connect to the IoT broker.
// 6. 'disconnect' message received - the client has quit.
// 7. unregisterDevice() - unregister the device.
// 8. unregisterCloudant() - unregister Cloudant data.

// An object and functions to link socket IDs and PINs.
var socketPINs = {};
function addSocketPin(socketID, pin) {
	socketPINs[socketID] = pin;
}
function getSocketPin(socketID) {
	return socketPINs[socketID];
}
function removeSocketPin(socketID) {
	delete socketPINs[socketID];
}

// Building a JSON payload to send via WebSocket.
function buildRegisterPayload(registerValue, pin, sensors) {
	var json_payload = {
		register: registerValue,
		device_pin: pin,
		device_class_id: []
	};
	for (sensorType in sensors) {
		json_payload.device_class_id.push(sensors[sensorType].device_class_id);
	}
	
	return json_payload;
}

// Get a list of devices that are already registered with Bluemix.
function acquireDevices(socketID) {
	var getHeaders = {
		'Content-Type': 'application/json; charset=UTF-8',
		'Authorization': authStr
	};
	var getOptions = {
		host: 'internetofthings.ibmcloud.com',
		path: '/api/v0001/organizations/'+org+'/devices',
		method: 'GET',
		headers: getHeaders
	};
	
	var buffer = "";
	
	var getRequest = https.request(getOptions, function(response) {
		response.on('data', function(chunk) {
			buffer += chunk;
		});
		
		// Once all the data is collected, we'll parse the list of PINs
		// and register a device.
		response.on('end', function(err) {
			registerDevice(buffer, socketID);
		});
	});
	getRequest.end();
}

// A function to create a new random PIN that isn't already used.
function getNewPin(activePinList) {
	var newPin = undefined;
	
	while (newPin === undefined) {
		// "0000" is not an acceptable PIN anymore.
		newPin = Math.floor(Math.random() * 10).toString() + 
				 Math.floor(Math.random() * 10).toString() +
				 Math.floor(Math.random() * 10).toString();
		if (newPin === "000") {
			newPin += (Math.floor(Math.random() * 9) + 1).toString();
		} else {
			newPin += Math.floor(Math.random() * 10).toString();
		}
		for (var i = 0; i < activePinList.length; i++) {
			if (newPin === activePinList[i].toString()) {
				newPin = undefined;
				break;
			}
		}
	}
	
	return newPin;
}

// A function to take device data and parse it into a list of
// currently used PINs.
function parsePins(deviceData) {
	var devices = JSON.parse(deviceData);
	var activePins = [];
	for (var i = 0; i < devices.length; i++) {
		activePins.push(devices[i].id);
	}
	return activePins;
}

// Create a unique PIN and register it as a device with Bluemix.
function registerDevice(deviceList, socketID) {
	// First, we need to determine a unique pin.
	var activePins = parsePins(deviceList);
	var newPin = getNewPin(activePins);
	
	var postHeaders = {
		'Content-Type': 'application/json; charset=UTF-8',
		'Authorization': authStr
	};
	var postOptions = {
		host: 'internetofthings.ibmcloud.com',
		path: '/api/v0001/organizations/'+org+'/devices',
		method: 'POST',
		headers: postHeaders
	};
	var reqBody = {
	    type: deviceType,
	    id: newPin
	};
	
	var postRequest = https.request(postOptions, function(response) {
		var buffer = "";
		
		response.on('data', function(chunk) {
			buffer += chunk;
		});
		
		response.on('end', function(err) {
			processDevice(buffer, newPin, socketID);
		});
	});
	postRequest.write(JSON.stringify(reqBody));
	postRequest.end();
}

// Return the registered device data to the client.
function processDevice(deviceData, newPin, socketID) {
	// Did the registration fail due to too many devices?
	var JSONdata = JSON.parse(deviceData);
	if (JSONdata.id === null || JSONdata.id === undefined || JSONdata.id === "null") {
		io.to(socketID).emit('register_failed');
	} else {
		addSocketPin(socketID, newPin);
		registerCloudant(newPin);
		io.to(socketID).emit('register_data', deviceData);
	}
}

// Registers a device with Cloudant.
function registerCloudant(pin) {
	var json_payload = buildRegisterPayload(1, pin, sensorDefinition);
	var websocket = new ws(wsHost);
	websocket.on('open', function open() {
		websocket.send(JSON.stringify(json_payload));
		websocket.close();
	});
}

// Unregisters a simulated device.
function unregisterDevice(pin) {
	var deleteHeaders = {
		'Content-Type': 'application/json; charset=UTF-8',
		'Authorization': authStr
	};
	var deleteOptions = {
		host: 'internetofthings.ibmcloud.com',
		path: '/api/v0001/organizations/'+org+'/devices/'+deviceType+'/'+pin,
		method: 'DELETE',
		headers: deleteHeaders
	};
	
	var deleteRequest = https.request(deleteOptions);
	deleteRequest.end();
}

// Unregisters a Cloudant registration.
function unregisterCloudant(pin) {
	var json_payload = buildRegisterPayload(0, pin, sensorDefinition);
	var websocket = new ws(wsHost);
	websocket.on('open', function open() {
		websocket.send(JSON.stringify(json_payload));
		websocket.close();
	});
}

// -------------------------------------------------
// The functions below are all for testing purposes.
// -------------------------------------------------

// Get a list of devices that are already registered with Bluemix.
function test_acquireDevices(socketID, connectStatus) {
	var getHeaders = {
		'Content-Type': 'application/json; charset=UTF-8',
		'Authorization': authStr
	};
	var getOptions = {
		host: 'internetofthings.ibmcloud.com',
		path: '/api/v0001/organizations/'+org+'/devices',
		method: 'GET',
		headers: getHeaders
	};
	
	var buffer = "";
	
	var getRequest = https.request(getOptions, function(response) {
		response.on('data', function(chunk) {
			buffer += chunk;
		});
		
		// Once all the data is collected, we'll parse the list of PINs
		// and register a device.
		response.on('end', function(err) {
			var dataObject = {
				deviceData: JSON.parse(buffer),
				connectStatus: connectStatus
			};
			io.to(socketID).emit('device_list', JSON.stringify(dataObject));
		});
	});
	getRequest.end();
}