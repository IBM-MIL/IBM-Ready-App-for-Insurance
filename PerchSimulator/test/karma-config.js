/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */

module.exports = function (config) {
    config.set({
        basePath: '',

        frameworks: ['jasmine-jquery', 'jasmine'],

        files: [
            '../public/js/jquery.js',
            '../public/js/bootstrap.js',
            '../public/js/fastclick.js',
            '../public/js/mqttws31.js',
            '../public/js/main.js',

            './spec/*.js'
        ],

        exclude: [
        ],

        preprocessors: {},

        reporters: ['progress'],
        port: 9876,
        colors: true,
        logLevel: config.LOG_INFO,
        autoWatch: false,
        browsers: ['Safari', 'Chrome'],
        singleRun: true,

        client: {
            captureConsole: true
        }
    });
};