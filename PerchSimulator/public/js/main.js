/****************************************************************/
/*                                                              */
/* Licensed Materials - Property of IBM                         */
/* 5725-F96 IBM MessageSight                                    */
/* (C) Copyright IBM Corp. 2012, 2013 All Rights Reserved.      */
/*                                                              */
/* US Government Users Restricted Rights - Use, duplication or  */
/* disclosure restricted by GSA ADP Schedule Contract with      */
/* IBM Corp.                                                    */
/*                                                              */
/****************************************************************/

//
// requires mqttws31.js
//

// The control flow of this client is as follows:
// 1. init() - The socket.io object is created with socketInit().
// 2. 'init_data' message received.
// 3. processInitPacket() - we process the init_data message, setting
//    variables, then create the sensors using initSensors(). We also
//    send a message to the server requesting a PIN be created and
//    initialized.
// 4. 'register_data' message received - the device was created based on
//    a randomly generated (but unique) PIN.
// 5. connectIoT() - The device data is parsed, and we use it to connect
//    to the actual IoT service.
// 6. onConnectSuccess() - The connection was successful.
// 7. updateSensors() - This is fired whenever any sensor is updated. It
//    updates the local display and sends an IoT update message to the
//    broker.
// 8. publish() - This happens at a regular interval. It updates the displays
//    automatically and sends a payload to the IoT broker.
// 9. unregisterDevice() - This is fired when the page is closed or
//    reloaded. It unregisters our simulated device.

// Connection variables.
var messenger = null;
var topic = "iot-2/evt/sensor-data/fmt/json";
var org, host, port, path, uuid, iotPassword, socket, currentPin;
// How often we will update.
var interval = 5000;
// If this is set to true, make no attempts to reconnect.
var connectionDead = false;

// The sensors that will be created, along with text descriptions,
// units, default values, min and max.
var sensorDefinition;

// The payload that will be sent to the IoT broker. It will be
// populated more when we create the sensors.
var packetPayload = {
    d: {
    }
};

// This is a dummy function that will be overwritten if we are
// running tests.
function testConnectSuccessHook () {
	console.log("testConnectSuccessHook override failed.");
}

function testConnectFailureHook () {
	console.log("testConnectFailureHook override failed.");
}

// Initialize the socket.io connection and set up message handlers.
function socketInit() {
	socket = io();
	
	// Receiving our initialization packet from the server.
	socket.on('init_data', function(msg){
		processInitPacket(JSON.parse(msg));
	});
	
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
	
	// Did the registration fail?
	socket.on('register_failed', function(){
		$("#pin").html("Too many devices.");
	});
	
	// Did we lose our connection?
	socket.on('disconnect', function(){
		connectionDead = true;
		$("#pin").html("Connection lost, refresh.");
	});
	
	// We'll start by sending a data request to the server.
	// We do this from here because we only want to go through this
	// whole process one time, max.
	socket.emit('request_init_data');
}

// This function does some useful tasks after receiving the PIN.
function registerPin(newPin) {
	//packetPayload.d.pin = newPin;
	topic = "iot-2/evt/sensor-data-" + newPin + "/fmt/json";
	$("#pin").html("PIN: " + newPin);
}

// Connect a registered device to the MQTT service.
function connectIoT() {
	messenger = new Paho.MQTT.Client(host, port, path, uuid);
	messenger.onConnectionLost = connectionLost;
	messenger.connect({userName: "use-token-auth", password: iotPassword, 
		onSuccess: onConnectSuccess, onFailure: onConnectFailure});
}

function connectionLost() {
	if (!connectionDead) {
		$("#pin").html("Reconnecting...");
		clearInterval();
    	console.log("connection lost! - reconnecting");
    	testConnectFailureHook();
    	messenger.connect({
        	onSuccess: onConnectSuccess,
        	onFailure: onConnectFailure
    	});
    }
}

function onConnectSuccess() {
    console.log("connected as " + currentPin);
    
    $("#pin").html("PIN: " + currentPin);
    
    setInterval(publish, interval);
    
    testConnectSuccessHook();

    publish();
}

function onConnectFailure() {
	if (!connectionDead) {
	    $("#pin").html("Reconnecting...");
	    clearInterval();
	    console.log("failed! - retry connection w/ current PIN " + currentPin);
	    testConnectFailureHook();
	    messenger.connect({
	        onSuccess: onConnectSuccess,
	        onFailure: onConnectFailure
	    });
	}
}

// Increase the sensor value, and send a message saying we have done so.
function increase(sensorType) {
	var deviceID = sensorDefinition[sensorType].device_class_id;
	if (sensorDefinition[sensorType].absoluteMax === undefined ||
		sensorDefinition[sensorType].absoluteMax > packetPayload.d[deviceID]) {
    	packetPayload.d[deviceID] += 1;
    	updateSensors();
    	//publish();
    }
}

