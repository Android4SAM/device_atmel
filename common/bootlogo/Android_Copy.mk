# make file for new hardware  from 
SHELL := /bin/bash
LOCAL_PATH := device/atmel/common/bootlogo

# system configuration files
#
$(shell mkdir -p root/system)
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/initlogo.rle:root/system/initlogo.rle \
        $(LOCAL_PATH)/initlogo_pda4.rle:root/system/initlogo_pda4.rle \
        $(LOCAL_PATH)/initlogo_pda7.rle:root/system/initlogo_pda7.rle
