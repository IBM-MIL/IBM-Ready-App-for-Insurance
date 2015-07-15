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
 *  @class Perch.PerchGraphController
 *  @memberOf Perch
 *
 *  @description
 *  The controller for the {@linkcode perchGraph} directive. Listens for the
 *  {@linkcode newPerchGraphStrategy} event to redigest the {@linkcode strategy}
 *  if a new one is plugged in.
 *
 *  @author Blake Ball
 *  @author Jonathan Ballands
 *  @copyright © 2015 IBM Corporation. All Rights Reserved.
 */
angular.module('Perch').controller('PerchGraphController', function($element, $scope) {

  var vm = this;

  // --------------------------

  /*
   *  Declarations
   */

  var _strategy;
  var _data, _biggestY, _biggestX;
  var _zoomBehavior;
  var _x, _y, _axis;
  var _width, _height;
  var _xAxis, _axisGutter, _axisOffset;
  var _svg, _dataGroup, _hudGroup, _axisGroup, _scrubber;
  var _mask, _maskShape, _maskGroup, _maskAxisGroup;
  var _animationSpeedSnap, _animationSpeedSwitch;

  var _focusDP, _started;

  // --------------------------

  /*
   *  Lifecycle
   */

  _started = false;

  /**
   *  @function Perch.PerchGraphController.onStart
   *
   *  @description
   *  Called when a {@linkcode newPerchGraphStrategy} event is heard. Only
   *  invoked once when the graph initializes itself; that is, called exactly
   *  one time when the graph is starting for the first time. May only be invoked
   *  properly if a {@linkcode strategy} attribute is provided on the directive.
   *
   *  Call this once to start the graphs and present data for the first time.
   */
  function onStart() {
    _strategy = vm.strategy;

    // Don't do anything if there's no strategy
    if (!_strategy) {
      return;
    }

    _width = $element[0].offsetWidth;
    _height = $element[0].offsetHeight;

    _axisGutter = 45;
    _axisOffset = 15;
    _animationSpeedSnap = .7;
    _animationSpeedSwitch = 1.5;

    // Bind graph to SVG
    bind();
    _started = true;
  }

  /**
   *  @function Perch.PerchGraphController.onRestart
   *
   *  @description
   *  Called when a {@linkcode newPerchGraphStrategy} event is heard. May be
   *  invoked many times. May only be invoked after {@linkcode onStart()} has been
   *  called, and should be invoked after a call to {@linkcode onStop()}. May only
   *  be invoked properly if a {@linkcode strategy} attribute is provided on the
   *  directive.
   *
   *  Call this after the graphs have been stopped and new data should be presented.
   */
  function onRestart() {
    _strategy = vm.strategy;

    // Don't do anything if there's no strategy or hasn't started
    if (!_strategy || !_started) {
      return;
    }

    // Kill all the SVGs before binding
    d3.select($element[0]).selectAll('svg').remove();

    // Bind graph to SVG
    bind();
  }

  /**
   *  @function Perch.PerchGraphController.onStop
   *
   *  @description
   *  Called when a {@linkcode newPerchGraphStrategy} event is heard. May be invoked
   *  many times. May only be invoked after {@linkcode onStart()} or
   *  {@linkcode onRestart()} has been called.
   *
   *  Call this to stop the graphs from presenting data.
   *
   *  @param {function} callback - The callback function to invoke when execution
   *  has finished.
   */
  function onStop(callback) {

    // Don't do anything if there's no strategy or hasn't started
    if (!_strategy || !_started) {
      return;
    }

    hideScrubber();

    _maskShape.transition()
              .duration(300)
              .ease('cubic-in')
              .attr('width', 0)
              .attr('transform', 'translate(0, 0)');

    updateDomain(1000, 'cubic-in', _animationSpeedSwitch, function() {
      if (callback) {
        callback();
      }
    });
  }

  // --------------------------

  /*
   *  Listeners
   */

  /**
   *  @function Perch.PerchGraphController.newPerchGraphStrategy
   *
   *  @description
   *  A listener that allows {@linkcode perchGraph} to react when a new
   *  {@linkcode strategy} is provided by its controller. When heard, checks if
   *  {@linkcode onStart()} has been executed. If so, calls {@linkcode onStop()} and
   *  then {@linkcode onRestart()} sequentially. Otherwise, only {@linkcode onStart()}
   *  is called.
   */
  $scope.$on('newPerchGraphStrategy', function() {
    if (!_started) {
      onStart();
    } else {
      onStop(function() {
        onRestart();
      });
    }
  });

  // --------------------------

  /*
   *  Behaviors
   */

  /**
   *  @function Perch.PerchGraphController.onPanStart
   *
   *  @description
   *  Called when {@linkcode zoomstart} is heard by the zoom behavior. Prepares
   *  the graph to receive panning gestures from the user.
   */
  function onPanStart() {
    hideScrubber();

    // Cancel transitions, if any
    _dataGroup.transition();
    _axisGroup.transition();
    _maskAxisGroup.transition();
  }

  /**
   *  @function Perch.PerchGraphController.onPanMove
   *
   *  @description
   *  Called when {@linkcode zoom} is heard by the zoom behavior. Translates the
   *  graph as panning gestures are recieved from the user.
   */
  function onPanMove() {
    var cx = _zoomBehavior.translate()[0];
    _dataGroup.attr('transform', 'translate(' + cx + ',0)');
    _axisGroup.attr('transform', 'translate(' + cx + ',' + (_height - _axisGutter + _axisOffset) + ')');
    _maskAxisGroup.attr('transform', 'translate(' + cx + ',' + (_height - _axisGutter + _axisOffset) + ')');
  }

  /**
   *  @function Perch.PerchGraphController.onPanStop
   *
   *  @description
   *  Called when {@linkcode zoomend} is heard by the zoom behavior. Snaps the
   *  graph to a data point and updates the y-axis to fit to the snapped point.
   */
  function onPanStop() {
    snap('cubic-out', 750);
    updateDomain(_focusDP.y * 2, 'elastic', _animationSpeedSnap);
    showScrubber();
  }

  // --------------------------

  /*
   *  Helpers
   */

  /**
   *  @function Perch.PerchGraphController.bind
   *
   *  @description
   *  Prepares the {@linkcode strategy} and binds the graph to the DOM when drawing.
   *  Usually invoked by {@linkcode onStart()} or {@linkcode onRestart()} to display
   *  new data.
   */
  function bind() {
    // Measured
    _strategy.onMeasure({'width': _width, 'height': _height});

    _data = _strategy.data();

    _zoomBehavior = d3.behavior.zoom();

    // Obtain the biggest Y value to get the range to animate in
    _biggestY = 0;
    for (var i = 0 ; i < _data.length ; i++) {
      var point = _data[i];
      if (point.y > _biggestY) {
        _biggestY = point.y;
      }
    }
    _biggestY += 1000;

    // Find the biggest X value to get the axis to display right
    var xs = _data.map(function(d) {
      return d.x;
    });
    _biggestX = xs.reduce(function(prev, curr, index, array) {
      return prev >= curr ? prev : curr;
    });

    // Set up scales
    _strategy.x().domain(_data.map(function(d) { return d.x; }));
    _strategy.x().range(_data.map(function(d) { return d.x * _strategy.delta(); }));
    _strategy.y().domain([0, _biggestY]);
    _strategy.y().range([_height - _axisGutter, 0]);

    _xAxis = d3.svg.axis()
              .scale(_strategy.x())
              .orient('bottom')
              .tickSize(0)
              .ticks(_data.length);

    _svg = d3.select($element[0]).append('svg')
             .attr('class', 'chart')
             .attr('width', _width)
             .attr('height', _height)
             .call(_zoomBehavior);

    _axisGroup = _svg.append('g')
                     .style('display', 'inline-block')
                     .attr('class', 'axis-group')
                     .attr('transform', 'translate(0,' + (_height - _axisGutter + _axisOffset) + ')');

    _axisGroup.call(_xAxis)
              .selectAll('text')
              .text(function (d,i) {
                 return _data[i].t;
              });

    _dataGroup = _svg.append('g')
                     .attr('class', 'data-group')
                     .style('display', 'inline-block');

    _hudGroup = _svg.append('g')
                    .attr('class', 'hud-group')
                    .style('display', 'inline-block');

    bindAxisMask();

    // Calculate time for snap based on length of the data
    var targetTime = _data.length * 70;

    // Adjust
    moveTo(0);
    snapTo(_data.length - 1, 'cubic-out', targetTime);
    updateDomain(_focusDP.y * 2, 'cubic-out', _animationSpeedSwitch);

    // Begin drawing
    invalidate();

    // Make scrubber
    _scrubber = _svg.append('text')
                    .attr('x', _width / 2)
                    .attr('y', _height / 2 - 50)
                    .attr('opacity', 0)
                    .attr('class', 'scrubber-text')
                    .text(_focusDP.y);
    showScrubber();

    // Add axis line
    _svg.append('g')
        .attr('class', 'axis-line-group')
        .selectAll('path')
        .data([[{'x': 0, 'y': _height - _axisGutter}, {'x': Math.ceil(_strategy.x().invert(_width)), 'y': _height - _axisGutter}]])
        .enter().append('path')
        .attr('d', d3.svg.line()
          .x(function(d) { return _strategy.x()(d.x); })
          .y(function(d) { return d.y; })
        )
        .attr('class', 'axis-line');

    // Set behaviors
    _zoomBehavior.on('zoomstart', function() {
      onPanStart();
    });

    _zoomBehavior.on('zoom', function() {
      onPanMove();
    });

    _zoomBehavior.on('zoomend', function() {
      onPanStop();
    });

  }

  /**
   *  @function Perch.PerchGraphController.bindAxisMask
   *
   *  @description
   *  Prepares and binds the little orange dot that appears on the x-axis to the
   *  DOM. Invoked by {@linkcode bind()} when it has finished binding other DOM
   *  elements.
   */
  function bindAxisMask() {

    _mask = _svg.append('defs')
                .append('mask')
                .attr('id', 'dot')
                .attr('width', _width)
                .attr('height', _axisGutter)
                .attr('x', 0)
                .attr('y', 0);

    _maskShape = _mask.append('rect')
                      .attr('width', 0)
                      .attr('height', 15)
                      .attr('x', _width / 2)
                      .attr('y', _height - _axisGutter + 15)
                      .attr('rx', 7)
                      .attr('ry', 7)
                      .style('fill', '#FFF');

    _maskGroup = _svg.append('g')
                     .attr('class', 'mask-group')
                     .attr('width', _width)
                     .attr('height', _axisGutter)
                     .attr('x', 0)
                     .attr('y', _height - _axisGutter)
                     .attr('mask', 'url(#dot)');

    _maskGroup.append('rect')
              .attr('width', _width)
              .attr('height', _axisGutter)
              .attr('x', 0)
              .attr('y', _height - _axisGutter)
              .style('fill', '#ff7832');

    _maskAxisGroup = _maskGroup.append('g')
                               .attr('class', 'mask-axis-group')
                               .style('display', 'inline-block')
                               .attr('transform', 'translate(0,' + (_height - _axisGutter + _axisOffset) + ')');

    _maskAxisGroup.call(_xAxis)
                  .selectAll('text')
                  .attr('fill', 'white')
                  .text(function (d,i) {
                    return _data[i].t;
                  });
  }

  /**
   *  @function Perch.PerchGraphController.snap
   *
   *  @description
   *  Snaps the data point closet to the center of the SVG to the center of the
   *  SVG with animations.
   *
   *  @param {string} ease - The d3 easing function to use, e.g. cubic-in, linear,
   *  quad, etc.
   *  @param {number} duration - The length of the snap animation in milliseconds.
   */
  function snap(ease, duration) {

    var center = (_zoomBehavior.translate()[0] * -1) + (_width / 2);
    var indexSnapPoint = findClosestIndex(center);

    snapTo(indexSnapPoint, ease, duration);
  }

  /**
   *  @function Perch.PerchGraphController.snapTo
   *
   *  @description
   *  Snaps the data point at {@linkcode index} to the center of the SVG with
   *  animations.
   *
   *  @param {number} index - The index of the data point to snap to.
   *  @param {string} ease - The d3 easing function to use, e.g. cubic-in, linear,
   *  quad, etc.
   *  @param {number} duration - The length of the snap animation in milliseconds.
   */
  function snapTo(index, ease, duration) {

    if (index >= _data.length || index < 0) {
      return;
    }

    var snapPoint = _data[index].x;
    var sx = (_strategy.x()(snapPoint) - (_width / 2)) * -1;

    _dataGroup
      .transition()
      .duration(duration)
      .ease(ease)
      .attr('transform', 'translate(' + sx + ',0)');

    _axisGroup
      .transition()
      .duration(duration)
      .ease(ease)
      .attr('transform', 'translate(' + sx + ',' + (_height - _axisGutter + _axisOffset) + ')');

    _maskAxisGroup
      .transition()
      .duration(duration)
      .ease(ease)
      .attr('transform', 'translate(' + sx + ',' + (_height - _axisGutter + _axisOffset) + ')');

    _zoomBehavior.translate([sx, _zoomBehavior.translate()[1]]);

    // Update the size of the dot
    var tickBBox = _maskAxisGroup.selectAll('g')[0][index].getBBox();
    var newMaskWidth = tickBBox.width;
    var maskPadding = 8;
    var newMaskX = tickBBox.x - (maskPadding / 2);

    _maskShape.transition()
              .duration(duration)
              .ease(ease)
              .attr('width', newMaskWidth + maskPadding)
              .attr('transform', 'translate(' + newMaskX + ', 0)');

    _focusDP = _data[index];
  }

  /**
   *  @function Perch.PerchGraphController.moveTo
   *
   *  @description
   *  Moves the data point at {@linkcode index} to the center of the SVG without
   *  animations.
   *
   *  @param {number} index - The index of the data point to move to.
   */
  function moveTo(index) {
    if (index >= _data.length || index < 0) {
      return;
    }

    var snapPoint = _data[index].x;
    var sx = (_strategy.x()(snapPoint) - (_width / 2)) * -1;

    _dataGroup
      .attr('transform', 'translate(' + sx + ',0)');

    _axisGroup
      .attr('transform', 'translate(' + sx + ',' + (_height - _axisGutter + _axisOffset) + ')');

    _maskAxisGroup
      .attr('transform', 'translate(' + sx + ',' + (_height - _axisGutter + _axisOffset) + ')');

    _zoomBehavior.translate([sx, _zoomBehavior.translate()[1]]);

    // Update the size of the dot
    var tickBBox = _maskAxisGroup.selectAll('g')[0][index].getBBox();
    var newMaskWidth = tickBBox.width;
    var maskPadding = 8;
    var newMaskX = tickBBox.x - (maskPadding / 2);

    _maskShape.attr('width', newMaskWidth + maskPadding)
              .attr('transform', 'translate(' + newMaskX + ', 0)');

    _focusDP = _data[index];
  }

  /**
   *  @function Perch.PerchGraphController.updateDomain
   *
   *  @description
   *  Recalculates and resizes the domain for the y-axis so that it appears
   *  to stretch and contract, depending on the value of the {@linkcode target}.
   *
   *  @param {number} target - The target value for the highest point of the
   *  y-axis' domain. Usually this value is two-times the amount of the value
   *  of the data point that was snapped to. Defaults to 10 if this argument is
   *  less than 10.
   *  @param {string} ease - The d3 easing function to use, e.g. cubic-in, linear,
   *  quad, etc.
   *  @param {number} speed - Multiplier for the standard 3% progress rate that
   *  the resizing animation uses, known as the "sweet spot". For example, if
   *  following a linear easing path and this argument is one, the animation will
   *  progress at a rate of 3% per frame. If this argument is two and a linear
   *  easing path is used, the animation will progress at a rate of 6% per frame.
   *  @param {function} callback - The callback function to invoke when execution
   *  has finished.
   */
  function updateDomain(target, ease, speed, callback) {

    // Prevent a domain of [0, 0]
    if (target < 10) {
      target = 10;
    }

    var _sweetSpot = 0.03;
    var calculatedSpeed = speed * _sweetSpot;
    var progress = 0;

    var easingFn = d3.ease(ease, 1, 1.2);
    var interpolationFn = d3.interpolate(_strategy.y().domain()[1], target);

    d3.timer(function(t) {

      var elapsed = easingFn(progress);
      var position = interpolationFn(elapsed);

      _strategy.y().domain([0, position]);

      // Draw
      invalidate();

      if (progress >= 1) {
        if (callback) {
          callback();
        }
        return true;
      }
      else {
        progress += calculatedSpeed;
        return false;
      }
    });
  }

  /**
   *  @function Perch.PerchGraphController.invalidate
   *
   *  @description
   *  Called when a graph has to be drawn. Drawing is defined as drawing the
   *  actual shapes on the SVG. It does not include resizing domains or translating
   *  the SVG.
   */
  function invalidate() {
    _strategy.onDrawGraph(_dataGroup);
    _strategy.onDrawHud(_hudGroup);
  }

  /**
   *  @function Perch.PerchGraphController.showScrubber
   *
   *  @description
   *  Presents the scrubber with animations, using the value of the focused
   *  data point as the value for the scubber.
   */
  function showScrubber() {
    _svg.selectAll('.scrubber-text')
        .transition()
        .duration(200)
        .attr('y', _height / 2 - _axisGutter + _axisOffset - 5)
        .attr('opacity', 1)
        .text(_focusDP.y + ' ' + _strategy.units());
  }

  /**
   *  @function Perch.PerchGraphController.hideScrubber
   *
   *  @description
   *  Hides the scubber with animations.
   */
  function hideScrubber() {
   _svg.selectAll('.scrubber-text')
     .transition()
     .attr('y', _height / 2 - _axisGutter + _axisOffset - 25)
     .attr('opacity', 0);
  }

  /**
   *  @function Perch.PerchGraphController.findClosestIndex
   *
   *  @description
   *  Inverts a range value on {@linkcode strategy.data().x} and finds the index
   *  of the data point who's range value is closest to the argument.
   *
   *  @param {number} center - Range value to query on all {@linkcode strategy.data().x}.
   *
   *  @return {number} The index of the data point in {@linkcode strategy.data()}
   *  who's ranged x property is closest to {@linkcode center}.
   */
  function findClosestIndex(center) {
    var cx = _strategy.x().invert(center);

    var distances = _data.map(function(d) {
      return Math.abs(d.x - cx);
    });

    var smallest = distances.reduce(function(prev, curr, index, array) {
      return prev <= curr ? prev : curr;
    });

    return distances.indexOf(smallest);
  }

  // --------------------------

  // Go
  onStart();

});

// ------------------------------------------------------------

/**
 *  @class Perch.perchGraph
 *  @memberOf Perch
 *
 *  @description
 *  Directive that can display Perch-style graphs given a {@linkcode strategy}.
 *  Broadcasting the {@linkcode newPerchGraphStrategy} event will cause this
 *  directive to redigest and update.
 *
 *  @example
 *  <perch-graph strategy='ctrl.barStrategy'></perch-graph>
 *
 *  @author Blake Ball
 *  @author Jonathan Ballands
 *  @copyright © 2015 IBM Corporation. All Rights Reserved.
 */
angular.module('Perch').directive('perchGraph', function() {

 return {
   restrict: 'E',
   scope: {
     'strategy': '='
   },
   controller: 'PerchGraphController',
   controllerAs: 'ctrl',
   bindToController: true
 };

});
