#!/system/bin/sh
# Thanks @raidenkk on Telegram and Rem01Gaming on Github for your contributions.
# This file is part of GriffithTweaks.
#
# GriffithTweaks is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GriffithTweaks is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GriffithTweaks.  If not, see <https://www.gnu.org/licenses/>.
#
# Copyright (C) 2024 haxislancelot

# Variables for 'nightshade.conf'
config_file="/sdcard/.NTSH/nightshade.conf"
github_url="https://raw.githubusercontent.com/haxislancelot/Nightshade/main/nightshade.conf"
cli="https://raw.githubusercontent.com/haxislancelot/Nightshade/main/plugins/start.sh"

# Logs
GFLOG=/sdcard/.NTSH/nightshade.log

if [[ -e $GFLOG ]]; then
	rm $GFLOG
fi

if [[ -d "/sdcard/.NTSH" ]]; then
	touch nightshade.log
else
	mkdir /sdcard/.NTSH
	touch nightshade.log
fi

# Verify if the plugins exist
if [ ! -d "/sdcard/.NTSH/plugins" ]; then
    mkdir -p "/sdcard/.NTSH/plugins"
fi


# Log in white and continue (unnecessary)
kmsg() {
	echo -e "[*] $@" >> $GFLOG
	echo -e "[*] $@"
}

kmsg1() {
	echo -e "$@" >> $GFLOG
	echo -e "$@"
}

# Bars
simple_bar() {
    kmsg1 "------------------------------------------------------"
}

# Toast
if ! pm list packages | grep -q 'bellavita.toast'; then
    curl -o /sdcard/toast.apk -L https://github.com/haxislancelot/Nightshade/raw/main/build/outputs/apk/debug/toast.apk \
    && mv /sdcard/toast.apk /data/local/tmp/ \
    && pm install /data/local/tmp/toast.apk \
    && rm -rf /data/local/tmp/toast.apk \
    && am start -a android.intent.action.MAIN -e toasttext "Toast downloaded successfully!" -n bellavita.toast/.MainActivity
else
    simple_bar
    kmsg1 "[ ! ] The 'bellavita.toast' package is already installed." 
fi

# Check if the configuration file exists
if [ ! -f "$config_file" ]; then
    kmsg1 "[ * ] 'nightshade.conf' not found. Downloading..."
    curl -o "$config_file" "$github_url"
    
    if [ $? -eq 0 ]; then
        kmsg1 "[ * ] 'nightshade.conf' file downloaded successfully."
    else
        kmsg1 "[ ! ] Error downloading the configuration file."
    fi
else
    echo "[ * ] 'nightshade.conf' file found."
fi

# Check if the configuration file exists
if [ -f "$config_file" ]; then
    # Read variables from the configuration file
    cli_support=$(grep -i 'cli_support' "$config_file" | awk -F= '{print $2}' | tr -d '[:space:]')
    plugins_enabled=$(grep -i 'plugins_enabled' "$config_file" | awk -F= '{print $2}' | tr -d '[:space:]')
    
    # Verify that CLI support is enabled
    if [ "$cli_support" = "True" ]; then
        # Download and place the start.sh file in the /sdcard/.NTSH directory
        kmsg1 "[ * ] Downloading start.sh file for CLI support..." > /dev/null
        curl -o "/sdcard/.NTSH/start.sh" "$cli"
        
        if [ $? -eq 0 ]; then
            kmsg1 "[ * ] File 'start.sh' downloaded successfully." > /dev/null
        else
            kmsg1 "[ ! ] Error downloading 'start.sh' file." > /dev/null
        fi
    fi
    
    # Check if plugins are enabled
    if [ "$plugins_enabled" = "True" ]; then
        # Download and place the plugins in /sdcard/.NTSH/plugins
        kmsg1 "[ * ] Downloading plugins..." > /dev/null
        curl -o "/sdcard/.NTSH/plugins/battery.sh" "https://raw.githubusercontent.com/haxislancelot/Nightshade/main/plugins/battery.sh"
        
        if [ $? -eq 0 ]; then
            kmsg1 "[ * ] Plugins downloaded successfully." > /dev/null
        else
            kmsg1 "[ ! ] Error downloading plugins." > /dev/null
        fi
    fi
else
    kmsg1 "[ ! ] Configuration file not found. Cannot continue."
fi

# Write
write() {
	# Bail out if file does not exist
	if [[ ! -f "$1" ]]; then
		kmsg "$1 doesn't exist, skipping..."
    return 1
	fi

	# Fetch the current key value
	local curval=$(cat "$1" 2> /dev/null)
	
	# Bail out if value is already set
	if [[ "$curval" == "$2" ]]; then
		kmsg "$1 is already set to $2, skipping..."
		return 1
	fi

	# Make file writable in case it is not already
	chmod +w "$1" 2> /dev/null

	# Write the new value and bail if there's an error
	if ! echo "$2" > "$1" 2> /dev/null
	then
		kmsg1 "[!] Failed: $1 -> $2"
		return 0
	fi

	# Log the success
	kmsg "$1 $curval -> $2"
}

# Grep prop
grep_prop() {
  local REGEX="s/^$1=//p"
  shift
  local FILES="$@"
  [[ -z "$FILES" ]] && FILES='/system/build.prop'
  sed -n "$REGEX" "$FILES" 2>/dev/null | head -n 1
}

# Check for root permissions and bail if not granted
if [[ "$(id -u)" -ne 0 ]]; then
	kmsg1 "[!] No root permissions. Exiting."
	exit 1
fi

# Duration in nanoseconds of one scheduling period
SCHED_PERIOD_LATENCY="$((1 * 1000 * 1000))"

SCHED_PERIOD_BALANCE="$((4 * 1000 * 1000))"

SCHED_PERIOD_BATTERY="$((8 * 1000 * 1000))"

SCHED_PERIOD_THROUGHPUT="$((10 * 1000 * 1000))"

# How many tasks should we have at a maximum in one scheduling period
SCHED_TASKS_LATENCY="10"

SCHED_TASKS_BATTERY="4"

SCHED_TASKS_BALANCE="8"

SCHED_TASKS_THROUGHPUT="6"

