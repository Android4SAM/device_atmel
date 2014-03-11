# make file for new hardware  from 
PREBUILD_FIRMWARE := false
LOCAL_PATH := device/atmel/common/config

# system configuration files
#
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/vold.fstab:system/etc/vold.fstab \
	$(LOCAL_PATH)/asound.conf:system/etc/asound.conf \
	$(LOCAL_PATH)/android.conf:system/etc/android.conf \
	$(LOCAL_PATH)/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl \
	$(LOCAL_PATH)/AT42QT1070_QTouch_Sensor.kl:system/usr/keylayout/AT42QT1070_QTouch_Sensor.kl \
	$(LOCAL_PATH)/egl.cfg:system/lib/egl/egl.cfg \
	$(LOCAL_PATH)/atmel_touch_screen_controller.idc:system/usr/idc/atmel_touch_screen_controller.idc \
        $(LOCAL_PATH)/Atmel_maXTouch_Touchscreen.idc:system/usr/idc/Atmel_maXTouch_Touchscreen.idc     \
	$(LOCAL_PATH)/media_profiles.xml:system/etc/media_profiles.xml \
	$(LOCAL_PATH)/media_codecs.xml:system/etc/media_codecs.xml \
	$(LOCAL_PATH)/mixer_paths.xml:system/etc/mixer_paths.xml

ifeq ($(PREBUILD_FIRMWARE), realtek)
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/wlan.ko:system/lib/modules/wlan.ko \
	$(LOCAL_PATH)/rtk_btusb.ko:system/lib/modules/rtk_btusb.ko \
	$(LOCAL_PATH)/rtk8723a:system/etc/firmware/rtk8723a
endif
