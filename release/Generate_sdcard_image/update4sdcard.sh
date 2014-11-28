#!/bin/bash
#
# update4sdcard.sh - Generate the android update package.
#
ANDROID_VERSION=ANDROID-4.4.2_r2
ANDROID_PATH=$PWD
ATMEL_RELEASE=$ANDROID_PATH/device/atmel/release
TMP_UPDATE_DIR=/tmp/update
META_INF=$TMP_UPDATE_DIR/META-INF/com/google/android
DTBS_DIR=$TMP_UPDATE_DIR/dtbs
UPDATE_BINARY=$TMP_UPDATE_DIR/META-INF/com/google/android/update-binary
UPDATER_SCRIPT=$TMP_UPDATE_DIR/META-INF/com/google/android/updater-script
SYSTEM_IMAGE_PATH=$ANDROID_PATH/system.img
ERRLOGFILE=$ANDROID_PATH/make_update_package.log

Update_system_image="false"

HELP_MESSAGE=("mk_updatepackage4sdcard -b build_target [-d dtb_file_dir] [-k kernel_image_dir] [-s]\n
  -b Specify the build target. We now support sama5d3 | sama5d4.
  -d Update the dtb files, you can specify 'dtb_file_dir' directly to the dtb file name or just to the path of the dtb files.
  -k Update the kernel image, you should specify 'kernel_image_dir' directly to uImage.
  -s Update android system image.
  -h Print help message\n"
  "We only support the following build targets: \nsama5d3 | sama5d4\n"
  "You must specify build target.\nExample: -b sama5d3\n"
  "You must specify a correct dtb file path after -d parameter\n"
  "You must specify a correct kernel image file path after -k parameter\n")

HELP()
{
	echo
	if [ "$1" != "0" ]
	then
		echo Error:
	else
		echo Usage:
	fi
	echo "-----------------------------"
	echo -e "${HELP_MESSAGE[$1]}"
	exit
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
	echo "Success: you can get $UPDATE_PACKAGE_NAME under current directory!"
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
	if [ 0 = $? ]
	then
		echo Successful
		echo
	else
		exit_cmd;
	fi
}

rm_update()
{
	if [ -e $TMP_UPDATE_DIR ]
	then
		check_cmd "rm -rf $TMP_UPDATE_DIR"
	fi
}

rm_zip()
{
	recover_stdout_stderr;
	if [ -e $1 ]
	then
		echo "Sure to remove $1? If sure input Y|y to remove."
		echo "What's your choice? (Y/N) "
		read var
		if [ "$var" = "Y" -o "$var" = "y" ]
		then
			check_cmd "rm -rf $1"
		fi
	fi
	redirect_stdout_stderr;
}

if [ -z "$1" ]
then
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
					ANDROID_PRODUCT_OUT=$ANDROID_PATH/out/target/product/$PRODUCT_DEVICE
					UPDATE_PACKAGE_NAME=update-$BOARD_ID-$ANDROID_VERSION-sdcard.zip
					UPDATE_PACKAGE_FILE=$ANDROID_PATH/$UPDATE_PACKAGE_NAME
				;;
				"sama5d4" )
					PRODUCT_DEVICE=$1
					BOARD_ID=SAMA5D4
					ANDROID_PRODUCT_OUT=$ANDROID_PATH/out/target/product/$PRODUCT_DEVICE
					UPDATE_PACKAGE_NAME=update-$BOARD_ID-$ANDROID_VERSION-sdcard.zip
					UPDATE_PACKAGE_FILE=$ANDROID_PATH/$UPDATE_PACKAGE_NAME
				;;
				* )
					HELP 1;
				;;
			esac
		;;
		"-d" )
			shift
			dtb_file_dir=$1
			if [ -z $dtb_file_dir ]
			then
				HELP 1;
			elif [ -f $dtb_file_dir ]
			then
				echo "We will update dtb file:  ${dtb_file_dir##*/}"
			elif [ -d $dtb_file_dir ]
			then
				echo "We will update dtb file under: $dtb_file_dir"
			else
				HELP 3;
			fi
		;;
		"-k" )
			shift
			kernel_image_dir=$1
			if [ -z $kernel_image_dir ]
			then
				HELP 2;
			elif [ -f $kernel_image_dir ]
			then
				echo "We will update kernel image:  ${kernel_image_dir##*/}"
			else
				HELP 4;
			fi
		;;
		"-s" )
			echo "We will update android system image"
			Update_system_image="true"
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

