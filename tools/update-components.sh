#/bin/bash

source ./tools/config.sh

CAMERA_REPO_URL="https://github.com/espressif/esp32-camera.git"
DL_REPO_URL="https://github.com/espressif/esp-dl.git"
SR_REPO_URL="https://github.com/espressif/esp-sr.git"
RMAKER_REPO_URL="https://github.com/espressif/esp-rainmaker.git"
DSP_REPO_URL="https://github.com/espressif/esp-dsp.git"
LITTLEFS_REPO_URL="https://github.com/joltwallet/esp_littlefs.git"
TINYUSB_REPO_URL="https://github.com/hathach/tinyusb.git"

#
# CLONE/UPDATE ARDUINO
#

if [ ! -d "$AR_COMPS/arduino" ]; then
	git clone $AR_REPO_URL "$AR_COMPS/arduino"
fi

if [ -z $AR_BRANCH ]; then
	if [ -z $GITHUB_HEAD_REF ]; then
		current_branch=`git branch --show-current`
	else
		current_branch="$GITHUB_HEAD_REF"
	fi
	echo "Current Branch: $current_branch"
	if [[ "$current_branch" != "master" && `git_branch_exists "$AR_COMPS/arduino" "$current_branch"` == "1" ]]; then
		export AR_BRANCH="$current_branch"
	else
		if [ -z "$IDF_COMMIT" ]; then #commit was not specified at build time
			AR_BRANCH_NAME="idf-$IDF_BRANCH"
		else
			AR_BRANCH_NAME="idf-$IDF_COMMIT"
		fi
		has_ar_branch=`git_branch_exists "$AR_COMPS/arduino" "$AR_BRANCH_NAME"`
		if [ "$has_ar_branch" == "1" ]; then
			export AR_BRANCH="$AR_BRANCH_NAME"
		else
			has_ar_branch=`git_branch_exists "$AR_COMPS/arduino" "$AR_PR_TARGET_BRANCH"`
			if [ "$has_ar_branch" == "1" ]; then
				export AR_BRANCH="$AR_PR_TARGET_BRANCH"
			fi
		fi
	fi
fi

if [ "$AR_BRANCH" ]; then
	git -C "$AR_COMPS/arduino" checkout "$AR_BRANCH" && \
	git -C "$AR_COMPS/arduino" fetch && \
	git -C "$AR_COMPS/arduino" pull --ff-only
fi
if [ $? -ne 0 ]; then exit 1; fi

#
# CLONE/UPDATE ESP32-CAMERA
#

if [ ! -d "$AR_COMPS/esp32-camera" ]; then
	git clone $CAMERA_REPO_URL "$AR_COMPS/esp32-camera"
else
	git -C "$AR_COMPS/esp32-camera" fetch
fi
git -C "$AR_COMPS/esp32-camera" checkout 5c8349f4cf169c8a61283e0da9b8cff10994d3f3
#this is a temp measure to fix build issue in recent IDF master
if [ -f "$AR_COMPS/esp32-camera/idf_component.yml" ]; then
	rm -rf "$AR_COMPS/esp32-camera/idf_component.yml"
fi
if [ $? -ne 0 ]; then exit 1; fi

#
# CLONE/UPDATE ESP-DL
#

if [ ! -d "$AR_COMPS/esp-dl" ]; then
	git clone $DL_REPO_URL "$AR_COMPS/esp-dl"
else
	git -C "$AR_COMPS/esp-dl" fetch
fi
git -C "$AR_COMPS/esp-dl" checkout f3006d77ef95ed21cc265493eb71335cd0ba38a8
if [ $? -ne 0 ]; then exit 1; fi

#
# CLONE/UPDATE ESP-SR
#

if [ ! -d "$AR_COMPS/esp-sr" ]; then
	git clone $SR_REPO_URL "$AR_COMPS/esp-sr"
else
	git -C "$AR_COMPS/esp-sr" fetch
fi
git -C "$AR_COMPS/esp-sr" checkout 6b7319071e14355d7df30f769e9859c2824a5162
if [ $? -ne 0 ]; then exit 1; fi

#
# CLONE/UPDATE ESP-LITTLEFS
#

if [ ! -d "$AR_COMPS/esp_littlefs" ]; then
	git clone $LITTLEFS_REPO_URL "$AR_COMPS/esp_littlefs"
else
	git -C "$AR_COMPS/esp_littlefs" fetch
fi
git -C "$AR_COMPS/esp_littlefs" checkout 485a037be66daedabfbb313315e5a7439123d014
git -C "$AR_COMPS/esp_littlefs" submodule update --init --recursive
if [ $? -ne 0 ]; then exit 1; fi

#
# CLONE/UPDATE ESP-RAINMAKER
#

if [ ! -d "$AR_COMPS/esp-rainmaker" ]; then
    git clone $RMAKER_REPO_URL "$AR_COMPS/esp-rainmaker"
    # git -C "$AR_COMPS/esp-rainmaker" checkout f1b82c71c4536ab816d17df016d8afe106bd60e3
else
	git -C "$AR_COMPS/esp-rainmaker" fetch
fi
git -C "$AR_COMPS/esp-rainmaker" checkout 9b33df844b6e4223c69973246264a10641ab95b5
git -C "$AR_COMPS/esp-rainmaker" submodule update --init --recursive
if [ $? -ne 0 ]; then exit 1; fi

#
# CLONE/UPDATE ESP-DSP
#

if [ ! -d "$AR_COMPS/esp-dsp" ]; then
	git clone $DSP_REPO_URL "$AR_COMPS/esp-dsp"
	# cml=`cat "$AR_COMPS/esp-dsp/CMakeLists.txt"`
	# echo "if(IDF_TARGET STREQUAL \"esp32\" OR IDF_TARGET STREQUAL \"esp32s2\" OR IDF_TARGET STREQUAL \"esp32s3\")" > "$AR_COMPS/esp-dsp/CMakeLists.txt"
	# echo "$cml" >> "$AR_COMPS/esp-dsp/CMakeLists.txt"
	# echo "endif()" >> "$AR_COMPS/esp-dsp/CMakeLists.txt"
else
	git -C "$AR_COMPS/esp-dsp" fetch
fi
git -C "$AR_COMPS/esp-dsp" checkout 401faf8bcf76bb5c958c83f39cb85627fdacc156
if [ $? -ne 0 ]; then exit 1; fi

#
# CLONE/UPDATE TINYUSB
#

if [ ! -d "$AR_COMPS/arduino_tinyusb/tinyusb" ]; then
	git clone $TINYUSB_REPO_URL "$AR_COMPS/arduino_tinyusb/tinyusb"
else
	git -C "$AR_COMPS/arduino_tinyusb/tinyusb" fetch
fi
git -C "$AR_COMPS/arduino_tinyusb/tinyusb" checkout 73f22e31c7a31e9b974e27407b906bbc8cb05a7a
if [ $? -ne 0 ]; then exit 1; fi

