/*eslint "angular/ng_window_service": 0, "angular/ng_document_service": 0*/
/**************************************
 *
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 *  This sample program is provided AS IS and may be used, executed, copied and modified without royalty payment by customer
 *  (a) for its own instruction and study, (b) in order to develop applications designed to run with an IBM product,
 *  either for customer's own internal use or for redistribution by customer, as part of such an application, in customer's
 *  own products.
 *
 ***************************************/
var angular, WL;
/**
 *  @class Perch.HybridJS
 *  @memberOf Perch
 *  @description
 *  A wrapper for all of the Worklight actions from and to native
 *
 *  @author Jim Avery
 *  @author Jon Ballands
 *  @author Blake Ball
 *  @copyright © 2015 IBM Corporation. All Rights Reserved.
 */
var HybridJS = (function () {
    'use strict';

    /**
     *  @function Perch.HybridJS.applyScope
     *
     *  @description
     *  Refreshes the scope.
     */
    function applyScope() {
        //We need to get the scope from the current controller in order to force an apply
        //The apply essentially performs a refresh on the view so the data will appear
        var selector = 'perch-app';
        var scope = angular.element(
            document.getElementById(selector)
        ).scope();
        scope.$apply();
    }

    /**
     *  @function Perch.HybridJS.initSensors
     *
     *  @description
     *  Initializes the sensor and device data from the native.
     *
     *  @param  {Sensors} sensors The sensors object to set
     */
    function initSensors(sensors) {
        window.allSensorData = sensors;
        var appWrapper = document.getElementById('perch-app');
        var $inj = angular.element(appWrapper).injector();
        var $sensors = $inj.get('Sensors');
        var $devices = $inj.get('Devices');

        // We need to massage the data so it's in a format we like. We'll
        // extract sensor and device data.
        var formattedSensors = [];
        var formattedDevices = [];
        for (var i = 0; i < sensors.length; i++) {
            // In a perfect world, this would all be in the same object, but
            // it's too late to change that now. So some stuff goes into a
            // sensor object, and some goes into a device object.
            var newSensor = {
                sensorName: sensors[i].name,
                sensorValue: sensors[i].value,
                alertState: sensors[i].status,
                alertDetail: {
                    value: null,
                    message: null,
                    detail: null,
                    timestamp: null,
                    partner: null
                },
                timestamp: sensors[i].time
            };
            var newDevice = {
                deviceName: sensors[i].name,
                deviceClassId: sensors[i].deviceClassId,
                maxThreshold: sensors[i].maxThreshold,
                displayName: sensors[i].name,
                displayUnit: sensors[i].units,
                displayIcon: "assets/images/ac_detail.png",
                displayAvgVal: sensors[i].averageUsage,
                displayAvgMsg: sensors[i].averageUsageUnit,
                detailName: sensors[i].partName,
                detailAge: sensors[i].age,
                detailMfrNo: sensors[i].serialNumber,
                sensorName: sensors[i].name
            };
            // Sensor alert detail.
            if (angular.isDefined(sensors[i].alert)) {
                newSensor.alertDetail = sensors[i].alert;
            }

            // Process the incentive.
            if (angular.isDefined(sensors[i].tip)) {
                newDevice.tip = true;
                newDevice.tipText = sensors[i].tip.title.toUpperCase();
            } else {
                newDevice.tip = false;
                newDevice.tipText = "NO INCENTIVE";
            }
            formattedSensors.push(newSensor);
            formattedDevices.push(newDevice);
        }
        $sensors.setSensors(formattedSensors);
        $devices.setDevices(formattedDevices);

        applyScope();
    }

    /**
     *  @function Perch.HybridJS.changeSensorValue
     *
     *  @description
     *  Receives the most up-to-date sensor information from the native and sets it in Angular.
     *
     *  @param  {int} sensorValue The new value to set the sensor to
     *  @param  {int} sensorAlert The alert status to set
     *  @param  {Object} sensorAlertDetail Detailed information about the alert state.
     */
    function changeSensorValue(sensorValue, sensorAlert, sensorAlertDetail) {
        var appWrapper = document.getElementById('perch-app');
        var $inj = angular.element(appWrapper).injector();
        var $sensors = $inj.get('Sensors');
        $sensors.updateSensor(sensorValue, sensorAlert, sensorAlertDetail);

        applyScope();
    }

    /**
     *  @function Perch.HybridJS.initGraph
     *
     *  @description
     *  Initializes historical graph data received from the native side
     *  fired every time we load an asset detail page, so deviceToView is safe to use.
     *
     *  @param  {Object} historicalData The historical graph data.
     */
    function initGraph(historicalData) {
        var appWrapper = document.getElementById('perch-app');
        var $inj = angular.element(appWrapper).injector();
        var $graph = $inj.get('GraphService');
        var $linestrat = $inj.get('PerchLineGraphStrategy');
        var $barstrat = $inj.get('PerchBarGraphStrategy');
        var $devices = $inj.get('Devices');

        // Initialize the graphs with historical data and device data.
        var dayGraph = new $linestrat($graph.coerceData(historicalData[0].reverse(), 'day'), $devices.deviceToView.maxThreshold, 55, $devices.deviceToView.displayUnit);
        var weekGraph = new $barstrat($graph.coerceData(historicalData[1].reverse(), 'week'), $devices.deviceToView.maxThreshold, 45, $devices.deviceToView.displayUnit, 25);
        var monthGraph = new $barstrat($graph.coerceData(historicalData[2].reverse(), 'month'), $devices.deviceToView.maxThreshold, 80, $devices.deviceToView.displayUnit, 45);
        $graph.setGraphStrategies({'day': dayGraph, 'week': weekGraph, 'month': monthGraph});

        applyScope();
    }

    // -----------------------------------------

    /**
     *  @function Perch.HybridJS.onBackButtonClicked
     *
     *  @description
     *  Captures when the navbar back button is clicked and goes to previous route using the history API.
     */
    function onBackButtonClicked() {
        console.log('Back Pressed!');
        window.history.back();
    }

    /**
     *  @function Perch.HybridJS.receiveAction
     *
     *  @description
     *  Acts as an observer to determine which action was fired.
     *
     *  @param  {Object} received The action which was fired and the data passed with it.
     */
    function receiveAction(received) {

        // Always purge the graph when an action is received
        // This way, the data is always "fresh"

        WL.Logger.info("Action received: " + String(received.action));
        switch (received.action) {
        case 'backButtonClicked':
            onBackButtonClicked();
            break;
        case 'changePage':
            changePage(received.data.route);
            break;
        case 'InitSensors':
            initSensors(received.data.sensors);
            break;
        case 'UpdateSensor':
            changeSensorValue(received.data.curValue, received.data.status, received.data.alert);
            break;
        case 'InitGraph':
            initGraph(received.data.historicalData);
            break;
        default:
            console.log('No handler for this action: ' + received.action);
        }
    }

    /**
     *  @function Perch.HybridJS.updatePage
     *
     *  @description
     *  Updates the native nav bar's title, needed for first screen.
     *
     *  @param  {string} newTitle The title to set
     */
    function updatePage(newTitle, newRoute, showBack, headerColor) {
        try {
            WL.App.sendActionToNative('updatePage', {
                title: newTitle,
                route: newRoute,
                showBackButton: showBack,
                headerColor: headerColor
            });

        } catch (e) {
            console.log('Worklight is not running properly');
            console.log(e.message);
        }
    }

    /**
     *  @function Perch.HybridJS.viewAlert
     *
     *  @description
     *  Sends a message to the native to change the page, so the user can view an alert
     *
     *  @param  {String} deviceClassId The ID of the current device.
     */
    function viewAlert(deviceClassId, alertDetail) {
        WL.App.sendActionToNative("viewAlert", {
            customData: deviceClassId,
            value: alertDetail.value,
            message: alertDetail.message,
            detail: alertDetail.detail,
            timestamp: alertDetail.timestamp,
            partner: alertDetail.partner
        });
    }

    /**
     *  @function Perch.HybridJS.viewIncentive
     *
     *  @description
     *  Sends a message to the native to change the page, so the user can view an incentive.
     *
     *  @param  {String} deviceClassId The ID of the current device.
     */
    function viewIncentive(deviceClassId) {
        WL.App.sendActionToNative("viewIncentive", {
            deviceClassId: deviceClassId
        });
    }

    /**
     *  @function Perch.HybridJS.changePage
     *
     *  @description
     *  Changes the page to the new route, callback is needed so native can perform the push animation.
     *
     *  @param  {Object} rote The route to go to.
     */
    function changePage(route) {
        window.location.hash = '#/' + route;
        if (route === '') {
            updatePage('SENSOR DETAIL', '', false, '#ffffff');
        }

        // Ungunk the graph service so that stale data doesn't
        // persist across sensors
        var appWrapper = document.getElementById('perch-app');
        var $inj = angular.element(appWrapper).injector();
        var $graph = $inj.get('GraphService');
        $graph.setGraphStrategies(undefined);
    }

    /**
     *  @function Perch.HybridJS.init
     *
     *  @description
     *  Initialize the object with the action receiver to get native actions.
     */
    function init() {
        try {
            WL.App.addActionReceiver('myActionReceiver', receiveAction);
        } catch (e) {
            console.log('faild to setup action receiver');
        }
    }

    return {
        init: init,
        updatePage: updatePage,
        viewAlert: viewAlert,
        viewIncentive: viewIncentive
    };
}());
