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
     * @class Perch.Devices
     * @memberOf Perch
     *
     * @description
     * Factory service for easily sending device data to the hybrid side, and
     * determining which device page to display.
     *
     * @author Jim Avery
     * @copyright © 2015 IBM Corporation. All Rights Reserved.
     */
    angular.module('Perch').factory('Devices', function () {
        /**
         * Example Device
         *
         *  deviceName: 'water',
            deviceClassId: '10001',
            displayName: 'Water Meter',
            displayUnit: ' L',
            displayIcon: 'assets/images/watermeter_detail.png',
            displayAvgVal: 'N/A',
            displayAvgMsg: 'Average usage per minute',
            detailName: 'Poseidon Water Meter, T-10 (1\")',
            detailAge: '17',
            detailMfrNo: 'M67540',
            tip: false,
            tipText: 'NO TIP',
            sensorName: 'Water Meter'
         */
        var allDevices = [];
        var deviceToView = null;
        /**
         * Get a device based on the name.
         * @param {String} deviceName The name of the device to return
         * @return {device} device The device requested
         */
        var getDevice = function (deviceName) {
            for (var i = 0; i < this.allDevices.length; i++) {
                var device = this.allDevices[i];
                if (deviceName === device.deviceName) {
                    return device;
                }
            }

            return null;
        };
        /**
         * Get a device based on the class ID.
         * @param {String} deviceClassId The ID of the device to return
         * @return {device} device The device requested
         */
        var getDeviceById = function (deviceId) {
            for (var i = 0; i < this.allDevices.length; i++) {
                var device = this.allDevices[i];
                if (deviceId === device.deviceClassId) {
                    return device;
                }
            }

            return null;
        };
        /**
         * Convenience function to set the user's devices.
         * @param {Array(device)} devices The devices to set for the user
         */
        var setDevices = function (devices) {
            this.allDevices = devices;
        };
        /**
         * Adds a device to the current list
         * @param {device} device The device to add
         */
        var addDevice = function (device) {
            this.allDevices.push(device);
        };
        /**
         * Removes a device using its unique name to locate it
         * @param  {device} deviceNameToDelete The device to remove from the list
         */
        var deleteDevice = function (deviceNameToDelete) {
            for (var i = 0; i < this.allDevices.length; i++) {
                var device = this.allDevices[i];
                if (deviceNameToDelete === device.deviceName) {
                    console.log(deviceNameToDelete);
                    this.allDevices.splice(i, 1);
                    console.log(this.allDevices);
                    break;
                }

            }
        };

        /**
         * Sets the current active device given the name of the device.
         * @param {String} deviceName The name of the device to set
         */
        var setDeviceToView = function (deviceName) {
            var device = this.getDevice(deviceName);
            this.deviceToView = device;
        };
        /**
         * Sets the current active device given the class ID of the device.
         * @param {String} deviceClassId The ID of the device to set
         */
        var setDeviceToViewById = function (deviceClassId) {
            var device = this.getDeviceById(deviceClassId);
            this.deviceToView = device;
        };
        /**
         * Determines if any devices have been loaded.
         * @return {boolean} Whether any devices have been loaded.
         */
        var devicesLoaded = function () {
            if (this.allDevices.length > 0) {
                return true;
            }
            
            return false;
        };


        return {
            allDevices: allDevices,
            deviceToView: deviceToView,
            getDevice: getDevice,
            getDeviceById: getDeviceById,
            setDevices: setDevices,
            addDevice: addDevice,
            deleteDevice: deleteDevice,
            setDeviceToView: setDeviceToView,
            setDeviceToViewById: setDeviceToViewById,
            devicesLoaded: devicesLoaded
        };
    });
}());