# Maximum unsigned integer size in C
UINT_MAX="4294967295"

    # Variable to GPU directories
    for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
		do
			if [ -d "$gpul" ]; then
				gpu=$gpul
			fi
		done
        
    for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
    do
			if [ -d "$gpul1" ]; then
				gpu=$gpul1
			fi
		done
        
    for gpul2 in /sys/devices/*.mali
    do
			if [ -d "$gpul2" ]; then
        gpu=$gpul2
      fi
		done
        
    for gpul3 in /sys/devices/platform/*.gpu
    do
			if [ -d "$gpul3" ]; then
        gpu=$gpul3
      fi
    done
        
    for gpul4 in /sys/devices/platform/mali-*.0
    do
			if [ -d "$gpul4" ]; then
				gpu=$gpul4
      fi
		done

		if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
			gpu="/sys/class/kgsl/kgsl-3d0"
		elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
			gpu="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
		elif [ -d "/sys/devices/platform/gpusysfs" ]; then
			gpu="/sys/devices/platform/gpusysfs"
		elif [ -d "/sys/devices/platform/mali.0" ]; then
			gpu="/sys/devices/platform/mali.0"
		fi
		
		for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq
		do
			if [ -d "$gpul" ]; then
				gpug=$gpul
			fi
		done

		for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq
		do
			if [ -d "$gpul1" ]; then
        gpug=$gpul1
      fi
		done

		for gpul2 in /sys/devices/platform/*.gpu
		do
			if [ -d "$gpul2" ]; then
        gpug=$gpul2
      fi
    done

		if [ -d "/sys/class/kgsl/kgsl-3d0/devfreq" ]; then
			gpug="/sys/class/kgsl/kgsl-3d0/devfreq"
		elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/devfreq" ]; then
			gpug="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/devfreq"
		elif [ -d "/sys/devices/platform/gpusysfs" ]; then
			gpug="/sys/devices/platform/gpusysfs"
		elif [ -d "/sys/module/mali/parameters" ]; then
			gpug="/sys/module/mali/parameters"		
		elif [ -d "/sys/kernel/gpu" ]; then
			gpug="/sys/kernel/gpu"
		fi
	
		for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
		do
			if [ -d "$gpul" ]; then
				gpum=$gpul
			fi
		done

		for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
    do
			if [ -d "$gpul1" ]; then
        gpum=$gpul1
      fi
    done

		if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
			gpum="/sys/class/kgsl/kgsl-3d0"
		elif [ -d "/sys/kernel/gpu" ]; then
			gpum="/sys/kernel/gpu"
		fi

	# Variable to GPU model
	if [[ -e $gpum/gpu_model ]]; then
		GPU_MODEL=$(cat "$gpum"/gpu_model | awk '{print $1}')
    fi
	if [[ -e $gpug/gpu_governor ]]; then
		GPU_GOVERNOR=$(cat "$gpug"/gpu_governor)
	elif [[ -e $gpug/governor ]]; then
        GPU_GOVERNOR=$(cat "$gpug"/governor)
    fi

    if [[ -e $gpu/min_pwrlevel ]]; then
		gpuminpl=$(cat "$gpu"/min_pwrlevel)
		gpupl=$((gpuminpl + 1))
    fi

	gpumx=$(cat "$gpu"/devfreq/available_frequencies | awk -v var="$gpupl" '{print $var}')

	if [[ $gpumx != $(cat "$gpu"/max_gpuclk) ]]; then
		gpumx=$(cat "$gpu"/devfreq/available_frequencies | awk '{print $1}')
    fi

	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
	do
		CPU_GOVERNOR=$(cat "$cpu"/scaling_governor)
	done
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq
	do
		cpumxfreq=$(cat "$cpu"/scaling_max_freq)
		cpumxfreq2=$(cat "$cpu"/cpuinfo_max_freq)

		if [[ $cpumxfreq2 > $cpumxfreq ]]; then
			cpumxfreq=$cpumxfreq2
		fi
	done

	cpumfreq=$((cpumxfreq / 2))

	gpufreq=$(cat "$gpu"/max_gpuclk)

	gpumfreq=$((gpufreq / 2))

# Variable to SOC manufacturer
mf=$(getprop ro.boot.hardware)

# Variable to device SOC
soc=$(getprop ro.board.platform)

if [[ $soc == " " ]]; then
	soc=$(getprop ro.product.board)
fi

# Variable to device SDK
sdk=$(getprop ro.build.version.sdk)

# Variable to device architeture
aarch=$(getprop ro.product.cpu.abi | awk -F- '{print $1}')

# Variable to device android release version
arv=$(getprop ro.build.version.release)

# Variable to device model
dm=$(getprop ro.product.model)

# Variable to total device ram
totalram=$(free -m | awk '/Mem:/{print $2}')

# Variable to battery actual capacity
percentage=$(cat /sys/class/power_supply/battery/capacity)

# Variable to Nightshade version
nightshade=$(echo "v2.0.1-Beta")

# Variable to ram usage
total_mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
free_mem=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')
buffers=$(cat /proc/meminfo | grep Buffers | awk '{print $2}')
cached=$(cat /proc/meminfo | grep "^Cached" | awk '{print $2}')
used_mem=$((total_mem - free_mem - buffers - cached))
used_percentage=$((used_mem * 100 / total_mem))

# Variable to battery temperature
temperature=$(($(cat /sys/class/power_supply/battery/temp) / 10)) 

# Lock_val
lock_val() {
	[ ! -f "$2" ] && return
	umount "$2"

	chown root:root "$2"
	chmod 0666 "$2"
	echo "$1" >"$2"
	chmod 0444 "$2"

	local TIME=$(date +"%s%N")
	echo "$1" >/dev/mount_mask_$TIME
	mount --bind /dev/mount_mask_$TIME "$2"
	rm /dev/mount_mask_$TIME
}

# Variable for default cpu 
cpu_cores="$(($(nproc --all) - 1))"
case $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors) in
*"schedplus"*) export default_cpu_gov="schedplus" ;;
*"sugov_ext"*) export default_cpu_gov="sugov_ext" ;;
*"walt"*) export default_cpu_gov="walt" ;;
*) export default_cpu_gov="schedutil" ;;
esac

am start -a android.intent.action.MAIN -e toasttext "Applying profile..." -n bellavita.toast/.MainActivity
# Mediatek Battery Profile
mtk_battery() {
	kmsg1 "----------------------- Info -----------------------"
    kmsg1 "[ * ] Date of execution: $(date) "
    kmsg1 "[ * ] Nightshade's version: $nightshade "
    kmsg1 "[ * ] Kernel: $(uname -a) "
    kmsg1 "[ * ] SOC: $mf, $soc "
    kmsg1 "[ * ] SDK: $sdk "
    kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
    kmsg1 "[ * ] CPU aarch: $aarch "
    kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
    kmsg1 "[ * ] GPU model: $GPU_MODEL "
    kmsg1 "[ * ] Android version: $arv "
    kmsg1 "[ * ] Device: $dm  "
    kmsg1 "[ * ] Battery charge level: $percentage% "
    kmsg1 "[ * ] Battery temperature: $temperature°C "
    kmsg1 "[ * ] Device total RAM: $totalram MB "
    kmsg1 "[ * ] RAM usage: $used_percentage% "
    kmsg1 "-------------------------------------------------------"
    simple_bar
    kmsg1 "[*] ENABLING $ntsh_profile PROFILE... "
    simple_bar
    
    renice -n -5 $(pgrep system_server)
    renice -n -5 $(pgrep com.miui.home)
    renice -n -5 $(pgrep launcher)
    renice -n -5 $(pgrep lawnchair)
    renice -n -5 $(pgrep home)
    renice -n -5 $(pgrep watchapp)
    renice -n -5 $(pgrep trebuchet)
    renice -n -1 $(pgrep dialer)
    renice -n -1 $(pgrep keyboard)
    renice -n -1 $(pgrep inputmethod)
    renice -n -9 $(pgrep fluid)
    renice -n -10 $(pgrep composer)
    renice -n -1 $(pgrep com.android.phone)
    renice -n -10 $(pgrep surfaceflinger)
    renice -n 1 $(pgrep kswapd0)
    renice -n 1 $(pgrep ksmd)
    renice -n -6 $(pgrep msm_irqbalance)
    renice -n -9 $(pgrep kgsl_worker)
    renice -n 6 $(pgrep android.gms)
    
    simple_bar
    kmsg1 "[*] RENICED PROCESSES. "
    simple_bar
    
    # Enable perfd and mpdecision
    start perfd > /dev/null
    start mpdecision > /dev/null

    simple_bar
    kmsg1 "[*] ENABLED MPDECISION AND PERFD. "
    simple_bar
    
    # Disable logd and statsd to reduce overhead.
    stop logd
    stop statsd

    simple_bar
    kmsg1 "[*] DISABLED STATSD AND LOGD. "
    simple_bar
    
	# CPU tweaks
	cpu="0"
	while [ $cpu -lt $cpu_cores ]; do
		cpu_dir="/sys/devices/system/cpu/cpu${cpu}"
		if [ -d "$cpu_dir" ]; then
			write "${cpu_dir}/cpufreq/scaling_governor" "$default_cpu_gov"
		fi
		cpu="$((cpu + 1))"
	done
	
	simple_bar
    kmsg1 "[*] CPU TWEAKED. "
    simple_bar

	# Idle charging
	write "/proc/mtk_battery_cmd/current_cmd" "0 0"
	
	simple_bar
    kmsg1 "[*] IDLE CHARGING DISABLED. "
    simple_bar
	
	# Enable back PPM
	write "/proc/ppm/enabled" "0"

	simple_bar
    kmsg1 "[*] PPM DISABLED. "
    simple_bar
	
	# MTK Power and CCI mode
	write "/proc/cpufreq/cpufreq_cci_mode" "0"
	write "/proc/cpufreq/cpufreq_power_mode" "1"
	
	simple_bar
    kmsg1 "[*] CPU POWER AND CCI MODE TWEAKED. "
    simple_bar
	
	# EAS/HMP Switch
	lock_val "1" /sys/devices/system/cpu/eas/enable

	simple_bar
    kmsg1 "[*] EAS/HMP TWEAKED. "
    simple_bar
	
	# GPU Frequency
	if [ ! $(uname -r | cut -d'.' -f1,2 | sed 's/\.//') -gt 500 ]; then
		echo "0" >/proc/gpufreq/gpufreq_opp_freq 2>/dev/null
	else
		write "/proc/gpufreqv2/fix_custom_freq_volt" "0 0"
	fi

	# Disable GPU Power limiter
	if [ -f "/proc/gpufreq/gpufreq_power_limited" ]; then
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_batt_oc 0"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_batt_percent 0"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_low_batt 0"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_thermal_protect 0"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_pbm_limited 0"
	fi
	
	simple_bar
    kmsg1 "[*] GPU TWEAKED. "
    simple_bar

	# Disable Power Budget management for new 5.x kernels
	write "/proc/pbm/pbm_stop" "stop 0"

	simple_bar
    kmsg1 "[*] POWER BUDGET MANAGEMENT TWEAKED. "
    simple_bar
	
	# Disable battery current limiter
	write "/proc/mtk_batoc_throttling/battery_oc_protect_stop" "stop 0"

	simple_bar
    kmsg1 "[*] BATTERY CURRENT LIMITER DISABLED. "
    simple_bar
	
	# DRAM Frequency
	if [ ! $(uname -r | cut -d'.' -f1,2 | sed 's/\.//') -gt 500 ]; then
		write "/sys/devices/platform/10012000.dvfsrc/helio-dvfsrc/dvfsrc_req_ddr_opp" "-1"
	else
		write "/sys/kernel/helio-dvfsrc/dvfsrc_force_vcore_dvfs_opp" "-1"
	fi

	simple_bar
    kmsg1 "[*] DRAM FREQUENCY TWEAKED. "
    simple_bar
	
	# Drop mem cache
	write "/proc/sys/vm/drop_caches" "3"

	simple_bar
    kmsg1 "[*] DROPPED MEM CACHE. "
    simple_bar
	
	# Mediatek's APU freq
	write "/sys/module/mmdvfs_pmqos/parameters/force_step" "-1"

	simple_bar
    kmsg1 "[*] MEDIATEK's APU FREQ TWEAKED. "
    simple_bar
    
	# Touchpanel
	tp_path="/proc/touchpanel"
	write "$tp_path/game_switch_enable" "0"
	write "$tp_path/oplus_tp_limit_enable" "1"
	write "$tp_path/oppo_tp_limit_enable" "1"
	write "$tp_path/oplus_tp_direction" "0"
	write "$tp_path/oppo_tp_direction" "0"
	
	simple_bar
    kmsg1 "[*] TOUCHPANEL TWEAKED. "
    simple_bar
	
	simple_bar
    kmsg1 "[*] $ntsh_profile PROFILE APPLIED WITH SUCCESS. "
    simple_bar

    simple_bar
    kmsg1 "[*] END OF EXECUTION: $(date)"
    simple_bar
    exit=$(date +%s)

    exectime=$((exit - init))
    simple_bar
    kmsg1 "[*] EXECUTION DONE IN $exectime SECONDS. "
    simple_bar

    init=$(date +%s)
	
    am start -a android.intent.action.MAIN -e toasttext "Battery profile was successfully applied!" -n bellavita.toast/.MainActivity
}

# Battery Profile
battery() {
init=$(date +%s)

# Checking mtk device
simple_bar
kmsg1 "[ * ] Checking device compatibility..."
chipset=$(grep "Hardware" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')
if [ -z "$chipset" ]; then
    chipset=$(getprop "ro.hardware")
fi

if [[ $chipset == *MT* ]] || [[ $chipset == *mt* ]]; then
    kmsg1 "[ ! ] Device is Mediatek, executing mtk_battery..."
    settings put global device_idle_constants inactive_to=60000,sensing_to=0,locating_to=0,location_accuracy=2000,motion_inactive_to=0,idle_after_inactive_to=0,idle_pending_to=60000,max_idle_pending_to=120000,idle_pending_factor=2.0,idle_to=900000,max_idle_to=21600000,idle_factor=2.0,max_temp_app_whitelist_duration=60000,mms_temp_app_whitelist_duration=30000,sms_temp_app_whitelist_duration=20000,light_after_inactive_to=10000,light_pre_idle_to=60000,light_idle_to=180000,light_idle_factor=2.0,light_max_idle_to=900000,light_idle_maintenance_min_budget=30000,light_idle_maintenance_max_budget=60000
    mtk_battery
    exit
else
    kmsg1 "[ * ] Device is not Mediatek, continuing script..."
fi

kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Nightshade's version: $nightshade "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Battery temperature: $temperature°C "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "-------------------------------------------------------"
simple_bar
kmsg1 "[*] ENABLING $ntsh_profile PROFILE... "
simple_bar

renice -n -5 $(pgrep system_server)
renice -n -5 $(pgrep com.miui.home)
renice -n -5 $(pgrep launcher)
renice -n -5 $(pgrep lawnchair)
renice -n -5 $(pgrep home)
renice -n -5 $(pgrep watchapp)
renice -n -5 $(pgrep trebuchet)
renice -n -1 $(pgrep dialer)
renice -n -1 $(pgrep keyboard)
renice -n -1 $(pgrep inputmethod)
renice -n -9 $(pgrep fluid)
renice -n -10 $(pgrep composer)
renice -n -1 $(pgrep com.android.phone)
renice -n -10 $(pgrep surfaceflinger)
renice -n 1 $(pgrep kswapd0)
renice -n 1 $(pgrep ksmd)
renice -n -6 $(pgrep msm_irqbalance)
renice -n -9 $(pgrep kgsl_worker)
renice -n 6 $(pgrep android.gms)

simple_bar
kmsg1 "[*] RENICED PROCESSES. "
simple_bar

# Enable perfd and mpdecision
start perfd > /dev/null
start mpdecision > /dev/null

simple_bar
kmsg1 "[*] ENABLED MPDECISION AND PERFD. "
simple_bar

# Disable logd and statsd to reduce overhead.
stop logd
stop statsd

simple_bar
kmsg1 "[*] DISABLED STATSD AND LOGD. "
simple_bar

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
	write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "5"
	simple_bar
	kmsg1 "[*] TWEAKED STUNE BOOST. "
	simple_bar
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
	if [[ -e "${corectl}/enable" ]]; then
		write "${corectl}/enable" "1"
	elif [[ -e "${corectl}/disable" ]]; then
		write "${corectl}/disable" "0"
	fi
done

simple_bar
kmsg1 "[*] ENABLED CORE CONTROL. "
simple_bar

# Caf CPU Boost
if [[ -e "/sys/module/cpu_boost/parameters/input_boost_ms" ]]; then
	write "/sys/module/cpu_boost/parameters/input_boost_ms" "0"
	simple_bar
	kmsg1 "[*] DISABLED CAF INPUT BOOST. "
	simple_bar
fi

# CPU input boost
if [[ -e "/sys/module/cpu_input_boost/parameters/input_boost_duration" ]]; then
	write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "0"
	simple_bar
	kmsg1 "[*] DISABLED CPU INPUT BOOST. "
	simple_bar
fi

simple_bar
kmsg1 "[*] ENABLED CORE CONTROL. "
simple_bar

# I/O Scheduler Tweaks.
for queue in /sys/block/*/queue/
do
	write "${queue}add_random" 0
	write "${queue}iostats" 0
	write "${queue}read_ahead_kb" 128
	write "${queue}nomerges" 0
	write "${queue}rq_affinity" 0
	write "${queue}nr_requests" 64
done

simple_bar
kmsg1 "[*] TWEAKED I/O SCHEDULER. "
simple_bar


# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
	avail_govs=$(cat "${cpu}scaling_available_governors")
	if [[ "$avail_govs" == *"schedutil"* ]]; then
		write "${cpu}scaling_governor" schedutil
		write "${cpu}schedutil/up_rate_limit_us" "$((SCHED_PERIOD_BATTERY / 1000))"
		write "${cpu}schedutil/down_rate_limit_us" "$((4 * SCHED_PERIOD_BATTERY / 1000))"
		write "${cpu}schedutil/pl" "0"
		write "${cpu}schedutil/iowait_boost_enable" "0"
		write "${cpu}schedutil/rate_limit_us" "$((4 * SCHED_PERIOD_BATTERY / 1000))"write "${cpu}schedutil/hispeed_load" "99"
		write "${cpu}schedutil/hispeed_freq" "$cpumfreq"
	elif [[ "$avail_govs" == *"interactive"* ]]; then
		write "${cpu}scaling_governor" interactive
		write "${cpu}interactive/timer_rate" "50000"
		write "${cpu}interactive/boost" "0"
		write "${cpu}interactive/timer_slack" "50000"
		write "${cpu}interactive/use_migration_notif" "1" 
		write "${cpu}interactive/ignore_hispeed_on_notif" "1"
		write "${cpu}interactive/use_sched_load" "1"
		write "${cpu}interactive/boostpulse" "0"
		write "${cpu}interactive/fastlane" "1"
		write "${cpu}interactive/fast_ramp_down" "1"
		write "${cpu}interactive/sampling_rate" "50000"
		write "${cpu}interactive/sampling_rate_min" "75000"
		write "${cpu}interactive/min_sample_time" "75000"
		write "${cpu}interactive/go_hispeed_load" "99"
		write "${cpu}interactive/hispeed_freq" "$cpumfreq"
	fi
done


simple_bar
kmsg1 "[*] TWEAKED CPU. "
simple_bar

for cpu in /sys/devices/system/cpu/cpu*
do
	if [[ $percentage -le "20" ]]; then
		write "/sys/devices/system/cpu/cpu1/online" "0"
		write "/sys/devices/system/cpu/cpu2/online" "0"
		write "/sys/devices/system/cpu/cpu5/online" "0"
		write "/sys/devices/system/cpu/cpu6/online" "0"
	elif [[ $percentage -ge "20" ]]; then
		write "$cpu/online" "1"
	fi
done

# GPU Tweaks
write "$gpu/throttling" "1"
write "$gpu/thermal_pwrlevel" "0"
write "$gpu/devfreq/adrenoboost" "0"
write "$gpu/force_no_nap" "0"
write "$gpu/bus_split" "1"
write "$gpu/devfreq/max_freq" "$gpumfreq"
write "$gpu/devfreq/min_freq" "100000000"
write "$gpu/default_pwrlevel" "$gpuminpl"
write "$gpu/force_bus_on" "0"
write "$gpu/force_clk_on" "0"
write "$gpu/force_rail_on" "0"
write "$gpu/idle_timer" "36"

if [[ -e "/proc/gpufreq/gpufreq_limited_thermal_ignore" ]]; then
	write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
fi

# Enable dvfs
if [[ -e "/proc/mali/dvfs_enable" ]]; then
	write "/proc/mali/dvfs_enable" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]]; then
	write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]; then
	write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
fi

simple_bar
kmsg1 "[*] TWEAKED GPU. "
simple_bar

# Enable and tweak adreno idler
if [[ -d "/sys/module/adreno_idler" ]]; then
	write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
	write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "10000"
	write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "35"
	write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "15"
	simple_bar
	kmsg1 "[*] ENABLED AND TWEAKED ADRENO IDLER. "
	simple_bar
fi

# Schedtune tweaks
if [[ -d "/dev/stune/" ]]; then
	write "/dev/stune/background/schedtune.boost" "0"
	write "/dev/stune/background/schedtune.prefer_idle" "0"
	write "/dev/stune/foreground/schedtune.boost" "0"
	write "/dev/stune/foreground/schedtune.prefer_idle" "1"
	write "/dev/stune/rt/schedtune.boost" "0"
	write "/dev/stune/rt/schedtune.prefer_idle" "0"
	write "/dev/stune/top-app/schedtune.boost" "5"
	write "/dev/stune/top-app/schedtune.prefer_idle" "1"
	write "/dev/stune/schedtune.boost" "0"
	write "/dev/stune/schedtune.prefer_idle" "0"
	simple_bar
	kmsg1 "[*] APPLIED SCHEDTUNE TWEAKS. "
	simple_bar
fi

# FS Tweaks.
if [[ -d "/proc/sys/fs" ]]; then
	write "/proc/sys/fs/dir-notify-enable" "0"
	write "/proc/sys/fs/lease-break-time" "20"
	write "/proc/sys/fs/leases-enable" "1"
	simple_bar
	kmsg1 "[*] APPLIED FS TWEAKS. "
	simple_bar
fi
    
