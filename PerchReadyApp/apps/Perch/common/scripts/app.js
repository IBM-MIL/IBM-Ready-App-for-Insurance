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
angular.module("Perch",["ngAnimate","ngTouch","ngSanitize","ngRoute","pascalprecht.translate"]),angular.module("Perch").config(["$routeProvider","$translateProvider",function(e,t){e.when("/sensorDetail/:deviceClassId",{templateUrl:"app/sensorDetail/sensorDetail.html",controller:"SensorDetailController",controllerAs:"SensorDetail"}).otherwise({redirectTo:"/loading"}),t.translations("en",englishTranslations).translations("es",spanishTranslations).preferredLanguage("en")}])}(),/**
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
angular.module("Perch").factory("PerchLineGraphStrategy",["$filter",function(e){function t(e,t,a,r){this._data=e,this._x=d3.scale.linear(),this._y=d3.scale.linear(),this._threshold=t,this._delta=a,this._units=r}return t.prototype=new PerchGraphStrategy,t.prototype.x=function(){return this._x},t.prototype.y=function(){return this._y},t.prototype.data=function(){return this._data},t.prototype.delta=function(){return this._delta},t.prototype.threshold=function(){return this._threshold},t.prototype.units=function(){return this._units},t.prototype.onMeasure=function(e){this._width=e.width,this._height=e.height},t.prototype.onDrawHud=function(t){var a=this,r=e("translate")("SAFETY_THRESHOLD");t.selectAll("path").remove(),t.selectAll("text").remove(),t.append("text").attr("y",a._y(this._threshold)+18).attr("x",18).attr("class","threshold-text").text(r),t.append("text").attr("y",a._y(a._threshold)+18).attr("x",133).attr("class","threshold-text").text(this._threshold+" "+this._units),t.selectAll("path").data([[{x:0,y:a._threshold},{x:Math.ceil(a._x.invert(a._width)),y:a._threshold}]]).enter().append("path").attr("d",d3.svg.line().x(function(e){return a._x(e.x)}).y(function(e){return a._y(e.y)})).attr("class","threshold")},t.prototype.onDrawGraph=function(e){var t=this;e.selectAll("path").remove(),e.selectAll("circle").remove(),e.selectAll("path").data([t._data]).enter().append("path").attr("d",d3.svg.line().x(function(e){return t._x(e.x)}).y(function(e){return t._y(e.y)})).attr("class","data"),e.selectAll("circle").data(t._data).enter().append("circle").attr("cx",function(e){return t._x(e.x)}).attr("cy",function(e){return t._y(e.y)}).attr("r",6).attr("class",function(e){return e.y>=t._threshold?"warning":"ok"})},t}]),PerchGraphStrategy.prototype.x=function(){throw new Error("x not implemented")},PerchGraphStrategy.prototype.y=function(){throw new Error("y not implemented")},PerchGraphStrategy.prototype.data=function(){throw new Error("data not implemented")},PerchGraphStrategy.prototype.delta=function(){throw new Error("delta not implemented")},PerchGraphStrategy.prototype.threshold=function(){throw new Error("threshold not implemented")},PerchGraphStrategy.prototype.units=function(){throw new Error("units not implemented")},PerchGraphStrategy.prototype.onMeasure=function(){throw new Error("onMeasure not implemented")},PerchGraphStrategy.prototype.onDrawHud=function(){},PerchGraphStrategy.prototype.onDrawGraph=function(){},/**
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
angular.module("Perch").controller("PerchGraphController",["$element","$scope",function(e,t){function a(){f=O.strategy,f&&(A=e[0].offsetWidth,T=e[0].offsetHeight,b=45,k=15,W=.7,B=1.5,l(),H=!0)}function r(){f=O.strategy,f&&H&&(d3.select(e[0]).selectAll("svg").remove(),l())}function n(e){f&&H&&(m(),L.transition().duration(300).ease("cubic-in").attr("width",0).attr("transform","translate(0, 0)"),u(1e3,"cubic-in",B,function(){e&&e()}))}function s(){m(),I.transition(),P.transition(),M.transition()}function i(){var e=D.translate()[0];I.attr("transform","translate("+e+",0)"),P.attr("transform","translate("+e+","+(T-b+k)+")"),M.attr("transform","translate("+e+","+(T-b+k)+")")}function o(){d("cubic-out",750),u(2*z.y,"elastic",W),v()}function l(){f.onMeasure({width:A,height:T}),S=f.data(),D=d3.behavior.zoom(),w=0;for(var t=0;t<S.length;t++){var a=S[t];a.y>w&&(w=a.y)}w+=1e3;var r=S.map(function(e){return e.x});x=r.reduce(function(e,t){return e>=t?e:t}),f.x().domain(S.map(function(e){return e.x})),f.x().range(S.map(function(e){return e.x*f.delta()})),f.y().domain([0,w]),f.y().range([T-b,0]),_=d3.svg.axis().scale(f.x()).orient("bottom").tickSize(0).ticks(S.length),N=d3.select(e[0]).append("svg").attr("class","chart").attr("width",A).attr("height",T).call(D),P=N.append("g").style("display","inline-block").attr("class","axis-group").attr("transform","translate(0,"+(T-b+k)+")"),P.call(_).selectAll("text").text(function(e,t){return S[t].t}),I=N.append("g").attr("class","data-group").style("display","inline-block"),C=N.append("g").attr("class","hud-group").style("display","inline-block"),c();var n=70*S.length;h(0),p(S.length-1,"cubic-out",n),u(2*z.y,"cubic-out",B),g(),G=N.append("text").attr("x",A/2).attr("y",T/2-50).attr("opacity",0).attr("class","scrubber-text").text(z.y),v(),N.append("g").attr("class","axis-line-group").selectAll("path").data([[{x:0,y:T-b},{x:Math.ceil(f.x().invert(A)),y:T-b}]]).enter().append("path").attr("d",d3.svg.line().x(function(e){return f.x()(e.x)}).y(function(e){return e.y})).attr("class","axis-line"),D.on("zoomstart",function(){s()}),D.on("zoom",function(){i()}),D.on("zoomend",function(){o()})}function c(){V=N.append("defs").append("mask").attr("id","dot").attr("width",A).attr("height",b).attr("x",0).attr("y",0),L=V.append("rect").attr("width",0).attr("height",15).attr("x",A/2).attr("y",T-b+15).attr("rx",7).attr("ry",7).style("fill","#FFF"),E=N.append("g").attr("class","mask-group").attr("width",A).attr("height",b).attr("x",0).attr("y",T-b).attr("mask","url(#dot)"),E.append("rect").attr("width",A).attr("height",b).attr("x",0).attr("y",T-b).style("fill","#ff7832"),M=E.append("g").attr("class","mask-axis-group").style("display","inline-block").attr("transform","translate(0,"+(T-b+k)+")"),M.call(_).selectAll("text").attr("fill","white").text(function(e,t){return S[t].t})}function d(e,t){var a=-1*D.translate()[0]+A/2,r=y(a);p(r,e,t)}function p(e,t,a){if(!(e>=S.length||0>e)){var r=S[e].x,n=-1*(f.x()(r)-A/2);I.transition().duration(a).ease(t).attr("transform","translate("+n+",0)"),P.transition().duration(a).ease(t).attr("transform","translate("+n+","+(T-b+k)+")"),M.transition().duration(a).ease(t).attr("transform","translate("+n+","+(T-b+k)+")"),D.translate([n,D.translate()[1]]);var s=M.selectAll("g")[0][e].getBBox(),i=s.width,o=8,l=s.x-o/2;L.transition().duration(a).ease(t).attr("width",i+o).attr("transform","translate("+l+", 0)"),z=S[e]}}function h(e){if(!(e>=S.length||0>e)){var t=S[e].x,a=-1*(f.x()(t)-A/2);I.attr("transform","translate("+a+",0)"),P.attr("transform","translate("+a+","+(T-b+k)+")"),M.attr("transform","translate("+a+","+(T-b+k)+")"),D.translate([a,D.translate()[1]]);var r=M.selectAll("g")[0][e].getBBox(),n=r.width,s=8,i=r.x-s/2;L.attr("width",n+s).attr("transform","translate("+i+", 0)"),z=S[e]}}function u(e,t,a,r){10>e&&(e=10);var n=.03,s=a*n,i=0,o=d3.ease(t,1,1.2),l=d3.interpolate(f.y().domain()[1],e);d3.timer(function(){var e=o(i),t=l(e);return f.y().domain([0,t]),g(),i>=1?(r&&r(),!0):(i+=s,!1)})}function g(){f.onDrawGraph(I),f.onDrawHud(C)}function v(){N.selectAll(".scrubber-text").transition().duration(200).attr("y",T/2-b+k-5).attr("opacity",1).text(z.y+" "+f.units())}function m(){N.selectAll(".scrubber-text").transition().attr("y",T/2-b+k-25).attr("opacity",0)}function y(e){var t=f.x().invert(e),a=S.map(function(e){return Math.abs(e.x-t)}),r=a.reduce(function(e,t){return t>=e?e:t});return a.indexOf(r)}var f,S,w,x,D,A,T,_,b,k,N,I,C,P,G,V,L,E,M,W,B,z,H,O=this;H=!1,t.$on("newPerchGraphStrategy",function(){H?n(function(){r()}):a()}),a()}]),/**
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
angular.module("Perch").factory("PerchBarGraphStrategy",["$filter",function(e){function t(e,t,a,r,n){this._data=e,this._x=d3.scale.linear(),this._y=d3.scale.linear(),this._threshold=t,this._delta=a,this._units=r,this._barWidth=n}return t.prototype=new PerchGraphStrategy,t.prototype.x=function(){return this._x},t.prototype.y=function(){return this._y},t.prototype.data=function(){return this._data},t.prototype.delta=function(){return this._delta},t.prototype.threshold=function(){return this._threshold},t.prototype.units=function(){return this._units},t.prototype.onMeasure=function(e){this._width=e.width,this._height=e.height},t.prototype.onDrawHud=function(t){var a=this,r=e("translate")("SAFETY_THRESHOLD");t.selectAll("path").remove(),t.selectAll("text").remove(),t.append("text").attr("y",a._y(a._threshold)+18).attr("x",18).attr("class","threshold-text").text(r),t.append("text").attr("y",a._y(a._threshold)+18).attr("x",133).attr("class","threshold-text").text(a._threshold+" "+a._units),t.selectAll("path").data([[{x:0,y:a._threshold},{x:Math.ceil(a._x.invert(a._width)),y:a._threshold}]]).enter().append("path").attr("d",d3.svg.line().x(function(e){return a._x(e.x)}).y(function(e){return a._y(e.y)})).attr("class","threshold")},t.prototype.onDrawGraph=function(e){var t=this;e.selectAll("rect").remove(),e.selectAll(".bar").data(t._data).enter().append("rect").attr("x",function(e){return t._x(e.x)-t._barWidth/2}).attr("width",t._barWidth).attr("y",function(e){return t._y(e.y)}).attr("height",function(e){return t._height-t._y(e.y)-45}).attr("class",function(e){return e.y>=t._threshold?"warning":"ok"})},t}]);/**************************************
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
var angular,HybridJS;!function(){"use strict";angular.module("Perch").controller("SensorDetailController",["Sensors","Devices","$scope","$document","$routeParams","PerchLineGraphStrategy","PerchBarGraphStrategy","GraphService",function(e,t,a,r,n,s,i,o){function l(e){for(var t=0;t<c.images.length;t++)if(e===c.images[t].deviceClassId)return void(c.imageToView=c.images[t]);c.imageToView={deviceClassId:"0",displayIcon:null}}var c=this;c.sensor=e,c.device=t,c.images=[{deviceClassId:"10001",displayIcon:"assets/images/watermeter_detail.png"},{deviceClassId:"10002",displayIcon:"assets/images/ac_detail.png"},{deviceClassId:"10003",displayIcon:"assets/images/sewer_detail.png"}],l(n.deviceClassId),a.$watch(function(){return c.sensor.allSensors},function(){c.sensor.setSensorToView(c.currentDevice.sensorName),c.currentSensor=c.sensor.sensorToView,c.alertState=c.currentSensor.alertState>0,c.sensor.sensorsLoaded()!==!1&&(c.noDataMessage=void 0)},!0),a.$watch(function(){return c.device.allDevices},function(){c.device.setDeviceToViewById(n.deviceClassId),c.currentDevice=c.device.deviceToView,c.sensor.setSensorToView(c.currentDevice.sensorName),c.currentSensor=c.sensor.sensorToView,c.alertState=c.currentSensor.alertState>0,c.sensor.sensorsLoaded()!==!1&&(c.noDataMessage=void 0)},!0);var d=[{sensorName:"Water Meter",sensorValue:"N/A",alertState:1,alertDetail:{value:null,message:"Unusual levels of water consumption.",detail:null,timestamp:null},timestamp:1429131527},{sensorName:"Air Conditioner",sensorValue:"N/A",alertState:0,alertDetail:{value:null,message:null,detail:null,timestamp:null},timestamp:1429131535},{sensorName:"Sewer System",sensorValue:"N/A",alertState:0,alertDetail:{value:null,message:null,detail:null,timestamp:null},timestamp:1429131568}];c.device=t;var p=[{deviceName:"ac",deviceClassId:"10002",displayName:"Air Conditioner",displayUnit:"°C",displayIcon:"assets/images/ac_detail.png",displayAvgVal:"N/A",displayAvgMsg:"Average temperature",detailName:"Ocean Breeze AC Horizontal Cased Coil",detailAge:"3",detailMfrNo:"CHPF1824A6",tip:!0,tipText:"GET $40 OFF YOUR POLICY",sensorName:"Air Conditioner"},{deviceName:"water",deviceClassId:"10001",displayName:"Water Meter",displayUnit:" L",displayIcon:"assets/images/watermeter_detail.png",displayAvgVal:"N/A",displayAvgMsg:"Average usage per minute",detailName:'Poseidon Water Meter, T-10 (1")',detailAge:"17",detailMfrNo:"M67540",tip:!1,tipText:"NO TIP",sensorName:"Water Meter"},{deviceName:"sewer",deviceClassId:"10003",displayName:"Sewer System",displayUnit:" kL",displayIcon:"assets/images/sewer_detail.png",displayAvgVal:"N/A",displayAvgMsg:"Average usage per minute",detailName:"Pipeline 5000 Liter Septic Tank",detailAge:"22",detailMfrNo:"N-417778",tip:!1,tipText:"NO TIP",sensorName:"Sewer System"}];c.graphType=0,c.graphStrategies=o.getGraphStrategies(),c.currentStrategy=c.graphStrategies?c.graphStrategies.day:void 0,c.handleGraphTabTouch=function(e){switch(e){case"day":if(0===c.graphType)return;c.graphType=0,c.graphStrategies&&(c.currentStrategy=c.graphStrategies.day);break;case"week":if(1===c.graphType)return;c.graphType=1,c.graphStrategies&&(c.currentStrategy=c.graphStrategies.week);break;case"month":if(2===c.graphType)return;c.graphType=2,c.graphStrategies&&(c.currentStrategy=c.graphStrategies.month);break;default:c.graphStrategies&&(c.currentStrategy=c.graphStrategies.day),c.graphType=0}a.$broadcast("newPerchGraphStrategy")},o.registerObserver(function(){c.graphStrategies=o.getGraphStrategies(),c.graphStrategies&&(c.currentStrategy=c.graphStrategies.day),a.$digest(),a.$broadcast("newPerchGraphStrategy")}),c.device.devicesLoaded()===!1&&c.device.setDevices(p),c.device.setDeviceToViewById(n.deviceClassId),c.currentDevice=c.device.deviceToView,c.sensor.sensorsLoaded()===!1&&(c.sensor.setSensors(d),c.noDataMessage="No data received."),c.sensor.setSensorToView(c.currentDevice.sensorName),c.currentSensor=c.sensor.sensorToView,c.rightArrow="assets/images/right_arrow.png",c.orangeArrow="assets/images/right_arrow_orange.png",c.alertIcon="assets/images/alert_icon.png",c.alertState=c.currentSensor.alertState>0,c.topScrollBoundary=65,c.headerScroll=function(e){window.testScrollData=e;{var t=document.getElementById("scrollHeader"),a=t.getBoundingClientRect().height;a/e.height}t.style.top=String(c.topScrollBoundary-a*e.offScreenRatio.top)+"px"},c.pathChange=function(e){window.pathChangeMessage=e,"alert"===e?HybridJS.viewAlert(n.deviceClassId,c.sensor.sensorToView.alertDetail):"incentive"===e&&HybridJS.viewIncentive(n.deviceClassId)}}])}();var wlInitOptions={showIOS7StatusBar:!1};window.addEventListener?window.addEventListener("load",function(){try{WL.Client.init(wlInitOptions)}catch(e){console.log("Worklight is not running properly"),console.log(e.message)}},!1):window.attachEvent&&window.attachEvent("onload",function(){try{WL.Client.init(wlInitOptions)}catch(e){console.log("Worklight is not running properly"),console.log(e.message)}});/**************************************
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
angular.module("Perch").factory("Sensors",function(){var e=[],t=null,a=function(e){for(var t=0;t<this.allSensors.length;t++){var a=this.allSensors[t];if(e===a.sensorName)return a}return null},r=function(e){this.allSensors=e,window.sensorFactory=this.allSensors,window.sensorLength=this.allSensors.length,window.sensorsLoaded=this.sensorsLoaded()},n=function(e){this.allSensors.push(e)},s=function(e){for(var t=0;t<this.allSensors.length;t++){var a=this.allSensors[t];if(e===a.sensorName){console.log(e),this.allSensors.splice(t,1),console.log(this.allSensors);break}}},i=function(e){var t=this.getSensor(e);this.sensorToView=t},o=function(e,t,a){var r=this.sensorToView;angular.isDefined(e)&&(r.sensorValue=e),angular.isDefined(t)&&(r.alertState=t),r.alertDetail=angular.isDefined(a)?a:{value:null,message:null,detail:null,timestamp:null}},l=function(){return this.allSensors.length>0?!0:!1};return{allSensors:e,sensorToView:t,getSensor:a,setSensors:r,addSensor:n,deleteSensor:s,setSensorToView:i,updateSensor:o,sensorsLoaded:l}})}();/**************************************
 *
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 *  This sample program is provided AS IS and may be used, executed, copied and modified without royalty payment by customer
 *  (a) for its own instruction and study, (b) in order to develop applications designed to run with an IBM product,
 *  either for customer's own internal use or for redistribution by customer, as part of such an application, in customer's
 *  own products.
 *
 ***************************************/
