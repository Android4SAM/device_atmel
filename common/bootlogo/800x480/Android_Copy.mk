# make file for new hardware  from 
SHELL := /bin/bash
LOCAL_PATH := device/atmel/common/bootlogo/800x480

# system configuration files
#
$(shell mkdir -p root/system)
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/initlogo.rle:root/system/initlogo.rle