# Enable dynamic_fsync.
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]; then
	write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
	simple_bar
	kmsg1 "[*] ENABLED DYNAMIC FSYNC. "
	simple_bar
fi

# Scheduler features.
if [[ -e "/sys/kernel/debug/sched_features" ]]; then
	write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
	write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
	write "/sys/kernel/debug/sched_features" "NO_WAKEUP_PREEMPTION"
	write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
	write "/sys/kernel/debug/sched_features" "ARCH_POWER"
	simple_bar
	kmsg1 "[*] APPLIED SCHEDULER FEATURES. "
	simple_bar
fi
	
# OP Chain disable
if [[ -d "/sys/module/opchain" ]]; then
	write "/sys/module/opchain/parameters/chain_on" "0"
	simple_bar
	kmsg1 "[*] DISABLED ONEPLUS CHAIN. "
	simple_bar
fi

# Tweak some kernel settings to improve overall performance.
write "/proc/sys/kernel/sched_child_runs_first" "1"
write "/proc/sys/kernel/sched_boost" "0"
write "/proc/sys/kernel/perf_cpu_time_max_percent" "10"
write "/proc/sys/kernel/sched_autogroup_enabled" "1"
write "/proc/sys/kernel/random/read_wakeup_threshold" "64"
write "/proc/sys/kernel/random/write_wakeup_threshold" "128"
write "/proc/sys/kernel/random/urandom_min_reseed_secs" "90"
write "/proc/sys/kernel/sched_tunable_scaling" "0"
write "/proc/sys/kernel/sched_latency_ns" "$SCHED_PERIOD_BATTERY"
write "/proc/sys/kernel/sched_min_granularity_ns" "$((SCHED_PERIOD_BATTERY / SCHED_TASKS_BATTERY))"
write "/proc/sys/kernel/sched_wakeup_granularity_ns" "$((SCHED_PERIOD_BATTERY / 2))"
write "/proc/sys/kernel/sched_migration_cost_ns" "5000000"
write "/proc/sys/kernel/sched_min_task_util_for_colocation" "0"
write "/proc/sys/kernel/sched_nr_migrate" "8"
write "/proc/sys/kernel/sched_schedstats" "0"
write "/proc/sys/kernel/sched_sync_hint_enable" "0"
write "/proc/sys/kernel/sched_user_hint" "0"
write "/proc/sys/kernel/printk_devkmsg" "off"

simple_bar
kmsg1 "[*] TWEAKED KERNEL SETTINGS. "
simple_bar

# Disable fingerprint boost.
if [[ -e "/sys/kernel/fp_boost/enabled" ]]; then
	write "/sys/kernel/fp_boost/enabled" "0"
	simple_bar
	kmsg1 "[*] DISABLED FINGERPRINT BOOST. "
	simple_bar
fi

# Set min and max clocks.
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
	if [[ -e "${minclk}scaling_min_freq" ]]; then
		write "${minclk}scaling_min_freq" "100000"
		write "${minclk}scaling_max_freq" "$cpumfreq"
	fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
	if [[ -e "${mnclk}scaling_min_freq" ]]; then
		write "${mnclk}scaling_min_freq" "100000"
		write "${mnclk}scaling_max_freq" "$cpumfreq"
	fi
done

simple_bar
kmsg1 "[*] SET MIN AND MAX CPU CLOCKS. "
simple_bar

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]]; then
	write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
	simple_bar
	kmsg1 "[*] ALLOWED CPUIDLE TO USE DEEPEST STATE. "
	simple_bar
fi

# Disable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]]; then
	write "/sys/module/acpuclock_krait/parameters/boost" "N"
	simple_bar
	kmsg1 "[*] DISABLED KRAIT VOLTAGE BOOST. "
	simple_bar
fi

# VM settings to improve overall user experience and performance.
write "/proc/sys/vm/dirty_background_ratio" "5"
write "/proc/sys/vm/dirty_ratio" "50"
write "/proc/sys/vm/dirty_expire_centisecs" "3000"
write "/proc/sys/vm/dirty_writeback_centisecs" "3000"
write "/proc/sys/vm/page-cluster" "0"
write "/proc/sys/vm/stat_interval" "60"
write "/proc/sys/vm/swappiness" "100"
write "/proc/sys/vm/laptop_mode" "0"
write "/proc/sys/vm/vfs_cache_pressure" "50"

simple_bar
kmsg1 "[*] APPLIED VM TWEAKS. "
simple_bar

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]; then
	write /sys/module/msm_thermal/vdd_restriction/enabled "1"
	write /sys/module/msm_thermal/core_control/enabled "1"
	write /sys/module/msm_thermal/parameters/enabled "Y"
	simple_bar
	kmsg1 "[*] APPLIED THERMAL TWEAKS. "
	simple_bar
fi

# Enable power efficient workqueue.
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]; then
	write "/sys/module/workqueue/parameters/power_efficient" "Y"
	simple_bar
	kmsg1 "[*] ENABLED POWER EFFICIENT WORKQUEUE. "
	simple_bar
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]; then
	write "/sys/devices/system/cpu/sched_mc_power_savings" "2"
	simple_bar
	kmsg1 "[*] ENABLED AGGRESSIVE MULTICORE POWER SAVINGS. "
	simple_bar
fi

# Fix DT2W.
if [[ -e "/sys/touchpanel/double_tap" && -e "/proc/tp_gesture" ]]; then
	write "/sys/touchpanel/double_tap" "1"
	write "/proc/tp_gesture" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN. "
	simple_bar
elif [[ -e "/proc/tp_gesture" ]]; then
	write "/proc/tp_gesture" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN. "
	simple_bar
elif [[ -e "/sys/touchpanel/double_tap" ]]; then
	write "/sys/touchpanel/double_tap" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN. "
	simple_bar
fi

# Disable touch boost on battery and balance profile.
if [[ -e /sys/module/msm_performance/parameters/touchboost ]]; then
	write "/sys/module/msm_performance/parameters/touchboost" "0"
	simple_bar
	kmsg1 "[*] DISABLED TOUCH BOOST. "simple_bar
elif [[ -e /sys/power/pnpmgr/touch_boost ]]; then
	write "/sys/power/pnpmgr/touch_boost" "0"
	simple_bar
	kmsg1 "[*] DISABLED TOUCH BOOST "
	simple_bar
fi

# Enable battery saver
if [[ -d "/sys/module/battery_saver" ]]; then
	write "/sys/module/battery_saver/parameters/enabled" "Y"
	simple_barkmsg1 "[*] ENABLED BATTERY SAVER. "
	simple_bar
fi

# Disable KSM
if [[ -e "/sys/kernel/mm/ksm/run" ]]; then
	write "/sys/kernel/mm/ksm/run" "0"
	simple_bar
	kmsg1 "[*] DISABLED KSM."
	simple_bar
# Disable UKSM
elif [[ -e "/sys/kernel/mm/uksm/run" ]]; then
	write "/sys/kernel/mm/uksm/run" "0"
	simple_bar
	kmsg1 "[*] DISABLED UKSM."
	simple_bar
fi

if [[ "$dm" = "Mi A3" ]]; then
    chmod 666 /sys/class/power_supply/battery/voltage_max
    write "/sys/class/power_supply/battery/voltage_max" "4200000"
fi

simple_bar
kmsg1 "[*] DECRESEAD BATTERY VOLTAGE. "
simple_bar

if [[ -e "/sys/class/lcd/panel/power_reduce" ]]; then
	write "/sys/class/lcd/panel/power_reduce" "1"
	simple_bar
	kmsg1 "[*] ENABLED LCD POWER REDUCE. "
	simple_bar
fi

if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]; then
	write "/sys/kernel/sched/gentle_fair_sleepers" "0"
	simple_bar
	kmsg1 "[*] DISABLED GENTLE FAIR SLEEPERS. "
	simple_bar
fi

simple_bar
kmsg1 "[*] $ntsh_profile PROFILE APPLIED WITH SUCCESS. "
simple_bar

simple_bar
kmsg1 "[*] END OF EXECUTION: $(date)"
simple_bar
exit=$(date +%s)

exectime=$((exit - init))
simple_bar
kmsg1 "[*] EXECUTION DONE IN $exectime SECONDS. "
simple_bar

init=$(date +%s)
}

# Mediatek Balanced(Normal) Mode
mtk_normal() {
	kmsg1 "----------------------- Info -----------------------"
    kmsg1 "[ * ] Date of execution: $(date) "
    kmsg1 "[ * ] Nightshade's version: $nightshade "
    kmsg1 "[ * ] Kernel: $(uname -a) "
    kmsg1 "[ * ] SOC: $mf, $soc "
    kmsg1 "[ * ] SDK: $sdk "
    kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
    kmsg1 "[ * ] CPU aarch: $aarch "
    kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
    kmsg1 "[ * ] GPU model: $GPU_MODEL "
    kmsg1 "[ * ] Android version: $arv "
    kmsg1 "[ * ] Device: $dm  "
    kmsg1 "[ * ] Battery charge level: $percentage% "
    kmsg1 "[ * ] Battery temperature: $temperature°C "
    kmsg1 "[ * ] Device total RAM: $totalram MB "
    kmsg1 "[ * ] RAM usage: $used_percentage% "
    kmsg1 "-------------------------------------------------------"
    simple_bar
    kmsg1 "[*] ENABLING $ntsh_profile PROFILE... "
    simple_bar
    
    renice -n -5 $(pgrep system_server)
    renice -n -5 $(pgrep com.miui.home)
    renice -n -5 $(pgrep launcher)
    renice -n -5 $(pgrep lawnchair)
    renice -n -5 $(pgrep home)
    renice -n -5 $(pgrep watchapp)
    renice -n -5 $(pgrep trebuchet)
    renice -n -1 $(pgrep dialer)
    renice -n -1 $(pgrep keyboard)
    renice -n -1 $(pgrep inputmethod)
    renice -n -9 $(pgrep fluid)
    renice -n -10 $(pgrep composer)
    renice -n -1 $(pgrep com.android.phone)
    renice -n -10 $(pgrep surfaceflinger)
    renice -n 1 $(pgrep kswapd0)
    renice -n 1 $(pgrep ksmd)
    renice -n -6 $(pgrep msm_irqbalance)
    renice -n -9 $(pgrep kgsl_worker)
    renice -n 6 $(pgrep android.gms)    
    
    simple_bar
    kmsg1 "[*] RENICED PROCESSES. "
    simple_bar
    
    # Enable perfd and mpdecision
    start perfd > /dev/null
    start mpdecision > /dev/null

    simple_bar
    kmsg1 "[*] ENABLED MPDECISION AND PERFD. "
    simple_bar    
    
    # Disable logd and statsd to reduce overhead.
    stop logd
    stop statsd

    simple_bar
    kmsg1 "[*] DISABLED STATSD AND LOGD. "
    simple_bar    
    
	# CPU tweaks
	cpu="0"
	while [ $cpu -lt $cpu_cores ]; do
		cpu_dir="/sys/devices/system/cpu/cpu${cpu}"
		if [ -d "$cpu_dir" ]; then
			write "${cpu_dir}/cpufreq/scaling_governor" "$default_cpu_gov"
		fi
		cpu="$((cpu + 1))"
	done
	
	simple_bar
    kmsg1 "[*] CPU TWEAKED. "
    simple_bar

	# Idle charging
	write "/proc/mtk_battery_cmd/current_cmd" "0 0"
	
	simple_bar
    kmsg1 "[*] IDLE CHARGING DISABLED. "
    simple_bar
	
	# Enable back PPM
	write "/proc/ppm/enabled" "1"

	simple_bar
    kmsg1 "[*] PPM ENABLED. "
    simple_bar
	
	# MTK Power and CCI mode
	write "/proc/cpufreq/cpufreq_cci_mode" "0"
	write "/proc/cpufreq/cpufreq_power_mode" "0"

	simple_bar
    kmsg1 "[*] CPU POWER AND CCI MODE TWEAKED. "
    simple_bar
	
	# EAS/HMP Switch
	lock_val "1" /sys/devices/system/cpu/eas/enable

	simple_bar
    kmsg1 "[*] EAS/HMP TWEAKED. "
    simple_bar
	
	# GPU Frequency
	if [ ! $(uname -r | cut -d'.' -f1,2 | sed 's/\.//') -gt 500 ]; then
		echo "0" >/proc/gpufreq/gpufreq_opp_freq 2>/dev/null
	else
		write "/proc/gpufreqv2/fix_custom_freq_volt" "0 0" 
	fi

	# Disable GPU Power limiter
	if [ -f "/proc/gpufreq/gpufreq_power_limited" ]; then
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_batt_oc 0"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_batt_percent 0"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_low_batt 0"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_thermal_protect 0" 
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_pbm_limited 0"
	fi
	
	simple_bar
    kmsg1 "[*] GPU TWEAKED. "
    simple_bar

	# Disable Power Budget management for new 5.x kernels
	write "/proc/pbm/pbm_stop" "stop 0"

	simple_bar
    kmsg1 "[*] POWER BUDGET MANAGEMENT TWEAKED. "
    simple_bar
	
	# Disable battery current limiter
	write "/proc/mtk_batoc_throttling/battery_oc_protect_stop" "stop 0"

	simple_bar
    kmsg1 "[*] BATTERY CURRENT LIMITER DISABLED. "
    simple_bar
	
	# DRAM Frequency
	if [ ! $(uname -r | cut -d'.' -f1,2 | sed 's/\.//') -gt 500 ]; then
		write "/sys/devices/platform/10012000.dvfsrc/helio-dvfsrc/dvfsrc_req_ddr_opp" "-1"
	else
		write "/sys/kernel/helio-dvfsrc/dvfsrc_force_vcore_dvfs_opp" "-1" 
	fi

	simple_bar
    kmsg1 "[*] DRAM FREQUENCY TWEAKED. "
    simple_bar
	
	# Drop mem cache
	write "/proc/sys/vm/drop_caches" "3"

	simple_bar
    kmsg1 "[*] DROPPED MEM CACHE. "
    simple_bar
	
	# Mediatek's APU freq
	write "/sys/module/mmdvfs_pmqos/parameters/force_step" "-1"

	simple_bar
    kmsg1 "[*] MEDIATEK's APU FREQ TWEAKED. "
    simple_bar
	
	# Touchpanel
	tp_path="/proc/touchpanel"
	write "$tp_path/game_switch_enable" "0"
	write "$tp_path/oplus_tp_limit_enable" "1"
	write "$tp_path/oppo_tp_limit_enable" "1"
	write "$tp_path/oplus_tp_direction" "0"
	write "$tp_path/oppo_tp_direction" "0"
	
	simple_bar
    kmsg1 "[*] TOUCHPANEL TWEAKED. "
    simple_bar
	
	simple_bar
    kmsg1 "[*] $ntsh_profile PROFILE APPLIED WITH SUCCESS. "
    simple_bar

    simple_bar
    kmsg1 "[*] END OF EXECUTION: $(date)"
    simple_bar
    exit=$(date +%s)

    exectime=$((exit - init))
    simple_bar
    kmsg1 "[*] EXECUTION DONE IN $exectime SECONDS. "
    simple_bar

    init=$(date +%s)
	
	am start -a android.intent.action.MAIN -e toasttext "Balanced profile was successfully applied!" -n bellavita.toast/.MainActivity
}