var angular,WL,HybridJS=function(){"use strict";function e(){var e="perch-app",t=angular.element(document.getElementById(e)).scope();t.$apply()}function t(t){window.allSensorData=t;for(var a=document.getElementById("perch-app"),r=angular.element(a).injector(),n=r.get("Sensors"),s=r.get("Devices"),i=[],o=[],l=0;l<t.length;l++){var c={sensorName:t[l].name,sensorValue:t[l].value,alertState:t[l].status,alertDetail:{value:null,message:null,detail:null,timestamp:null,partner:null},timestamp:t[l].time},d={deviceName:t[l].name,deviceClassId:t[l].deviceClassId,maxThreshold:t[l].maxThreshold,displayName:t[l].name,displayUnit:t[l].units,displayIcon:"assets/images/ac_detail.png",displayAvgVal:t[l].averageUsage,displayAvgMsg:t[l].averageUsageUnit,detailName:t[l].partName,detailAge:t[l].age,detailMfrNo:t[l].serialNumber,sensorName:t[l].name};angular.isDefined(t[l].alert)&&(c.alertDetail=t[l].alert),angular.isDefined(t[l].tip)?(d.tip=!0,d.tipText=t[l].tip.title.toUpperCase()):(d.tip=!1,d.tipText="NO INCENTIVE"),i.push(c),o.push(d)}n.setSensors(i),s.setDevices(o),e()}function a(t,a,r){var n=document.getElementById("perch-app"),s=angular.element(n).injector(),i=s.get("Sensors");i.updateSensor(t,a,r),e()}function r(t){var a=document.getElementById("perch-app"),r=angular.element(a).injector(),n=r.get("GraphService"),s=r.get("PerchLineGraphStrategy"),i=r.get("PerchBarGraphStrategy"),o=r.get("Devices"),l=new s(n.coerceData(t[0].reverse(),"day"),o.deviceToView.maxThreshold,55,o.deviceToView.displayUnit),c=new i(n.coerceData(t[1].reverse(),"week"),o.deviceToView.maxThreshold,45,o.deviceToView.displayUnit,25),d=new i(n.coerceData(t[2].reverse(),"month"),o.deviceToView.maxThreshold,80,o.deviceToView.displayUnit,45);n.setGraphStrategies({day:l,week:c,month:d}),e()}function n(){console.log("Back Pressed!"),window.history.back()}function s(e){switch(WL.Logger.info("Action received: "+String(e.action)),e.action){case"backButtonClicked":n();break;case"changePage":c(e.data.route);break;case"InitSensors":t(e.data.sensors);break;case"UpdateSensor":a(e.data.curValue,e.data.status,e.data.alert);break;case"InitGraph":r(e.data.historicalData);break;default:console.log("No handler for this action: "+e.action)}}function i(e,t,a,r){try{WL.App.sendActionToNative("updatePage",{title:e,route:t,showBackButton:a,headerColor:r})}catch(n){console.log("Worklight is not running properly"),console.log(n.message)}}function o(e,t){WL.App.sendActionToNative("viewAlert",{customData:e,value:t.value,message:t.message,detail:t.detail,timestamp:t.timestamp,partner:t.partner})}function l(e){WL.App.sendActionToNative("viewIncentive",{deviceClassId:e})}function c(e){window.location.hash="#/"+e,""===e&&i("SENSOR DETAIL","",!1,"#ffffff");var t=document.getElementById("perch-app"),a=angular.element(t).injector(),r=a.get("GraphService");r.setGraphStrategies(void 0)}function d(){try{WL.App.addActionReceiver("myActionReceiver",s)}catch(e){console.log("faild to setup action receiver")}}return{init:d,updatePage:i,viewAlert:o,viewIncentive:l}}();/**
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
angular.module("Perch").service("GraphService",function(){var e=[],t=void 0,a=function(){for(var t=0;t<e.length;t++)e[t]()};this.registerObserver=function(t){e.push(t)},this.setGraphStrategies=function(e){t=e,a()},this.getGraphStrategies=function(){return t},this.coerceData=function(e,t){var a,r=[];e.length>0&&(a=moment(e[0].timestamp).format("A"));for(var n=0;n<e.length;n++){var s,i=e[n];switch(t){case"day":s=moment(i.timestamp).format("h"),moment(i.timestamp).format("A")!==a&&(s=moment(i.timestamp).format("A"),a=moment(i.timestamp).format("A"));break;case"week":s=moment(i.timestamp).format("dd");break;case"month":var o=moment(i.timestamp);s=o.format("M/D"),s+=" - "+o.add(7,"days").format("M/D");break;default:console.error("Bad scope argument... defaulting to day"),s=moment(i.timestamp).format("h"),moment(i.timestamp).format("A")!==a&&(s=moment(i.timestamp).format("A"))}r.push({x:n,y:e[n].value,t:s}),a=moment(i.timestamp).format("A")}return r}});/**************************************
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
angular.module("Perch").factory("Devices",function(){var e=[],t=null,a=function(e){for(var t=0;t<this.allDevices.length;t++){var a=this.allDevices[t];if(e===a.deviceName)return a}return null},r=function(e){for(var t=0;t<this.allDevices.length;t++){var a=this.allDevices[t];if(e===a.deviceClassId)return a}return null},n=function(e){this.allDevices=e},s=function(e){this.allDevices.push(e)},i=function(e){for(var t=0;t<this.allDevices.length;t++){var a=this.allDevices[t];if(e===a.deviceName){console.log(e),this.allDevices.splice(t,1),console.log(this.allDevices);break}}},o=function(e){var t=this.getDevice(e);this.deviceToView=t},l=function(e){var t=this.getDeviceById(e);this.deviceToView=t},c=function(){return this.allDevices.length>0?!0:!1};return{allDevices:e,deviceToView:t,getDevice:a,getDeviceById:r,setDevices:n,addDevice:s,deleteDevice:i,setDeviceToView:o,setDeviceToViewById:l,devicesLoaded:c}})}(),angular.module("Perch").run(["$templateCache",function(e){e.put("app/sensorDetail/sensorDetail.html",'<hr class="top-buffer-line" ng-class="{\'gold-line\': SensorDetail.alertState, \'gray-line\': !SensorDetail.alertState}"><div class="nav-bar" ng-class="{\'alert\': SensorDetail.alertState}"><div id="scrollHeader" class="karla dark-gray-text size17pt header-text">{{SensorDetail.currentDevice.displayName}}</div></div><div id="sensor-container" class="sensor-container" data-ng-model="SensorDetail.currentSensor"><div class="nav-buffer" ng-class="{\'alert\': SensorDetail.alertState}"></div><div class="status-div" ng-class="{\'alert\': SensorDetail.alertState}"><div class="device-name-div"><img width="101px" ng-src="{{SensorDetail.imageToView.displayIcon}}"><div ng-if="SensorDetail.noDataMessage !== undefined" style="margin-top: 30px;"><p><span class="merriweather dark-gray-text size18pt" style="letter-spacing: -1px;">{{SensorDetail.noDataMessage}}</span></p></div><div class="alert-message" ng-if="SensorDetail.alertState" style="margin-top: 30px;"><p><span class="merriweather dark-gray-text size18pt" style="letter-spacing: -1px;"><span class="merriweather-bold">{{ \'WARNING\' | translate }}:</span> {{SensorDetail.currentSensor.alertDetail.message}}</span></p><p class="karla-bold white-text size12pt" style="letter-spacing: 3px;margin-top: -3px;" ng-click="SensorDetail.pathChange(\'alert\')">{{ \'VIEW_ALERT\' | translate }} <img height="12px" ng-src="{{SensorDetail.rightArrow}}"></p></div></div><hr class="mid-line" ng-class="{\'gold-line\': SensorDetail.alertState, \'gray-line\': !SensorDetail.alertState}"><div class="data-div"><div id="current-data" class="current-data"><span><img ng-src="{{SensorDetail.alertIcon}}" ng-if="SensorDetail.alertState" height="17px"> <span class="size18pt">{{SensorDetail.currentSensor.sensorValue}}{{SensorDetail.currentDevice.displayUnit}}</span></span><p style="margin-top: 3px;line-height: 100%;"><span class="karla-bold size12pt">{{ \'CURRENT_MEASUREMENT\' | translate }}</span></p></div><div id="average-data" class="average-data"><span class="size18pt">{{SensorDetail.currentDevice.displayAvgVal}}</span><p style="margin-top: 3px;line-height: 100%;"><span class="karla-bold size12pt">{{SensorDetail.currentDevice.displayAvgMsg}}</span></p></div></div></div><div class="device-info-div"><div class="karla size18pt dark-gray-text" style="margin-bottom: 15px;">{{SensorDetail.currentDevice.detailName}}</div><div class="karla size12pt light-gray-text"><span class="karla-bold">{{ \'AGE\' | translate }}</span> {{SensorDetail.currentDevice.detailAge}} Years&nbsp;&nbsp;&nbsp;&nbsp; <span class="karla-bold">{{ \'MFR_PART_NO\' | translate }}</span> {{SensorDetail.currentDevice.detailMfrNo}}</div><div ng-if="SensorDetail.currentDevice.tip == true" class="karla-bold orange-text size12pt" style="letter-spacing: 2px;-webkit-tap-highlight-color: rgba(0,0,0,0);margin-top: 22px;" ng-click="SensorDetail.pathChange(\'incentive\')">{{SensorDetail.currentDevice.tipText}}&nbsp;&nbsp;<img height="12px" ng-src="{{SensorDetail.orangeArrow}}"></div></div><div class="graph-tab-container karla-bold light-gray-text"><div class="graph-tab" ng-class=\'{ "active": SensorDetail.graphType === 0 }\' ng-click=\'SensorDetail.handleGraphTabTouch("day")\'>{{ \'DAY\' | translate }}</div><div class="graph-tab" ng-class=\'{ "active": SensorDetail.graphType === 1 }\' ng-click=\'SensorDetail.handleGraphTabTouch("week")\'>{{ \'WEEK\' | translate }}</div><div class="graph-tab" ng-class=\'{ "active": SensorDetail.graphType === 2 }\' ng-click=\'SensorDetail.handleGraphTabTouch("month")\'>{{ \'MONTH\' | translate }}</div></div><perch-graph strategy="SensorDetail.currentStrategy"></perch-graph></div>')}]);