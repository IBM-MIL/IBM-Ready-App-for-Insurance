/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 *  This sample program is provided AS IS and may be used, executed, copied and modified without royalty
 *  payment by customer (a) for its own instruction and study, (b) in order to develop applications designed to
 *  run with an IBM product, either for customer's own internal use or for redistribution by customer, as part
 *  of such an application, in customer's own products.
 */

'use strict';

/**
 *  @class Perch.GraphService
 *  @memberOf Perch
 *
 *  @description
 *  A service whose responsibility is holding onto graph data recieved via
 *  {@linkcode Perch.HybridJS} and handing it off to any observers. This allows
 *  the observing controller and {@linkcode Perch.HybridJS} to work asyncronously
 *  to each other, guaranteeing that data will be available when the observing
 *  controller binds after {@linkcode Perch.HybridJS}.
 *
 *  @author Jonathan Ballands
 *  @copyright © 2015 IBM Corporation. All Rights Reserved.
 */
angular.module('Perch').service('GraphService', function() {

  var observers = [];
  var strategies = undefined;

  /**
   *  @function Perch.GraphService.notifyObservers
   *  @private
   *
   *  @description
   *  Fires the callback registered by any observing controllers.
   */
  var notifyObservers = function() {
    for (var i = 0 ; i < observers.length ; i++) {
      observers[i]();
    }
  }

  /**
   *  @function Perch.GraphService.registerObserver
   *
   *  @description
   *  Registers a callback to be fired by {@linkcode notifyObservers()}.
   */
  this.registerObserver = function(callback){
    observers.push(callback);
  }

  /**
   *  @function Perch.GraphService.setGraphStrategies
   *
   *  @description
   *  Sets an object of strategies for the "day", "week", and "month" tabs, as
   *  provided by {@linkcode Perch.HybridJS}.
   *
   *  @param {object} strats - An object with "day", "week", and "month" properties,
   *  each corresponding to a {@linkcode PerchGraphStrategy}.
   */
  this.setGraphStrategies = function(strats) {
    strategies = strats;
    notifyObservers();
  }

  /**
   *  @function Perch.GraphService.getGraphStrategies
   *
   *  @description
   *  Gets an object of strategies for the "day", "week", and "month" tabs, as
   *  provided by {@linkcode Perch.HybridJS}.
   *
   *  @return {object} An object with "day", "week", and "month" properties,
   *  each corresponding to a {@linkcode PerchGraphStrategy}.
   */
  this.getGraphStrategies = function() {
    return strategies;
  }

  /**
   *  @function Perch.GraphService.coerceData
   *
   *  @description
   *  Utility function that massages data provided directly from the server into
   *  a format that {@linkcode perchGraph} will accept.
   *
   *  @param {array<object>} data - Data in its raw form from the server; that is,
   *  containing objects with properties "timestamp" and "value", where "timestamp"
   *  is the milliseconds since epoch.
   *  @param {string} scope - Either "day", "week", "month", depending on how you
   *  want the data massaged.
   *
   *  @return {array<object>} -Data in a form that {@linkcode perchGraph} will
   *  accept; that is, containing objects with properties "x", "y", and "t". See
   *  {@linkcode Perch.PerchGraphStrategy.data()} to learn more about this format.
   */
  this.coerceData = function(data, scope) {
    var massaged = [];
    var a;

    if (data.length > 0) {
      a = moment(data[0].timestamp).format('A');
    }

    for (var i = 0 ; i < data.length ; i++) {
      var pt = data[i];
      var t;

      switch (scope) {
        case 'day':
          t = moment(pt.timestamp).format('h');

          // Use AM/PM if there's a switch
          if (moment(pt.timestamp).format('A') !== a) {
            t = moment(pt.timestamp).format('A');
            a = moment(pt.timestamp).format('A');
          }
          break;

        case 'week':
          t = moment(pt.timestamp).format('dd');
          break;

        case 'month':
          var m = moment(pt.timestamp);
          t = m.format('M/D');
          t += ' - ' + m.add(7, 'days').format('M/D');
          break;

        default:
          console.error('Bad scope argument... defaulting to day');
          t = moment(pt.timestamp).format('h');

          // Use AM/PM if there's a switch
          if ( moment(pt.timestamp).format('A') !== a) {
            t = moment(pt.timestamp).format('A');
          }
      }

      // Push
      massaged.push({'x': i, 'y': data[i].value, 't': t});

      // Save AM/PM and watch for a switch
      a = moment(pt.timestamp).format('A');
    }

    return massaged;
  }

});
