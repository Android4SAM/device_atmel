# Copyright (C) 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Copy some config files: idc alsa etc...
$(call inherit-product, device/atmel/common/config/Android_Copy.mk)

# Atmel boot logo
$(call inherit-product, device/atmel/common/bootlogo/Android_Copy.mk)

#Enabling Ring Tones
$(call inherit-product, frameworks/base/data/sounds/OriginalAudio.mk)

LOCAL_PATH := device/atmel/sama5d4

PRODUCT_COPY_FILES += \
        $(LOCAL_PATH)/init.rc:root/init.rc \
        $(LOCAL_PATH)/init.sama5-ek.rc:root/init.sama5-ek.rc \
        $(LOCAL_PATH)/init.sama5-pda.rc:root/init.sama5-pda.rc \
        $(LOCAL_PATH)/ueventd.sama5-ek.rc:root/ueventd.sama5-ek.rc \
        $(LOCAL_PATH)/ueventd.sama5-pda.rc:root/ueventd.sama5-pda.rc \
        $(LOCAL_PATH)/init.sama5d4.usb.rc:root/init.sama5d4.usb.rc

PRODUCT_COPY_FILES += \
		$(LOCAL_PATH)/libstagefrighthw.so:system/lib/libstagefrighthw.so \
		$(LOCAL_PATH)/libhantro_omx_core.so:system/lib/libhantro_omx_core.so \
		$(LOCAL_PATH)/libOMX.hantro.G1.video.decoder.so:system/lib/libOMX.hantro.G1.video.decoder.so

PRODUCT_PACKAGES += \
        Calibrate \
        AtmelLogo \
        Ethernet \
        PinyinIME \
        libjni_pinyinime \
        libdrmframework_jni \
        com.android.inputmethod.pinyin.lib \
        lights.$(TARGET_BOOTLOADER_BOARD_NAME) \
        gralloc.$(TARGET_BOOTLOADER_BOARD_NAME) \
        audio.primary.$(TARGET_BOOTLOADER_BOARD_NAME) \
        hwcomposer.$(TARGET_BOOTLOADER_BOARD_NAME) \
        copybit.$(TARGET_BOOTLOADER_BOARD_NAME) \
        libGLES_ATMEL_SAM \
        PicoLangInstaller

PRODUCT_PACKAGES += \
        libethernet_jni 

# These are the hardware-specific features
PRODUCT_COPY_FILES += \
        frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
        frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
        frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.xml
PRODUCT_PROPERTY_OVERRIDES += ro.config.low_ram=true \
                              wifi.interface=wlan0   \
                              dalvik.vm.jit.codecachesize=0
