/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 *  This sample program is provided AS IS and may be used, executed, copied and modified without royalty
 *  payment by customer (a) for its own instruction and study, (b) in order to develop applications designed to
 *  run with an IBM product, either for customer's own internal use or for redistribution by customer, as part
 *  of such an application, in customer's own products.
 */

/**
 *  @interface PerchGraphStrategy
 *
 *  @description
 *  Strategy interface that is used by the {@linkcode perchGraph} directive.
 *  A {@linkcode PerchGraphStrategy} is responsible for the rendering of a graph
 *  on the {@linkcode perchGraph}. It knows all of the graph's properties,
 *  including its data and d3 scales. It also knows how to draw itself via the
 *  {@linkcode onDrawGraph()} and {@linkcode onDrawHud()} functions.
 *
 *  @author Jonathan Ballands
 *  @copyright © 2015 IBM Corporation. All Rights Reserved.
 */
function PerchGraphStrategy() { /* Nothing to do */ }

/**
 *  @function PerchGraphStrategy.x
 *
 *  @description
 *  Required. Provides the d3 scale for the x-axis of the graph. Any configuration
 *  to the scale will be overridden by {@linkcode perchGraph}.
 *
 *  @return {d3.scale} A [d3 scale]{@link https://github.com/mbostock/d3/wiki/API-Reference#d3scale-scales}.
 */
PerchGraphStrategy.prototype.x = function() {
  throw new Error('x not implemented');
}

/**
 *  @function PerchGraphStrategy.y
 *
 *  @description
 *  Required. Provides the d3 scale for the y-axis of the graph. Any configuration
 *  to the scale will be overridden by {@linkcode perchGraph}.
 *
 *  @return {d3.scale} A [d3 scale]{@link https://github.com/mbostock/d3/wiki/API-Reference#d3scale-scales}.
 */
PerchGraphStrategy.prototype.y = function() {
  throw new Error('y not implemented');
}

/**
 *  @function PerchGraphStrategy.data
 *
 *  @description
 *  Required. Provides data for the graph in the form of the example. In general,
 *  {@linkcode x} must be positive integers in accending order, but not necessarily
 *  sequential, {@linkcode y} must be positive integers, and {@linkcode t} is an
 *  arbitrary string used to tick the x-axis.
 *
 *  @example
 *  [{ 'x': 0, 'y': 5, 't': 'Red' }, { 'x': 1, 'y': 9, 't': 'Blue'}]
 *
 *  @return {array<object>} The data array to graph.
 */
PerchGraphStrategy.prototype.data = function() {
  throw new Error('data not implemented');
}

/**
 *  @function PerchGraphStrategy.delta
 *
 *  @description
 *  Required. Provides the amount of space, in pixels, that should be placed
 *  between data points.
 *
 *  @return {integer} The amount of space between data points.
 */
PerchGraphStrategy.prototype.delta = function() {
  throw new Error('delta not implemented');
}

/**
 *  @function PerchGraphStrategy.theshold
 *
 *  @description
 *  Required. Provides the threshold value such that any data point whose value
 *  surprasses this will appear yellow.
 *
 *  @return {integer} The threshold value.
 */
PerchGraphStrategy.prototype.threshold = function() {
  throw new Error('threshold not implemented');
}

/**
 *  @function PerchGraphStrategy.units
 *
 *  @description
 *  Required. Provides the units for the value of each data point.
 *
 *  @return {string} The unit for the value of each data point.
 */
PerchGraphStrategy.prototype.units = function() {
  throw new Error('units not implemented');
}

/**
 *  @function PerchGraphStrategy.onMeasure
 *
 *  @description
 *  Required. Called when the {@linkcode perchGraph} has established its size.
 *  This allows the strategy to lay itself out properly when the {@linkcode onDrawGraph()}
 *  and {@linkcode onDrawHud()} functions are called. The measurements are with
 *  respect to the entire SVG, not necessarily the drawing group.
 *
 *  @param {object} measurements - An object with a {@linkcode width} property
 *  and a {@linkcode height} property.
 */
PerchGraphStrategy.prototype.onMeasure = function(measurements) {
  throw new Error('onMeasure not implemented');
}

/**
 *  @function PerchGraphStrategy.onDrawHud
 *
 *  @description
 *  Optional. Called when the {@link perchGraph} is ready to draw the hud.
 *  The hud does not transform; that is, it does not translate on the
 *  [d3 zoom behavior]{@link https://github.com/mbostock/d3/wiki/Zoom-Behavior}. All
 *  animations and scale manipulations are handled by {@linkcode perchGraph}.
 *  This means this function's only responsibility is drawing the data based on the
 *  scales that you created and returned via {@linkcode x()} and {@linkcode y()}.
 *
 *  @param {selection} hudGroup - The [d3 selection]{@link https://github.com/mbostock/d3/wiki/Selections}
 *  that corresponds to the hud; this will be the drawing area.
 */
PerchGraphStrategy.prototype.onDrawHud = function(hudGroup) {
  /* Nothing to do... */
}

/**
 *  @function PerchGraphStrategy.onDrawGraph
 *
 *  @description
 *  Optional. Called when the {@link perchGraph} is ready to draw the graph.
 *  The graph will be transformed with a translation on the
 *  [d3 zoom behavior]{@link https://github.com/mbostock/d3/wiki/Zoom-Behavior}. All
 *  animations and scale manipulations are handled by {@linkcode perchGraph}.
 *  This means this function's only responsibility is drawing the data based on the
 *  scales that you created and returned via {@linkcode x()} and {@linkcode y()}.
 *
 *  @param {selection} graphGroup - The [d3 selection]{@link https://github.com/mbostock/d3/wiki/Selections}
 *  that corresponds to the graph; this will be the drawing area.
 */
PerchGraphStrategy.prototype.onDrawGraph = function(graphGroup) {
  /* Nothing to do... */
}
