#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>

#define STA_WIFI_SSID               "ESPHOME"
#define STA_WIFI_PASS               "12345678"

const char* r4venz_host =           "esp.r4venz.me";
const uint16_t r4venz_port =        8443;

WiFiClientSecure client;
HTTPClient https;

void set_gpio_state(uint8_t pin, int state) {
    if (state == 0) {
        Serial.println(state);
        digitalWrite(pin, HIGH);
    } 
    else if (state == 1) {
        Serial.println(state);
        digitalWrite(pin, LOW);
    }
}

void handleAPI() {
    if (WiFi.status() == WL_CONNECTED) {

        if (!client.connect(r4venz_host, r4venz_port)) {

            Serial.println("Connected To GoogleHome");

            https.begin(client, "http://esp.r4venz.me:8443/api/get_state");
            if (https.GET() > 0) {
                String deviceState = https.getString();
            
                DynamicJsonDocument json(1024);
                deserializeJson(json, deviceState);

                Serial.println(deviceState);

                set_gpio_state(4, json["1"]["on"]);
                set_gpio_state(5, json["2"]["on"]);
                set_gpio_state(12, json["3"]["on"]);
                set_gpio_state(13, json["4"]["on"]);
                set_gpio_state(14, json["5"]["on"]);
            }
            https.end();
            
            https.begin(client, "http://esp.r4venz.me:8443/api/set_state");
            https.addHeader("Content-Type", "application/json");
            https.POST("{\"6\":{\"online\":true,\"status\":\"SUCCESS\",\"thermostatMode\":\"cool\",\"thermostatTemperatureAmbient\":" + String(30) + ",\"thermostatTemperatureSetpoint\":" + String(30) + "}}");

            https.end();
        } else {
            Serial.println("Connecting To GoogleHome Failed!");
        }
    }
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

    client.setInsecure();

    pinMode(2, OUTPUT);
    pinMode(4, OUTPUT);
    pinMode(5, OUTPUT);
    pinMode(12, OUTPUT);
    pinMode(13, OUTPUT);
    pinMode(14, OUTPUT);
}

void loop() {
    handleAPI();
}