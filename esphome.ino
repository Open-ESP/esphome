#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#define MEASUREMENT_INTERVAL 1000

int16_t measurement[5] = { -1, -1, -1, -1, -1};
unsigned long oldTime = 30000;

String suhuValue;

#define STA_WIFI_SSID               "Free wifi sedang ultah wokwkwk"
#define STA_WIFI_PASS               ""

const char* r4venz_host =           "esp.r4venz.me";
const uint16_t r4venz_port =        8443;

WiFiClientSecure client;
HTTPClient https;

void set_gpio_state(uint8_t pin, int state) {
    if (state == 0) {
        digitalWrite(pin, HIGH);
    } 
    else if (state == 1) {
        digitalWrite(pin, LOW);
    }
}

void handleAPI() {
    if (WiFi.status() == WL_CONNECTED) {

        client.setInsecure();

        if (client.connect(r4venz_host, r4venz_port)) {

            set_gpio_state(2, 1);
            Serial.println("Sending requests to server..");

            https.begin(client, "http://esp.r4venz.me:8443/api/get_state");
            if (https.GET() > 0) {
                String deviceState = https.getString();
            
                DynamicJsonDocument json(1024);
                deserializeJson(json, deviceState);

                set_gpio_state(4, json["1"]["on"]);
                set_gpio_state(5, json["2"]["on"]);
                set_gpio_state(12, json["3"]["on"]);
                set_gpio_state(13, json["4"]["on"]);
                set_gpio_state(14, json["5"]["on"]);
            }
            https.end();
            
            https.begin(client, "https://esp.r4venz.me:8443/api/set_state");
            https.addHeader("Content-Type", "application/json");
            https.POST("{\"6\":{\"online\":true,\"status\":\"SUCCESS\",\"thermostatTemperatureAmbient\":" + suhuValue + ",\"thermostatTemperatureSetpoint\":" + suhuValue + "}}");
            https.end();
        } else {
            Serial.println("Failed to sent requests, server disconnected!");
        }
        set_gpio_state(2, 0);
    }
}

void temp_detect(int16_t *temperature) {
  String temperatureStr = String(temperature[0]);
  suhuValue = temperatureStr;
}

void setup() {
    Serial.begin(115200);
    Serial.println();
    
    Serial.println("Booting ESP..");

    WiFi.mode(WIFI_STA);

    WiFi.begin(STA_WIFI_SSID, STA_WIFI_PASS);

    Serial.print("Connecting to WiFi");
    while (WiFi.status() != WL_CONNECTED) {
        Serial.print(".");
        delay(500);
    }
    Serial.println();

    pinMode(2, OUTPUT);
    pinMode(4, OUTPUT);
    pinMode(5, OUTPUT);
    pinMode(12, OUTPUT);
    pinMode(13, OUTPUT);
    pinMode(14, OUTPUT);
}

void loop() {
    handleAPI();
    if (millis() - oldTime >= MEASUREMENT_INTERVAL) {
    float milliVoltage = analogRead(A0) * 3300.0 / 1023.0;
    float temperature = (milliVoltage - 500) / 10;

    if (temperature - (int)temperature > 0.5)
      temperature = (int)temperature + 1;
    else
      temperature = (int)temperature;

    for (byte i = 4; i > 0; i--)
      measurement[i] = measurement[i - 1];
    measurement[0] = (int)temperature;

    temp_detect(measurement);
    oldTime = millis();
  }
}
