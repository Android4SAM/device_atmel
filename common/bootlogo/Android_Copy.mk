# make file for new hardware  from 
SHELL := /bin/bash
LOCAL_PATH := device/atmel/common/bootlogo

# system configuration files
#
$(shell mkdir -p root/system)
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/wvga.rle:root/system/wvga.rle \
        $(LOCAL_PATH)/hvga.rle:root/system/hvga.rle

PRODUCT_COPY_FILES += \
        $(LOCAL_PATH)/init.wvga.rc:root/init.wvga.rc \
        $(LOCAL_PATH)/init.hvga.rc:root/init.hvga.rc
