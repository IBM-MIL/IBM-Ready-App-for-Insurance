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
 *  @class Perch.PerchBarGraphStrategy
 *  @memberOf Perch
 *
 *  @description
 *  Strategy for bar graphs.
 *
 *  @param {array} data - The data that the graph should display.
 *  @param {number} threshold - The value for the y-axis that should act as the
 *  threshold. Any data points whose value above this will have the {@linkcode warning}
 *  style class.
 *  @param {number} delta - The amount of space between data points.
 *  @param {string} units - The units to use for the scubber on the graph.
 *  @param {number} barWidth - The width of the bars in the bar graph.
 *
 *  @implements {PerchGraphStrategy}
 *
 *  @author Jonathan Ballands
 *  @copyright © 2015 IBM Corporation. All Rights Reserved.
 */
angular.module('Perch').factory('PerchBarGraphStrategy', ['$filter', function($filter) {

  function PerchBarGraphStrategy(data, threshold, delta, units, barWidth) {
    this._data = data;
    this._x = d3.scale.linear();
    this._y = d3.scale.linear();
    this._threshold = threshold;
    this._delta = delta;
    this._units = units;
    this._barWidth = barWidth;
  }

  // Inherit
  PerchBarGraphStrategy.prototype = new PerchGraphStrategy();

  PerchBarGraphStrategy.prototype.x = function() {
    return this._x;
  }

  PerchBarGraphStrategy.prototype.y = function() {
    return this._y;
  }

  PerchBarGraphStrategy.prototype.data = function() {
    return this._data;
  }

  PerchBarGraphStrategy.prototype.delta = function() {
    return this._delta;
  }

  PerchBarGraphStrategy.prototype.threshold = function() {
    return this._threshold;
  }

  PerchBarGraphStrategy.prototype.units = function() {
    return this._units;
  }

  PerchBarGraphStrategy.prototype.onMeasure = function(measurements) {
    this._width = measurements.width;
    this._height = measurements.height;
  }

  PerchBarGraphStrategy.prototype.onDrawHud = function(hudGroup) {

    var vm = this;

    var safety_threshold = $filter('translate')('SAFETY_THRESHOLD');

    hudGroup.selectAll('path').remove();
    hudGroup.selectAll('text').remove();

    hudGroup.append('text')
             .attr('y', vm._y(vm._threshold) + 18)
             .attr('x', 18)
             .attr('class', 'threshold-text')
             .text(safety_threshold);

    hudGroup.append('text')
             .attr('y', vm._y(vm._threshold) + 18)
             .attr('x', 133)
             .attr('class', 'threshold-text')
             .text( vm._threshold + ' ' + vm._units);

    hudGroup.selectAll('path')
             .data([[{'x': 0, 'y': vm._threshold}, {'x': Math.ceil(vm._x.invert(vm._width)), 'y': vm._threshold}]])
             .enter().append('path')
             .attr('d', d3.svg.line()
               .x(function(d) { return vm._x(d.x); })
               .y(function(d) { return vm._y(d.y); })
             )
             .attr('class', 'threshold');
  }

  PerchBarGraphStrategy.prototype.onDrawGraph = function(dataGroup) {

    var vm = this;

    dataGroup.selectAll('rect').remove();

    dataGroup.selectAll('.bar')
             .data(vm._data)
             .enter().append('rect')
             .attr('x', function(d) { return vm._x(d.x) - (vm._barWidth / 2); })
             .attr('width', vm._barWidth)
             .attr('y', function(d) { return vm._y(d.y); })
             .attr('height', function(d) { return vm._height - vm._y(d.y) - 45; })  // 45 is _axisGutter
             .attr('class', function(d) {
               if (d.y >= vm._threshold) {
                 return 'warning';
               }
               return 'ok';
             });
  }

  return PerchBarGraphStrategy;

}]);