# Balanced Profile
balanced() {
init=$(date +%s)     

# Checking mtk device
simple_bar
kmsg1 "[ * ] Checking device compatibility..."
chipset=$(grep "Hardware" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')
if [ -z "$chipset" ]; then
    chipset=$(getprop "ro.hardware")
fi

if [[ $chipset == *MT* ]] || [[ $chipset == *mt* ]]; then
    kmsg1 "[ ! ] Device is Mediatek, executing mtk_normal..."
    settings delete global device_idle_constants
    mtk_normal
    exit
else
    kmsg1 "[ * ] Device is not Mediatek, continuing script..."
fi

kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Nightshade's version: $nightshade "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Battery temperature: $temperature°C "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "-------------------------------------------------------"
simple_bar
kmsg1 "[*] ENABLING $ntsh_profile PROFILE... "
simple_bar       	
 	
renice -n -5 $(pgrep system_server)
renice -n -5 $(pgrep com.miui.home)
renice -n -5 $(pgrep launcher)
renice -n -5 $(pgrep lawnchair)
renice -n -5 $(pgrep home)
renice -n -5 $(pgrep watchapp)
renice -n -5 $(pgrep trebuchet)
renice -n -1 $(pgrep dialer)
renice -n -1 $(pgrep keyboard)
renice -n -1 $(pgrep inputmethod)
renice -n -9 $(pgrep fluid)
renice -n -10 $(pgrep composer)
renice -n -1 $(pgrep com.android.phone)
renice -n -10 $(pgrep surfaceflinger)
renice -n 1 $(pgrep kswapd0)
renice -n 1 $(pgrep ksmd)
renice -n -6 $(pgrep msm_irqbalance)
renice -n -9 $(pgrep kgsl_worker)
renice -n 6 $(pgrep android.gms)

simple_bar
kmsg1 "[*] RENICED PROCESSES. "
simple_bar


# Enable perfd and mp decision
start perfd > /dev/null
start mpdecision > /dev/null

simple_bar
kmsg1 "[*] ENABLED MPDECISION AND PERFD "
simple_bar

# Disable logd and statsd to reduce overhead.
stop logd
stop statsd

simple_bar
kmsg1 "[*] DISABLED STATSD AND LOGD. "
simple_bar

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
	write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "10"
	simple_bar
	kmsg1 "[*] TWEAKED STUNE BOOST."
	simple_bar
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
	if [[ -e "${corectl}/enable" ]]; then
		write "${corectl}/enable" "1"
    elif [[ -e "${corectl}/disable" ]]; then
	write "${corectl}/disable" "0"
	fi
done

simple_bar
kmsg1 "[*] ENABLED CORE CONTROL. "
simple_bar

# I/O Scheduler Tweaks.
for queue in /sys/block/*/queue/
do
	write "${queue}add_random" 0
	write "${queue}iostats" 0
	write "${queue}read_ahead_kb" 128
	write "${queue}nomerges" 2
	write "${queue}rq_affinity" 1
	write "${queue}nr_requests" 64
done

simple_bar
kmsg1 "[*] TWEAKED I/O SCHEDULER."
simple_bar

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
	avail_govs=$(cat "${cpu}scaling_available_governors")
	if [[ "$avail_govs" == *"schedutil"* ]]; then
		write "${cpu}scaling_governor" schedutil
		write "${cpu}schedutil/up_rate_limit_us" "$((SCHED_PERIOD_BALANCE / 1000))"
		write "${cpu}schedutil/down_rate_limit_us" "$((4 * SCHED_PERIOD_BALANCE / 1000))"
		write "${cpu}schedutil/pl" "0"
		write "${cpu}schedutil/iowait_boost_enable" "0"
		write "${cpu}schedutil/rate_limit_us" "$((4 * SCHED_PERIOD_BALANCE / 1000))"
		write "${cpu}schedutil/hispeed_load" "89"
		write "${cpu}schedutil/hispeed_freq" "$cpumxfreq"
	elif [[ "$avail_govs" == *"interactive"* ]]; then
		write "${cpu}scaling_governor" interactive
		write "${cpu}interactive/timer_rate" "40000"
		write "${cpu}interactive/boost" "0"
		write "${cpu}interactive/timer_slack" "40000"
		write "${cpu}interactive/use_migration_notif" "1" 
		write "${cpu}interactive/ignore_hispeed_on_notif" "1"
		write "${cpu}interactive/use_sched_load" "1"
		write "${cpu}interactive/boostpulse" "0"
		write "${cpu}interactive/fastlane" "1"
		write "${cpu}interactive/fast_ramp_down" "0"
		write "${cpu}interactive/sampling_rate" "40000"
		write "${cpu}interactive/sampling_rate_min" "50000"
		write "${cpu}interactive/min_sample_time" "50000"
		write "${cpu}interactive/go_hispeed_load" "89"
		write "${cpu}interactive/hispeed_freq" "$cpumxfreq"
	fi
done

for cpu in /sys/devices/system/cpu/cpu*
do
	write "$cpu/online" "1"
done

simple_bar
kmsg1 "[*] TWEAKED CPU "
simple_bar

# GPU Tweaks.
write "$gpu/throttling" "1"
write "$gpu/thermal_pwrlevel" "0"
write "$gpu/devfreq/adrenoboost" "0"
write "$gpu/force_no_nap" "0"
write "$gpu/bus_split" "1"
write "$gpu/devfreq/max_freq" $(cat "$gpu"/max_gpuclk)
write "$gpu/devfreq/min_freq" "100000000"
write "$gpu/default_pwrlevel" "$gpuminpl"
write "$gpu/force_bus_on" "0"
write "$gpu/force_clk_on" "0"
write "$gpu/force_rail_on" "0"
write "$gpu/idle_timer" "96"

if [[ -e "/proc/gpufreq/gpufreq_limited_thermal_ignore" ]]; then
	write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
fi

# Enable dvfs
if [[ -e "/proc/mali/dvfs_enable" ]];then
	write "/proc/mali/dvfs_enable" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]];then
	write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]; then
	write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
fi

simple_bar
kmsg1 "[*] TWEAKED GPU "
simple_bar
	
# Enable and tweak adreno idler
if [[ -d "/sys/module/adreno_idler" ]]; then
	write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
	write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "6000"
	write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "25"
	write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "25"
	simple_bar
	kmsg1 "[*] ENABLED AND TWEAKED ADRENO IDLER... "
	simple_bar
fi

# Schedtune Tweaks
if [[ -d "/dev/stune/" ]]; then
	write "/dev/stune/background/schedtune.boost" "0"
	write "/dev/stune/background/schedtune.prefer_idle" "0"
	write "/dev/stune/foreground/schedtune.boost" "0"
	write "/dev/stune/foreground/schedtune.prefer_idle" "1"
	write "/dev/stune/rt/schedtune.boost" "0"
	write "/dev/stune/rt/schedtune.prefer_idle" "0"
	write "/dev/stune/top-app/schedtune.boost" "10"
	write "/dev/stune/top-app/schedtune.prefer_idle" "1"
	write "/dev/stune/schedtune.boost" "0"
	write "/dev/stune/schedtune.prefer_idle" "0"
	simple_bar
	kmsg1 "[*] APPLIED SCHEDTUNE TWEAKS. "
	simple_bar
fi

# FS tweaks.
if [[ -d "/proc/sys/fs" ]]; then
	write "/proc/sys/fs/dir-notify-enable" "0"
	write "/proc/sys/fs/lease-break-time" "20"
	write "/proc/sys/fs/leases-enable" "1"
	simple_bar
	kmsg1 "[*] APPLIED FS TWEAKS "
	simple_bar
fi

# Enable dynamic_fsync.
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]; then
	write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
	simple_bar
	kmsg1 "[*] ENABLED DYNAMIC FSYNC."
	simple_bar
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]; then
	write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
	write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
	write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
	write "/sys/kernel/debug/sched_features" "WAKEUP_PREEMPTION"
fi

simple_bar
kmsg1 "[*] APPLIED SCHEDULER FEATURES. "
simple_bar

# OP Chain disable.
if [[ -d "/sys/module/opchain" ]]; then
	write "/sys/module/opchain/parameters/chain_on" "0"
	simple_bar
	kmsg1 "[*] DISABLED ONEPLUS CHAIN. "
	simple_bar
fi

# Tweak some kernel settings to improve overall performance.
write "/proc/sys/kernel/sched_child_runs_first" "0"
write "/proc/sys/kernel/sched_boost" "0"
write "/proc/sys/kernel/perf_cpu_time_max_percent" "15"
write "/proc/sys/kernel/sched_autogroup_enabled" "1"
write "/proc/sys/kernel/random/read_wakeup_threshold" "64"
write "/proc/sys/kernel/random/write_wakeup_threshold" "256"
write "/proc/sys/kernel/random/urandom_min_reseed_secs" "90"
write "/proc/sys/kernel/sched_tunable_scaling" "0"
write "/proc/sys/kernel/sched_latency_ns" "$SCHED_PERIOD_BALANCE"
write "/proc/sys/kernel/sched_min_granularity_ns" "$((SCHED_PERIOD_BALANCE / SCHED_TASKS_BALANCE))"
write "/proc/sys/kernel/sched_wakeup_granularity_ns" "$((SCHED_PERIOD_BALANCE / 2))"
write "/proc/sys/kernel/sched_migration_cost_ns" "5000000"
write "/proc/sys/kernel/sched_min_task_util_for_colocation" "0"
write "/proc/sys/kernel/sched_nr_migrate" "32"
write "/proc/sys/kernel/sched_schedstats" "0"
write "/proc/sys/kernel/sched_sync_hint_enable" "0"
write "/proc/sys/kernel/sched_user_hint" "0"
write "/proc/sys/kernel/printk_devkmsg" "off"

simple_bar
kmsg1 "[*] TWEAKED KERNEL SETTINGS. "
simple_bar

# Enable fingerprint boost.
if [[ -e "/sys/kernel/fp_boost/enabled" ]]; then
	write "/sys/kernel/fp_boost/enabled" "1"
	simple_bar
	kmsg1 "[*] ENABLED FINGERPRINT BOOST. "
	simple_bar
fi

# Set min and max clocks.
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
	if [[ -e "${minclk}scaling_min_freq" ]]; then
		write "${minclk}scaling_min_freq" "100000"
		write "${minclk}scaling_max_freq" "$cpumxfreq"
	fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
	if [[ -e "${mnclk}scaling_min_freq" ]]; then
		write "${mnclk}scaling_min_freq" "100000"
		write "${mnclk}scaling_max_freq" "$cpumxfreq"
	fi
done

simple_bar
kmsg1 "[*] SET MIN AND MAX CPU CLOCKS. "
simple_bar

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]]; then
	write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
	simple_bar
	kmsg1 "[*] ALLOWED CPUIDLE TO USE DEEPEST STATE. "
	simple_bar
fi

# Disable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]]; then
	write "/sys/module/acpuclock_krait/parameters/boost" "N"
	simple_bar
	kmsg1 "[*] DISABLED KRAIT VOLTAGE BOOST. "
	simple_bar
fi

sync

# VM settings to improve overall user experience and smoothness.
write "/proc/sys/vm/drop_caches" "3"
write "/proc/sys/vm/dirty_background_ratio" "10"
write "/proc/sys/vm/dirty_ratio" "30"
write "/proc/sys/vm/dirty_expire_centisecs" "1000"
write "/proc/sys/vm/dirty_writeback_centisecs" "3000"
write "/proc/sys/vm/page-cluster" "0"
write "/proc/sys/vm/stat_interval" "60"
write "/proc/sys/vm/swappiness" "100"
write "/proc/sys/vm/laptop_mode" "0"
write "/proc/sys/vm/vfs_cache_pressure" "50"

simple_bar
kmsg1 "[*] APPLIED VM TWEAKS."
simple_bar

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]; then
	write /sys/module/msm_thermal/vdd_restriction/enabled "0"
	write /sys/module/msm_thermal/core_control/enabled "1"
	write /sys/module/msm_thermal/parameters/enabled "Y"
	simple_bar
	kmsg1 "[*] APPLIED THERMAL TWEAKS. "
	simple_bar
fi

# Enable power efficient workqueue.
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]; then
	write "/sys/module/workqueue/parameters/power_efficient" "Y"
	simple_bar
	kmsg1 "[*] ENABLED POWER EFFICIENT WORKQUEUE. "
	simple_bar
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]; then
	write "/sys/devices/system/cpu/sched_mc_power_savings" "1"
	simple_bar
	kmsg1 "[*] ENABLED MULTICORE POWER SAVINGS. "
	simple_bar
fi

# Fix DT2W.
if [[ -e "/sys/touchpanel/double_tap" && -e "/proc/tp_gesture" ]]; then
	write "/sys/touchpanel/double_tap" "1"
	write "/proc/tp_gesture" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN. "
	simple_bar
elif [[ -e "/proc/tp_gesture" ]]; then
	write "/proc/tp_gesture" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN. "
	simple_bar
elif [[ -e "/sys/touchpanel/double_tap" ]]; then
	write "/sys/touchpanel/double_tap" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN. "
	simple_bar
fi

# Disable touch boost on balance and battery profile.
if [[ -e /sys/module/msm_performance/parameters/touchboost ]]; then
	write "/sys/module/msm_performance/parameters/touchboost" "0"
	simple_bar
	kmsg1 "[*] DISABLED TOUCH BOOST. "
	simple_bar
elif [[ -e /sys/power/pnpmgr/touch_boost ]]; then
	write "/sys/power/pnpmgr/touch_boost" "0"
	simple_bar
	kmsg1 "[*] DISABLED TOUCH BOOST. "
	simple_bar
fi


# Enable KSM
if [[ -e "/sys/kernel/mm/ksm/run" ]]; then
	write "/sys/kernel/mm/ksm/run" "1"
	simple_bar
	kmsg1 "[*] ENABLED KSM."
	simple_bar
# Enable UKSM
elif [[ -e "/sys/kernel/mm/uksm/run" ]]; then
	write "/sys/kernel/mm/uksm/run" "1"
	simple_bar
	kmsg1 "[*] ENABLED UKSM."
	simple_bar
fi

if [[ "$dm" = "Mi A3" ]]; then
    chmod 666 /sys/class/power_supply/battery/voltage_max
    write "/sys/class/power_supply/battery/voltage_max" "4400000"
fi

simple_bar
kmsg1 "[*] TWEAKED BATTERY VOLTAGE. "
simple_bar

if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]]; then
	write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
	simple_bar
	kmsg1 "[*] ENABLED PM2 IDLE SLEEP MODE. "
	simple_bar
fi

if [[ -e "/sys/class/lcd/panel/power_reduce" ]]; then
	write "/sys/class/lcd/panel/power_reduce" "0"
	simple_bar
	kmsg1 "[*] DISABLED LCD POWER REDUCE. "
	simple_bar
fi

if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]; then
	write "/sys/kernel/sched/gentle_fair_sleepers" "1"
	simple_bar
	kmsg1 "[*] ENABLED GENTLE FAIR SLEEPERS. "
	simple_bar
fi

simple_bar
kmsg1 "[*] $ntsh_profile PROFILE APPLIED WITH SUCCESS "
simple_bar

simple_bar
kmsg1 "[*] END OF EXECUTION: $(date)"
simple_bar

exit=$(date +%s)

exectime=$((exit - init))
simple_bar
kmsg1 "[*] EXECUTION DONE IN $exectime SECONDS. "
simple_bar

init=$(date +%s)
}

# Mediatek Performance Profile
mtk_perf() {
	kmsg1 "----------------------- Info -----------------------"
    kmsg1 "[ * ] Date of execution: $(date) "
    kmsg1 "[ * ] Nightshade's version: $nightshade "
    kmsg1 "[ * ] Kernel: $(uname -a) "
    kmsg1 "[ * ] SOC: $mf, $soc "
    kmsg1 "[ * ] SDK: $sdk "
    kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
    kmsg1 "[ * ] CPU aarch: $aarch "
    kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
    kmsg1 "[ * ] GPU model: $GPU_MODEL "
    kmsg1 "[ * ] Android version: $arv "
    kmsg1 "[ * ] Device: $dm  "
    kmsg1 "[ * ] Battery charge level: $percentage% "
    kmsg1 "[ * ] Battery temperature: $temperature°C "
    kmsg1 "[ * ] Device total RAM: $totalram MB "
    kmsg1 "[ * ] RAM usage: $used_percentage% "
    kmsg1 "-------------------------------------------------------"
    simple_bar
    kmsg1 "[*] ENABLING $ntsh_profile PROFILE... "
    simple_bar
    
    renice -n -5 $(pgrep system_server)
    renice -n -5 $(pgrep com.miui.home)
    renice -n -5 $(pgrep launcher)
    renice -n -5 $(pgrep lawnchair)
    renice -n -5 $(pgrep home)
    renice -n -5 $(pgrep watchapp)
    renice -n -5 $(pgrep trebuchet)
    renice -n -1 $(pgrep dialer)
    renice -n -1 $(pgrep keyboard)
    renice -n -1 $(pgrep inputmethod)
    renice -n -9 $(pgrep fluid)
    renice -n -10 $(pgrep composer)
    renice -n -1 $(pgrep com.android.phone)
    renice -n -10 $(pgrep surfaceflinger)
    renice -n 1 $(pgrep kswapd0)
    renice -n 1 $(pgrep ksmd)
    renice -n -6 $(pgrep msm_irqbalance)
    renice -n -9 $(pgrep kgsl_worker)
    renice -n 6 $(pgrep android.gms)    
    
    simple_bar
    kmsg1 "[*] RENICED PROCESSES. "
    simple_bar
    
    # Enable perfd and mpdecision
    start perfd > /dev/null
    start mpdecision > /dev/null

    simple_bar
    kmsg1 "[*] ENABLED MPDECISION AND PERFD. "
    simple_bar    
    
    # Disable logd and statsd to reduce overhead.
    stop logd
    stop statsd

    simple_bar
    kmsg1 "[*] DISABLED STATSD AND LOGD. "
    simple_bar    
    
	# CPU tweaks
	cpu="0"
	while [ $cpu -lt $cpu_cores ]; do
		cpu_dir="/sys/devices/system/cpu/cpu${cpu}"
		if [ -d "$cpu_dir" ]; then
			write "${cpu_dir}/cpufreq/scaling_governor" "performance"
		fi
		cpu="$((cpu + 1))"
	done

	simple_bar
    kmsg1 "[*] CPU TWEAKED. "
    simple_bar
	
	# MTK Power and CCI mode
	write "/proc/cpufreq/cpufreq_cci_mode" "1"
	write "/proc/cpufreq/cpufreq_power_mode" "3"

	simple_bar
    kmsg1 "[*] MTK POWER AND CCI MODE TWEAKED. "
    simple_bar
	
	# EAS/HMP Switch
	lock_val "0" /sys/devices/system/cpu/eas/enable

	simple_bar
    kmsg1 "[*] EAS/HMP TWEAKED. "
    simple_bar
	
	# Idle charging
	write "/proc/mtk_battery_cmd/current_cmd" "0 1"

	simple_bar
    kmsg1 "[*] IDLE CHARGING ENABLED. "
    simple_bar
	
	# Disable PPM (this is fire dumpster)
	write "/proc/ppm/enabled" "0"

	simple_bar
    kmsg1 "[*] PPM DISABLED. "
    simple_bar
	
	# GPU Frequency
	if [ ! $(uname -r | cut -d'.' -f1,2 | sed 's/\.//') -gt 500 ]; then
		gpu_freq="$(cat /proc/gpufreq/gpufreq_opp_dump | grep -o 'freq = [0-9]*' | sed 's/freq = //' | sort -nr | head -n 1)"
		write "/proc/gpufreq/gpufreq_opp_freq" "$gpu_freq"
	else
		gpu_freq="$(cat /proc/gpufreqv2/gpu_working_opp_table | awk '{print $3}' | sed 's/,//g' | sort -nr | head -n 1)"
		gpu_volt="$(cat /proc/gpufreqv2/gpu_working_opp_table | awk -v freq="$freq" '$0 ~ freq {gsub(/.*, volt: /, ""); gsub(/,.*/, ""); print}')"
		write "/proc/gpufreqv2/fix_custom_freq_volt" "${gpu_freq} ${gpu_volt}" 
	fi

	# Disable GPU Power limiter
	if [ -f "/proc/gpufreq/gpufreq_power_limited" ]; then
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_batt_oc 1"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_batt_percent 1"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_low_batt 1"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_thermal_protect 1"
		write "/proc/gpufreq/gpufreq_power_limited" "ignore_pbm_limited 1"
	fi

	simple_bar
    kmsg1 "[*] GPU TWEAKED. "
    simple_bar
	
	# Disable battery current limiter
	write "/proc/mtk_batoc_throttling/battery_oc_protect_stop" "stop 1" 

	simple_bar
    kmsg1 "[*] DISABLED BATTERY CURRENT LIMITER. "
    simple_bar
	
	# DRAM Frequency
	if [ ! $(uname -r | cut -d'.' -f1,2 | sed 's/\.//') -gt 500 ]; then
		write "sys/devices/platform/10012000.dvfsrc/helio-dvfsrc/dvfsrc_req_ddr_opp" "0"
	else
		write "/sys/kernel/helio-dvfsrc/dvfsrc_force_vcore_dvfs_opp" "0"
	fi

	simple_bar
    kmsg1 "[*] DRAM FREQUENCY TWEAKED. "
    simple_bar
	
	# Drop mem cache
	write "/proc/sys/vm/drop_caches" "3"

	simple_bar
    kmsg1 "[*] DROPPED MEM CACHE. "
    simple_bar
	
	# Mediatek's APU freq
	write "/sys/module/mmdvfs_pmqos/parameters/force_step" "0"

	simple_bar
    kmsg1 "[*] MEDIATEK's APU FREQUENCY TWEAKED. "
    simple_bar
	
	# Touchpanel
	tp_path="/proc/touchpanel"
	write "$tp_path/game_switch_enable" "1"
	write "$tp_path/oplus_tp_limit_enable" "0"
	write "$tp_path/oppo_tp_limit_enable" "0"
	write "$tp_path/oplus_tp_direction" "1"
	write "$tp_path/oppo_tp_direction" "1"
	
	simple_bar
    kmsg1 "[*] TOUCHPANEL TWEAKED. "
    simple_bar
     
    simple_bar
    kmsg1 "[*] $ntsh_profile PROFILE APPLIED WITH SUCCESS. "
    simple_bar

    simple_bar
    kmsg1 "[*] END OF EXECUTION: $(date)"
    simple_bar
    exit=$(date +%s)

    exectime=$((exit - init))
    simple_bar
    kmsg1 "[*] EXECUTION DONE IN $exectime SECONDS. "
    simple_bar

    init=$(date +%s)
	
	am start -a android.intent.action.MAIN -e toasttext "Performance profile was successfully applied!" -n bellavita.toast/.MainActivity
}

