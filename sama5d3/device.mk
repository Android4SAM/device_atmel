# Include other Android.mk

LOCAL_PATH := device/atmel/sama5d3
 
common_dir := device/atmel/common

#PRODUCT_PACKAGE_OVERLAYS := $(common_dir)/overlay
DEVICE_PACKAGE_OVERLAYS := $(common_dir)/overlay

# Copy init.rc init.atmel.rc
PRODUCT_COPY_FILES := \
	$(LOCAL_PATH)/init.sama5d3x-ek.rc:root/init.sama5d3x-ek.rc \
	$(LOCAL_PATH)/init.sama5d3x-pda.rc:root/init.sama5d3x-pda.rc \
	$(LOCAL_PATH)/init.miura.usb.rc:root/init.miura.usb.rc

#ifeq ($(strip $(TARGET_PROVIDES_INIT_RC)),true)
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/init.rc:root/init.rc \
	$(LOCAL_PATH)/ueventd.sama5d3x-ek.rc:root/ueventd.sama5d3x-ek.rc \
	$(LOCAL_PATH)/ueventd.sama5d3x-pda.rc:root/ueventd.sama5d3x-pda.rc
#endif
	
#PRODUCT_COPY_FILES += \
#	$(LOCAL_PATH)/libhantro_hwdec.so:obj/lib/libhantro_hwdec.so \
#	$(LOCAL_PATH)/libhantro_hwdec.so:system/lib/libhantro_hwdec.so

# Publish that we support the live wallpaper feature.
PRODUCT_COPY_FILES += packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:/system/etc/permissions/android.software.live_wallpaper.xml  \
frameworks/base/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
frameworks/base/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
frameworks/base/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml

PRODUCT_PROPERTY_OVERRIDES := \
	wifi.interface=wlan0

PRODUCT_PACKAGES += \
	Calibrate \
        Camera    \
	AtmelLogo \
	Ethernet \
	PinyinIME \
	libjni_pinyinime \
	libdrmframework_jni \
	com.android.inputmethod.pinyin.lib \
	lights.$(TARGET_BOOTLOADER_BOARD_NAME) \
	gralloc.$(TARGET_BOOTLOADER_BOARD_NAME) \
	hwcomposer.$(TARGET_BOOTLOADER_BOARD_NAME) \
	copybit.$(TARGET_BOOTLOADER_BOARD_NAME) \
        camera.$(TARGET_BOOTLOADER_BOARD_NAME)

PRODUCT_PACKAGES += \
	libethernet_jni \
	libGLES_ATMEL_SAM
	
PRODUCT_PACKAGES += \
	libasound \
	audio.primary.$(TARGET_BOOTLOADER_BOARD_NAME) \
	libaudiopolicy \
	alsa.default

#Include this Android.mk to copy the initlogo.rle
#So android will show an boot logo at bootup time
#After show the logo,android will remove the picture,so we use a command in init.atmel.rc to copy this picture
include $(common_dir)/bootlogo/800*480/Android_Copy.mk

#Use our own vold.conf for sd card auto mount and asound.conf for Music configuration
include $(common_dir)/config/Android_Copy.mk

#Include this Android.mk to make to copy the config file needed for wifi
include $(common_dir)/config/wifi/Android_Copy.mk

#For audio
include $(TOPDIR)external/alsa-lib/src/conf/Android_Copy.mk 
#Include this mk file to install some ogg files to our system
include $(TOPDIR)frameworks/base/data/sounds/AllAudio.mk
