#!/system/bin/sh
# Modified by @donottelmyname, on Telegram.
# Credit to @raidenkk on Telegram, because without him this script would not be possible.

# Logs
RLOG=/sdcard/.GTKS/griffithTweaks.log

if [[ -e $RLOG ]]; then
	rm $RLOG
fi

if [[ -d "/sdcard/.GTKS" ]]; then
	touch griffithTweaks.log
else
	mkdir /sdcard/.GTKS
	touch griffithTweaks.log
fi

# Log in white and continue (unnecessary)
kmsg() {
	echo -e "[*] $@" >> $RLOG
	echo -e "[*] $@"
}

kmsg1() {
	echo -e "$@" >> $RLOG
	echo -e "$@"
}

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

# Bars
simple_bar() {
    kmsg1 "------------------------------------------------------"
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

# Variable to Griffith's version
griffv=$(echo "v1.0-beta2")

# Variable to ram usage
total_mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
free_mem=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')
buffers=$(cat /proc/meminfo | grep Buffers | awk '{print $2}')
cached=$(cat /proc/meminfo | grep "^Cached" | awk '{print $2}')
used_mem=$((total_mem - free_mem - buffers - cached))
used_percentage=$((used_mem * 100 / total_mem))

# Battery Profile
battery() {
	init=$(date +%s)

kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Griffith's version: $griffv "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "-------------------------------------------------------"
simple_bar
kmsg1 "[*] ENABLING $gtks_profile PROFILE... "
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
    simple_bar
    kmsg1 "[*] DECRESEAD BATTERY VOLTAGE. "
fi

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
kmsg1 "[*] $gtks_profile PROFILE APPLIED WITH SUCCESS. "
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

# Balanced Profile
balanced() {
	init=$(date +%s)
     	
kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Griffith's version: $griffv "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "------------------------------------------------------"
simple_bar
kmsg1 "[*] ENABLING $gtks_profile PROFILE... "
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
    simple_bar
    kmsg1 "[*] DECRESEAD BATTERY VOLTAGE. "
fi

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
kmsg1 "[*] $gtks_profile PROFILE APPLIED WITH SUCCESS "
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

# Performance Profile
performance() {
	init=$(date +%s)
     	
kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Griffith's version: $griffv "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "-------------------------------------------------------
                                                 "
simple_bar
kmsg1 "[*] ENABLING $gtks_profile PROFILE..."
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
    write "/sys/class/power_supply/battery/voltage_max" "4200000"
    simple_bar
    kmsg1 "[*] DECRESEAD BATTERY VOLTAGE. "
fi

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
kmsg1 "[*] $gtks_profile PROFILE APPLIED SUCCESS "
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

# Variable to ram usage
total_mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
free_mem=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')
buffers=$(cat /proc/meminfo | grep Buffers | awk '{print $2}')
cached=$(cat /proc/meminfo | grep "^Cached" | awk '{print $2}')
used_mem=$((total_mem - free_mem - buffers - cached))
used_percentage=$((used_mem * 100 / total_mem))

# Kill background apps
while IFS= read -r pkg_nm; do
    [[ "$pkg_nm" != "com.tweaker.griffith" ]] && am force-stop "$pkg_nm"
done <<< "$(pm list packages -e -3 | grep package | cut -f 2 -d ":")"

kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Griffith's version: $griffv "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "-------------------------------------------------------
                                                 "
simple_bar
kmsg1 "[*] ENABLING $gtks_profile PROFILE... "
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
    simple_bar
    kmsg1 "[*] DECRESEAD BATTERY VOLTAGE. "
fi

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
kmsg1 "[*] $gtks_profile PROFILE APPLIED WITH SUCCESS. "
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
	
kmsg1 "----------------------- Info -----------------------"
kmsg1 "[ * ] Date of execution: $(date) "
kmsg1 "[ * ] Griffith's version: $griffv "
kmsg1 "[ * ] Kernel: $(uname -a) "
kmsg1 "[ * ] SOC: $mf, $soc "
kmsg1 "[ * ] SDK: $sdk "
kmsg1 "[ * ] CPU governor: $CPU_GOVERNOR "
kmsg1 "[ * ] CPU aarch: $aarch "
kmsg1 "[ * ] GPU governor: $GPU_GOVERNOR "
kmsg1 "[ * ] Android version: $arv "
kmsg1 "[ * ] GPU model: $GPU_MODEL "
kmsg1 "[ * ] Device: $dm  "
kmsg1 "[ * ] Battery charge level: $percentage% "
kmsg1 "[ * ] Device total RAM: $totalram MB "
kmsg1 "[ * ] RAM usage: $used_percentage% "
kmsg1 "-------------------------------------------------------"

simple_bar
kmsg1 "[*] ENABLING $gtks_profile PROFILE.... "
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
    simple_bar
    kmsg1 "[*] DECRESEAD BATTERY VOLTAGE. "
fi

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
kmsg1 "[*] $gtks_profile PROFILE APPLIED "
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
gtks_mode=$(getprop persist.griffithtweaks.mode)
[ -z "$gtks_mode" ] && setprop persist.griffithtweaks.mode "3"

while true
do
	sleep 3
	if $boot_run_once
	then
		[ "$(getprop persist.griffithtweaks.mode)" == "$gtks_mode" ] && continue
	else
		boot_run_once=true
	fi

	gtks_mode=$(getprop persist.griffithtweaks.mode)

	if [[ "$gtks_mode" == "1" ]]; then
		gtks_profilebr=Automático
	elif [[ "$gtks_mode" == "2" ]]; then
		gtks_profilebr=Bateria
	elif [[ "$gtks_mode" == "3" ]]; then
		gtks_profilebr=Balanceado
	elif [[ "$gtks_mode" == "4" ]]; then
		gtks_profilebr=Performance
	elif [[ "$gtks_mode" == "5" ]]; then
		gtks_profilebr=Gaming
	elif [[ "$gtks_mode" == "6" ]]; then
		gtks_profilebr=Thermal
	fi
	 	
	if [[ "$gtks_mode" == "1" ]]; then
		gtks_profile=Automatic
	elif [[ "$gtks_mode" == "2" ]]; then
		gtks_profile=Battery
	elif [[ "$gtks_mode" == "3" ]]; then
		gtks_profile=Balanced
	elif [[ "$gtks_mode" == "4" ]]; then
		gtks_profile=Performance
	elif [[ "$gtks_mode" == "5" ]]; then
		gtks_profile=Gaming
	elif [[ "$gtks_mode" == "6" ]]; then
		gtks_profile=Thermal
	fi

	case "$gtks_profile" in
  	"Battery") {
			settings put global device_idle_constants inactive_to=60000,sensing_to=0,locating_to=0,location_accuracy=2000,motion_inactive_to=0,idle_after_inactive_to=0,idle_pending_to=60000,max_idle_pending_to=120000,idle_pending_factor=2.0,idle_to=900000,max_idle_to=21600000,idle_factor=2.0,max_temp_app_whitelist_duration=60000,mms_temp_app_whitelist_duration=30000,sms_temp_app_whitelist_duration=20000,light_after_inactive_to=10000,light_pre_idle_to=60000,light_idle_to=180000,light_idle_factor=2.0,light_max_idle_to=900000,light_idle_maintenance_min_budget=30000,light_idle_maintenance_max_budget=60000
			battery
			su -lp 2000 -c "cmd notification post -S bigtext -t 'Griffith' 'Tag' 'Battery profile was successfully applied!'" > /dev/null
			echo "3" > "/proc/sys/vm/drop_caches"
			exit
		};;

	  "Balanced") {
			settings delete global device_idle_constants
	 		balanced
	 		su -lp 2000 -c "cmd notification post -S bigtext -t 'Griffith' 'Tag' 'Balanced profile was successfully applied!'" > /dev/null
	 		echo "3"  > "/proc/sys/vm/drop_caches"
	 		exit
		};;

	  "Performance") {
			settings delete global device_idle_constants
			performance
			su -lp 2000 -c "cmd notification post -S bigtext -t 'Griffith' 'Tag' 'Performance profile was successfully applied!'" > /dev/null
			echo "3"  > "/proc/sys/vm/drop_caches"
			exit
		};;

	  "Gaming") {
			settings delete global device_idle_constants
			gaming
			su -lp 2000 -c "cmd notification post -S bigtext -t 'Griffith' 'Tag' 'Gaming profile was successfully applied!'" > /dev/null
			echo "3" > "/proc/sys/vm/drop_caches"
			exit
		};;
	  
	  "Thermal") {
                        settings delete global device_idle_constants
			thermal
			su -lp 2000 -c "cmd notification post -S bigtext -t 'Griffith' 'Tag' 'Thermal profile was successfully applied!'" > /dev/null
			echo "3" > "/proc/sys/vm/drop_caches"
			exit
	   };;
	 				
esac
done
