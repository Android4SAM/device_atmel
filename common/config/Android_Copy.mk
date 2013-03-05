# make file for new hardware  from 

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
	$(LOCAL_PATH)/wallpaper_info.xml:data/system/wallpaper_info.xml \
	$(LOCAL_PATH)/rtk8723a.bin:system/etc/firmware/rtk8723a.bin 	

