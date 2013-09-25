#!/bin/bash
#
# ubifs.sh - Generate the android RootFS with the type of ubifs.
#
# Copyright (C) 2009-2010 <www.Android4SAM.org>
# Created. liuxin <liuxing@embedinfo.com>
ANDROID_VERSION=ANDROID-4.2.2_r1.1
SYSTEM_IMG=system_ubifs
USERDATA_IMG=userdata_ubifs
ANDROID_PATCH=$PWD
ERRLOGFILE=make_android_ubifs.log

HELP_MESSAGE=("mkubi_image -b board_chip\n
	-b Specify the board chip. We now support sam9x5 | sam9m10 | sam9g45 | sama5d3.
	-h Print help message\n"
	"We only support the following boards\nsam9x5 |sam9m10 | sam9g45 | sama5d3\n"
	"You must specify sdcard device node.\nExample: -s /dev/sdc\n"
	"You must specify board chip.\nExample: -b sama5d3\n")
               
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
	echo "Success:you can get $SYS_NAME and $DATA_NAME under current directory!"
	exit
}

exit_cmd()
{
	recover_stdout_stderr;
	echo "Failed:please see $ERRLOGFILE for detail message!"
	exit -1
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

rm_jffs2()
{
	if [ -e ./$SYS_NAME ];then
	check_cmd "rm -rf ./$SYS_NAME"
	fi
	
	if [ -e ./$DATA_NAME ];then
	check_cmd "rm -rf ./$DATA_NAME"
	fi	
}

rm_img()
{
	if [ -e ./*.img ];then
	check_cmd "rm -rf ./*.img"
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
                    BOARD_ID=SAMA5D3
                    SYS_NAME=$SYSTEM_IMG-$BOARD_ID-$ANDROID_VERSION.img
                    DATA_NAME=$USERDATA_IMG-$BOARD_ID-$ANDROID_VERSION.img
					;;
                "sam9x5" )
                    PRODUCT_DEVICE=$1
                    BOARD_ID=SAM9X5
                    SYS_NAME=$SYSTEM_IMG-$BOARD_ID-$ANDROID_VERSION.img
                    DATA_NAME=$USERDATA_IMG-$BOARD_ID-$ANDROID_VERSION.img
                ;;

                "sam9m10" )
                    PRODUCT_DEVICE=$1
                    BOARD_ID=SAM9M10
                    SYS_NAME=$SYSTEM_IMG-$BOARD_ID-$ANDROID_VERSION.img
                    DATA_NAME=$USERDATA_IMG-$BOARD_ID-$ANDROID_VERSION.img
                ;;

				"sam9g45" )
					PRODUCT_DEVICE=$1
					BOARD_ID=SAM9G45
					SYS_NAME=$SYSTEM_IMG-$BOARD_ID-$ANDROID_VERSION.img
					DATA_NAME=$USERDATA_IMG-$BOARD_ID-$ANDROID_VERSION.img
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
echo "Generate android ubifs file, please wait for about 2-3 minutes ..."
redirect_stdout_stderr;
check_cmd "cd $ANDROID_PATCH/device/atmel/release/Generate_ubifs_image/"
rm_root;
rm_img;
check_cmd "cp -a $ANDROID_PATCH/out/target/product/$PRODUCT_DEVICE/root ./"
check_cmd "cd ./root/system/"
check_cmd "cp -a $ANDROID_PATCH/out/target/product/$PRODUCT_DEVICE/system/* ./"
check_cmd "cd .."
check_cmd "cp -a $ANDROID_PATCH/out/target/product/$PRODUCT_DEVICE/data/* ./data/"
check_cmd "chmod 0777 -R ./data"

if [ $BOARD_ID = "SAM9X5" ] || [ $BOARD_ID = "SAMA5D3" ]; then
	check_cmd "mkfs.ubifs -x lzo -m 2KiB -e 124KiB -c 1000 -o system_ubifs.img -d system/"
	check_cmd "mkfs.ubifs -m 2KiB -e 124KiB -c 984 -o userdata_ubifs.img -d  data/"
	check_cmd "ubinize -o ../$SYS_NAME -m 2KiB -p 128KiB -s 2048 ../system_ubi.cfg"
	check_cmd "ubinize -o  ../$DATA_NAME -m 2KiB -p 128KiB -s 2048 ../userdata_ubi.cfg"

elif [ $BOARD_ID = "SAM9M10" ] || [ $BOARD_ID = "SAM9G45" ] ; then
	check_cmd "mkfs.ubifs -x lzo -m 2KiB -e 129024 -c 720 -o system_ubifs.img -d system/"
	check_cmd "mkfs.ubifs -m 2KiB -e 129024 -c 1230 -o userdata_ubifs.img -d data/"
	check_cmd "ubinize -o ../$SYS_NAME -m 2KiB -p 128KiB -s 512 ../system_ubi.cfg"
	check_cmd "ubinize -o  ../$DATA_NAME -m 2KiB -p 128KiB -s 512 ../userdata_ubi.cfg"
fi
check_cmd "cp ../$SYS_NAME $ANDROID_PATCH/"
check_cmd "cp ../$DATA_NAME $ANDROID_PATCH/"
success_cmd;
