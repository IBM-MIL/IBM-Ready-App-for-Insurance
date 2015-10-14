
/* JavaScript content from scripts/app.js in folder common */
/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 *  This sample program is provided AS IS and may be used, executed, copied and modified without royalty
 *  payment by customer (a) for its own instruction and study, (b) in order to develop applications designed to
 *  run with an IBM product, either for customer's own internal use or for redistribution by customer, as part
 *  of such an application, in customer's own products.
 */
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
function PerchGraphStrategy(){}function onConnectSuccess(){window.taylor="success",WL.Logger.debug("Successfully connected to Worklight Server."),WL.App.sendActionToNative("connectStatus",{status:!0})}function onConnectFailure(){window.jim="fail",WL.Logger.debug("Failed connecting to Worklight Server."),WL.App.sendActionToNative("connectStatus",{status:!1})}function wlCommonInit(){window.evan="please work";try{WL.Logger.debug("Attempting to connect to WL server..."),WL.Client.connect({onSuccess:onConnectSuccess,onFailure:onConnectFailure})}catch(e){console.log("Worklight is not running properly"),console.log(e.message)}HybridJS.init()}var angular,englishTranslations,spanishTranslations;!function(){"use strict";/**
     *  @namespace Perch
     *  @description Defines the {@linkcode Perch} module, as well as sets up routing for the Angular app.
     *  @author Jonathan Ballands
     *  @author Blake Ball
     *  @author Jim Avery
     *  @copyright © 2015 IBM Corporation. All Rights Reserved.
     */
angular.module("Perch",["ngAnimate","ngTouch","ngSanitize","ngRoute","pascalprecht.translate","MILResponsiveHybrid"]),angular.module("Perch").config(["$routeProvider","$translateProvider","$responsiveHybridProvider",function(e,t,r){e.when("/sensorDetail/:deviceClassId",{templateUrl:"app/sensorDetail/sensorDetail.html",controller:"SensorDetailController",controllerAs:"SensorDetail"}).otherwise({redirectTo:"/loading"}),t.translations("en",englishTranslations).translations("es",spanishTranslations).preferredLanguage("en"),r.setClassSpec(["IPHONE_5","IPHONE_6"],"warningSize","size18pt").setClassSpec(["IPHONE_6PLUS","IPAD"],"warningSize","size23pt").setClassSpec(["IPHONE_5","IPHONE_6"],"infoSize","size12pt").setClassSpec(["IPHONE_6PLUS","IPAD"],"infoSize","size15pt").setHtmlSpec(["IPHONE_5","IPHONE_6"],"imageSize","101px").setHtmlSpec(["IPHONE_6PLUS","IPAD"],"imageSize","125px").setDeviceStyles(["IPHONE_5","IPAD"],{testStyle:"color: red"}).setStyleSpec(["IPHONE_6","IPHONE_6PLUS"],"testStyle","color: blue").defaultDevice("IPHONE_6")}])}(),/**
 *  @class Perch.PerchLineGraphStrategy
 *  @memberOf Perch
 *
 *  @description
 *  Strategy for line graphs.
 *
 *  @implements {PerchGraphStrategy}
 *
 *  @author Jonathan Ballands
 *  @copyright © 2015 IBM Corporation. All Rights Reserved.
 */
