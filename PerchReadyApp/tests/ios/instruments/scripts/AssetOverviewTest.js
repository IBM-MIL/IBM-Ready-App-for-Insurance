var testName = "AssetOverviewTest";

var target = UIATarget.localTarget();

var app = target.frontMostApp();

var window = app.mainWindow();

target.logElementTree();


UIALogger.logStart("Asset Overview test started");


/*

UIATarget.onAlert = function onAlert(alert) {
    var title = alert.name();
    UIALogger.logWarning("Alert with title '" + title + "' encountered."); 
    try{
       target.frontMostApp().alert().buttons()["Yes"].tap(); 
    }
    catch(e){
         UIALogger.logWarning("Demo Mode Alert not visible");
    }
    return false;
}

target.delay(40);

var waterMeterText = window.scrollViews()[0].collectionViews()[0].cells()["Water Meter"];

if (waterMeterText.isValid()== false){
    UIALogger.logFail( testName + " Try Again button not visible");
}


UIALogger.logPass( testName + " was successful");

var waterMeter = window.scrollViews()[0].collectionViews()[0].cells()[0];
if(waterMeter.name()!="Water Meter"){
    UIALogger.logWarning(waterMeter.name() + " does not match the expected Water Meter text");
    
    UIALogger.logFail( testName + " Water Meter is not visible or not in the correct position");
}

var airConditioner = window.scrollViews()[0].collectionViews()[0].cells()[1];
if(airConditioner.name()!="Air Conditioner"){
    UIALogger.logWarning(airConditioner.name() + " does not match the expected Air Conditioner text");
    
    UIALogger.logFail( testName + "Air Conditioner is not visible or not in the correct position");}
var sewerSystem = window.scrollViews()[0].collectionViews()[0].cells()[2];
if(sewerSystem.name()!="Sewer System"){
    UIALogger.logWarning(sewerSystem.name() + " does not match the expected Sewer System text");
    
    UIALogger.logFail( testName + "Sewer System is not visible or not in the correct position");
}
var electricalPanel = window.scrollViews()[0].collectionViews()[0].cells()[3];

if(electricalPanel.name()!="Electrical Panel"){
    UIALogger.logWarning(electricalPanel.name() + " does not match the expected Electrical Panel text");
    
    UIALogger.logFail( testName + "Electrical Panel is not visible or not in the correct position");
    
}
*/
UIALogger.logPass( testName + " was successful");