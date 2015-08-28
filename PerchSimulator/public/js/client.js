// The control flow of this client is as follows:
// 1. init() - The socket.io object is created, and we send a message
//    to the server requesting a list of all devices. We also create
//    all the sensors with initSensors().
// 2. 'register_data' message received - the device was created based on
//    a randomly generated (but unique) PIN.
// 3. connectIoT() - The device data is parsed, and we use it to connect
//    to the actual IoT service.
// 4. onConnectSuccess() - The connection was successful.
// 5. updateSensors() - This is fired whenever any sensor is updated. It
//    updates the local display and sends an IoT update message to the
//    broker.
// 6. unregisterDevice() - This is fired when the page is closed or
//    reloaded. It unregisters our simulated device.

// Connection variables.
var messenger = null;
var org = "nlbign";
var host = org + ".messaging.internetofthings.ibmcloud.com";
var port = 1883;
var path = "/mqtt";
var topic = "iot-2/evt/sensor-data/fmt/json";
var uuid = undefined;
var iotPassword = undefined;
var socket = undefined;
var currentPin = undefined;

// The sensors that will be created, along with text descriptions,
// units, default values, min and max.
var sensorDefinition = {
    flow: {
    	text: "Water Flow",
    	unit: " L/s",
    	defaultValue: 75,
    	absoluteMin: 0,
    	absoluteMax: 100,
    	maxThreshold: 90
    },
    temp: {
    	text: "Temperature",
    	unit: "&deg;C",
    	defaultValue: 30,
    	minThreshold: 0,
    	maxThreshold: 50
    },
    light: {
    	text: "Light",
    	unit: "%",
    	defaultValue: 20,
    	absoluteMin: 0,
    	absoluteMax: 100,
    	maxThreshold: 50
    }
};

// The payload that will be sent to the IoT broker. It will be
// populated more when we create the sensors.
var packetPayload = {
    d: {
        pin: undefined
    }
};

// Initialize the socket.io connection and set up message handlers.
function socketInit() {
	socket = io();
	
	// Receiving the registered device data. We parse the
	// data, then connect to the IoT broker.
	socket.on('register_data', function(msg){
		var registerData = JSON.parse(msg);
		uuid = registerData.uuid;
		iotPassword = registerData.password;
		currentPin = registerData.id;
		registerPin(currentPin);
		connectIoT();
	});
}

// This function does some useful tasks after receiving the PIN.
function registerPin(newPin) {
	packetPayload.d.pin = newPin;
	topic = "iot-2/evt/sensor-data-" + newPin + "/fmt/json";
	document.getElementById("pin_div").innerHTML = newPin;
}

// A quick function to display a status message while registering devices.
function registerStatus(infoString, xmlReq) {
	document.getElementById("register_div").innerHTML = infoString;
	if (xmlReq !== undefined) {
		document.getElementById("register_div").innerHTML += "<br />" + xmlReq.statusText;
	}
}

// Connect a registered device to the MQTT service.
function connectIoT() {
	messenger = new Paho.MQTT.Client(host, port, path, uuid);
	messenger.onConnectionLost = onConnectFailure;
	messenger.connect({userName: "use-token-auth", password: iotPassword, 
		onSuccess: onConnectSuccess, onFailure: onConnectFailure});
}

// The initializing function. When the page loads, connect to the IoT broker.
function init() {
	// We create the sensor interface.
	initSensors(sensorDefinition);
	
	// Initialize the socket.io connection.
    socketInit();
    
    // Need to register with the online IBM IoT service.
    socket.emit('acquire_devices');
}

// If the connection succeeds, send an initial message.
function onConnectSuccess() {
    document.getElementById("status_div").innerHTML = "Connected, hopefully.";
    updateSensor();
}

// If the connection fails, display a failure message, then try to reconnect.
function onConnectFailure(response) {
    document.getElementById("status_div").innerHTML = "Connection failed.<br />Error code: " + 
    	response.errorCode + "<br />Error message: " + response.errorMessage;
    messenger.connect({userName: "use-token-auth", password: iotPassword, 
    	onSuccess: onConnectSuccess, onFailure: onConnectFailure});
}

// Create a single sensor, given a name and a default value.
function createSensor(sensorName, sensorText, sensorUnit, sensorDefault) {
    var newSensorDiv = document.createElement("div");
    newSensorDiv.id = sensorName + "_sensor";
    newSensorDiv.appendChild(document.createTextNode(sensorText + ": "));
    
    var downButton = document.createElement("button");
    downButton.onclick = function(){ decrease(sensorName); };
    downButton.innerHTML = "Down";
    newSensorDiv.appendChild(downButton);
    
    var sensorSpan = document.createElement("span");
    sensorSpan.id = sensorName + "_value_span";
    sensorSpan.innerHTML = sensorDefault.toString() + sensorUnit;
    newSensorDiv.appendChild(sensorSpan);
    
    var upButton = document.createElement("button");
    upButton.onclick = function(){ increase(sensorName); };
    upButton.innerHTML = "Up";
    newSensorDiv.appendChild(upButton);
    
    newSensorDiv.appendChild(document.createElement("br"));
    document.getElementById("sensor_div").appendChild(newSensorDiv);
}

// Create all the sensors based on the values provided by JSON. Each sensor item
// in the packet payload contains a currentValue, and can contain a minThreshold
// and maxThreshold if they are defined in the sensorDefinition.
function initSensors(sensors) {
    for (var i in sensors) {
        createSensor(i, sensors[i].text, sensors[i].unit, sensors[i].defaultValue);
        packetPayload.d[i] = {
        	currentValue: sensors[i].defaultValue
        };
        if (sensors[i].minThreshold !== undefined) {
        	packetPayload.d[i].minThreshold = sensors[i].minThreshold;
        }
        if (sensors[i].maxThreshold !== undefined) {
        	packetPayload.d[i].maxThreshold = sensors[i].maxThreshold;
        }
    }
}

// Increase the sensor value, and send a message saying we have done so.
function increase(sensorType) {
	if (sensorDefinition[sensorType].absoluteMax === undefined ||
		sensorDefinition[sensorType].absoluteMax > packetPayload.d[sensorType].currentValue) {
    	packetPayload.d[sensorType].currentValue += 1;
    	updateSensor(sensorType);
    }
}

// Decrease the sensor value, and send a message saying we have done so.
function decrease(sensorType) {
	if (sensorDefinition[sensorType].absoluteMin === undefined ||
		sensorDefinition[sensorType].absoluteMin < packetPayload.d[sensorType].currentValue) {
    	packetPayload.d[sensorType].currentValue -= 1;
    	updateSensor(sensorType);
    }
}

function updateSensor(sensorType) {
    if (sensorType !== undefined) {
        document.getElementById(sensorType+"_value_span").innerHTML = 
        	packetPayload.d[sensorType].currentValue.toString() + sensorDefinition[sensorType].unit;
    }
    messenger.send(topic,JSON.stringify(packetPayload),0,false);
}

// Unregister the device and tag. Fires when the page is closed.
function unregisterServices(pin) {
    socket.emit('unregister_services',pin);
}

// When the window closes, unregister this device.
window.onbeforeunload = function() {
    unregisterServices(currentPin);
};