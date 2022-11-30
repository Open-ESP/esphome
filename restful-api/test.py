import json

file = open("devices.json")
data = json.load(file)
print(data[0])