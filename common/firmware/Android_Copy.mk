# make file for new hardware  from 
SHELL := /bin/bash
LOCAL_PATH := device/atmel/common/firmware

# system configuration files
#
$(shell mkdir -p root/lib/firmware/atmel/)
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/wilc1000_ap_fw.bin:root/lib/firmware/atmel/wilc1000_ap_fw.bin \
        $(LOCAL_PATH)/wilc1000_p2p_fw.bin:root/lib/firmware/atmel/wilc1000_p2p_fw.bin \
        $(LOCAL_PATH)/wilc1000_fw.bin:root/lib/firmware/atmel/wilc1000_fw.bin \
        $(LOCAL_PATH)/wilc1002_firmware.bin:root/lib/firmware/atmel/wilc1002_firmware.bin \
        $(LOCAL_PATH)/wilc1003_firmware.bin:root/lib/firmware/atmel/wilc1003_firmware.bin

