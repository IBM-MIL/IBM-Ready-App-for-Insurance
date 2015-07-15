/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 *  This sample program is provided AS IS and may be used, executed, copied and modified without royalty
 *  payment by customer (a) for its own instruction and study, (b) in order to develop applications designed to
 *  run with an IBM product, either for customer's own internal use or for redistribution by customer, as part
 *  of such an application, in customer's own products.
 */
var angular, englishTranslations, spanishTranslations;

(function () {
    'use strict';

    /**
     *  @namespace Perch
     *  @description Defines the {@linkcode Perch} module, as well as sets up routing for the Angular app.
     *  @author Jonathan Ballands
     *  @author Blake Ball
     *  @author Jim Avery
     *  @copyright © 2015 IBM Corporation. All Rights Reserved.
     */
    angular.module('Perch', ['ngAnimate', 'ngTouch', 'ngSanitize', 'ngRoute', 'pascalprecht.translate']);

    angular.module('Perch').config(function ($routeProvider, $translateProvider) {
        $routeProvider
            .when('/sensorDetail/:deviceClassId', {
                templateUrl: 'app/sensorDetail/sensorDetail.html',
                controller: 'SensorDetailController',
                controllerAs: 'SensorDetail'
            })
            .otherwise({
                redirectTo: '/loading'
            });
        $translateProvider
            .translations('en', englishTranslations)
            .translations('es', spanishTranslations)
            .preferredLanguage('en');
    });
}());
