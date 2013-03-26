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

HELP_MESSAGE=("mksd_image -b board_chip -s /dev/sdxx [-u uImage_dir] [-d xxxM]\n
	-b Specify the board chip. We now support sam9g45,sam9m10,sam9x5,sama5d3\n
	-s Specify the sdcard node. Like /dev/sdc. You should plugin in the sdcard first\n
	-u Specify the dir of the uImage if you want update kernel image. It is not a must\n
	-d Specify the userspace size on sd card.It is not a must, default is 1000M\n
	-h Print help message\n"
	"We only support the following boards: \nsam9g45 | sam9m10 | sam9x5 | sama5d3\n"
	"You must specify sdcard device node\nExample: -s /dev/sdc\n"
	"You must specify board chip\nExample: -b sam9m10\n"
	"We could not find the sdcard device which you specify\n")
               
WARING_MESSAGE=("We could not find uImage,please check the uImage dir!\nIf continue,we will not update uImage\n
Continue: YES\n
Quit:     Any other key")
 
HARDWARE=("at91sama5d3-ek"
          "at91sama5d3-pda")
DTBFILES=("sama5d31ek.dtb"
          "sama5d33ek.dtb"
          "sama5d34ek.dtb"
          "sama5d35ek.dtb"
          "sama5d31ek_pda.dtb"
          "sama5d33ek_pda.dtb"
          "sama5d34ek_pda.dtb")

SDDtbFile=("d31.dtb"
           "d33.dtb"
           "d34.dtb"
           "d35.dtb"
           "d31_pda.dtb"
           "d33_pda.dtb"
           "d34_pda.dtb") 
             
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

Waring()
{	
	echo
	echo "****************"
	echo "*  WARNING!!!  *"
	echo "****************"
	echo

	until [ -z "$1" ]
	do
		echo -e "${WARING_MESSAGE[$1]} "
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

rm_root()
{
	if [ -e ./root ];then
	check_cmd "rm -rf ./root"
	fi
}

choose_hardware()
{  
        local DEFAULT_NUM DEFAULT_VALUE ANSWER
        DEFAULT_NUM=0
        DEFAULT_VALUE=at91sama5d3-ek

	echo "Supported hardware are:"
	for count in $(seq 0 $((${#HARDWARE[@]} - 1)));do
		echo "      $count. ${HARDWARE[count]}"
	done
         
        echo -n "Which would you like? ["$DEFAULT_NUM"] "	
	read ANSWER
 
	if [  $ANSWER -gt $count  ]; then
		echo "Warning: $ANSWER is not supported! use $DEFAULT_VALUE as default"
		cp at91sama5d3xek-sd-linux-dt-3.5.2.bin boot.bin
        else
		cp at91sama5d3xpda-sd-linux-dt-3.5.2.bin boot.bin
	fi
}

rename_dtbfile()
{
        local DEFAULT_NUM DEFAULT_VALUE ANSWER
        DEFAULT_NUM=0
        DEFAULT_VALUE=sama5d31ek.dtb
        
        for count in $(seq 0 $((${#DTBFILES[@]} - 1)));do
	if [ -e ${DTBFILES[count]} ] ; then
        	mv ${DTBFILES[count]} ${SDDtbFile[count]}
	fi
        done
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
		Waring 0;
	fi
fi

if [ "$var_boardchip" = "sama5d3" ]; then
check_cmd "cd $ANDROID_PATCH/device/atmel/release/Generate_sdcard_image/"
choose_hardware;
rename_dtbfile;
check_cmd "cd $ANDROID_PATCH"
fi

WARING_MESSAGE[1]="The next step will make partitions on the \nSD Card device \"$SDCARD_DEVICE\" as you specified.\n"
WARING_MESSAGE[2]="If you say 'YES' here,\nAll data on device \"$SDCARD_DEVICE\" will * TOTALLY LOST *."
WARING_MESSAGE[3]="You should be aware of what you are doing."
WARING_MESSAGE[4]=""
WARING_MESSAGE[5]="We recommend you make a double check here to \nmake sure \"$SDCARD_DEVICE\" is pointed to your SD card, \nnothing else."
WARING_MESSAGE[6]=""
WARING_MESSAGE[7]="If you are NOT sure, please say 'no' to abort."
WARING_MESSAGE[8]=""
WARING_MESSAGE[9]="What's your choice? (YES / no) "
Waring 1 2 3 4 5 6 7 8 9;

Display;
echo "Gnerate android SD Image file,Please wait for about 2-3 minute..."
redirect_stdout_stderr;

check_cmd "cd $ANDROID_PATCH/device/atmel/release/Generate_sdcard_image/"
rm_root;

for p in `ls $SDCARD_DEVICE*`
do
umount $p
done

fdisk $SDCARD_DEVICE <<end
d
1
d
2
d
3
d
4
w
end

fdisk $SDCARD_DEVICE <<end
o
w
end

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
+500M
n
p
3
+
+$SD_STORAGE
w
end
sleep 5
umount "$SDCARD_DEVICE"1
umount "$SDCARD_DEVICE"2
check_cmd "mkfs.msdos -F 32 "$SDCARD_DEVICE"1"
check_cmd "mkdir boot"
check_cmd "mount "$SDCARD_DEVICE"1 boot"
check_cmd "cp boot_$PRODUCT_DEVICE/* boot/"
check_cmd "cp config.txt boot/"
if [ -e "$UIMAGE_DIR" ];then
	check_cmd "cp $UIMAGE_DIR boot/UIMAGE"
fi
check_cmd "umount boot"
check_cmd "rm -rf boot"

check_cmd "mkfs.ext2 "$SDCARD_DEVICE"2"
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
check_cmd "sudo umount "$SDCARD_DEVICE"2"
check_cmd "rm -rf root"
check_cmd "mkfs.msdos -F 32 "$SDCARD_DEVICE"3"
success_cmd;
