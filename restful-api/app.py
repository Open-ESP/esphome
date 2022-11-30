from urllib import response
from flask import Flask, request, render_template, jsonify, redirect
import json
import uuid
import urllib
import sys

app = Flask(__name__)

CLIENT_ID =     "ABC123"
CLIENT_SECRET = "CBA123"

user_code = None
user_name = None

sync_intent = [
    {
        "id": "1",
        "type": "action.devices.types.SWITCH",
        "traits": [
            "action.devices.traits.OnOff"
        ],
        "name": {
        "defaultNames": [
            "Plug Socket"
        ],
        "name": "Smart Switch",
        "nicknames": [
            "New Switch"
        ]
        },
        "deviceInfo": {
            "manufacturer": "Siddhy Co",
            "model": "Siddhys On/Off Switch",
            "hwVersion": "6.0",
            "swVersion": "7.0.1"
        },
        "willReportState": True,
        "attributes": {
            "commandOnlyOnOff": "false"
        }
    },
        {
        "id": "2",
        "type": "action.devices.types.SWITCH",
        "traits": [
            "action.devices.traits.OnOff"
        ],
        "name": {
        "defaultNames": [
            "Plug Socket"
        ],
        "name": "Smart Switch",
        "nicknames": [
            "New Switch"
        ]
        },
        "deviceInfo": {
            "manufacturer": "Siddhy Co",
            "model": "Siddhys On/Off Switch",
            "hwVersion": "6.0",
            "swVersion": "7.0.1"
        },
        "willReportState": True,
        "attributes": {
            "commandOnlyOnOff": "false"
        }
    },
    {
        "id": "3",
        "type": "action.devices.types.SWITCH",
        "traits": [
            "action.devices.traits.OnOff"
        ],
        "name": {
        "defaultNames": [
            "Plug Socket"
        ],
        "name": "Smart Switch",
        "nicknames": [
            "New Switch"
        ]
        },
        "deviceInfo": {
            "manufacturer": "Siddhy Co",
            "model": "Siddhys On/Off Switch",
            "hwVersion": "6.0",
            "swVersion": "7.0.1"
        },
        "willReportState": True,
        "attributes": {
            "commandOnlyOnOff": "false"
        }
    },
    {
        "id": "4",
        "type": "action.devices.types.SWITCH",
        "traits": [
            "action.devices.traits.OnOff"
        ],
        "name": {
        "defaultNames": [
            "Plug Socket"
        ],
        "name": "Smart Switch",
        "nicknames": [
            "New Switch"
        ]
        },
        "deviceInfo": {
            "manufacturer": "Siddhy Co",
            "model": "Siddhys On/Off Switch",
            "hwVersion": "6.0",
            "swVersion": "7.0.1"
        },
        "willReportState": True,
        "attributes": {
            "commandOnlyOnOff": "false"
        }
    },
    {
        "id": "5",
        "type": "action.devices.types.SWITCH",
        "traits": [
            "action.devices.traits.OnOff"
        ],
        "name": {
        "defaultNames": [
            "Plug Socket"
        ],
        "name": "Smart Switch",
        "nicknames": [
            "New Switch"
        ]
        },
        "deviceInfo": {
            "manufacturer": "Siddhy Co",
            "model": "Siddhys On/Off Switch",
            "hwVersion": "6.0",
            "swVersion": "7.0.1"
        },
        "willReportState": True,
        "attributes": {
            "commandOnlyOnOff": "false"
        }
    },

    {
        "id": "6",
        "type": "action.devices.types.THERMOSTAT",
        "traits": [
          "action.devices.traits.TemperatureSetting"
        ],
        "name": {
          "name": "Simple thermostat"
        },
        "willReportState": True,
        "attributes": {
          "availableThermostatModes": [
            "cool"
          ],
          "thermostatTemperatureRange": {
            "minThresholdCelsius": 15,
            "maxThresholdCelsius": 60
          },
          "thermostatTemperatureUnit": "C",
          "queryOnlyTemperatureSetting": True
        },
        "deviceInfo": {
          "manufacturer": "smart-home-inc",
          "model": "hs1234",
          "hwVersion": "3.2",
          "swVersion": "11.4"
        }
    },
]

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

