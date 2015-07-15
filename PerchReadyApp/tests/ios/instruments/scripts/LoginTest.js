var testName = "LoginTest";

var target = UIATarget.localTarget();

var app = target.frontMostApp();

var window = app.mainWindow();

target.logElementTree();


UIALogger.logStart("Login test started");
target.delay(3);

function dismissMQA() {
    target.delay(1);
    target.tap({x:265.50, y:200.00});
    
}

UIATarget.onAlert = function onAlert(alert) {
    var title = alert.name();
    UIALogger.logWarning("Alert with title '" + title + "' encountered.");
    
    
    if(title =="Q4M"){
        target.frontMostApp().alert().defaultButton().tap();
    }
    return false;	
}

var needPinButtonName = window.buttons()[0].name();

target.delay(3);

dismissMQA();

target.delay(3);
try{
    target.frontMostApp().alert().buttons()[0].tap();
    target.frontMostApp().alert().buttons()[0].tap();
}
catch (e) {
    
}



target.delay(3);



var pinEditText= window.textFields()[0].textFields()[0];

pinEditText.tap();



target.frontMostApp().keyboard().typeString("0000");

target.delay(3);


window.buttons()[3].tap();




target.delay(5);


var LoginTitle= window.staticTexts()[1].name();
if (LoginTitle!="Log In"){
    UIALogger.logWarning(LoginTitle + " does not match the expected Log In text");
    
    UIALogger.logFail( testName + " Log In Title not visible");
}
var userEditText = window.textFields()[0].textFields()[0];
userEditText.tap();
app.keyboard().typeString("wrong_user1");
var passwordEditText = window.secureTextFields()[0].secureTextFields()[0];
passwordEditText.tap();
app.keyboard().typeString("wrong_password1");


var enterButton = window.buttons()[0];
if (enterButton.name()!="ENTER"){
    UIALogger.logWarning(enterButton.name() + " does not match the expected ENTER text");
    
    UIALogger.logFail( testName + " Enter button not visible");
}

enterButton.tap();

target.delay(5);

var tryAgainButton = window.buttons()[0]
if(tryAgainButton.name() != "TRY AGAIN"){
    UIALogger.logWarning(tryAgainButton.name() + " does not match the expected TRY AGAIN text");
    
    UIALogger.logFail( testName + " Try Again button not visible");
}

userEditText.tap();
app.keyboard().typeString("user1");

passwordEditText.tap();
app.keyboard().typeString("password1");


tryAgainButton.tap();

target.delay(5);

var waterMeterText = window.scrollViews()[0].collectionViews()[0].cells()["Water Meter"];

if (waterMeterText.isValid()== false){
    UIALogger.logFail( testName + " Try Again button not visible");
}


UIALogger.logPass( testName + " was successful");



