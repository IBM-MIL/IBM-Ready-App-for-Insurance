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
var angular;

(function () {
    'use strict';
    /**
     * @class Perch.Sensors
     * @memberOf Perch
     *
     * @description
     * Factory service for keeping track of the sensor data on the client side
     *
     * @author Jim Avery
     * @copyright © 2015 IBM Corporation. All Rights Reserved.
     */
    angular.module('Perch').factory('Sensors', function () {
        /**
         * Example Sensor
         *
         *  sensorName: 'Water Meter',
            sensorValue: "N/A",
            alertState: 1,
            alertDetail: {
                value: null,
                message: "Unusual levels of water consumption.",
                detail: null,
                timestamp: null
            },
            timestamp: 1429131527
         */
        var allSensors = [];
        var sensorToView = null;
        /**
         * Get a sensor based on the name.
         * @param {String} sensorName The name of the sensor to return
         */
        var getSensor = function (sensorName) {
            for (var i = 0; i < this.allSensors.length; i++) {
                var sensor = this.allSensors[i];
                if (sensorName === sensor.sensorName) {
                    return sensor;
                }
            }

            return null;
        };
        /**
         * Convenience function to set the user's sensors.
         * @param {Array(sensor)} sensors The sensors to set for the user
         */
        var setSensors = function (sensors) {
            this.allSensors = sensors;
            window.sensorFactory = this.allSensors;
            window.sensorLength = this.allSensors.length;
            window.sensorsLoaded = this.sensorsLoaded();
        };
        /**
         * Adds a sensor to the current list
         * @param {sensor} sensor The sensor to add
         */
        var addSensor = function (sensor) {
            this.allSensors.push(sensor);
        };
        /**
         * Removes a sensor using its unique name to locate it
         * @param  {sensor} sensorNameToDelete The sensor to remove from the list
         */
        var deleteSensor = function (sensorNameToDelete) {
            for (var i = 0; i < this.allSensors.length; i++) {
                var sensor = this.allSensors[i];
                if (sensorNameToDelete === sensor.sensorName) {
                    console.log(sensorNameToDelete);
                    this.allSensors.splice(i, 1);
                    console.log(this.allSensors);
                    break;
                }

            }
        };

        /**
         * Sets the current active sensor given the name of the sensor.
         * @param {String} sensorName The name of the sensor to set
         */
        var setSensorToView = function (sensorName) {
            var sensor = this.getSensor(sensorName);
            this.sensorToView = sensor;
        };
        /**
         * Updates the current sensor with a new value and alert status.
         * @param {int} sensorValue The new value to set
         * @param {int} sensorAlert The current alert state.
         * @param {OBject} sensorAlertDetail Detailed information about the alert.
         */
        var updateSensor = function (sensorValue, sensorAlert, sensorAlertDetail) {
            var sensor = this.sensorToView;
            if (angular.isDefined(sensorValue)) {
                sensor.sensorValue = sensorValue;
            }
            if (angular.isDefined(sensorAlert)) {
                sensor.alertState = sensorAlert;
            }
            if (angular.isDefined(sensorAlertDetail)) {
                sensor.alertDetail = sensorAlertDetail;
            } else {
                // We need a default blank value.
                sensor.alertDetail = {
                    value: null,
                    message: null,
                    detail: null,
                    timestamp: null
                };
            }
        };
        /**
         * Determines if any sensors have been loaded.
         * @return {boolean} Whether any sensors have been loaded.
         */
        var sensorsLoaded = function () {
            if (this.allSensors.length > 0) {
                return true;
            }
            
            return false;
        };

        return {
            allSensors: allSensors,
            sensorToView: sensorToView,
            getSensor: getSensor,
            setSensors: setSensors,
            addSensor: addSensor,
            deleteSensor: deleteSensor,
            setSensorToView: setSensorToView,
            updateSensor: updateSensor,
            sensorsLoaded: sensorsLoaded
        };
    });
}());