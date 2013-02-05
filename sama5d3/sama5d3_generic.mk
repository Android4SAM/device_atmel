# This is a generic product that isn't specialized for a specific device.
# It includes the base Android platform. If you need Google-specific features,
# you should derive from generic_with_google.mk

$(call inherit-product, $(TOPDIR)device/atmel/common/generic_no_telephony.mk)

# Inherit from atmel device
$(call inherit-product, device/atmel/sama5d3/device.mk)

# Overrides
PRODUCT_NAME := sama5d3
PRODUCT_MANUFACTURER := atmel
PRODUCT_DEVICE := sama5d3
PRODUCT_BRAND := atmel

TARGET_BOOTLOADER_BOARD_NAME := sama5d3-ek
