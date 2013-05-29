#!/bin/bash
#
# sdimage.sh - Generate the android RootFS,you can use this shell to let android boot from sdcard..
#
# Copyright (C) 2010-2012 <www.embedinfo.com> <www.atmel.com>
# Created. liuxin <liuxing@embedinfo.com>

RELEASE_VERSION=ver1.1
ANDROID_VERSION=ANDROID-4.0.4_r2.1
ANDROID_PATCH=$PWD
ERRLOGFILE=make_android_sdcard.log
SD_USERSPACE=64M
SD_STORAGE=1000M
FORCE_REMOVE=false
HELP_MESSAGE=("mksd_image -b board_chip -s /dev/sdxx [-u uImage_dir] [-d xxxM] --force\n
	-b Specify the board chip. We now support sam9g45,sam9m10,sam9x5,sama5d3\n
	-s Specify the sdcard node. Like /dev/sdc. You should plugin in the sdcard first\n
	-u Specify the dir of the uImage if you want update kernel image. It is not a must\n
	-d Specify the userspace size on sd card.It is not a must, default is 1000M\n
	-h Print help message\n
	--force Force remove files without warning. This maybe dangerous.\n"
	"We only support the following boards: \nsam9g45 | sam9m10 | sam9x5 | sama5d3\n"
	"You must specify sdcard device node\nExample: -s /dev/sdc\n"
	"You must specify board chip\nExample: -b sam9m10\n"
	"We could not find the sdcard device which you specify\n")
               