# Performance Profile
performance() {
init=$(date +%s)     

# Checking mtk device
simple_bar
kmsg1 "[ * ] Checking device compatibility..."
chipset=$(grep "Hardware" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')
if [ -z "$chipset" ]; then
    chipset=$(getprop "ro.hardware")
fi

if [[ $chipset == *MT* ]] || [[ $chipset == *mt* ]]; then
    kmsg1 "[ ! ] Device is Mediatek, executing mtk_perf..."
    settings delete global device_idle_constants
    mtk_perf
    exit
else
    kmsg1 "[ * ] Device is not Mediatek, continuing script..."
fi

kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Nightshade's version: $nightshade "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Battery temperature: $temperature°C "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "-------------------------------------------------------"
kmsg1 "[*] ENABLING $ntsh_profile PROFILE..."
simple_bar
	  
renice -n -5 $(pgrep system_server)
renice -n -5 $(pgrep com.miui.home)
renice -n -5 $(pgrep launcher)
renice -n -5 $(pgrep lawnchair)
renice -n -5 $(pgrep home)
renice -n -5 $(pgrep watchapp)
renice -n -5 $(pgrep trebuchet)
renice -n -1 $(pgrep dialer)
renice -n -1 $(pgrep keyboard)
renice -n -1 $(pgrep inputmethod)
renice -n -9 $(pgrep fluid)
renice -n -10 $(pgrep composer)
renice -n -1 $(pgrep com.android.phone)
renice -n -10 $(pgrep surfaceflinger)
renice -n 1 $(pgrep kswapd0)
renice -n 1 $(pgrep ksmd)
renice -n -6 $(pgrep msm_irqbalance)
renice -n -9 $(pgrep kgsl_worker)
renice -n 6 $(pgrep android.gms)

simple_bar
kmsg1 "[*] RENICED PROCESSES. "
simple_bar

# Enable perfd and stop mp decision
start perfd > /dev/null
stop mpdecision > /dev/null

simple_bar
kmsg1 "[*] DISABLED MPDECISION AND ENABLED PERFD. "
simple_bar

# Disable logd and statsd to reduce overhead.
stop logd
stop statsd

simple_bar
kmsg1 "[*] DISABLED STATSD AND LOGD. "
simple_bar

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
	write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
	simple_bar
	kmsg1 "[*] TWEAKED STUNE BOOST "
	simple_bar
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
	if [[ -e "${corectl}/enable" ]]; then
		write "${corectl}/enable" "0"
	elif [[ -e "${corectl}/disable" ]]; then
		write "${corectl}/disable" "1"
	fi
done

simple_bar
kmsg1 "[*] DISABLED CORE CONTROL. "
simple_bar

# Caf CPU Boost
if [[ -d "/sys/module/cpu_boost" ]]; then
	write "/sys/module/cpu_boost/parameters/input_boost_freq" "0:$cpumxfreq 1:$cpumxfreq 2:$cpumxfreq 3:$cpumxfreq 4:$cpumxfreq 5:$cpumxfreq 6:$cpumxfreq 7:$cpumxfreq"
	write "/sys/module/cpu_boost/parameters/input_boost_ms" "128"
	simple_bar
	kmsg1 "[*] TWEAKED CAF INPUT BOOST. "
	simple_bar
# CPU input boost
elif [[ -d "/sys/module/cpu_input_boost" ]]; then
	write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "128"
	write "/sys/module/cpu_input_boost/parameters/input_boost_freq_hp" "$cpumxfreq"
	write "/sys/module/cpu_input_boost/parameters/input_boost_freq_lp" "$cpumxfreq"
	simple_bar
	kmsg1 "[*] TWEAKED CPU INPUT BOOST. "
	simple_bar
fi

# I/O Scheduler Tweaks.
for queue in /sys/block/*/queue/
do
	write "${queue}add_random" 0
	write "${queue}iostats" 0
	write "${queue}read_ahead_kb" 512
	write "${queue}nomerges" 2
	write "${queue}rq_affinity" 2
	write "${queue}nr_requests" 256
done

simple_bar
kmsg1 "[*] TWEAKED I/O SCHEDULER."
simple_bar

for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
	avail_govs=$(cat "${cpu}scaling_available_governors")
	if [[ "$avail_govs" == *"schedutil"* ]]; then
		write "${cpu}scaling_governor" schedutil
		write "${cpu}schedutil/up_rate_limit_us" "500"
		write "${cpu}schedutil/down_rate_limit_us" "20000"
		write "${cpu}schedutil/pl" "1"
		write "${cpu}schedutil/iowait_boost_enable" "1"
		write "${cpu}schedutil/rate_limit_us" "20000"
		write "${cpu}schedutil/hispeed_load" "80"
		write "${cpu}schedutil/hispeed_freq" "$UINT_MAX"
	elif [[ "$avail_govs" == *"interactive"* ]]; then
		write "${cpu}scaling_governor" interactive
		write "${cpu}interactive/timer_rate" "20000"
		write "${cpu}interactive/boost" "1"
		write "${cpu}interactive/timer_slack" "20000"
		write "${cpu}interactive/use_migration_notif" "1"
		write "${cpu}interactive/ignore_hispeed_on_notif" "1"
		write "${cpu}interactive/use_sched_load" "1"
		write "${cpu}interactive/fastlane" "1"
		write "${cpu}interactive/fast_ramp_down" "0"
		write "${cpu}interactive/sampling_rate" "20000"
		write "${cpu}interactive/sampling_rate_min" "20000"
		write "${cpu}interactive/min_sample_time" "20000"
		write "${cpu}interactive/go_hispeed_load" "80"
		write "${cpu}interactive/hispeed_freq" "$UINT_MAX"
	fi
done
	
for cpu in /sys/devices/system/cpu/cpu*
do
	write "$cpu/online" "1"
done

simple_bar
kmsg1 "[*] TWEAKED CPU "
simple_bar

# GPU Tweaks.
write "$gpu/throttling" "0"
write "$gpu/thermal_pwrlevel" "0"
write "$gpu/devfreq/adrenoboost" "1"
write "$gpu/force_no_nap" "0"
write "$gpu/bus_split" "0"
write "$gpu/devfreq/max_freq" $(cat "$gpu"/max_gpuclk)
write "$gpu/devfreq/min_freq" "100000000"
write "$gpu/default_pwrlevel" "1"
write "$gpu/force_bus_on" "0"
write "$gpu/force_clk_on" "0"
write "$gpu/force_rail_on" "0"
write "$gpu/idle_timer" "146"

if [[ -e "/proc/gpufreq/gpufreq_limited_thermal_ignore" ]]; then
	write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
fi

# Enable dvfs
if [[ -e "/proc/mali/dvfs_enable" ]]; then
	write "/proc/mali/dvfs_enable" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]]; then
	write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]; then
	write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
fi

simple_bar
kmsg1 "[*] TWEAKED GPU "
simple_bar

# Disable adreno idler
if [[ -d "/sys/module/adreno_idler" ]]; then
	write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
	simple_bar
	kmsg1 "[*] DISABLED ADRENO IDLER."
	simple_bar
fi

# Schedtune Tweaks
if [[ -d "/dev/stune/" ]]; then
	write "/dev/stune/background/schedtune.boost" "0"
	write "/dev/stune/background/schedtune.prefer_idle" "0"
	write "/dev/stune/foreground/schedtune.boost" "50"
	write "/dev/stune/foreground/schedtune.prefer_idle" "0"
	write "/dev/stune/rt/schedtune.boost" "0"
	write "/dev/stune/rt/schedtune.prefer_idle" "0"
	write "/dev/stune/top-app/schedtune.boost" "50"
	write "/dev/stune/top-app/schedtune.prefer_idle" "0"
	write "/dev/stune/schedtune.boost" "0"
	write "/dev/stune/schedtune.prefer_idle" "0"
	simple_bar
	kmsg1 "[*] APPLIED SCHEDTUNE TWEAKS. "
	simple_bar
fi

# FS Tweaks.
if [[ -d "/proc/sys/fs" ]]; then
	write "/proc/sys/fs/dir-notify-enable" "0"
	write "/proc/sys/fs/lease-break-time" "20"
	write "/proc/sys/fs/leases-enable" "1"
	simple_bar
	kmsg1 "[*] APPLIED FS TWEAKS."
	simple_bar
fi

# Enable dynamic_fsync.
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]; then
	write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
	simple_bar
	kmsg1 "[*] ENABLED DYNAMIC FSYNC."
	simple_bar
fi

# Scheduler features.
if [[ -e "/sys/kernel/debug/sched_features" ]]; then
	write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
	write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
	write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
	write "/sys/kernel/debug/sched_features" "NO_WAKEUP_PREEMPTION"
	simple_bar
	kmsg1 "[*] APPLIED SCHEDULER FEATURES. "
	simple_bar
fi

# OP Tweaks
if [[ -d "/sys/module/opchain" ]]; then
	write "/sys/module/opchain/parameters/chain_on" "0"
	simple_bar
	kmsg1 "[*] DISABLED ONEPLUS CHAIN. "
	simple_bar
fi

# Tweak some kernel settings to improve overall performance.
write "/proc/sys/kernel/sched_child_runs_first" "0"
write "/proc/sys/kernel/sched_boost" "1"
write "/proc/sys/kernel/perf_cpu_time_max_percent" "25"
write "/proc/sys/kernel/sched_autogroup_enabled" "1"
write "/proc/sys/kernel/random/read_wakeup_threshold" "128"
write "/proc/sys/kernel/random/write_wakeup_threshold" "1024"
write "/proc/sys/kernel/random/urandom_min_reseed_secs" "90"
write "/proc/sys/kernel/sched_tunable_scaling" "0"
write "/proc/sys/kernel/sched_latency_ns" "$SCHED_PERIOD_THROUGHPUT"
write "/proc/sys/kernel/sched_min_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / SCHED_TASKS_THROUGHPUT))"
write "/proc/sys/kernel/sched_wakeup_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / 2))"
write "/proc/sys/kernel/sched_migration_cost_ns" "5000000"
write "/proc/sys/kernel/sched_min_task_util_for_colocation" "0"
write "/proc/sys/kernel/sched_nr_migrate" "128"
write "/proc/sys/kernel/sched_schedstats" "0"
write "/proc/sys/kernel/sched_sync_hint_enable" "0"
write "/proc/sys/kernel/sched_user_hint" "0"
write "/proc/sys/kernel/sched_conservative_pl" "0"
write "/proc/sys/kernel/printk_devkmsg" "off"

simple_bar
kmsg1 "[*] TWEAKED KERNEL SETTINGS. "
simple_bar

# Enable fingerprint boost.
if [[ -e "/sys/kernel/fp_boost/enabled" ]]; then
	write "/sys/kernel/fp_boost/enabled" "1"
	simple_bar
	kmsg1 "[*] ENABLED FINGERPRINT BOOST. "
	simple_bar
fi

# Set max clocks in gaming / performance profile.
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
	if [[ -e "${minclk}scaling_min_freq" ]]; then
		write "${minclk}scaling_min_freq" "$cpumxfreq"
		write "${minclk}scaling_max_freq" "$cpumxfreq"
	fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
	if [[ -e "${mnclk}scaling_min_freq" ]]; then
		write "${mnclk}scaling_min_freq" "$cpumxfreq"
		write "${mnclk}scaling_max_freq" "$cpumxfreq"
	fi
done

simple_bar
kmsg1 "[*] SET MIN AND MAX CPU CLOCKS. "
simple_bar

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]]; then
	write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "0"
	simple_bar
	kmsg1 "[*] NOT ALLOWED CPUIDLE TO USE DEEPEST STATE. "
	simple_bar
fi

# Enable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]]; then
	write "/sys/module/acpuclock_krait/parameters/boost" "Y"
	simple_bar
	kmsg1 "[*] ENABLED KRAIT VOLTAGE BOOST "
	simple_bar
fi

sync

# VM settings to improve overall user experience and performance.
write "/proc/sys/vm/drop_caches" "3"
write "/proc/sys/vm/dirty_background_ratio" "5"
write "/proc/sys/vm/dirty_ratio" "30"
write "/proc/sys/vm/dirty_expire_centisecs" "500"
write "/proc/sys/vm/dirty_writeback_centisecs" "3000"
write "/proc/sys/vm/page-cluster" "0"
write "/proc/sys/vm/stat_interval" "60"
write "/proc/sys/vm/swappiness" "100"
write "/proc/sys/vm/laptop_mode" "0"
write "/proc/sys/vm/vfs_cache_pressure" "80"

simple_bar
kmsg1 "[*] APPLIED VM TWEAKS "
simple_bar

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]; then
	write /sys/module/msm_thermal/vdd_restriction/enabled "0"
	write /sys/module/msm_thermal/core_control/enabled "0"
	write /sys/module/msm_thermal/parameters/enabled "N"
	simple_bar
	kmsg1 "[*] APPLIED THERMAL TWEAKS "
	simple_bar
fi

# Disable power efficient workqueue.
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]; then
	write "/sys/module/workqueue/parameters/power_efficient" "N" 
	simple_bar
	kmsg1 "[*] DISABLED POWER EFFICIENT WORKQUEUE. "
	simple_bar
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]; then
	write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
	simple_bar
	kmsg1 "[*] DISABLED MULTICORE POWER SAVINGS "
	simple_bar
fi

# Fix DT2W.
if [[ -e "/sys/touchpanel/double_tap" && -e "/proc/tp_gesture" ]]; then
	write "/sys/touchpanel/double_tap" "1"
	write "/proc/tp_gesture" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN "
	simple_bar
elif [[ -e "/proc/tp_gesture" ]]; then
	write "/proc/tp_gesture" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN "
	simple_bar
elif [[ -e "/sys/touchpanel/double_tap" ]]; then
	write "/sys/touchpanel/double_tap" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN "
	simple_bar
fi

# Enable touch boost on gaming and performance profile.
if [[ -e /sys/module/msm_performance/parameters/touchboost ]]; then
	write "/sys/module/msm_performance/parameters/touchboost" "1"
	simple_bar
	kmsg1 "[*] ENABLED TOUCH BOOST "
	simple_bar
elif [[ -e /sys/power/pnpmgr/touch_boost ]]; then
	write "/sys/power/pnpmgr/touch_boost" "1"
	simple_bar
	kmsg1 "[*] ENABLED TOUCH BOOST "
	simple_bar
fi


# Disable battery saver
if [[ -d "/sys/module/battery_saver" ]]; then
	write "/sys/module/battery_saver/parameters/enabled" "N"
	simple_bar
	kmsg1 "[*] DISABLED BATTERY SAVER "
	simple_bar
fi

# Enable KSM
if [[ -e "/sys/kernel/mm/ksm/run" ]]; then
	write "/sys/kernel/mm/ksm/run" "1"
	simple_bar
	kmsg1 "[*] ENABLED KSM."
	simple_bar
# Enable UKSM
elif [[ -e "/sys/kernel/mm/uksm/run" ]]; then
	write "/sys/kernel/mm/uksm/run" "1"
	simple_bar
	kmsg1 "[*] ENABLED UKSM."
	simple_bar
fi

if [[ "$dm" = "Mi A3" ]]; then
    chmod 666 /sys/class/power_supply/battery/voltage_max
    write "/sys/class/power_supply/battery/voltage_max" "4400000"
fi

simple_bar
kmsg1 "[*] TWEAKED BATTERY VOLTAGE. "
simple_bar

# Disable arch power
if [[ -e "/sys/kernel/sched/arch_power" ]]; then
	write "/sys/kernel/sched/arch_power" "0"
	simple_bar
	kmsg1 "[*] DISABLED ARCH POWER "
	simple_bar
fi

if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]]; then
	write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
	simple_bar
	kmsg1 "[*] DISABLED PM2 IDLE SLEEP MODE "
	simple_bar
fi

if [[ -e "/sys/class/lcd/panel/power_reduce" ]]; then
	write "/sys/class/lcd/panel/power_reduce" "0"
	simple_bar
	kmsg1 "[*] DISABLED LCD POWER REDUCE. "
	simple_bar
fi

if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]; then
	write "/sys/kernel/sched/gentle_fair_sleepers" "0"
	simple_bar
	kmsg1 "[*] DISABLED GENTLE FAIR SLEEPERS "
	simple_bar
fi

simple_bar
kmsg1 "[*] $ntsh_profile PROFILE APPLIED SUCCESS "
simple_bar

simple_bar
kmsg1 "[*] END OF EXECUTION: $(date)"
simple_bar
exit=$(date +%s)

exectime=$((exit - init))
simple_bar
kmsg1 "[*] EXECUTION DONE IN $exectime SECONDS. "
simple_bar

init=$(date +%s)
}

# Gaming Profile
gaming() {
init=$(date +%s)
# Checking mtk device
simple_bar
kmsg1 "[ * ] Checking device compatibility..."
chipset=$(grep "Hardware" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')
if [ -z "$chipset" ]; then
    chipset=$(getprop "ro.hardware")
fi

if [[ $chipset == *MT* ]] || [[ $chipset == *mt* ]]; then
    kmsg1 "[ ! ] Device is Mediatek, your device does not support this mode!"
    simple_bar
    su -lp 2000 -c "cmd notification post -S bigtext -t 'Nightshade' 'Tag' '[ERROR] Your device does not support this mode!'" > /dev/null
    exit
else
    kmsg1 "[ * ] Device is not Mediatek, continuing script..."
fi

# Kill background apps
while IFS= read -r pkg_nm; do
    [[ "$pkg_nm" != "com.nihil.nightshade" ]] && am force-stop "$pkg_nm"
done <<< "$(pm list packages -e -3 | grep package | cut -f 2 -d ":")" && kmsg1 "[ * ] Cleaned background apps. "

# Variable to ram usage
total_mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
free_mem=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')
buffers=$(cat /proc/meminfo | grep Buffers | awk '{print $2}')
cached=$(cat /proc/meminfo | grep "^Cached" | awk '{print $2}')
used_mem=$((total_mem - free_mem - buffers - cached))
used_percentage=$((used_mem * 100 / total_mem))

kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Nightshade's version: $nightshade "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Battery temperature: $temperature°C "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "-------------------------------------------------------"
simple_bar
kmsg1 "[*] ENABLING $ntsh_profile PROFILE... "
simple_bar

renice -n -5 $(pgrep system_server)
renice -n -5 $(pgrep com.miui.home)
renice -n -5 $(pgrep launcher)
renice -n -5 $(pgrep lawnchair)
renice -n -5 $(pgrep home)
renice -n -5 $(pgrep watchapp)
renice -n -5 $(pgrep trebuchet)
renice -n -1 $(pgrep dialer)
renice -n -1 $(pgrep keyboard)
renice -n -1 $(pgrep inputmethod)
renice -n -9 $(pgrep fluid)
renice -n -10 $(pgrep composer)
renice -n -1 $(pgrep com.android.phone)
renice -n -10 $(pgrep surfaceflinger)
renice -n 1 $(pgrep kswapd0)
renice -n 1 $(pgrep ksmd)
renice -n -6 $(pgrep msm_irqbalance)
renice -n -9 $(pgrep kgsl_worker)
renice -n 6 $(pgrep android.gms)

simple_bar
kmsg1 "[*] RENICED PROCESSES. "
simple_bar

# Disable perfd and mpdecision
stop perfd > /dev/null
stop mpdecision > /dev/null

simple_bar
kmsg1 "[*] DISABLED MPDECISION AND PERFD "
simple_bar

# Disable logd and statsd to reduce overhead.
stop logd
stop statsd

simple_bar
kmsg1 "[*] DISABLED STATSD AND LOGD "
simple_bar

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
	write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
	simple_bar
	kmsg1 "[*] TWEAKED STUNE BOOST "
	simple_bar
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
	if [[ -e "${corectl}/enable" ]]; then
		write "${corectl}/enable" "0"
	elif [[ -e "${corectl}/disable" ]]; then
		write "${corectl}/disable" "1"
	fi
done

simple_bar
kmsg1 "[*] DISABLED CORE CONTROL. "
simple_bar

# Caf CPU Boost
if [[ -d "/sys/module/cpu_boost" ]]; then
	write "/sys/module/cpu_boost/parameters/input_boost_freq" "0:$cpumxfreq 1:$cpumxfreq 2:$cpumxfreq 3:$cpumxfreq 4:$cpumxfreq 5:$cpumxfreq 6:$cpumxfreq 7:$cpumxfreq"
	write "/sys/module/cpu_boost/parameters/input_boost_ms" "128"
	simple_bar
	kmsg1 "[*] TWEAKED CAF INPUT BOOST "
	simple_bar
# CPU input boost
elif [[ -d "/sys/module/cpu_input_boost" ]]; then
	write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "128"
	write "/sys/module/cpu_input_boost/parameters/input_boost_freq_hp" "$cpumxfreq"
	write "/sys/module/cpu_input_boost/parameters/input_boost_freq_lp" "$cpumxfreq"
	simple_bar
	kmsg1 "[*] TWEAKED CPU INPUT BOOST"
	simple_bar
fi

# I/O Scheduler Tweaks.
for queue in /sys/block/*/queue/
do
	write "${queue}add_random" 0
	write "${queue}iostats" 0
	write "${queue}read_ahead_kb" 512
	write "${queue}nomerges" 2
	write "${queue}rq_affinity" 2
	write "${queue}nr_requests" 256
done

simple_bar
kmsg1 "[*] TWEAKED I/O SCHEDULER."
simple_bar

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
	avail_govs=$(cat "${cpu}scaling_available_governors")
	if [[ "$avail_govs" == *"schedutil"* ]]; then
		write "${cpu}scaling_governor" schedutil
		write "${cpu}schedutil/up_rate_limit_us" "500"
		write "${cpu}schedutil/down_rate_limit_us" "20000"
		write "${cpu}schedutil/pl" "1"
		write "${cpu}schedutil/iowait_boost_enable" "1"
		write "${cpu}schedutil/rate_limit_us" "20000"
		write "${cpu}schedutil/hispeed_load" "80"
		write "${cpu}schedutil/hispeed_freq" "$UINT_MAX"
	elif [[ "$avail_govs" == *"interactive"* ]]; then
		write "${cpu}scaling_governor" interactive
		write "${cpu}interactive/timer_rate" "20000"
		write "${cpu}interactive/boost" "1"
		write "${cpu}interactive/timer_slack" "20000"
		write "${cpu}interactive/use_migration_notif" "1"
		write "${cpu}interactive/ignore_hispeed_on_notif" "1"
		write "${cpu}interactive/use_sched_load" "1"
		write "${cpu}interactive/boostpulse" "0"
		write "${cpu}interactive/fastlane" "1"
		write "${cpu}interactive/fast_ramp_down" "0"
		write "${cpu}interactive/sampling_rate" "20000"
		write "${cpu}interactive/sampling_rate_min" "20000"
		write "${cpu}interactive/min_sample_time" "20000"
		write "${cpu}interactive/go_hispeed_load" "80"
		write "${cpu}interactive/hispeed_freq" "$UINT_MAX"
	fi
done

for cpu in /sys/devices/system/cpu/cpu*
do
	write "$cpu/online" "1"
done

simple_bar
kmsg1 "[* ]TWEAKED CPU "
simple_bar

# GPU Tweaks.
write "$gpu/throttling" "0"
write "$gpu/thermal_pwrlevel" "0"
write "$gpu/devfreq/adrenoboost" "2"
write "$gpu/force_no_nap" "1"
write "$gpu/bus_split" "0"
write "$gpu/devfreq/max_freq" $(cat "$gpu"/max_gpuclk)
write "$gpu/devfreq/min_freq" "$gpumx"
write "$gpu/default_pwrlevel" $(cat "$gpu"/max_pwrlevel)
write "$gpu/force_bus_on" "1"
write "$gpu/force_clk_on" "1"
write "$gpu/force_rail_on" "1"
write "$gpu/idle_timer" "1050"

if [[ -e "/proc/gpufreq/gpufreq_limited_thermal_ignore" ]]; then
	write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
fi

# Enable dvfs
if [[ -e "/proc/mali/dvfs_enable" ]]; then
	write "/proc/mali/dvfs_enable" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]]; then
	write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]; then
	write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
