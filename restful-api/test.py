from flask import Flask, request, render_template, jsonify, redirect
import json

query_intent = {
    "1": {
        "status": "SUCCESS",
        "online": True,
        "on": True
    },
    "2": {
        "status": "SUCCESS",
        "online": True,
        "on": True
    },
    "3": {
        "status": "SUCCESS",
        "online": True,
        "on": True
    },
    "4": {
        "status": "SUCCESS",
        "online": True,
        "on": True
    },
    "5": {
        "status": "SUCCESS",
        "online": True,
        "on": True
    },
    "6": {
        "status": "SUCCESS",
        "online": True,
        "thermostatMode": "on",
        "thermostatTemperatureSetpoint": 25,
        "thermostatTemperatureAmbient": 25,
    }
}

for devices in query_intent:
    if devices == "6":
        print(query_intent[devices])