angular.module("Perch").factory("PerchLineGraphStrategy",["$filter",function(e){function t(e,t,r,a){this._data=e,this._x=d3.scale.linear(),this._y=d3.scale.linear(),this._threshold=t,this._delta=r,this._units=a}return t.prototype=new PerchGraphStrategy,t.prototype.x=function(){return this._x},t.prototype.y=function(){return this._y},t.prototype.data=function(){return this._data},t.prototype.delta=function(){return this._delta},t.prototype.threshold=function(){return this._threshold},t.prototype.units=function(){return this._units},t.prototype.onMeasure=function(e){this._width=e.width,this._height=e.height},t.prototype.onDrawHud=function(t){var r=this,a=e("translate")("SAFETY_THRESHOLD");t.selectAll("path").remove(),t.selectAll("text").remove(),t.append("text").attr("y",r._y(this._threshold)+18).attr("x",18).attr("class","threshold-text").text(a),t.append("text").attr("y",r._y(r._threshold)+18).attr("x",133).attr("class","threshold-text").text(this._threshold+" "+this._units),t.selectAll("path").data([[{x:0,y:r._threshold},{x:Math.ceil(r._x.invert(r._width)),y:r._threshold}]]).enter().append("path").attr("d",d3.svg.line().x(function(e){return r._x(e.x)}).y(function(e){return r._y(e.y)})).attr("class","threshold")},t.prototype.onDrawGraph=function(e){var t=this;e.selectAll("path").remove(),e.selectAll("circle").remove(),e.selectAll("path").data([t._data]).enter().append("path").attr("d",d3.svg.line().x(function(e){return t._x(e.x)}).y(function(e){return t._y(e.y)})).attr("class","data"),e.selectAll("circle").data(t._data).enter().append("circle").attr("cx",function(e){return t._x(e.x)}).attr("cy",function(e){return t._y(e.y)}).attr("r",6).attr("class",function(e){return e.y>=t._threshold?"warning":"ok"})},t}]),PerchGraphStrategy.prototype.x=function(){throw new Error("x not implemented")},PerchGraphStrategy.prototype.y=function(){throw new Error("y not implemented")},PerchGraphStrategy.prototype.data=function(){throw new Error("data not implemented")},PerchGraphStrategy.prototype.delta=function(){throw new Error("delta not implemented")},PerchGraphStrategy.prototype.threshold=function(){throw new Error("threshold not implemented")},PerchGraphStrategy.prototype.units=function(){throw new Error("units not implemented")},PerchGraphStrategy.prototype.onMeasure=function(){throw new Error("onMeasure not implemented")},PerchGraphStrategy.prototype.onDrawHud=function(){},PerchGraphStrategy.prototype.onDrawGraph=function(){},/**
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
angular.module("Perch").controller("PerchGraphController",["$element","$scope",function(e,t){function r(){m=B.strategy,m&&(A=e[0].offsetWidth,_=e[0].offsetHeight,P=45,T=15,M=.7,V=1.5,l(),z=!0)}function a(){m=B.strategy,m&&z&&(d3.select(e[0]).selectAll("svg").remove(),l())}function n(e){m&&z&&(f(),L.transition().duration(300).ease("cubic-in").attr("width",0).attr("transform","translate(0, 0)"),u(1e3,"cubic-in",V,function(){e&&e()}))}function s(){f(),N.transition(),H.transition(),G.transition()}function i(){var e=x.translate()[0];N.attr("transform","translate("+e+",0)"),H.attr("transform","translate("+e+","+(_-P+T)+")"),G.attr("transform","translate("+e+","+(_-P+T)+")")}function o(){d("cubic-out",750),u(2*W.y,"elastic",M),v()}function l(){m.onMeasure({width:A,height:_}),S=m.data(),x=d3.behavior.zoom(),w=0;for(var t=0;t<S.length;t++){var r=S[t];r.y>w&&(w=r.y)}w+=1e3;var a=S.map(function(e){return e.x});D=a.reduce(function(e,t){return e>=t?e:t}),m.x().domain(S.map(function(e){return e.x})),m.x().range(S.map(function(e){return e.x*m.delta()})),m.y().domain([0,w]),m.y().range([_-P,0]),I=d3.svg.axis().scale(m.x()).orient("bottom").tickSize(0).ticks(S.length),b=d3.select(e[0]).append("svg").attr("class","chart").attr("width",A).attr("height",_).call(x),H=b.append("g").style("display","inline-block").attr("class","axis-group").attr("transform","translate(0,"+(_-P+T)+")"),H.call(I).selectAll("text").text(function(e,t){return S[t].t}),N=b.append("g").attr("class","data-group").style("display","inline-block"),C=b.append("g").attr("class","hud-group").style("display","inline-block"),c();var n=70*S.length;h(0),p(S.length-1,"cubic-out",n),u(2*W.y,"cubic-out",V),g(),k=b.append("text").attr("x",A/2).attr("y",_/2-50).attr("opacity",0).attr("class","scrubber-text").text(W.y),v(),b.append("g").attr("class","axis-line-group").selectAll("path").data([[{x:0,y:_-P},{x:Math.ceil(m.x().invert(A)),y:_-P}]]).enter().append("path").attr("d",d3.svg.line().x(function(e){return m.x()(e.x)}).y(function(e){return e.y})).attr("class","axis-line"),x.on("zoomstart",function(){s()}),x.on("zoom",function(){i()}),x.on("zoomend",function(){o()})}function c(){E=b.append("defs").append("mask").attr("id","dot").attr("width",A).attr("height",P).attr("x",0).attr("y",0),L=E.append("rect").attr("width",0).attr("height",15).attr("x",A/2).attr("y",_-P+15).attr("rx",7).attr("ry",7).style("fill","#FFF"),O=b.append("g").attr("class","mask-group").attr("width",A).attr("height",P).attr("x",0).attr("y",_-P).attr("mask","url(#dot)"),O.append("rect").attr("width",A).attr("height",P).attr("x",0).attr("y",_-P).style("fill","#ff7832"),G=O.append("g").attr("class","mask-axis-group").style("display","inline-block").attr("transform","translate(0,"+(_-P+T)+")"),G.call(I).selectAll("text").attr("fill","white").text(function(e,t){return S[t].t})}function d(e,t){var r=-1*x.translate()[0]+A/2,a=y(r);p(a,e,t)}function p(e,t,r){if(!(e>=S.length||0>e)){var a=S[e].x,n=-1*(m.x()(a)-A/2);N.transition().duration(r).ease(t).attr("transform","translate("+n+",0)"),H.transition().duration(r).ease(t).attr("transform","translate("+n+","+(_-P+T)+")"),G.transition().duration(r).ease(t).attr("transform","translate("+n+","+(_-P+T)+")"),x.translate([n,x.translate()[1]]);var s=G.selectAll("g")[0][e].getBBox(),i=s.width,o=8,l=s.x-o/2;L.transition().duration(r).ease(t).attr("width",i+o).attr("transform","translate("+l+", 0)"),W=S[e]}}function h(e){if(!(e>=S.length||0>e)){var t=S[e].x,r=-1*(m.x()(t)-A/2);N.attr("transform","translate("+r+",0)"),H.attr("transform","translate("+r+","+(_-P+T)+")"),G.attr("transform","translate("+r+","+(_-P+T)+")"),x.translate([r,x.translate()[1]]);var a=G.selectAll("g")[0][e].getBBox(),n=a.width,s=8,i=a.x-s/2;L.attr("width",n+s).attr("transform","translate("+i+", 0)"),W=S[e]}}function u(e,t,r,a){10>e&&(e=10);var n=.03,s=r*n,i=0,o=d3.ease(t,1,1.2),l=d3.interpolate(m.y().domain()[1],e);d3.timer(function(){var e=o(i),t=l(e);return m.y().domain([0,t]),g(),i>=1?(a&&a(),!0):(i+=s,!1)})}function g(){m.onDrawGraph(N),m.onDrawHud(C)}function v(){b.selectAll(".scrubber-text").transition().duration(200).attr("y",_/2-P+T-5).attr("opacity",1).text(W.y+" "+m.units())}function f(){b.selectAll(".scrubber-text").transition().attr("y",_/2-P+T-25).attr("opacity",0)}function y(e){var t=m.x().invert(e),r=S.map(function(e){return Math.abs(e.x-t)}),a=r.reduce(function(e,t){return t>=e?e:t});return r.indexOf(a)}var m,S,w,D,x,A,_,I,P,T,b,N,C,H,k,E,L,O,G,M,V,W,z,B=this;z=!1,t.$on("newPerchGraphStrategy",function(){z?n(function(){a()}):r()}),r()}]),/**
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
angular.module("Perch").directive("perchGraph",function(){return{restrict:"E",scope:{strategy:"="},controller:"PerchGraphController",controllerAs:"ctrl",bindToController:!0}}),/**
 *  @class Perch.PerchBarGraphStrategy
 *  @memberOf Perch
 *
 *  @description
 *  Strategy for bar graphs.
 *
 *  @implements {PerchGraphStrategy}
 *
 *  @author Jonathan Ballands
 *  @copyright © 2015 IBM Corporation. All Rights Reserved.
 */