// Decrease the sensor value, and send a message saying we have done so.
function decrease(sensorType) {
	var deviceID = sensorDefinition[sensorType].device_class_id;
	if (sensorDefinition[sensorType].absoluteMin === undefined ||
		sensorDefinition[sensorType].absoluteMin < packetPayload.d[deviceID]) {
    	packetPayload.d[deviceID] -= 1;
    	updateSensors();
    	//publish();
    }
}

function createSensor(sensorType, sensorText, sensorCounter, sensorColor) {
	var active = (sensorCounter === 0) ? " active" : "";
	var activeClass = (sensorCounter === 0) ? " class='active'" : "";
	
	// First, we need to add a list item to the carousel-indicators thing.
	$(".carousel-indicators").append($("<li data-target='#myCarousel' data-slide-to='" + 
		sensorCounter + "'" + activeClass + "></li>"));
	
	// Now to add a lot of nested elements. First, carousel-caption stuff.
	var readingButtons = $("<div class='readingButtons'></div>");
	readingButtons.append($("<button id='" + sensorType + 
		"Down' class='readingButton btn btn-lg btn-default' style='margin-right: 20px;' href='#' role='button' onclick='decrease(\"" + 
		sensorType + "\")'></button>")
		.append("<span class='glyphicon glyphicon-arrow-down'></span>"));
	readingButtons.append($("<button id='" + sensorType + 
		"Up' class='readingButton btn btn-lg btn-default' href='#' role='button' onclick='increase(\"" + 
		sensorType + "\")'></button>")
		.append("<span class='glyphicon glyphicon-arrow-up'></span>"));
	var carouselCaption = $("<div class='carousel-caption'></div>");
	carouselCaption.append(readingButtons);
	carouselCaption.append($("<small><i>swipe left/right for more</i></small>"));
	
	// Then, create the container and add all the carousel elements into it.
	var container = $("<div class='container'></div>");
	container.append($("<div class='carousel-top'></div>")
		.append($("<h4>" + sensorText + "</h4>")));
	container.append($("<div class='carousel-main'></div>")
		.append($("<div class='readingBox'></div>")
		.append($("<h1 class='readingValue' id='" + sensorType + "Reading'></h1>"))));
	container.append(carouselCaption);
	
	// Finally, create the outer containing item, and add it to the carousel-inner.
	var sensorItem = $("<div class='" + sensorColor + " item " + active + "'></div>")
		.append(container);
	$(".carousel-inner").append(sensorItem);
}

// A function to generate the sensors from our sensorDefinition.
function initSensors(sensors) {
	// This will keep track of what color we should use.
	var sensorCounter = 0;
	var colorArray = ["navy", "green", "orange", "blue", "purple"];
	
	for (i in sensors) {
		// Create the sensor objects in the DOM.
		var currentColor = colorArray[(sensorCounter % 5)];
		createSensor(i, sensors[i].text, sensorCounter, currentColor);
		
		var deviceID = sensors[i].device_class_id;
		
		// Update the packetPayload appropriately.
        packetPayload.d[deviceID] = sensors[i].defaultValue;
		
		sensorCounter++;
	}
}

/*
In the sensor payload, need to include all three device_class_id codes.
*/

function init() {
	// Initialize the socket.io connection.
    socketInit();
}

// This function fires off after we receive our init packet.
// It sets some data, then starts the process of creating sensors.
function processInitPacket(initData) {
	// Process the packet and set some variables.
	sensorDefinition = initData.sensorDefinition;
	interval = parseInt(initData.interval, 10);
	org = initData.connection.org;
	host = org + initData.connection.host;
	port = parseInt(initData.connection.port, 10);
	path = initData.connection.path;
	
	// Create the sensors and make the UI functional.
	initSensors(sensorDefinition);

    $("#interval").html(interval);

    $("#myCarousel").swiperight(function() {  
        $("#myCarousel").carousel('prev');  
    });  
    $("#myCarousel").swipeleft(function() {  
        $("#myCarousel").carousel('next');  
    });
    $('#myCarousel').carousel('pause');
    
    // Need to register with the online IBM IoT service.
    socket.emit('acquire_devices');

	// Finally, initialize the sensor display with some numbers.
    updateSensors();
}

function updateSensors() {
    for (var i in sensorDefinition) {
    	var deviceID = sensorDefinition[i].device_class_id;
    	$("#"+i+"Reading").html(packetPayload.d[deviceID].toString() + sensorDefinition[i].displayUnit);
    }
}

function publish() {
    updateSensors();
    
    if (messenger !== null) {
    	messenger.send(topic,JSON.stringify(packetPayload),0,false);
    }
}

// Unregister the device and tag. Fires when the page is closed.
/*function unregisterServices(pin) {
    socket.emit('unregister_services',pin);
}*/

// When the window closes, unregister this device.
/*window.onbeforeunload = function() {
	if (messenger !== null) {
    	unregisterServices(currentPin);
    }
};*/