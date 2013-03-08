# make file for new hardware  from 

LOCAL_PATH := device/atmel/common/config/wifi

# system configuration files
#
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/wlan.ko:system/lib/modules/wlan.ko
