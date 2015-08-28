describe("The simulator UI", function () {
    
    var sensordef = {
        water: {
            device_class_id: 10001,
            text: "Water Meter",
            defaultValue: 75,
            displayUnit: " L"
        },
        ac: {
            device_class_id: 10002,
            text: "Air Conditioner",
            defaultValue: 30,
            displayUnit: " deg"
        }
    };
    
    beforeEach(function () {
        $('body').append('<div id="pin"></div>');
        $('body').append('<ol class="carousel-indicators"></ol>');
        $('body').append('<div class="carousel-inner"></div>');
        packetPayload = {
            d: {
            }
        }
        sensordef = {
            water: {
                device_class_id: 10001,
                text: "Water Meter",
                defaultValue: 75,
                displayUnit: " L"
            },
            ac: {
                device_class_id: 10002,
                text: "Air Conditioner",
                defaultValue: 30,
                displayUnit: " deg"
            }
        };
        sensorDefinition = sensordef;
    });
    
    afterEach(function () {
        $(".carousel-inner").remove();
        $(".carousel-indicators").remove();
        $("#pin").remove();
    });
    
    it("changes the topic and PIN when the number is received", function () {
        registerPin("1234");
        expect(topic).toEqual("iot-2/evt/sensor-data-1234/fmt/json");
        expect($("#pin")).toContainHtml("PIN: 1234");
    });
    
    it("can create the HTML for an individual sensor dynamically", function () {        
        createSensor("water", "Water Meter", 0, "green");
        
        expect($(".carousel-indicators li")).toBeInDOM();
        expect($(".carousel-indicators li")).toHaveAttr("data-slide-to","0");
        expect($(".carousel-indicators li")).toHaveClass("active");
        
        expect($('#waterDown')).toBeInDOM();
        expect($('#waterDown')).toHaveAttr("onclick","decrease(\"water\")");
        expect($('#waterDown')).toContainElement("span.glyphicon-arrow-down");      
        
        expect($('#waterUp')).toBeInDOM();
        expect($('#waterUp')).toHaveAttr("onclick","increase(\"water\")");
        expect($('#waterUp')).toContainElement("span.glyphicon-arrow-up");
        
        expect($('#waterReading')).toBeInDOM();
        
        expect($("div.readingButtons")).toBeInDOM();
        expect($("div.readingButtons")).toContainElement("#waterDown");
        expect($("div.readingButtons")).toContainElement("#waterUp");
        expect($("div.carousel-caption")).toContainElement("div.readingButtons");
        
        expect($("h4")).toContainText("Water Meter");
        expect($("h1#waterReading")).toBeInDOM();
        expect($("div.green")).toHaveClass("active");
        expect($("div.carousel-inner")).toContainElement("div.green");
    });
    
    it("can generate a group of sensors from a definition object", function () {
        initSensors(sensordef);
        
        // Quickly check to see that sensor HTML was created.
        expect($("#waterDown")).toBeInDOM();
        expect($("#acUp")).toBeInDOM();
        expect($("div.navy")).toHaveClass("active");
        expect($("div.green")).not.toHaveClass("active");
        
        // Then inspect the values stored in the HTML for display.
        expect($("#waterReading")).not.toHaveText("75 L");
        expect($("#acReading")).not.toHaveText("30 deg");
        
        // They shouldn't work until we call the update function.
        updateSensors();
        
        // Now check again.
        expect($("#waterReading")).toHaveText("75 L");
        expect($("#acReading")).toHaveText("30 deg");
        
        // Now inspect the packet payload.
        expect(packetPayload.d["10001"]).toEqual(75);
        expect(packetPayload.d["10002"]).toEqual(30);
    });
    
    it("can increase the value of a sensor", function () {
        initSensors(sensordef);
        updateSensors();
        
        // Check the current value of the water sensor.
        expect($("#waterReading")).toHaveText("75 L");
        expect(packetPayload.d["10001"]).toEqual(75);
        
        // Increase the sensor value.
        increase("water");
        
        // Check the new value of the water sensor.
        expect($("#waterReading")).toHaveText("76 L");
        expect(packetPayload.d["10001"]).toEqual(76);
    });
    
    it("can decrease the value of a sensor", function () {
        initSensors(sensordef);
        updateSensors();
        
        // Check the current value of the AC sensor.
        expect($("#acReading")).toHaveText("30 deg");
        expect(packetPayload.d["10002"]).toEqual(30);
        
        // Decrease the sensor value.
        decrease("ac");
        
        // Check the new value of the AC sensor.
        expect($("#acReading")).toHaveText("29 deg");
        expect(packetPayload.d["10002"]).toEqual(29);
    });
    
    it("should not increase a sensor's value beyond the maximum", function () {
        sensordef.water.absoluteMax = 76;
        sensorDefinition = sensordef;
        initSensors(sensordef);
        updateSensors();
        
        // Check the current value of the water sensor.
        expect($("#waterReading")).toHaveText("75 L");
        expect(packetPayload.d["10001"]).toEqual(75);
        
        // Increase the sensor value.
        increase("water");
        
        // Check the new value of the water sensor.
        expect($("#waterReading")).toHaveText("76 L");
        expect(packetPayload.d["10001"]).toEqual(76);
        
        // Increase the sensor value again.
        increase("water");
        
        // The value should not have changed.
        expect($("#waterReading")).toHaveText("76 L");
        expect(packetPayload.d["10001"]).toEqual(76);
    });
    
    it("should not decrease a sensor's value beyond the minimum", function () {
        sensordef.ac.absoluteMin = 29;
        sensorDefinition = sensordef;
        initSensors(sensordef);
        updateSensors();
        
        // Check the current value of the AC sensor.
        expect($("#acReading")).toHaveText("30 deg");
        expect(packetPayload.d["10002"]).toEqual(30);
        
        // Decrease the sensor value.
        decrease("ac");
        
        // Check the new value of the AC sensor.
        expect($("#acReading")).toHaveText("29 deg");
        expect(packetPayload.d["10002"]).toEqual(29);
        
        // Decrease the sensor value again.
        decrease("ac");
        
        // The value should not have changed.
        expect($("#acReading")).toHaveText("29 deg");
        expect(packetPayload.d["10002"]).toEqual(29);
    });
});