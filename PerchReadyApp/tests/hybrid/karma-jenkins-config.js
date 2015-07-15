/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */

module.exports = function (config) {
    config.set({
        basePath: '',

        frameworks: ['jasmine'],

        files: [
            // Vendor
            '../../apps/Perch/bower_components/angular/angular.js',
            '../../apps/Perch/bower_components/angular-animate/angular-animate.js',
            '../../apps/Perch/bower_components/angular-mocks/angular-mocks.js',
            '../../apps/Perch/bower_components/angular-route/angular-route.js',
            '../../apps/Perch/bower_components/angular-sanitize/angular-sanitize.js',
            '../../apps/Perch/bower_components/angular-touch/angular-touch.js',
            '../../apps/Perch/bower_components/angular-translate/angular-translate.js',
            '../../apps/Perch/bower_components/d3/d3.js',
            '../../apps/Perch/bower_components/moment/moment.js',

            // Src
            '../../apps/Perch/src/app/*.js',
            '../../apps/Perch/src/app/**/*.js',

            // Specs
            './spec/**/*.js'
        ],

        exclude: [
        ],

        preprocessors: {},

        reporters: ['progress', 'dots', 'junit'],
        junitReporter: {
            outputFile: 'test-results.xml'
        },
        port: 9876,
        colors: true,
        logLevel: config.LOG_INFO,
        autoWatch: false,
        browsers: ['Chrome', 'Safari'],
        singleRun: true,

        client: {
            captureConsole: true
        }
    });
};