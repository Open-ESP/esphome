# Board definitions
CORE_DEBUG_LEVEL ?= 
F_CPU ?= 80000000L
FLASH_MODE ?= dio
FLASH_SPEED ?= 40
UPLOAD_RESET ?= --before default_reset --after hard_reset
UPLOAD_SPEED ?= 115200
COMP_WARNINGS ?= -w
INCLUDE_VARIANT = nodemcu
VTABLE_FLAGS?=-DVTABLES_IN_FLASH
MMU_FLAGS?=-DMMU_IRAM_SIZE=0x8000 -DMMU_ICACHE_SIZE=0x8000
SSL_FLAGS?=
BOOT_LOADER?=$(ESP_ROOT)/bootloaders/eboot/eboot.elf
# Commands
C_COM=$(C_COM_PREFIX) "$(ESP_ROOT)/tools/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc" -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ "-I$(ESP_ROOT)/tools/sdk/include" "-I$(ESP_ROOT)/tools/sdk/lwip2/include" "-I$(ESP_ROOT)/tools/sdk/libc/xtensa-lx106-elf/include" "-I$(BUILD_DIR)/core" $(C_PRE_PROC_FLAGS) -c $(COMP_WARNINGS) -Os -g -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals -falign-functions=4 -MMD -std=gnu99 -ffunction-sections -fdata-sections -fno-exceptions $(SSL_FLAGS) -DNONOSDK22x_190703=1 -DF_CPU=$(F_CPU) -DLWIP_OPEN_SRC -DTCP_MSS=536 -DLWIP_FEATURES=1 -DLWIP_IPV6=0   -DARDUINO=10605 -DARDUINO_ESP8266_NODEMCU -DARDUINO_ARCH_$(UC_CHIP) -DARDUINO_BOARD=\"ESP8266_NODEMCU\"  -DFLASHMODE_DIO  -DESP8266 $(BUILD_EXTRA_FLAGS) $(C_INCLUDES) 
CPP_COM=$(CPP_COM_PREFIX) "$(ESP_ROOT)/tools/xtensa-lx106-elf/bin/xtensa-lx106-elf-g++" -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ "-I$(ESP_ROOT)/tools/sdk/include" "-I$(ESP_ROOT)/tools/sdk/lwip2/include" "-I$(ESP_ROOT)/tools/sdk/libc/xtensa-lx106-elf/include" "-I$(BUILD_DIR)/core" $(C_PRE_PROC_FLAGS) -c $(COMP_WARNINGS) -Os -g -mlongcalls -mtext-section-literals -fno-rtti -falign-functions=4 -std=gnu++11 -MMD -ffunction-sections -fdata-sections -fno-exceptions $(SSL_FLAGS) -DNONOSDK22x_190703=1 -DF_CPU=$(F_CPU) -DLWIP_OPEN_SRC -DTCP_MSS=536 -DLWIP_FEATURES=1 -DLWIP_IPV6=0   -DARDUINO=10605 -DARDUINO_ESP8266_NODEMCU -DARDUINO_ARCH_$(UC_CHIP) -DARDUINO_BOARD=\"ESP8266_NODEMCU\"  -DFLASHMODE_DIO  -DESP8266 $(BUILD_EXTRA_FLAGS) $(C_INCLUDES) 
S_COM="$(ESP_ROOT)/tools/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc" -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ "-I$(ESP_ROOT)/tools/sdk/include" "-I$(ESP_ROOT)/tools/sdk/lwip2/include" "-I$(ESP_ROOT)/tools/sdk/libc/xtensa-lx106-elf/include" "-I$(BUILD_DIR)/core" $(C_PRE_PROC_FLAGS) -c -g -x assembler-with-cpp -MMD -mlongcalls -DNONOSDK22x_190703=1 -DF_CPU=$(F_CPU) -DLWIP_OPEN_SRC -DTCP_MSS=536 -DLWIP_FEATURES=1 -DLWIP_IPV6=0   -DARDUINO=10605 -DARDUINO_ESP8266_NODEMCU -DARDUINO_ARCH_$(UC_CHIP) -DARDUINO_BOARD=\"ESP8266_NODEMCU\"  -DFLASHMODE_DIO  -DESP8266 $(BUILD_EXTRA_FLAGS) $(C_INCLUDES) 
LIB_COM="$(ESP_ROOT)/tools/xtensa-lx106-elf/bin/xtensa-lx106-elf-ar"
CORE_LIB_COM="$(ESP_ROOT)/tools/xtensa-lx106-elf/bin/xtensa-lx106-elf-ar" cru  "$(CORE_LIB)" 
LD_COM="$(ESP_ROOT)/tools/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc" -fno-exceptions -Wl,-Map "-Wl,$(BUILD_DIR)/$(MAIN_NAME).map" -g $(COMP_WARNINGS) -Os -nostdlib -Wl,--no-check-sections -u app_entry -u _printf_float -u _scanf_float -Wl,-static "-L$(ESP_ROOT)/tools/sdk/lib" "-L$(ESP_ROOT)/tools/sdk/lib/NONOSDK22x_190703" "-L$(ESP_ROOT)/tools/sdk/ld" "-L$(ESP_ROOT)/tools/sdk/libc/xtensa-lx106-elf/lib" "-Teagle.flash.4m2m.ld" -Wl,--gc-sections -Wl,-wrap,system_restart_local -Wl,-wrap,spi_flash_read  -o "$(BUILD_DIR)/$(MAIN_NAME).elf" -Wl,--start-group $^ $(BUILD_INFO_OBJ) "$(CORE_LIB)" -lhal -lphy -lpp -lnet80211 -llwip2-536-feat -lwpa -lcrypto -lmain -lwps -lbearssl -laxtls -lespnow -lsmartconfig -lairkiss -lwpa2 -lstdc++ -lm -lc -lgcc -Wl,--end-group  "-L$(BUILD_DIR)"
PART_FILE?=$(ESP_ROOT)/tools/partitions/default.csv
GEN_PART_COM=
OBJCOPY="$(PYTHON3_PATH)/python3" "$(ESP_ROOT)/tools/elf2bin.py" --eboot "$(BOOT_LOADER)" --app "$(BUILD_DIR)/$(MAIN_NAME).elf" --flash_mode $(FLASH_MODE) --flash_freq $(FLASH_SPEED) --flash_size 4M --path "$(ESP_ROOT)/tools/xtensa-lx106-elf/bin" --out "$(BUILD_DIR)/$(MAIN_NAME).bin" && \
"$(PYTHON3_PATH)/python3" "$(ESP_ROOT)/tools/signing.py" --mode sign --privatekey "$(dir $(SKETCH))/private.key" --bin "$(BUILD_DIR)/$(MAIN_NAME).bin" --out "$(BUILD_DIR)/$(MAIN_NAME).bin.signed" --legacy "$(BUILD_DIR)/$(MAIN_NAME).bin.legacy_sig" && \
"$(PYTHON3_PATH)/python3" "$(ESP_ROOT)/tools/sizes.py" --elf "$(BUILD_DIR)/$(MAIN_NAME).elf" --path "$(ESP_ROOT)/tools/xtensa-lx106-elf/bin"
SIZE_COM="$(ESP_ROOT)/tools/xtensa-lx106-elf/bin/xtensa-lx106-elf-size" -A "$(BUILD_DIR)/$(MAIN_NAME).elf"
ESPTOOL_COM?=$(error esptool must be installed for this operation! Run: pip install esptool)
UPLOAD_COM?="$(ESP_ROOT)/tools/python3/python3" "$(ESP_ROOT)/tools/upload.py" --chip esp8266 --port "$(UPLOAD_PORT)" --baud "$(UPLOAD_SPEED)"   $(UPLOAD_RESET) write_flash 0x0 "$(BUILD_DIR)/$(MAIN_NAME).bin"
SPIFFS_START?=0x200000
SPIFFS_SIZE?=0x1FA000
SPIFFS_BLOCK_SIZE?=8192
MK_FS_COM?="$(MK_FS_PATH)" -b $(SPIFFS_BLOCK_SIZE) -s $(SPIFFS_SIZE) -c $(FS_DIR) $(FS_IMAGE)
RESTORE_FS_COM?="$(MK_FS_PATH)" -b $(SPIFFS_BLOCK_SIZE) -s $(SPIFFS_SIZE) -u $(FS_RESTORE_DIR) $(FS_IMAGE)
FS_UPLOAD_COM?="$(ESP_ROOT)/tools/python3/python3" "$(ESP_ROOT)/tools/upload.py" --chip esp8266 --port "$(UPLOAD_PORT)" --baud "$(UPLOAD_SPEED)"   $(UPLOAD_RESET) write_flash 0x0 "$(BUILD_DIR)/$(MAIN_NAME).bin"
CORE_PREBUILD=
SKETCH_PREBUILD="$(PYTHON3_PATH)/python3" "$(ESP_ROOT)/tools/signing.py" --mode header --publickey "$(dir $(SKETCH))/public.key" --out "$(BUILD_DIR)/core/Updater_Signing.h"
LINK_PREBUILD="$(ESP_ROOT)/tools/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc" -CC -E -P $(VTABLE_FLAGS) "$(ESP_ROOT)/tools/sdk/ld/eagle.app.v6.common.ld.h" -o "$(BUILD_DIR)/local.eagle.app.v6.common.ld"
MEM_FLASH=^(?:\.irom0\.text|\.text|\.text1|\.data|\.rodata|)\s+([0-9]+).*
MEM_RAM=^(?:\.data|\.rodata|\.bss)\s+([0-9]+).*
FLASH_INFO=4MB (FS:2MB OTA:~1019KB)
LWIP_INFO=v2 Lower Memory