fi

simple_bar
kmsg1 "[*] TWEAKED GPU "
simple_bar

# Disable adreno idler
if [[ -d "/sys/module/adreno_idler" ]]; then
	write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
	simple_bar
	kmsg1 "[*] DISABLED ADRENO IDLER."
	simple_bar
fi

# Schedtune Tweaks
if [[ -d "/dev/stune/" ]]; then
	write "/dev/stune/background/schedtune.boost" "0"write "/dev/stune/background/schedtune.prefer_idle" "0"
	write "/dev/stune/foreground/schedtune.boost" "50"
	write "/dev/stune/foreground/schedtune.prefer_idle" "0"
	write "/dev/stune/rt/schedtune.boost" "0"
	write "/dev/stune/rt/schedtune.prefer_idle" "0"
	write "/dev/stune/top-app/schedtune.boost" "50"
	write "/dev/stune/top-app/schedtune.prefer_idle" "0"
	write "/dev/stune/schedtune.boost" "0"
	write "/dev/stune/schedtune.prefer_idle" "0"
	simple_bar
	kmsg1 "[*] APPLIED SCHEDTUNE TWEAKS "
	simple_bar
fi

# FS Tweaks.
if [[ -d "/proc/sys/fs" ]]; then
	write "/proc/sys/fs/dir-notify-enable" "0"
	write "/proc/sys/fs/lease-break-time" "20"
	write "/proc/sys/fs/leases-enable" "1"
	simple_bar
	kmsg1 "[*] APPLIED FS TWEAKS "
	simple_bar
