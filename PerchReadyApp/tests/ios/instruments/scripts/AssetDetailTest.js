var testName = "AssetDetailTest";

var target = UIATarget.localTarget();

var app = target.frontMostApp();

var window = app.mainWindow();

target.logElementTree();


UIALogger.logStart("Asset Detail test started");



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

target.delay(10);
var waterMeter = window.scrollViews()[0].collectionViews()[0].cells()["Water Meter"];
waterMeter.tap();
target.delay(2);
var Title = window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[0];
if (Title.name() != "Water Meter"){
    UIALogger.logWarning(Title.name() + " does not match the expected title of Water Meter");
    
    UIALogger.logFail( testName + " The title is not correct");
}

var Warning = window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[1];
if (Warning.name() != "Warning:"){
    UIALogger.logWarning(Warning.name() + " does not match the expected state of Warning on the water meter");
    
    UIALogger.logFail( testName + " The warning state should be visible and the text warning should appear");
}

var Alert = window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[3];
if (Alert.name() != "VIEW ALERT"){
    UIALogger.logWarning(Alert.name() + " does not show the expected view alert text");
    
    UIALogger.logFail( testName + " you should be able to click on a view alert option");
}

// Alert detected. Expressions for handling alerts should be moved into the UIATarget.onAlert function definition.


var currentMeasurement= window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[4];

if (currentMeasurement.name() != "91 L/min"){
    UIALogger.logWarning(currentMeasurement.name() + " does not show the expected 91 L/min value");
    
    UIALogger.logFail( testName + " the current measurement value is not expected");
}

var averageMeasurement= window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[6];
if (averageMeasurement.name() != "15-16 L"){
    UIALogger.logWarning(averageMeasurement.name() + " does not show the expected 15-16 value");
    
    UIALogger.logFail( testName + " the average measurement value is not expected");
}

var assetBrand= window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[8];
if (assetBrand.name() != "Poseidon Water Meter"){
    UIALogger.logWarning(assetBrand.name() + " does not show the expected brand");
    
    UIALogger.logFail( testName + " the correct brand is not displayed");
}

window.scrollViews()[0].navigationBar().leftButton().tap();
var airConditioner = window.scrollViews()[0].collectionViews()[0].cells()["Air Conditioner"];
airConditioner.tap();
target.delay(2)
var Title = window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[0];
if (Title.name() != "Air Conditioner"){
    UIALogger.logWarning(Title.name() + " does not match the expected title of Air Conditioner");
    
    UIALogger.logFail( testName + " The title is not correct");
}

var Warning = window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[1];
if (Warning.name() != "Warning:"){
    UIALogger.logWarning(Warning.name() + " does not match the expected state of Warning on the air conditioner");
    
    UIALogger.logFail( testName + " The warning state should be visible and the text warning should appear");
}

var Alert = window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[3];
if (Alert.name() != "VIEW ALERT"){
    UIALogger.logWarning(Alert.name() + " does not show the expected view alert text");
    
    UIALogger.logFail( testName + " you should be able to click on a view alert option");
}

var averageMeasurement= window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[6];
if (averageMeasurement.name() != "4-5 Gal"){
    UIALogger.logWarning(averageMeasurement.name() + " does not show the expected 4-5 Gal");
    
    UIALogger.logFail( testName + " the average measurement value is not expected");
}

var assetBrand= window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[8];
if (assetBrand.name() != "Ocean Breeze AC Horizontal Cased Coil"){
    UIALogger.logWarning(assetBrand.name() + " does not show the expected brand");
    
    UIALogger.logFail( testName + " the correct brand is not displayed");
}


window.scrollViews()[0].navigationBar().leftButton().tap();
var sewerSystem = window.scrollViews()[0].collectionViews()[0].cells()["Sewer System"];
sewerSystem.tap();
target.delay(2)
var Title = window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[0];
if (Title.name() != "Sewer System"){
    UIALogger.logWarning(Title.name() + " does not match the expected title of Air Conditioner");
    
    UIALogger.logFail( testName + " The title is not correct");
}
var currentMeasurement= window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[1];
if (currentMeasurement.name() != "3 kL"){
    UIALogger.logWarning(currentMeasurement.name() + " does not show the expected 3 kL value");
    
    UIALogger.logFail( testName + " the current measurement value is not expected");
}
var averageMeasurement= window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[3];
if (averageMeasurement.name() != "2%"){
    UIALogger.logWarning(averageMeasurement.name() + " does not show the expected 2%");
    
    UIALogger.logFail( testName + " the average measurement value is not expected");
}

var assetBrand= window.scrollViews()[0].scrollViews()[1].webViews()[0].staticTexts()[5];
if (assetBrand.name() != "Pipeline 5000 Liter Septic Tank"){
    UIALogger.logWarning(assetBrand.name() + " does not show the expected brand");
    
    UIALogger.logFail( testName + " the correct brand is not displayed");
}

UIALogger.logPass( testName + " was successful");