WARNING_MESSAGE=("We could not find uImage,please check the uImage dir!\nIf continue,we will not update uImage\n
Continue: YES\n
Quit:     Any other key")
             
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

Warning()
{	
	echo
	echo "****************"
	echo "*  WARNING!!!  *"
	echo "****************"
	echo

	until [ -z "$1" ]
	do
		echo -e "${WARNING_MESSAGE[$1]} "
		shift
	done
	echo "-----------------------------"
	echo "Input you choice:"
	read var
	if [ "$var" = "YES" ];then
		echo
	else
		echo
		echo "Script aborted!"
		echo
		exit
	fi
}

Display()
{
	echo "=============================="
	echo "Sdcard:$SDCARD_DEVICE"
	echo "Board chip:$PRODUCT_DEVICE"
	if [ -e "$UIMAGE_DIR" ];then
		echo "uImage will be updated with $UIMAGE_DIR"
	fi
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
	echo "Success: you can bootup android with this sdcard on $BOARD_ID"
	exit
}

exit_cmd()
{
	recover_stdout_stderr;
	echo "Failed: please see $ERRLOGFILE for detail message!"
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

check_media()
{
	local media=`basename $SDCARD_DEVICE`
	local is_media_removable=`cat /sys/block/$media/removable`
	local is_media_readonly=`cat /sys/block/$media/ro`
	
	local WARNING_MESSAGE[1]="The media $media is not removable. Are you sure that $media is the correct device?$.\n"
	local WARNING_MESSAGE[2]="The media $media is readonly. Please check the media status and try again$.\n"
	local WARNING_MESSAGE[3]="Enter (YES) to go on, (no) to abort"
	local WARNING_MESSAGE[4]="What's your choice? (YES / no) "
	
	if [[ $is_media_removable = 0 ]]; then
	Warning 1 3 4
	fi
	
	if [[ $is_media_readonly = 1 ]]; then
	Warning 2 3 4
	fi
}

if [ -z "$1" ];then
	HELP 0;
fi

until [ -z "$1" ]
do
	case "$1" in
		"-s" )
			shift
			SDCARD_DEVICE=$1
			if [ ! -e $SDCARD_DEVICE ];then
				HELP 4;
			fi
		;;
		"-u" )
			shift
			UIMAGE=$1
			if [ -d $UIMAGE ];then
				file=$UIMAGE
				UIMAGE_DIR=${file%/*}/uImage
			else
				UIMAGE_DIR=$UIMAGE
			fi
		;;
		"-b" )
			shift
			var_boardchip=$1
			case "$var_boardchip" in
				"sam9g45" )
					PRODUCT_DEVICE=$1
					BOARD_ID=SAM9G45
					SD_IMAGE_NAME=$BOARD_ID-$ANDROID_VERSION-$RELEASE_VERSION.img
				;;
				"sam9m10" )
					PRODUCT_DEVICE=$1
					BOARD_ID=SAM9M10
					SD_IMAGE_NAME=$BOARD_ID-$ANDROID_VERSION-$RELEASE_VERSION.img
				;;
				"sam9x5" )
					PRODUCT_DEVICE=$1
					BOARD_ID=SAM9X5
					SD_IMAGE_NAME=$BOARD_ID-$ANDROID_VERSION-$RELEASE_VERSION.img
				;;
				"sama5d3" )
					PRODUCT_DEVICE=$1
					BOARD_ID=SAMA5D3
					SD_IMAGE_NAME=$BOARD_ID-$ANDROID_VERSION-$RELEASE_VERSION.img
				;;
				* )
					HELP 1;
				;;
			esac
		;;
		"-d" )
			shift
			SD_STORAGE=$1
		;;
                "--force" )
                        FORCE_REMOVE=true;
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

if [ -z "$SDCARD_DEVICE" ];then
	HELP 2;
fi

if [ -z "$PRODUCT_DEVICE" ];then
	HELP 3;
fi

if [ -n "$UIMAGE_DIR" ];then
	if [ ! -e "$UIMAGE_DIR" ];then
		Warning 0;
	fi
fi
check_media;

WARNING_MESSAGE[1]="The next step will make partitions on the \nSD Card device \"$SDCARD_DEVICE\" as you specified.\n"
WARNING_MESSAGE[2]="If you say 'YES' here,\nAll data on device \"$SDCARD_DEVICE\" will * TOTALLY LOST *."
WARNING_MESSAGE[3]="You should be aware of what you are doing."
WARNING_MESSAGE[4]=""
WARNING_MESSAGE[5]="We recommend you make a double check here to \nmake sure \"$SDCARD_DEVICE\" is pointed to your SD card, \nnothing else."
WARNING_MESSAGE[6]=""
WARNING_MESSAGE[7]="If you are NOT sure, please say 'no' to abort."
WARNING_MESSAGE[8]=""
WARNING_MESSAGE[9]="What's your choice? (YES / no) "
Warning 1 2 3 4 5 6 7 8 9;

Display;
echo "Gnerate android SD Image file,Please wait for about 2-3 minute..."
redirect_stdout_stderr;

check_cmd "cd $ANDROID_PATCH/device/atmel/release/Generate_sdcard_image/"
rm_dir ./root >&6 

check_cmd "dd if=/dev/zero of="$SDCARD_DEVICE" bs=512 count=1";

fdisk $SDCARD_DEVICE <<end
n
p
1
+
+$SD_USERSPACE
n
p
2
+
+700M
n
p
3
+
+
w
end
sleep 5
umount "$SDCARD_DEVICE"1
umount "$SDCARD_DEVICE"2
umount "$SDCARD_DEVICE"3
check_cmd "mkfs.msdos -F 32 "$SDCARD_DEVICE"1"
check_cmd "mkdir boot -p"
check_cmd "mount -t vfat "$SDCARD_DEVICE"1 boot"
if [ -e "$UIMAGE_DIR" ];then
	check_cmd "cp $UIMAGE_DIR boot/UIMAGE"
fi
check_cmd "sync"
check_cmd "umount boot"
rm_dir boot >&6
check_cmd "mkfs.ext4 "$SDCARD_DEVICE"2"
check_cmd "mkdir root"
check_cmd "mount "$SDCARD_DEVICE"2 root"
check_cmd "cp -a $ANDROID_PATCH/out/target/product/$PRODUCT_DEVICE/root/* ./root"
check_cmd "cd ./root/system/"
check_cmd "cp -a $ANDROID_PATCH/out/target/product/$PRODUCT_DEVICE/system/* ./"
check_cmd "cp ./initlogo.rle ../"
check_cmd "cd .."
check_cmd "cp -a $ANDROID_PATCH/out/target/product/$PRODUCT_DEVICE/data/* ./data/"
check_cmd "chmod 777 ../root/ -R"
check_cmd "cd .."
check_cmd "cp boot_$PRODUCT_DEVICE/vold.fstab ./root/system/etc/vold.fstab"
check_cmd "cp boot_$PRODUCT_DEVICE/init.rc ./root/init.rc"
check_cmd "sync"
check_cmd "sudo umount "$SDCARD_DEVICE"2"
check_cmd "mkfs.msdos -F 32 "$SDCARD_DEVICE"3"
success_cmd;
