# config.mk
#
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true

TARGET_ARCH_VARIANT := armv7-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi

ARCH_ARM_HAVE_TLS_REGISTER := true

# Music
#HAVE_HTC_AUDIO_DRIVER := true
#BOARD_USES_GENERIC_AUDIO := true
BOARD_USES_ALSA_AUDIO := true
BUILD_WITH_ALSA_UTILS := true

# no hardware camera
USE_CAMERA_STUB := true

# Set /system/bin/sh to ash, not mksh, to make sure we can switch back.
TARGET_SHELL := ash

#init.rc
TARGET_PROVIDES_INIT_RC := true
#Bluetooth
BOARD_HAVE_BLUETOOTH := true
