#!/bin/bash
#
# update.sh - Generate the android update package.
#
ANDROID_VERSION=ANDROID-4.2.2_r1.1
ANDROID_PATCH=$PWD
BOARD_ID=SAMA5D3
UPDATE_PACKAGE_NAME=update-$BOARD_ID-$ANDROID_VERSION.zip

ERRLOGFILE=make_update_package.log

Update_system_image="false"

HELP_MESSAGE=("mk_updatepackage [-d dtb_file_dir] [-k kernel_image_dir] [-s]\n
  -d Update the dtb files, you can specify 'dtb_file_dir' directly to the dtb file name or just to the path of the dtb files.
  -k Update the kernel image, you should specify 'kernel_image_dir' directly to uImage.
  -s Update android system image.
  -h Print help message\n"
  "You must specify a correct dtb file path after -d parameter\n"
  "You must specify a correct kernel image file path after -k parameter\n")
	
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
	echo "Success:you can get $UPDATE_PACKAGE_NAME under current directory!"
	exit
}

exit_cmd()
{
	recover_stdout_stderr;
	echo "Failed:please see $ERRLOGFILE for detail message!"
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

rm_update()
{
	if [ -e ./update ];then
	check_cmd "rm -rf ./update"
	fi
}


rm_zip()
{
	if [ -e ./*.zip ];then
	check_cmd "rm -rf ./*.zip"
	fi
}

if [ -z "$1" ];then
	HELP 0;
fi

until [ -z "$1" ]
do
	case "$1" in
		"-d" )
			shift
			dtb_file_dir=$1
			if [ -z $dtb_file_dir ];then
				HELP 1;
			elif [ -f $dtb_file_dir ];then
				echo "We will update dtb file:  ${dtb_file_dir##*/}"
			elif [ -d $dtb_file_dir ];then
				echo "We will update dtb file under: $dtb_file_dir"
			else
				HELP 1;
			fi
		;;
		"-k" )
			shift
			kernel_image_dir=$1
			if [ -z $kernel_image_dir ];then
				HELP 2;
			elif [ -f $kernel_image_dir ];then
				echo "We will update kernel image:  ${kernel_image_dir##*/}"
			else
				HELP 2;
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

echo "Gnerate android update package,Please wait for about 1-2 minute..."
redirect_stdout_stderr;
check_cmd "cd $ANDROID_PATCH/device/atmel/release/Generate_update_package/"
rm_update;
rm_zip;
check_cmd "mkdir update"
check_cmd "mkdir -p ./update/META-INF/com/google/android/"
echo -e "show_progress(0.8, 40);\n" > update/META-INF/com/google/android/updater-script
check_cmd "cp $ANDROID_PATCH/out/target/product/sama5d3/system/bin/updater update/META-INF/com/google/android/update-binary"

if [ ! -z $dtb_file_dir ];then
	if [ -f $dtb_file_dir ];then
		check_cmd "cp $dtb_file_dir update/"
	elif [ -d $dtb_file_dir ];then
		if [ -z ${dtb_file_dir##*/} ];then
			check_cmd "cp "$dtb_file_dir"sama5d3*.dtb update/"
		else
			check_cmd "cp "$dtb_file_dir"/sama5d3*.dtb update/"
		fi
	fi
	echo -e "ui_print(\"Updating dtb...\");" >> update/META-INF/com/google/android/updater-script
	echo -e "package_extract_file(choose_dtb_file_auto(),\"/tmp/sama5d3xek.dtb\");" >> update/META-INF/com/google/android/updater-script
	echo -e "write_raw_image(\"/tmp/sama5d3xek.dtb\", \"dtb\");" >> update/META-INF/com/google/android/updater-script
	echo -e "delete(\"/tmp/sama5d3xek.dtb\");\n" >> update/META-INF/com/google/android/updater-script
fi

if [ ! -z $kernel_image_dir ]; then
	if [ -f $kernel_image_dir ];then
		check_cmd "cp $kernel_image_dir update/"
		echo -e "ui_print(\"Updating boot...\");" >> update/META-INF/com/google/android/updater-script
		echo -e "package_extract_file(\"uImage\",\"/tmp/uImage\");" >> update/META-INF/com/google/android/updater-script
		echo -e "write_raw_image(\"/tmp/uImage\", \"boot\");" >> update/META-INF/com/google/android/updater-script
		echo -e "delete(\"/tmp/uImage\");\n" >> update/META-INF/com/google/android/updater-script
	fi
fi

if [ $Update_system_image = "true" ];then
	check_cmd "cd $ANDROID_PATCH"
	source build/envsetup.sh
	check_cmd "mkubi_image -b sama5d3"
	p=`ls system_ubifs*.img`
	check_cmd "cp $p $ANDROID_PATCH/device/atmel/release/Generate_update_package/update/"
	check_cmd "cd $ANDROID_PATCH/device/atmel/release/Generate_update_package/"
	echo -e "ui_print(\"Updating system...\");" >> update/META-INF/com/google/android/updater-script
	echo -e "package_extract_file(\"$p\",\"/tmp/$p\");" >> update/META-INF/com/google/android/updater-script
	echo -e "write_raw_image(\"/tmp/$p\", \"system\");" >> update/META-INF/com/google/android/updater-script
	echo -e "delete(\"/tmp/$p\");\n" >> update/META-INF/com/google/android/updater-script
fi

echo -e "show_progress(0.1, 0);\n" >> update/META-INF/com/google/android/updater-script
check_cmd "cd ./update"
check_cmd "zip ../$UPDATE_PACKAGE_NAME -r ./"
check_cmd "cd .."
check_cmd "cp $UPDATE_PACKAGE_NAME $ANDROID_PATCH/"
rm_update;
rm_zip;
success_cmd;
