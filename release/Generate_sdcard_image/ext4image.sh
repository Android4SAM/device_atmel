#!/bin/bash
#
# sdimage.sh - Generate the android RootFS with the type of ext4.
#
# Copyright (C) 2010-2014 <www.embedinfo.com> <www.atmel.com>
# Created. Max Liao <liaops@embedinfo.com>

RELEASE_VERSION=ver1.1
ANDROID_VERSION=ANDROID-4.2.2_r1.1
ANDROID_PATH=$PWD
EXT4_MNT_DIR=/tmp/mnt_dir
ATMEL_SDCARD_TOOL=$ANDROID_PATH/device/atmel/release/Generate_sdcard_image
ERRLOGFILE=$ANDROID_PATH/make_android_ext4_image.log
ROOTFS_IMAGE_NAME=android_ext4_image.img
ROOTFS_IMAGE_SIZE=320

HELP_MESSAGE=("mkext4_image -b build_target\n
    -b Specify the build target. We now support sama5d3 | sama5d3isi.
    -h Print help message\n"
    "We only support the following build targets\n sama5d3 | sama5d3isi\n"
    "You must specify build target.\nExample: -b sama5d3\n")

HELP()
{
    echo
    if [ "$1" != "0" ];then
        echo Error:
    else
        echo Usage:
    fi
    echo "-----------------------------"
    echo -e "${HELP_MESSAGE[$1]}"
    exit
}

Display()
{
    echo "=============================="
    echo "Board chip:$PRODUCT_DEVICE"
    echo "=============================="
}

redirect_stdout_stderr()
{
    exec 6>&2
    exec 7>&1
    exec &> $ERRLOGFILE
    echo "/*--------------------------log file for this shell--------------------------*/"
}

recover_stdout_stderr()
{
    exec 2>&6 6>&-
    exec 1>&7 7>&-
}

success_cmd()
{
    echo "Done!"
    recover_stdout_stderr;
    echo "Success:you can get $ROOTFS_IMAGE_NAME under current directory!"
    exit
}

check_cmd()
{
    echo "$1"
    $1
    var=$?
    if [ 0 = $var ];then
    echo Successful
    echo
    else
    exit_cmd;
    fi
}

exit_cmd()
{
    recover_stdout_stderr;
    echo "Failed: please see $ERRLOGFILE for detail message!"
    exit
}

rm_dir()
{
    local WARNING_MESSAGE[1]="Sure to remove $1? If not sure Enter no to exit\n"
    local WARNING_MESSAGE[2]="What's your choice? (YES / no) "
    if [ -e "$1" ];then
        if [ "$FORCE_REMOVE" == "false" ] ; then
            Warning 1 2
            check_cmd "rm -rf $1"
        else
            check_cmd "rm -rf $1"
        fi
    fi
}

rm_img()
{
    if [ -e ./$ROOTFS_IMAGE_NAME ];then
    check_cmd "rm ./$ROOTFS_IMAGE_NAME"
    fi
}

if [ -z "$1" ];then
    HELP 0;
fi

until [ -z "$1" ]
do
    case "$1" in
        "-b" )
            shift
            var_boardchip=$1
            case "$var_boardchip" in
                "sama5d3" )
                    PRODUCT_DEVICE=$1
                    ;;

                "sama5d3isi" )
                    PRODUCT_DEVICE=$1
                    ;;
                * )
                    HELP 1;
                ;;
            esac
        ;;
        "-h" )
            HELP 0;
        ;;
        "--h" )
            HELP 0;
        ;;
    esac
    shift
done

if [ -z "$PRODUCT_DEVICE" ];then
    HELP 3;
fi
Display;
echo "Generate android ext4 image file, please wait for about 2-3 minutes..."
redirect_stdout_stderr;

check_cmd "cd $ATMEL_SDCARD_TOOL"
rm_dir $EXT4_MNT_DIR >&6
rm_img;

check_cmd "dd if=/dev/zero of=./$ROOTFS_IMAGE_NAME bs=1M count=$ROOTFS_IMAGE_SIZE"

recover_stdout_stderr;
check_cmd "mkfs.ext4 -b 4096 $ROOTFS_IMAGE_NAME"
redirect_stdout_stderr;

check_cmd "mkdir $EXT4_MNT_DIR"
check_cmd "mount -t ext4 -o loop $ROOTFS_IMAGE_NAME $EXT4_MNT_DIR"

check_cmd "cp -a $ANDROID_PATH/out/target/product/$PRODUCT_DEVICE/root/* $EXT4_MNT_DIR"
check_cmd "cp -a $ANDROID_PATH/out/target/product/$PRODUCT_DEVICE/system/* $EXT4_MNT_DIR/system/"
check_cmd "cp $EXT4_MNT_DIR/system/initlogo.rle $EXT4_MNT_DIR/"
check_cmd "cp -a $ANDROID_PATH/out/target/product/$PRODUCT_DEVICE/data/* $EXT4_MNT_DIR/data/"
check_cmd "chmod 0777 -R $EXT4_MNT_DIR/data/"
check_cmd "cp boot_$PRODUCT_DEVICE/vold.fstab $EXT4_MNT_DIR/system/etc/vold.fstab"
check_cmd "cp boot_$PRODUCT_DEVICE/init.rc $EXT4_MNT_DIR/init.rc"

check_cmd "umount $EXT4_MNT_DIR"

check_cmd "cp $ROOTFS_IMAGE_NAME $ANDROID_PATH/"

rm_dir $EXT4_MNT_DIR >&6
rm_img;

success_cmd;