angular.module("Perch").factory("PerchBarGraphStrategy",["$filter",function(e){function t(e,t,r,a,n){this._data=e,this._x=d3.scale.linear(),this._y=d3.scale.linear(),this._threshold=t,this._delta=r,this._units=a,this._barWidth=n}return t.prototype=new PerchGraphStrategy,t.prototype.x=function(){return this._x},t.prototype.y=function(){return this._y},t.prototype.data=function(){return this._data},t.prototype.delta=function(){return this._delta},t.prototype.threshold=function(){return this._threshold},t.prototype.units=function(){return this._units},t.prototype.onMeasure=function(e){this._width=e.width,this._height=e.height},t.prototype.onDrawHud=function(t){var r=this,a=e("translate")("SAFETY_THRESHOLD");t.selectAll("path").remove(),t.selectAll("text").remove(),t.append("text").attr("y",r._y(r._threshold)+18).attr("x",18).attr("class","threshold-text").text(a),t.append("text").attr("y",r._y(r._threshold)+18).attr("x",133).attr("class","threshold-text").text(r._threshold+" "+r._units),t.selectAll("path").data([[{x:0,y:r._threshold},{x:Math.ceil(r._x.invert(r._width)),y:r._threshold}]]).enter().append("path").attr("d",d3.svg.line().x(function(e){return r._x(e.x)}).y(function(e){return r._y(e.y)})).attr("class","threshold")},t.prototype.onDrawGraph=function(e){var t=this;e.selectAll("rect").remove(),e.selectAll(".bar").data(t._data).enter().append("rect").attr("x",function(e){return t._x(e.x)-t._barWidth/2}).attr("width",t._barWidth).attr("y",function(e){return t._y(e.y)}).attr("height",function(e){return t._height-t._y(e.y)-45}).attr("class",function(e){return e.y>=t._threshold?"warning":"ok"})},t}]);/**************************************
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
var angular,HybridJS;!function(){"use strict";angular.module("Perch").controller("SensorDetailController",["Sensors","Devices","$scope","$document","$routeParams","PerchLineGraphStrategy","PerchBarGraphStrategy","GraphService",function(e,t,r,a,n,s,i,o){function l(e){for(var t=0;t<c.images.length;t++)if(e===c.images[t].deviceClassId)return void(c.imageToView=c.images[t]);c.imageToView={deviceClassId:"0",displayIcon:null}}var c=this;c.sensor=e,c.device=t,c.images=[{deviceClassId:"10001",displayIcon:"assets/images/watermeter_detail.png"},{deviceClassId:"10002",displayIcon:"assets/images/ac_detail.png"},{deviceClassId:"10003",displayIcon:"assets/images/sewer_detail.png"}],l(n.deviceClassId),r.$watch(function(){return c.sensor.allSensors},function(){c.sensor.setSensorToView(c.currentDevice.sensorName),c.currentSensor=c.sensor.sensorToView,c.alertState=c.currentSensor.alertState>0,c.sensor.sensorsLoaded()!==!1&&(c.noDataMessage=void 0)},!0),r.$watch(function(){return c.device.allDevices},function(){c.device.setDeviceToViewById(n.deviceClassId),c.currentDevice=c.device.deviceToView,c.sensor.setSensorToView(c.currentDevice.sensorName),c.currentSensor=c.sensor.sensorToView,c.alertState=c.currentSensor.alertState>0,c.sensor.sensorsLoaded()!==!1&&(c.noDataMessage=void 0)},!0);var d=[{sensorName:"Water Meter",sensorValue:"N/A",alertState:1,alertDetail:{value:null,message:"Unusual levels of water consumption.",detail:null,timestamp:null},timestamp:1429131527},{sensorName:"Air Conditioner",sensorValue:"N/A",alertState:0,alertDetail:{value:null,message:null,detail:null,timestamp:null},timestamp:1429131535},{sensorName:"Sewer System",sensorValue:"N/A",alertState:0,alertDetail:{value:null,message:null,detail:null,timestamp:null},timestamp:1429131568}];c.device=t;var p=[{deviceName:"ac",deviceClassId:"10002",displayName:"Air Conditioner",displayUnit:"°C",displayIcon:"assets/images/ac_detail.png",displayAvgVal:"N/A",displayAvgMsg:"Average temperature",detailName:"Ocean Breeze AC Horizontal Cased Coil",detailAge:"3",detailMfrNo:"CHPF1824A6",tip:!0,tipText:"GET $40 OFF YOUR POLICY",sensorName:"Air Conditioner"},{deviceName:"water",deviceClassId:"10001",displayName:"Water Meter",displayUnit:" L",displayIcon:"assets/images/watermeter_detail.png",displayAvgVal:"N/A",displayAvgMsg:"Average usage per minute",detailName:'Poseidon Water Meter, T-10 (1")',detailAge:"17",detailMfrNo:"M67540",tip:!1,tipText:"NO TIP",sensorName:"Water Meter"},{deviceName:"sewer",deviceClassId:"10003",displayName:"Sewer System",displayUnit:" kL",displayIcon:"assets/images/sewer_detail.png",displayAvgVal:"N/A",displayAvgMsg:"Average usage per minute",detailName:"Pipeline 5000 Liter Septic Tank",detailAge:"22",detailMfrNo:"N-417778",tip:!1,tipText:"NO TIP",sensorName:"Sewer System"}];c.graphType=0,c.graphStrategies=o.getGraphStrategies(),c.currentStrategy=c.graphStrategies?c.graphStrategies.day:void 0,c.handleGraphTabTouch=function(e){switch(e){case"day":if(0===c.graphType)return;c.graphType=0,c.graphStrategies&&(c.currentStrategy=c.graphStrategies.day);break;case"week":if(1===c.graphType)return;c.graphType=1,c.graphStrategies&&(c.currentStrategy=c.graphStrategies.week);break;case"month":if(2===c.graphType)return;c.graphType=2,c.graphStrategies&&(c.currentStrategy=c.graphStrategies.month);break;default:c.graphStrategies&&(c.currentStrategy=c.graphStrategies.day),c.graphType=0}r.$broadcast("newPerchGraphStrategy")},o.registerObserver(function(){c.graphStrategies=o.getGraphStrategies(),c.graphStrategies&&(c.currentStrategy=c.graphStrategies.day),r.$digest(),r.$broadcast("newPerchGraphStrategy")}),c.device.devicesLoaded()===!1&&c.device.setDevices(p),c.device.setDeviceToViewById(n.deviceClassId),c.currentDevice=c.device.deviceToView,c.sensor.sensorsLoaded()===!1&&(c.sensor.setSensors(d),c.noDataMessage="No data received."),c.sensor.setSensorToView(c.currentDevice.sensorName),c.currentSensor=c.sensor.sensorToView,c.rightArrow="assets/images/right_arrow.png",c.orangeArrow="assets/images/right_arrow_orange.png",c.alertIcon="assets/images/alert_icon.png",c.alertState=c.currentSensor.alertState>0,c.topScrollBoundary=65,c.headerScroll=function(e){window.testScrollData=e;{var t=document.getElementById("scrollHeader"),r=t.getBoundingClientRect().height;r/e.height}t.style.top=String(c.topScrollBoundary-r*e.offScreenRatio.top)+"px"},c.pathChange=function(e){window.pathChangeMessage=e,"alert"===e?HybridJS.viewAlert(n.deviceClassId,c.sensor.sensorToView.alertDetail):"incentive"===e&&HybridJS.viewIncentive(n.deviceClassId)}}])}();var wlInitOptions={showIOS7StatusBar:!1};window.addEventListener?window.addEventListener("load",function(){try{WL.Client.init(wlInitOptions)}catch(e){console.log("Worklight is not running properly"),console.log(e.message)}},!1):window.attachEvent&&window.attachEvent("onload",function(){try{WL.Client.init(wlInitOptions)}catch(e){console.log("Worklight is not running properly"),console.log(e.message)}});/**************************************
 *
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 *  This sample program is provided AS IS and may be used, executed, copied and modified without royalty payment by customer
 *  (a) for its own instruction and study, (b) in order to develop applications designed to run with an IBM product,
 *  either for customer's own internal use or for redistribution by customer, as part of such an application, in customer's
 *  own products.
 *
 ***************************************/
