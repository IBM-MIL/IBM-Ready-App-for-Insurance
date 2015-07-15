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

/**
 *  @class Perch.SensorDetailCtrl
 *  @memberOf Perch
 *  @description
 *  The controller for the asset/sensor detail view. Handles asset switching, graph display, and the like.
 *
 *  @see {@linkcode sensorDetail.html}
 *  @author Jim Avery
 *  @author Jon Ballands
 *  @author Blake Ball
 *  @copyright © 2015 IBM Corporation. All Rights Reserved.
 */

var angular, HybridJS;

(function () {
    'use strict';

    angular.module('Perch').controller('SensorDetailController', ['Sensors', 'Devices', '$scope', '$document', '$routeParams', 'PerchLineGraphStrategy', 'PerchBarGraphStrategy', 'GraphService', function (Sensors, Devices, $scope, $document, $routeParams, PerchLineGraphStrategy, PerchBarGraphStrategy, GraphService) {

        // Adding in factories.
        var ctrl = this;
        ctrl.sensor = Sensors;
        ctrl.device = Devices;

        // Images are hardcoded, so here we will associate images with their appropriate device class IDs.
        ctrl.images = [{
            deviceClassId: '10001',
            displayIcon: 'assets/images/watermeter_detail.png'
        }, {
            deviceClassId: '10002',
            displayIcon: 'assets/images/ac_detail.png'
        }, {
            deviceClassId: '10003',
            displayIcon: 'assets/images/sewer_detail.png'
        }];

        function selectImageById(deviceClassId) {
            for (var i = 0; i < ctrl.images.length; i++) {
                if (deviceClassId === ctrl.images[i].deviceClassId) {
                    ctrl.imageToView = ctrl.images[i];
                    return;
                }
            }

            ctrl.imageToView = {
                deviceClassId: '0',
                displayIcon: null
            };
        }

        selectImageById($routeParams.deviceClassId);

        // We need to watch the sensor and device factories, so we can load in all of the device
        // and sensor data, overwriting the defaults.
        $scope.$watch(function() { return ctrl.sensor.allSensors; }, function(newValue, oldValue) {
            ctrl.sensor.setSensorToView(ctrl.currentDevice.sensorName);
            ctrl.currentSensor = ctrl.sensor.sensorToView;
            ctrl.alertState = ctrl.currentSensor.alertState > 0;
            if (ctrl.sensor.sensorsLoaded() !== false) {
                ctrl.noDataMessage = undefined;
            }
        }, true);

        $scope.$watch(function() { return ctrl.device.allDevices; }, function(newValue, oldValue) {
            ctrl.device.setDeviceToViewById($routeParams.deviceClassId);
            ctrl.currentDevice = ctrl.device.deviceToView;
            ctrl.sensor.setSensorToView(ctrl.currentDevice.sensorName);
            ctrl.currentSensor = ctrl.sensor.sensorToView;
            ctrl.alertState = ctrl.currentSensor.alertState > 0;
            if (ctrl.sensor.sensorsLoaded() !== false) {
                ctrl.noDataMessage = undefined;
            }
        }, true);

        // The default data to use, in case we never received anything (for gulp serve, mainly).
        var defaultSensors = [
            {
                sensorName: 'Water Meter',
                sensorValue: "N/A",
                alertState: 1,
                alertDetail: {
                    value: null,
                    message: "Unusual levels of water consumption.",
                    detail: null,
                    timestamp: null
                },
                timestamp: 1429131527
            },
            {
                sensorName: 'Air Conditioner',
                sensorValue: "N/A",
                alertState: 0,
                alertDetail: {
                    value: null,
                    message: null,
                    detail: null,
                    timestamp: null
                },
                timestamp: 1429131535
            },
            {
                sensorName: 'Sewer System',
                sensorValue: "N/A",
                alertState: 0,
                alertDetail: {
                    value: null,
                    message: null,
                    detail: null,
                    timestamp: null
                },
                timestamp: 1429131568
            }
        ];

        ctrl.device = Devices;
        var newDevices = [{
            deviceName: 'ac',
            deviceClassId: '10002',
            displayName: 'Air Conditioner',
            displayUnit: '°C',
            displayIcon: 'assets/images/ac_detail.png',
            displayAvgVal: 'N/A',
            displayAvgMsg: 'Average temperature',
            detailName: 'Ocean Breeze AC Horizontal Cased Coil',
            detailAge: '3',
            detailMfrNo: 'CHPF1824A6',
            tip: true,
            tipText: 'GET $40 OFF YOUR POLICY',
            sensorName: 'Air Conditioner'
        }, {
            deviceName: 'water',
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
        }, {
            deviceName: 'sewer',
            deviceClassId: '10003',
            displayName: 'Sewer System',
            displayUnit: ' kL',
            displayIcon: 'assets/images/sewer_detail.png',
            displayAvgVal: 'N/A',
            displayAvgMsg: 'Average usage per minute',
            detailName: 'Pipeline 5000 Liter Septic Tank',
            detailAge: '22',
            detailMfrNo: 'N-417778',
            tip: false,
            tipText: 'NO TIP',
            sensorName: 'Sewer System'
        }];

        // This code will initialize the graphs and handle graph switching.
        
        ctrl.graphType = 0;
        ctrl.graphStrategies = GraphService.getGraphStrategies();
        if (ctrl.graphStrategies) {
          ctrl.currentStrategy = ctrl.graphStrategies.day;
        } else {
          ctrl.currentStrategy = undefined;
        }

        ctrl.handleGraphTabTouch = function(tab) {
          switch(tab) {
            case 'day':
              if (ctrl.graphType === 0) return;
              ctrl.graphType = 0;

              if (ctrl.graphStrategies) {
                ctrl.currentStrategy = ctrl.graphStrategies.day;
              }
              break;
            case 'week':
              if (ctrl.graphType === 1) return;
              ctrl.graphType = 1;

              if (ctrl.graphStrategies) {
                ctrl.currentStrategy = ctrl.graphStrategies.week;
              }
              break;
            case 'month':
              if (ctrl.graphType === 2) return;
              ctrl.graphType = 2;

              if (ctrl.graphStrategies) {
                ctrl.currentStrategy = ctrl.graphStrategies.month;
              }
              break;
            default:
              if (ctrl.graphStrategies) {
                ctrl.currentStrategy = ctrl.graphStrategies.day;
              }
              ctrl.graphType = 0;
          }

          $scope.$broadcast('newPerchGraphStrategy');
        };

        GraphService.registerObserver(function() {
          ctrl.graphStrategies = GraphService.getGraphStrategies();
          if (ctrl.graphStrategies) {
            ctrl.currentStrategy = ctrl.graphStrategies.day;
          }

          $scope.$digest();
          $scope.$broadcast('newPerchGraphStrategy');
        });

        // Initialize devices and sensors, based on whatever was passed in the route.

        // Did device data not get loaded?
        if (ctrl.device.devicesLoaded() === false) {
            ctrl.device.setDevices(newDevices);
        }
        ctrl.device.setDeviceToViewById($routeParams.deviceClassId);
        ctrl.currentDevice = ctrl.device.deviceToView;

        // Did sensor data not get sent? We need to handle that with an error message.
        if (ctrl.sensor.sensorsLoaded() === false) {
            ctrl.sensor.setSensors(defaultSensors);
            ctrl.noDataMessage = "No data received.";
        }
        ctrl.sensor.setSensorToView(ctrl.currentDevice.sensorName);
        ctrl.currentSensor = ctrl.sensor.sensorToView;

        // Random images needed.
        ctrl.rightArrow = 'assets/images/right_arrow.png';
        ctrl.orangeArrow = 'assets/images/right_arrow_orange.png';
        ctrl.alertIcon = 'assets/images/alert_icon.png';

        // If we're in an alert state, several things change.
        ctrl.alertState = ctrl.currentSensor.alertState > 0;

        // Scrolling handlers. (Not currently used.)
        ctrl.topScrollBoundary = 65;
        ctrl.headerScroll = function (scrollData) {
            window.testScrollData = scrollData;
            var header = document.getElementById('scrollHeader');
            var headerHeight = header.getBoundingClientRect().height;
            var scrollRatio = headerHeight / scrollData.height;

            header.style.top = String(ctrl.topScrollBoundary - (headerHeight * scrollData.offScreenRatio.top)) + "px";
        };

        // If VIEW ALERT or an incentive are clicked, this function will
        // handle sending route change information vack to the native.
        ctrl.pathChange = function (message) {
            window.pathChangeMessage = message;
            if (message === 'alert') {
                HybridJS.viewAlert($routeParams.deviceClassId, ctrl.sensor.sensorToView.alertDetail);
            } else if (message === 'incentive') {
                HybridJS.viewIncentive($routeParams.deviceClassId);
            }
        };

    }]);
}());