if [ -z "$PRODUCT_DEVICE" ]
then
	HELP 2;
fi

echo "Generate android update package, please wait for about 2-3 minutes ..."
redirect_stdout_stderr;
check_cmd "cd $ATMEL_RELEASE/Generate_sdcard_image/"
rm_update;
rm_zip "$UPDATE_PACKAGE_FILE";
check_cmd "mkdir $TMP_UPDATE_DIR"
check_cmd "mkdir -p $META_INF/"
check_cmd "mkdir -p $DTBS_DIR/"
echo -e "show_progress(0.8, 40);\n" > $UPDATER_SCRIPT
check_cmd "cp $ANDROID_PRODUCT_OUT/system/bin/updater $UPDATE_BINARY"

if [ ! -z $dtb_file_dir ]
then
	if [ -f $dtb_file_dir ]
	then
		check_cmd "cp $dtb_file_dir $DTBS_DIR"
	elif [ -d $dtb_file_dir ]
	then
		if [ -z ${dtb_file_dir##*/} ]
		then
			check_cmd "cp "$dtb_file_dir"sama5d3*.dtb $DTBS_DIR"
		else
			check_cmd "cp "$dtb_file_dir"/sama5d3*.dtb $DTBS_DIR"
		fi
	fi
	echo -e "ui_print(\"Updating dtb...\");" >> $UPDATER_SCRIPT
	echo -e "mount(\"vfat\", \"EMMC\", \"/dev/block/mmcblk0p1\", \"/boot\");" >> $UPDATER_SCRIPT
	echo -e "package_extract_dir(dtbs, \"/boot\");" >> $UPDATER_SCRIPT
	echo -e "unmount(\"/boot\");\n" >> $UPDATER_SCRIPT
fi

if [ ! -z $kernel_image_dir ]
then
	if [ -f $kernel_image_dir ]
	then
		check_cmd "cp $kernel_image_dir $TMP_UPDATE_DIR"
		echo -e "ui_print(\"Updating kernel...\");" >> $UPDATER_SCRIPT
		echo -e "mount(\"vfat\", \"EMMC\", \"/dev/block/mmcblk0p1\", \"/boot\");" >> $UPDATER_SCRIPT
		echo -e "package_extract_file(\"zImage\", \"/boot/zImage\");" >> $UPDATER_SCRIPT
		echo -e "unmount(\"/boot\");\n" >> $UPDATER_SCRIPT
	fi
fi

if [ $Update_system_image = "true" ]
then
	check_cmd "cp $SYSTEM_IMAGE_PATH $TMP_UPDATE_DIR"
	echo -e "ui_print(\"Updating Android System image...\");" >> $UPDATER_SCRIPT
	echo -e "package_extract_file(\"system.img\",\"/tmp/system.img\");" >> $UPDATER_SCRIPT
	echo -e "write_ext4_image(\"/tmp/system.img\", \"/dev/block/mmcblk0p2\");" >> $UPDATER_SCRIPT
	echo -e "delete(\"/tmp/system.img\");\n" >> $UPDATER_SCRIPT
fi

echo -e "show_progress(0.1, 0);\n" >> $UPDATER_SCRIPT
check_cmd "cd $TMP_UPDATE_DIR"
check_cmd "zip $UPDATE_PACKAGE_FILE -r ./"
rm_update;
success_cmd;