fi

# Enable dynamic_fsync.
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]; then
	write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
	simple_bar
	kmsg1 "[*] ENABLED DYNAMIC FSYNC."
	simple_bar
fi

# Scheduler features.
if [[ -e "/sys/kernel/debug/sched_features" ]]; then
	write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
	write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
	write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
	write "/sys/kernel/debug/sched_features" "NO_WAKEUP_PREEMPTION"
	simple_bar
	kmsg1 "[*] APPLIED SCHEDULER FEATURES "
	simple_bar
fi

# OP Tweaks
if [[ -d "/sys/module/opchain" ]]; then
	write "/sys/module/opchain/parameters/chain_on" "0"
	simple_bar
	kmsg1 "[*] DISABLED ONEPLUS CHAIN "
	simple_bar
fi

# Tweak some kernel settings to improve overall performance.
write "/proc/sys/kernel/sched_child_runs_first" "0"
write "/proc/sys/kernel/sched_boost" "1"
write "/proc/sys/kernel/perf_cpu_time_max_percent" "25"
write "/proc/sys/kernel/sched_autogroup_enabled" "1"
write "/proc/sys/kernel/random/read_wakeup_threshold" "128"
write "/proc/sys/kernel/random/write_wakeup_threshold" "1024"
write "/proc/sys/kernel/random/urandom_min_reseed_secs" "90"
write "/proc/sys/kernel/sched_tunable_scaling" "0"
write "/proc/sys/kernel/sched_latency_ns" "$SCHED_PERIOD_THROUGHPUT"
write "/proc/sys/kernel/sched_min_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / SCHED_TASKS_THROUGHPUT))"
write "/proc/sys/kernel/sched_wakeup_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / 2))"
write "/proc/sys/kernel/sched_migration_cost_ns" "5000000"
write "/proc/sys/kernel/sched_min_task_util_for_colocation" "0"
write "/proc/sys/kernel/sched_nr_migrate" "128"
write "/proc/sys/kernel/sched_schedstats" "0"
write "/proc/sys/kernel/sched_sync_hint_enable" "0"
write "/proc/sys/kernel/sched_user_hint" "0"
write "/proc/sys/kernel/sched_conservative_pl" "0"
write "/proc/sys/kernel/printk_devkmsg" "off"

simple_bar
kmsg1 "[*] TWEAKED KERNEL SETTINGS "
simple_bar

# Enable fingerprint boost.
if [[ -e "/sys/kernel/fp_boost/enabled" ]]; then
	write "/sys/kernel/fp_boost/enabled" "1"
	simple_bar
	kmsg1 "[*] ENABLED FINGERPRINT BOOST "
	simple_bar
fi

# Set max clocks in gaming / performance profile.
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
	if [[ -e "${minclk}scaling_min_freq" ]]; then
		write "${minclk}scaling_min_freq" "$cpumxfreq"
		write "${minclk}scaling_max_freq" "$cpumxfreq"
	fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
	if [[ -e "${mnclk}scaling_min_freq" ]]
	then
		write "${mnclk}scaling_min_freq" "$cpumxfreq"
		write "${mnclk}scaling_max_freq" "$cpumxfreq"
	fi
done

simple_bar
kmsg1 "[*] SET MIN AND MAX CPU CLOCKS "
simple_bar

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]]; then
	write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "0"
	simple_bar
	kmsg1 "[*] NOT ALLOWED CPUIDLE TO USE DEEPEST STATE. "
	simple_bar
fi

# Enable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]]; then
	write "/sys/module/acpuclock_krait/parameters/boost" "Y"
	simple_bar
	kmsg1 "[*] ENABLED KRAIT VOLTAGE BOOST "
	simple_bar
fi

sync

# VM settings to improve overall user experience and performance.
write "/proc/sys/vm/drop_caches" "3"
write "/proc/sys/vm/dirty_background_ratio" "5"
write "/proc/sys/vm/dirty_ratio" "20"
write "/proc/sys/vm/dirty_expire_centisecs" "500"
write "/proc/sys/vm/dirty_writeback_centisecs" "3000"
write "/proc/sys/vm/page-cluster" "0"
write "/proc/sys/vm/stat_interval" "60"
write "/proc/sys/vm/swappiness" "100"
write "/proc/sys/vm/laptop_mode" "0"
write "/proc/sys/vm/vfs_cache_pressure" "200"

simple_bar
kmsg1 "[*] APPLIED VM TWEAKS."
simple_bar

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]; then
	write /sys/module/msm_thermal/vdd_restriction/enabled "0"
	write /sys/module/msm_thermal/core_control/enabled "0"
	write /sys/module/msm_thermal/parameters/enabled "N"
	simple_bar
	kmsg1 "[*] APPLIED THERMAL TWEAKS "
	simple_bar
fi

# Disable power efficient workqueue.
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]; then
	write "/sys/module/workqueue/parameters/power_efficient" "N" 
	simple_bar
	kmsg1 "[*] DISABLED POWER EFFICIENT WORKQUEUE. "
	simple_bar
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]; then
	write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
	simple_bar
	kmsg1 "[*] DISABLED MULTICORE POWER SAVINGS "
	simple_bar
fi

# Fix DT2W.
if [[ -e "/sys/touchpanel/double_tap" && -e "/proc/tp_gesture" ]]; then
	write "/sys/touchpanel/double_tap" "1"
	write "/proc/tp_gesture" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN "
	simple_bar
elif [[ -e "/proc/tp_gesture" ]]; then
	write "/proc/tp_gesture" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN "
	simple_bar
elif [[ -e "/sys/touchpanel/double_tap" ]]; then
	write "/sys/touchpanel/double_tap" "1"
	simple_bar
	kmsg1 "[*] FIXED DOUBLE TAP TO WAKEUP IF BROKEN "
	simple_bar
fi

# Enable touch boost on gaming and performance profile.
if [[ -e /sys/module/msm_performance/parameters/touchboost ]]; then
	write "/sys/module/msm_performance/parameters/touchboost" "1"
	simple_bar
	kmsg1 "[*] ENABLED TOUCH BOOST "
	simple_bar
elif [[ -e /sys/power/pnpmgr/touch_boost ]]; then
	write "/sys/power/pnpmgr/touch_boost" "1"
	simple_bar
	kmsg1 "[*] ENABLED TOUCH BOOST "
	simple_bar
fi


# Disable battery saver
if [[ -d "/sys/module/battery_saver" ]]; then
	write "/sys/module/battery_saver/parameters/enabled" "N"
	simple_bar
	kmsg1 "[*] DISABLED BATTERY SAVER "
	simple_bar
fi

# Enable KSM
if [[ -e "/sys/kernel/mm/ksm/run" ]]; then
	write "/sys/kernel/mm/ksm/run" "1"
	simple_bar
	kmsg1 "[*] ENABLED KSM."
	simple_bar
# Enable UKSM
elif [[ -e "/sys/kernel/mm/uksm/run" ]]; then
	write "/sys/kernel/mm/uksm/run" "1"
	simple_bar
	kmsg1 "[*] ENABLED UKSM."
	simple_bar
fi

if [[ "$dm" = "Mi A3" ]]; then
    chmod 666 /sys/class/power_supply/battery/voltage_max
    write "/sys/class/power_supply/battery/voltage_max" "4400000"
fi

simple_bar
kmsg1 "[*] TWEAKED BATTERY VOLTAGE. "
simple_bar

# Disable arch power
if [[ -e "/sys/kernel/sched/arch_power" ]]; then
	write "/sys/kernel/sched/arch_power" "0"
	simple_bar
	kmsg1 "[*] DISABLED ARCH POWER "
	simple_bar
fi