var angular;!function(){"use strict";/**
     * @class Perch.Sensors
     * @memberOf Perch
     *
     * @description
     * Factory service for keeping track of the sensor data on the client side
     *
     * @author Jim Avery
     * @copyright © 2015 IBM Corporation. All Rights Reserved.
     */
angular.module("Perch").factory("Sensors",function(){var e=[],t=null,r=function(e){for(var t=0;t<this.allSensors.length;t++){var r=this.allSensors[t];if(e===r.sensorName)return r}return null},a=function(e){this.allSensors=e,window.sensorFactory=this.allSensors,window.sensorLength=this.allSensors.length,window.sensorsLoaded=this.sensorsLoaded()},n=function(e){this.allSensors.push(e)},s=function(e){for(var t=0;t<this.allSensors.length;t++){var r=this.allSensors[t];if(e===r.sensorName){console.log(e),this.allSensors.splice(t,1),console.log(this.allSensors);break}}},i=function(e){var t=this.getSensor(e);this.sensorToView=t},o=function(e,t,r){var a=this.sensorToView;angular.isDefined(e)&&(a.sensorValue=e),angular.isDefined(t)&&(a.alertState=t),a.alertDetail=angular.isDefined(r)?r:{value:null,message:null,detail:null,timestamp:null}},l=function(){return this.allSensors.length>0?!0:!1};return{allSensors:e,sensorToView:t,getSensor:r,setSensors:a,addSensor:n,deleteSensor:s,setSensorToView:i,updateSensor:o,sensorsLoaded:l}})}();/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
var angular;!function(){"use strict";angular.module("MILResponsiveHybrid",[]).provider("$responsiveHybrid",function(){var e,t,r,a,n,s,i,o;e={IPHONE_5:{},IPHONE_6:{},IPHONE_6PLUS:{},IPAD:{}},t={IPHONE_5:{},IPHONE_6:{},IPHONE_6PLUS:{},IPAD:{}},r={IPHONE_5:{},IPHONE_6:{},IPHONE_6PLUS:{},IPAD:{}},a={IPHONE_5:{},IPHONE_6:{},IPHONE_6PLUS:{},IPAD:{}},n={IPHONE_5:{width:320,height:568},IPHONE_6:{width:375,height:667},IPHONE_6PLUS:{width:414,height:736},IPAD:{width:768,height:1024}},s="IPHONE_6",i=function(n,s,i){return"class"===n?e[s][i]:"style"===n?t[s][i]:"html"===n?r[s][i]:"text"===n?a[s][i]:null},this.classSpecifications=function(t){return e=t,this},this.setDeviceClasses=function(t,r){if(Array.isArray(t))for(o=0;o<t.length;o+=1)this.setDeviceClasses(t[o],r);else e[t]=r;return this},this.setClassSpec=function(t,r,a){if(Array.isArray(t))for(o=0;o<t.length;o+=1)this.setClassSpec(t[o],r,a);else if(Array.isArray(r))for(o=0;o<r.length;o+=1)this.setClassSpec(t,r[o],a);else e[t][r]=a;return this},this.styleSpecifications=function(e){return t=e,this},this.setDeviceStyles=function(e,r){if(Array.isArray(e))for(o=0;o<e.length;o+=1)this.setDeviceStyles(e[o],r);else t[e]=r;return this},this.setStyleSpec=function(e,r,a){if(Array.isArray(e))for(o=0;o<e.length;o+=1)this.setStyleSpec(e[o],r,a);else if(Array.isArray(r))for(o=0;o<r.length;o+=1)this.setStyleSpec(e,r[o],a);else t[e][r]=a;return this},this.htmlSpecifications=function(e){return r=e,this},this.setDeviceHtml=function(e,t){if(Array.isArray(e))for(o=0;o<e.length;o+=1)this.setDeviceHtml(e[o],t);else r[e]=t;return this},this.setHtmlSpec=function(e,t,a){if(Array.isArray(e))for(o=0;o<e.length;o+=1)this.setHtmlSpec(e[o],t,a);else if(Array.isArray(t))for(o=0;o<t.length;o+=1)this.setHtmlSpec(e,t[o],a);else r[e][t]=a;return this},this.textSpecifications=function(e){return a=e,this},this.setDeviceText=function(e,t){if(Array.isArray(e))for(o=0;o<e.length;o+=1)this.setDeviceText(e[o],t);else a[e]=t;return this},this.setTextSpec=function(e,t,r){if(Array.isArray(e))for(o=0;o<e.length;o+=1)this.setTextSpec(e[o],t,r);else if(Array.isArray(t))for(o=0;o<t.length;o+=1)this.setTextSpec(e,t[o],r);else a[e][t]=r;return this},this.defaultDevice=function(e){return s=e,this},this.addNewDevice=function(s,i,o){return n[s]={width:i,height:o},e[s]={},t[s]={},r[s]={},a[s]={},this},this.$get=["$window",function(e){return{getCurrentDevice:function(){var t,r=e.innerHeight,a=e.innerWidth;for(t in n)if(n.hasOwnProperty(t)&&n[t].width===a&&n[t].height===r)return t;return s},getSpec:i}}]}),angular.module("MILResponsiveHybrid").filter("responsiveClass",["$responsiveHybrid",function(e){var t=function(t){var r=e.getCurrentDevice();return e.getSpec("class",r,t)};return t}]),angular.module("MILResponsiveHybrid").filter("responsiveStyle",["$responsiveHybrid",function(e){var t=function(t){var r=e.getCurrentDevice();return String(e.getSpec("style",r,t))+";"};return t}]),angular.module("MILResponsiveHybrid").filter("responsiveHTML",["$responsiveHybrid",function(e){var t=function(t){var r=e.getCurrentDevice();return e.getSpec("html",r,t)};return t}]),angular.module("MILResponsiveHybrid").filter("responsiveText",["$responsiveHybrid",function(e){var t=function(t){var r=e.getCurrentDevice();return e.getSpec("text",r,t)};return t}])}();/**************************************
 *
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 *  This sample program is provided AS IS and may be used, executed, copied and modified without royalty payment by customer
 *  (a) for its own instruction and study, (b) in order to develop applications designed to run with an IBM product,
 *  either for customer's own internal use or for redistribution by customer, as part of such an application, in customer's
 *  own products.
 *
 ***************************************/
