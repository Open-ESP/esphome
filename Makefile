SKETCH = ./esphome.ino

UPLOAD_PORT = /dev/ttyUSB0
UPLOAD_SPEED = 115200

CHIP = esp8266
BOARD = nodemcuv2
FS_TYPE = spiffs
FS_DIR = spiffs/

BUILD_ROOT = out
BUILD_DIR = out/objects

build_out:
	mkdir out
	mkdir out/objects

include ./scripts/makeEspArduino.mk