@app.route('/auth/', methods=['GET', 'POST'])
def auth():
    global user_code, user_name
    
    if request.method == "GET":
        return render_template("login.html")
    elif request.method == "POST":
        user = request.form["username"]
        password = request.form["password"]
        
    if user == "admin" and password == "admin":
        
        user_code = str(uuid.uuid4())
        user_name = request.form["username"]
        
        params = {
            "state": request.args["state"],
            "code": user_code,
            "client_id": CLIENT_ID
        }
        
        return redirect(request.args["redirect_uri"] + "?" + urllib.parse.urlencode(params))
    else:
        return render_template("login.html", login_failed=True)
    
@app.route("/token/", methods=["POST"])
def token():
    global user_code, user_name, access_token
    
    if ("client_secret" not in request.form
        or request.form["client_secret"] != CLIENT_SECRET
        or "client_id" not in request.form
        or request.form["client_id"] != CLIENT_ID
        or "code" not in request.form):
            return "Invalid request", 401
    if request.form["code"] != user_code:
        return "Invalid code", 402
    
    token = str(uuid.uuid4().hex)
    with open("access_token.json", "r+") as file:
        data = json.load(file)
        data.update({token: user_name})
        file.seek(0)
        json.dump(data, file)
        
    return jsonify({"access_token": token})

@app.route('/', methods=['GET', 'POST'])
def fulfillment():
    # Handle Authorization
    headers = request.headers.get("Authorization")
    headers = headers.split(' ', 2)
    if headers[0] == "Bearer":
        with open("access_token.json", "r") as file:
            data = json.load(file)
            try:
                user_id = str(data[headers[1]])
            except KeyError:
                return "Access Denied", 403
            
    # Handle Fulfillment        
    req = request.get_json()
    
    result = {}
    result["requestId"] = req["requestId"]
    
    for i in req["inputs"]:
        
        intent = i["intent"]
        
        if intent == "action.devices.SYNC":
            result["payload"] = {"agentUserId": user_id, "devices": []}
            result["payload"]["devices"] = sync_intent
                
        if intent == "action.devices.QUERY":
            result["payload"] = {}
            result["payload"]["devices"] = {}
            for device in i["payload"]["devices"]:
                device_id = device["id"]
                result["payload"]["devices"][device_id] = query_intent[device_id]
                
        if intent == "action.devices.EXECUTE":
            result["payload"] = {}
            result["payload"]["commands"] = []
            for command in i["payload"]["commands"]:
                for device in command["devices"]:
                    device_id = device["id"]
                    for execution in command["execution"]:
                        
                        command = execution["command"]
                        params = execution["params"]
                        
                        if command == "action.devices.commands.OnOff":
                            
                            response = {
                                "ids": [
                                    device_id
                                ],
                                "status": "SUCCESS",
                                "states": {
                                    "online": True,
                                    "on": params["on"]
                                }
                            }
                            
                            result["payload"]["commands"].append(response)
                            query_intent[device_id]["on"] = params["on"]
                                
                            
    return jsonify(result)


@app.route('/api/get_state', methods=['GET'])
def get_state():
    
    return query_intent


@app.route('/api/set_state', methods=['POST'])
def commands():
    
    req = request.get_json()
    
    for device in req:
        if device == "6":
            query_intent[device]["thermostatTemperatureSetpoint"] = req[device]["thermostatTemperatureSetpoint"]
            query_intent[device]["thermostatTemperatureAmbient"] = req[device]["thermostatTemperatureAmbient"]
    
    return jsonify({"status":"SUCCESS"})

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8443, ssl_context=('cert.pem', 'key.pem'))