var angular,WL,HybridJS=function(){"use strict";function e(){var e="perch-app",t=angular.element(document.getElementById(e)).scope();t.$apply()}function t(t){window.allSensorData=t;for(var r=document.getElementById("perch-app"),a=angular.element(r).injector(),n=a.get("Sensors"),s=a.get("Devices"),i=[],o=[],l=0;l<t.length;l++){var c={sensorName:t[l].name,sensorValue:t[l].value,alertState:t[l].status,alertDetail:{value:null,message:null,detail:null,timestamp:null,partner:null},timestamp:t[l].time},d={deviceName:t[l].name,deviceClassId:t[l].deviceClassId,maxThreshold:t[l].maxThreshold,displayName:t[l].name,displayUnit:t[l].units,displayIcon:"assets/images/ac_detail.png",displayAvgVal:t[l].averageUsage,displayAvgMsg:t[l].averageUsageUnit,detailName:t[l].partName,detailAge:t[l].age,detailMfrNo:t[l].serialNumber,sensorName:t[l].name};angular.isDefined(t[l].alert)&&(c.alertDetail=t[l].alert),angular.isDefined(t[l].tip)?(d.tip=!0,d.tipText=t[l].tip.title.toUpperCase()):(d.tip=!1,d.tipText="NO INCENTIVE"),i.push(c),o.push(d)}n.setSensors(i),s.setDevices(o),e()}function r(t,r,a){var n=document.getElementById("perch-app"),s=angular.element(n).injector(),i=s.get("Sensors");i.updateSensor(t,r,a),e()}function a(t){var r=document.getElementById("perch-app"),a=angular.element(r).injector(),n=a.get("GraphService"),s=a.get("PerchLineGraphStrategy"),i=a.get("PerchBarGraphStrategy"),o=a.get("Devices"),l=new s(n.coerceData(t[0].reverse(),"day"),o.deviceToView.maxThreshold,55,o.deviceToView.displayUnit),c=new i(n.coerceData(t[1].reverse(),"week"),o.deviceToView.maxThreshold,45,o.deviceToView.displayUnit,25),d=new i(n.coerceData(t[2].reverse(),"month"),o.deviceToView.maxThreshold,80,o.deviceToView.displayUnit,45);n.setGraphStrategies({day:l,week:c,month:d}),e()}function n(){console.log("Back Pressed!"),window.history.back()}function s(e){switch(WL.Logger.info("Action received: "+String(e.action)),e.action){case"backButtonClicked":n();break;case"changePage":c(e.data.route);break;case"InitSensors":t(e.data.sensors);break;case"UpdateSensor":r(e.data.curValue,e.data.status,e.data.alert);break;case"InitGraph":a(e.data.historicalData);break;default:console.log("No handler for this action: "+e.action)}}function i(e,t,r,a){try{WL.App.sendActionToNative("updatePage",{title:e,route:t,showBackButton:r,headerColor:a})}catch(n){console.log("Worklight is not running properly"),console.log(n.message)}}function o(e,t){WL.App.sendActionToNative("viewAlert",{customData:e,value:t.value,message:t.message,detail:t.detail,timestamp:t.timestamp,partner:t.partner})}function l(e){WL.App.sendActionToNative("viewIncentive",{deviceClassId:e})}function c(e){window.location.hash="#/"+e,""===e&&i("SENSOR DETAIL","",!1,"#ffffff");var t=document.getElementById("perch-app"),r=angular.element(t).injector(),a=r.get("GraphService");a.setGraphStrategies(void 0)}function d(){try{WL.App.addActionReceiver("myActionReceiver",s)}catch(e){console.log("faild to setup action receiver")}}return{init:d,updatePage:i,viewAlert:o,viewIncentive:l}}();/**
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
angular.module("Perch").service("GraphService",function(){var e=[],t=void 0,r=function(){for(var t=0;t<e.length;t++)e[t]()};this.registerObserver=function(t){e.push(t)},this.setGraphStrategies=function(e){t=e,r()},this.getGraphStrategies=function(){return t},this.coerceData=function(e,t){var r,a=[];e.length>0&&(r=moment(e[0].timestamp).format("A"));for(var n=0;n<e.length;n++){var s,i=e[n];switch(t){case"day":s=moment(i.timestamp).format("h"),moment(i.timestamp).format("A")!==r&&(s=moment(i.timestamp).format("A"),r=moment(i.timestamp).format("A"));break;case"week":s=moment(i.timestamp).format("dd");break;case"month":var o=moment(i.timestamp);s=o.format("M/D"),s+=" - "+o.add(7,"days").format("M/D");break;default:console.error("Bad scope argument... defaulting to day"),s=moment(i.timestamp).format("h"),moment(i.timestamp).format("A")!==r&&(s=moment(i.timestamp).format("A"))}a.push({x:n,y:e[n].value,t:s}),r=moment(i.timestamp).format("A")}return a}});/**************************************
 *
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 *  This sample program is provided AS IS and may be used, executed, copied and modified without royalty payment by customer
 *  (a) for its own instruction and study, (b) in order to develop applications designed to run with an IBM product,
 *  either for customer's own internal use or for redistribution by customer, as part of such an application, in customer's
 *  own products.
 *
 ***************************************/