if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]]; then
	write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
	simple_bar
	kmsg1 "[*] DISABLED PM2 IDLE SLEEP MODE "
	simple_bar
fi

if [[ -e "/sys/class/lcd/panel/power_reduce" ]]; then
	write "/sys/class/lcd/panel/power_reduce" "0"
	simple_bar
	kmsg1 "[*] DISABLED LCD POWER REDUCE. "
	simple_bar
fi

if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]; then
	write "/sys/kernel/sched/gentle_fair_sleepers" "0"
	simple_bar
	kmsg1 "[*] DISABLED GENTLE FAIR SLEEPERS. "
	simple_bar
fi

simple_bar
kmsg1 "[*] $ntsh_profile PROFILE APPLIED WITH SUCCESS. "
simple_bar

simple_bar
kmsg1 "[*] END OF EXECUTION: $(date)"
simple_bar
exit=$(date +%s)

exectime=$((exit - init))
simple_bar
kmsg1 "[*] EXECUTION DONE IN $exectime SECONDS. "
simple_bar
}

# Thermal Profile
thermal() {
init=$(date +%s)

# Checking mtk device
simple_bar
kmsg1 "[ * ] Checking device compatibility..."
chipset=$(grep "Hardware" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')
if [ -z "$chipset" ]; then
    chipset=$(getprop "ro.hardware")
fi

if [[ $chipset == *MT* ]] || [[ $chipset == *mt* ]]; then
    kmsg1 "[ ! ] Device is Mediatek, your device does not support this mode!"
    simple_bar
    su -lp 2000 -c "cmd notification post -S bigtext -t 'Nightshade' 'Tag' '[ERROR] Your device does not support this mode!'" > /dev/null
    exit
else
    kmsg1 "[ * ] Device is not Mediatek, continuing script..."
fi

kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Nightshade's version: $nightshade "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Battery temperature: $temperature°C "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "-------------------------------------------------------"
kmsg1 "[*] ENABLING $ntsh_profile PROFILE.... "
simple_bar

renice -n -5 $(pgrep system_server)
renice -n -5 $(pgrep com.miui.home)
renice -n -5 $(pgrep launcher)
renice -n -5 $(pgrep lawnchair)
renice -n -5 $(pgrep home)
renice -n -5 $(pgrep watchapp)
renice -n -5 $(pgrep trebuchet)
renice -n -1 $(pgrep dialer)
renice -n -1 $(pgrep keyboard)
renice -n -1 $(pgrep inputmethod)
renice -n -9 $(pgrep fluid)
renice -n -10 $(pgrep composer)
renice -n -1 $(pgrep com.android.phone)
renice -n -10 $(pgrep surfaceflinger)
renice -n 1 $(pgrep kswapd0)
renice -n 1 $(pgrep ksmd)
renice -n -6 $(pgrep msm_irqbalance)
renice -n -9 $(pgrep kgsl_worker)
renice -n 6 $(pgrep android.gms)

simple_bar
kmsg1 "[*] RENICED PROCESSES. "
simple_bar

# Enable perfd and mpdecision
start perfd > /dev/null
start mpdecision > /dev/null

simple_bar
kmsg1 "[*] ENABLED MPDECISION AND PERFD "
simple_bar

# Disable logd and statsd to reduce overhead.
stop logd
stop statsd

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
	avail_govs=$(cat "${cpu}scaling_available_governors")
	if [[ "$avail_govs" == *"schedutil"* ]]; then
		write "${cpu}scaling_governor" schedutil
		write "${cpu}schedutil/up_rate_limit_us" "$((SCHED_PERIOD_BATTERY / 1000))"
		write "${cpu}schedutil/down_rate_limit_us" "$((4 * SCHED_PERIOD_BATTERY / 1000))"
		write "${cpu}schedutil/pl" "0"
		write "${cpu}schedutil/iowait_boost_enable" "0"
		write "${cpu}schedutil/rate_limit_us" "$((4 * SCHED_PERIOD_BATTERY / 1000))"
		write "${cpu}schedutil/hispeed_load" "99"
		write "${cpu}schedutil/hispeed_freq" "$cpumfreq"
	elif [[ "$avail_govs" == *"interactive"* ]]; then
		write "${cpu}scaling_governor" interactive
		write "${cpu}interactive/timer_rate" "50000"
		write "${cpu}interactive/boost" "0"
		write "${cpu}interactive/timer_slack" "50000"
		write "${cpu}interactive/use_migration_notif" "1" 
		write "${cpu}interactive/ignore_hispeed_on_notif" "1"
		write "${cpu}interactive/use_sched_load" "1"
		write "${cpu}interactive/boostpulse" "0"
		write "${cpu}interactive/fastlane" "1"
		write "${cpu}interactive/fast_ramp_down" "1"
		write "${cpu}interactive/sampling_rate" "50000"
		write "${cpu}interactive/sampling_rate_min" "75000"
		write "${cpu}interactive/min_sample_time" "75000"
		write "${cpu}interactive/go_hispeed_load" "99"
		write "${cpu}interactive/hispeed_freq" "$cpumfreq"
	fi
done

for cpu in /sys/devices/system/cpu/cpu*
do
	if [[ $percentage -le "20" ]]; then
		write "/sys/devices/system/cpu/cpu1/online" "0"
		write "/sys/devices/system/cpu/cpu2/online" "0"
		write "/sys/devices/system/cpu/cpu5/online" "0"
		write "/sys/devices/system/cpu/cpu6/online" "0"
	elif [[ $percentage -ge "20" ]]; then
		write "$cpu/online" "1"
	fi
done

simple_bar
kmsg1 "[*] APPLIED CPU TWEAKS"
simple_bar

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]; then
	write "/proc/sys/fs/dir-notify-enable" "0"
	write "/proc/sys/fs/lease-break-time" "20"
	write "/proc/sys/fs/leases-enable" "1"
	simple_bar
	kmsg1 "[*] APPLIED FS TWEAKS "
	simple_bar
fi
    
# Enable dynamic_fsync.
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]; then
	write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
	simple_bar
	kmsg1 "[*] ENABLED DYNAMIC FSYNC."
	simple_bar
fi

write "/dev/cpuset/audio-app/cpus" "0-1"
write "/dev/cpuset/top-app/cpus" "0-1,4-5"
write "/dev/cpuset/foreground/cpus" "0-1"
write "/dev/cpuset/background/cpus" "0-1,4-5" 
write "/dev/cpuset/system-background/cpus" "0-1"
write "/dev/cpuset/restricted/cpus" "0-1"

simple_bar
kmsg1 "[*] APPLIED CPUSET TWEAKS."
simple_bar

write "/sys/module/workqueue/parameters/power_efficient" "Y"

simple_bar
kmsg1 "[*] POWER EFFICIENT TWEAKS."
simple_bar

write "/sys/module/adreno_idler/paremeters/adreno_idler_active" "Y"

simple_bar
kmsg1 "[*] TWEAKED ADRENO IDLER."
simple_bar

write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "0"
write "/sys/module/cpu_input_boost/parameters/dynamic_stune_boost_duration" "0"
write "/sys/module/cpu_input_boost/parameters/dynamic_stune_boost" "0"
write "/dev/stune/schedtune.sched_boost" "0"
write "/dev/stune/schedtune.sched_boost_enabled" "0"
write "/dev/stune/top-app/schedtune.boost" "0"

simple_bar
kmsg1 "[*] CPU AND SCHEDTUNE OPTMIZED."
simple_bar

write "/sys/class/kgsl/kgsl-3d0/throttling" "1"
write "/sys/class/kgsl/kgsl-3d0/default_pwrlevel" "5"

simple_bar
kmsg1 "[*] ENABLED THROTTLING AND DEFAULT POWERLEVEL TWEAKS."
simple_bar

write "/sys/block/sda/queue/scheduler" "cfq"
write "/sys/block/sdb/queue/scheduler" "cfq"
write "/sys/block/sdc/queue/scheduler" "cfq"
write "/sys/block/sdd/queue/scheduler" "cfq"
write "/sys/block/sde/queue/scheduler" "cfq"
write "/sys/block/sdf/queue/scheduler" "cfq"

simple_bar
kmsg1 "[*] SDB SDA SDC SDD ADE SDF TWEAKED."
simple_bar

chmod 666 /sys/module/sync/parameters/fsync_enable
chown root /sys/module/sync/parameters/fsync_enable
write "/sys/module/sync/parameters/fsync_enable" "N"
chmod 666 /sys/kernel/dyn_fsync/Dyn_fsync_active
chown root /sys/kernel/dyn_fsync/Dyn_fsync_active
write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "0"
chmod 666 /sys/class/misc/fsynccontrol/fsync_enabled
chown root /sys/class/misc/fsynccontrol/fsync_enabled
write "/sys/class/misc/fsynccontrol/fsync_enabled" "0"
chmod 666 /sys/module/sync/parameters/fsync
chown root /sys/module/sync/parameters/fsync
write "/sys/module/sync/parameters/fsync" "0"

simple_bar
kmsg1 "[*] FSYNC AND DYN TWEAKED."
simple_bar

if [[ "$dm" = "Mi A3" ]]; then
    chmod 666 /sys/class/power_supply/battery/voltage_max
    write "/sys/class/power_supply/battery/voltage_max" "4000000"
fi

simple_bar
kmsg1 "[*] DECRESEAD BATTERY VOLTAGE. "
simple_bar

write "/proc/sys/fs/dir-notify-enable" "0"
write "/proc/sys/fs/lease-break-time" "15"
write "/proc/sys/fs/aio-max-nr" "131072"

simple_bar
kmsg1 "[*] FS KERNEL TWEAKED."
simple_bar

if [ -d "/sys/module/msm_thermal" ]; then
	write "/sys/module/msm_thermal/parameters/enabled" "Y"
	write "/sys/module/msm_thermal/core_control/enabled" "1"
	write "/sys/module/msm_thermal/vdd_restriction/enabled" "1"
	write "/sys/module/msm_thermal/core_control/cpus_offlined" "2"
fi

simple_bar
kmsg1 "[*] THERMAL SETTINGS APPLIED."
simple_bar

simple_bar
kmsg1 "[*] $ntsh_profile PROFILE APPLIED "
simple_bar

simple_bar
kmsg1 "[*] END OF EXECUTION: $(date)"
simple_bar
exit=$(date +%s)

exectime=$((exit - init))
simple_bar
kmsg1 "[*] EXECUTION DONE IN $exectime SECONDS. "
simple_bar
}

boot_run_once=false
ntsh_mode=$(getprop persist.nightshade.mode)
[ -z "$ntsh_mode" ] && setprop persist.nightshade.mode "3"

while true
do
	if $boot_run_once
	then
		[ "$(getprop persist.nightshade.mode)" == "$ntsh_mode" ] && continue
	else
		boot_run_once=true
	fi
	
	ntsh_mode=$(getprop persist.nightshade.mode)

	if [[ "$ntsh_mode" == "1" ]]; then
		ntsh_profilebr=Automático
	elif [[ "$ntsh_mode" == "2" ]]; then
		ntsh_profilebr=Bateria
	elif [[ "$ntsh_mode" == "3" ]]; then
		ntsh_profilebr=Balanceado
	elif [[ "$ntsh_mode" == "4" ]]; then
		ntsh_profilebr=Performance
	elif [[ "$ntsh_mode" == "5" ]]; then
		ntsh_profilebr=Gaming
	elif [[ "$ntsh_mode" == "6" ]]; then
		ntsh_profilebr=Thermal
	fi
	 	
	if [[ "$ntsh_mode" == "1" ]]; then
		ntsh_profile=Automatic
	elif [[ "$ntsh_mode" == "2" ]]; then
		ntsh_profile=Battery
	elif [[ "$ntsh_mode" == "3" ]]; then
		ntsh_profile=Balanced
	elif [[ "$ntsh_mode" == "4" ]]; then
		ntsh_profile=Performance
	elif [[ "$ntsh_mode" == "5" ]]; then
		ntsh_profile=Gaming
	elif [[ "$ntsh_mode" == "6" ]]; then
		ntsh_profile=Thermal
	fi

	case "$ntsh_profile" in
  	"Battery") {
			settings put global device_idle_constants inactive_to=60000,sensing_to=0,locating_to=0,location_accuracy=2000,motion_inactive_to=0,idle_after_inactive_to=0,idle_pending_to=60000,max_idle_pending_to=120000,idle_pending_factor=2.0,idle_to=900000,max_idle_to=21600000,idle_factor=2.0,max_temp_app_whitelist_duration=60000,mms_temp_app_whitelist_duration=30000,sms_temp_app_whitelist_duration=20000,light_after_inactive_to=10000,light_pre_idle_to=60000,light_idle_to=180000,light_idle_factor=2.0,light_max_idle_to=900000,light_idle_maintenance_min_budget=30000,light_idle_maintenance_max_budget=60000
			start thermal-engine
			battery
			am start -a android.intent.action.MAIN -e toasttext "Battery profile was successfully applied!" -n bellavita.toast/.MainActivity
			echo "3" > "/proc/sys/vm/drop_caches"
			exit
		};;

	  "Balanced") {
	  	  settings delete global device_idle_constants
			start thermal-engine
			balanced
			am start -a android.intent.action.MAIN -e toasttext "Balanced profile was successfully applied!" -n bellavita.toast/.MainActivity
	 	   echo "3"  > "/proc/sys/vm/drop_caches"	
	 	   exit
		};;

	  "Performance") {
			settings delete global device_idle_constants
			start thermal-engine
			performance
			am start -a android.intent.action.MAIN -e toasttext "Performance profile was successfully applied!" -n bellavita.toast/.MainActivity
			echo "3"  > "/proc/sys/vm/drop_caches"
			exit
		};;

	  "Gaming") {
			settings delete global device_idle_constants
			stop thermal-engine
			gaming
			am start -a android.intent.action.MAIN -e toasttext "Gaming profile was successfully applied!" -n bellavita.toast/.MainActivity
			echo "3" > "/proc/sys/vm/drop_caches"
			exit
		};;
	  
	  "Thermal") {
	  	  settings delete global device_idle_constants
			thermal
			am start -a android.intent.action.MAIN -e toasttext "Gaming profile was successfully applied!" -n bellavita.toast/.MainActivity
			echo "3" > "/proc/sys/vm/drop_caches"
			exit
	   };;
	 				
esac
done