var angular;!function(){"use strict";/**
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
angular.module("Perch").factory("Devices",function(){var e=[],t=null,r=function(e){for(var t=0;t<this.allDevices.length;t++){var r=this.allDevices[t];if(e===r.deviceName)return r}return null},a=function(e){for(var t=0;t<this.allDevices.length;t++){var r=this.allDevices[t];if(e===r.deviceClassId)return r}return null},n=function(e){this.allDevices=e},s=function(e){this.allDevices.push(e)},i=function(e){for(var t=0;t<this.allDevices.length;t++){var r=this.allDevices[t];if(e===r.deviceName){console.log(e),this.allDevices.splice(t,1),console.log(this.allDevices);break}}},o=function(e){var t=this.getDevice(e);this.deviceToView=t},l=function(e){var t=this.getDeviceById(e);this.deviceToView=t},c=function(){return this.allDevices.length>0?!0:!1};return{allDevices:e,deviceToView:t,getDevice:r,getDeviceById:a,setDevices:n,addDevice:s,deleteDevice:i,setDeviceToView:o,setDeviceToViewById:l,devicesLoaded:c}})}(),angular.module("Perch").run(["$templateCache",function(e){e.put("app/sensorDetail/sensorDetail.html",'<hr class="top-buffer-line" ng-class="{\'gold-line\': SensorDetail.alertState, \'gray-line\': !SensorDetail.alertState}"><div class="nav-bar" ng-class="{\'alert\': SensorDetail.alertState}"><div id="scrollHeader" class="karla dark-gray-text header-text size17pt" style="{{ \'testStyle\' | responsiveStyle }}">{{SensorDetail.currentDevice.displayName}}</div></div><div id="sensor-container" class="sensor-container" data-ng-model="SensorDetail.currentSensor"><div class="nav-buffer" ng-class="{\'alert\': SensorDetail.alertState}"></div><div class="status-div" ng-class="{\'alert\': SensorDetail.alertState}"><div class="device-name-div"><img width="{{ \'imageSize\' | responsiveHTML }}" ng-src="{{SensorDetail.imageToView.displayIcon}}"><div ng-if="SensorDetail.noDataMessage !== undefined" style="margin-top: 30px;"><p><span class="merriweather dark-gray-text {{ \'warningSize\' | responsiveClass }}" style="letter-spacing: -1px;">{{SensorDetail.noDataMessage}}</span></p></div><div class="alert-message" ng-if="SensorDetail.alertState" style="margin-top: 30px;"><p><span class="merriweather dark-gray-text {{ \'warningSize\' | responsiveClass }}" style="letter-spacing: -1px;"><span class="merriweather-bold">{{ \'WARNING\' | translate }}:</span> {{SensorDetail.currentSensor.alertDetail.message}}</span></p><p class="karla-bold white-text size12pt" style="letter-spacing: 3px;margin-top: -3px;" ng-click="SensorDetail.pathChange(\'alert\')">{{ \'VIEW_ALERT\' | translate }} <img height="12px" ng-src="{{SensorDetail.rightArrow}}"></p></div></div><hr class="mid-line" ng-class="{\'gold-line\': SensorDetail.alertState, \'gray-line\': !SensorDetail.alertState}"><div class="data-div"><div id="current-data" class="current-data"><span><img ng-src="{{SensorDetail.alertIcon}}" ng-if="SensorDetail.alertState" height="17px"> <span class="size18pt">{{SensorDetail.currentSensor.sensorValue}}{{SensorDetail.currentDevice.displayUnit}}</span></span><p style="margin-top: 3px;line-height: 100%;"><span class="karla-bold size12pt">{{ \'CURRENT_MEASUREMENT\' | translate }}</span></p></div><div id="average-data" class="average-data"><span class="size18pt">{{SensorDetail.currentDevice.displayAvgVal}}</span><p style="margin-top: 3px;line-height: 100%;"><span class="karla-bold size12pt">{{SensorDetail.currentDevice.displayAvgMsg}}</span></p></div></div></div><div class="device-info-div"><div class="karla {{ \'warningSize\' | responsiveClass }} dark-gray-text" style="margin-bottom: 15px;">{{SensorDetail.currentDevice.detailName}}</div><div class="karla {{ \'infoSize\' | responsiveClass }} light-gray-text"><span class="karla-bold">{{ \'AGE\' | translate }}</span> {{SensorDetail.currentDevice.detailAge}} Years&nbsp;&nbsp;&nbsp;&nbsp; <span class="karla-bold">{{ \'MFR_PART_NO\' | translate }}</span> {{SensorDetail.currentDevice.detailMfrNo}}</div><div ng-if="SensorDetail.currentDevice.tip == true" class="karla-bold orange-text size12pt" style="letter-spacing: 2px;-webkit-tap-highlight-color: rgba(0,0,0,0);margin-top: 22px;" ng-click="SensorDetail.pathChange(\'incentive\')">{{SensorDetail.currentDevice.tipText}}&nbsp;&nbsp;<img height="12px" ng-src="{{SensorDetail.orangeArrow}}"></div></div><div class="graph-tab-container karla-bold light-gray-text"><div class="graph-tab" ng-class=\'{ "active": SensorDetail.graphType === 0 }\' ng-click=\'SensorDetail.handleGraphTabTouch("day")\'>{{ \'DAY\' | translate }}</div><div class="graph-tab" ng-class=\'{ "active": SensorDetail.graphType === 1 }\' ng-click=\'SensorDetail.handleGraphTabTouch("week")\'>{{ \'WEEK\' | translate }}</div><div class="graph-tab" ng-class=\'{ "active": SensorDetail.graphType === 2 }\' ng-click=\'SensorDetail.handleGraphTabTouch("month")\'>{{ \'MONTH\' | translate }}</div></div><perch-graph strategy="SensorDetail.currentStrategy"></perch-graph></div>')}]);