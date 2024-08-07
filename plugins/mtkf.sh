#!/system/bin/sh
# This file is part of Mtkfest.
# Edited and adapted as a Nightshade plugin by haxislancelot @ Github.
#
# Mtkfest is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Mtkfest is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Mtkfest.  If not, see <https://www.gnu.org/licenses/>.
#
# Copyright (C) 2024 Rem01Gaming

cpu_cores="$(($(nproc --all) - 1))"
data_dir="/sdcard/.NTSH"
VERSION="v1.0.3"
LINE=$(stty size | awk '{print $2}')

if [ ! -f ${data_dir}/scheduler_switch_enabled ]; then
	touch ${data_dir}/scheduler_switch_enabled
	echo 0 >${data_dir}/scheduler_switch_enabled
fi

if [ ! -f ${data_dir}/idle_charging_enabled ]; then
	touch ${data_dir}/idle_charging_enabled
	echo 0 >${data_dir}/idle_charging_enabled
fi

if [ ! -f ${data_dir}/drop_cache_enabled ]; then
	touch ${data_dir}/drop_cache_enabled
	echo 0 >${data_dir}/drop_cache_enabled
fi

if [ ! -f ${data_dir}/apu_freq_lock ]; then
	touch ${data_dir}/apu_freq_lock
	echo 0 >${data_dir}/apu_freq_lock
fi

game_list_filter="com.example.gamelist1|com.example.gamelist2$(awk '!/^[[:space:]]*$/ && !/^#/ && !(/[[:alnum:]]+[[:space:]]+[[:alnum:]]+[[:space:]]+[[:alnum:]]+/) {sub("-e ", ""); printf "|%s", $0}' "${data_dir}/gamelist.txt")"

case $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors) in
*"schedplus"*) export default_cpu_gov="schedplus" ;;
*"sugov_ext"*) export default_cpu_gov="sugov_ext" ;;
*"walt"*) export default_cpu_gov="walt" ;;
*) export default_cpu_gov="schedutil" ;;
esac

clear() {
	echo -e "\033[H\033[2J\033[3J" # tput clear
}

write_val() {
	if [ -f $2 ]; then
		echo $1 >$2
	fi
}

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

performance_mode() {
	# CPU tweaks
	cpu="0"
	while [ $cpu -lt $cpu_cores ]; do
		cpu_dir="/sys/devices/system/cpu/cpu${cpu}"
		if [ -d "$cpu_dir" ]; then
			echo "performance" >"${cpu_dir}/cpufreq/scaling_governor"
		fi
		cpu="$((cpu + 1))"
	done

	# MTK Power and CCI mode
	write_val "1" /proc/cpufreq/cpufreq_cci_mode
	write_val "3" /proc/cpufreq/cpufreq_power_mode

	# EAS/HMP Switch
	if [[ $(cat ${data_dir}/scheduler_switch_enabled) == 1 ]]; then
		lock_val "0" /sys/devices/system/cpu/eas/enable
	fi

	# Idle charging
	if [[ $(cat ${data_dir}/idle_charging_enabled) == 1 ]]; then
		write_val "0 1" /proc/mtk_battery_cmd/current_cmd
	fi

	# Disable PPM (this is fire dumpster)
	write_val "0" /proc/ppm/enabled

	# GPU Frequency
	if [ ! $(uname -r | cut -d'.' -f1,2 | sed 's/\.//') -gt 500 ]; then
		gpu_freq="$(cat /proc/gpufreq/gpufreq_opp_dump | grep -o 'freq = [0-9]*' | sed 's/freq = //' | sort -nr | head -n 1)"
		echo "$gpu_freq" >/proc/gpufreq/gpufreq_opp_freq
	else
		gpu_freq="$(cat /proc/gpufreqv2/gpu_working_opp_table | awk '{print $3}' | sed 's/,//g' | sort -nr | head -n 1)"
		gpu_volt="$(cat /proc/gpufreqv2/gpu_working_opp_table | awk -v freq="$freq" '$0 ~ freq {gsub(/.*, volt: /, ""); gsub(/,.*/, ""); print}')"
		echo "${gpu_freq} ${gpu_volt}" >/proc/gpufreqv2/fix_custom_freq_volt
	fi

	# Disable GPU Power limiter
	if [ -f "/proc/gpufreq/gpufreq_power_limited" ]; then
		echo "ignore_batt_oc 1" >/proc/gpufreq/gpufreq_power_limited
		echo "ignore_batt_percent 1" >/proc/gpufreq/gpufreq_power_limited
		echo "ignore_low_batt 1" >/proc/gpufreq/gpufreq_power_limited
		echo "ignore_thermal_protect 1" >/proc/gpufreq/gpufreq_power_limited
		echo "ignore_pbm_limited 1" >/proc/gpufreq/gpufreq_power_limited
	fi

	# Disable battery current limiter
	write_val "stop 1" /proc/mtk_batoc_throttling/battery_oc_protect_stop

	# DRAM Frequency
	write_val "0" /sys/devices/platform/10012000.dvfsrc/helio-dvfsrc/dvfsrc_req_ddr_opp
	write_val "0" /sys/kernel/helio-dvfsrc/dvfsrc_force_vcore_dvfs_opp
	write_val "performance" /sys/class/devfreq/mtk-dvfsrc-devfreq/governor
	write_val "performance" /sys/devices/platform/soc/1c00f000.dvfsrc/mtk-dvfsrc-devfreq/devfreq/mtk-dvfsrc-devfreq/governor

	# Drop mem cache
	if [[ $(cat ${data_dir}/drop_cache_enabled) == 1 ]]; then
		echo "3" >/proc/sys/vm/drop_caches
	fi

	# Mediatek's APU freq
	if [[ $(cat ${data_dir}/apu_freq_lock) == 1 ]]; then
		write_val "0" /sys/module/mmdvfs_pmqos/parameters/force_step
	fi

	# Touchpanel
	tp_path="/proc/touchpanel"
	write_val "1" $tp_path/game_switch_enable
	write_val "0" $tp_path/oplus_tp_limit_enable
	write_val "0" $tp_path/oppo_tp_limit_enable
	write_val "1" $tp_path/oplus_tp_direction
	write_val "1" $tp_path/oppo_tp_direction
	
	# Eara Thermal
	write_val "0" /sys/kernel/eara_thermal/enable
}

normal_mode() {
	# CPU tweaks
	cpu="0"
	while [ $cpu -lt $cpu_cores ]; do
		cpu_dir="/sys/devices/system/cpu/cpu${cpu}"
		if [ -d "$cpu_dir" ]; then
			echo "$default_cpu_gov" >"${cpu_dir}/cpufreq/scaling_governor"
		fi
		cpu="$((cpu + 1))"
	done

	# Idle charging
	if [[ $(cat ${data_dir}/idle_charging_enabled) == 1 ]]; then
		write_val "0 0" /proc/mtk_battery_cmd/current_cmd
	fi

	# Enable back PPM
	write_val "1" /proc/ppm/enabled

	# MTK Power and CCI mode
	write_val "0" /proc/cpufreq/cpufreq_cci_mode
	write_val "0" /proc/cpufreq/cpufreq_power_mode

	# EAS/HMP Switch
	if [[ $(cat ${data_dir}/scheduler_switch_enabled) == 1 ]]; then
		lock_val "1" /sys/devices/system/cpu/eas/enable
	fi

	# GPU Frequency
	if [ ! $(uname -r | cut -d'.' -f1,2 | sed 's/\.//') -gt 500 ]; then
		echo "0" >/proc/gpufreq/gpufreq_opp_freq 2>/dev/null
	else
		echo "0 0" >/proc/gpufreqv2/fix_custom_freq_volt
	fi

	# Disable GPU Power limiter
	if [ -f "/proc/gpufreq/gpufreq_power_limited" ]; then
		echo "ignore_batt_oc 0" >/proc/gpufreq/gpufreq_power_limited
		echo "ignore_batt_percent 0" >/proc/gpufreq/gpufreq_power_limited
		echo "ignore_low_batt 0" >/proc/gpufreq/gpufreq_power_limited
		echo "ignore_thermal_protect 0" >/proc/gpufreq/gpufreq_power_limited
		echo "ignore_pbm_limited 0" >/proc/gpufreq/gpufreq_power_limited
	fi

	# Disable Power Budget management for new 5.x kernels
	write_val "stop 0" /proc/pbm/pbm_stop

	# Disable battery current limiter
	write_val "stop 0" /proc/mtk_batoc_throttling/battery_oc_protect_stop

	# DRAM Frequency
	write_val "-1" /sys/devices/platform/10012000.dvfsrc/helio-dvfsrc/dvfsrc_req_ddr_opp
	write_val "-1" /sys/kernel/helio-dvfsrc/dvfsrc_force_vcore_dvfs_opp
	write_val "simple_ondemand" /sys/class/devfreq/mtk-dvfsrc-devfreq/governor
	write_val "simple_ondemand" /sys/devices/platform/soc/1c00f000.dvfsrc/mtk-dvfsrc-devfreq/devfreq/mtk-dvfsrc-devfreq/governor

	# Drop mem cache
	if [[ $(cat ${data_dir}/drop_cache_enabled) == 1 ]]; then
		echo "1" >/proc/sys/vm/drop_caches
	fi

	# Mediatek's APU freq
	if [[ $(cat ${data_dir}/apu_freq_lock) == 1 ]]; then
		write_val "-1" /sys/module/mmdvfs_pmqos/parameters/force_step
	fi

	# Touchpanel
	tp_path="/proc/touchpanel"
	write_val "0" $tp_path/game_switch_enable
	write_val "1" $tp_path/oplus_tp_limit_enable
	write_val "1" $tp_path/oppo_tp_limit_enable
	write_val "0" $tp_path/oplus_tp_direction
	write_val "0" $tp_path/oppo_tp_direction
	
	# Eara Thermal
	write_val "1" /sys/kernel/eara_thermal/enable
}

powersave_mode() {
	normal_mode

	# CPU Power mode to low power
	write_val "1" /proc/cpufreq/cpufreq_power_mode

	# DRAM frequency
	write_val "$(cat /sys/devices/platform/10012000.dvfsrc/helio-dvfsrc/dvfsrc_opp_table | grep -o '\[[^]]*\]' | grep -oE '[+-]?[0-9]+' | sort -nr | head -n 1)" /sys/devices/platform/10012000.dvfsrc/helio-dvfsrc/dvfsrc_req_ddr_opp
	write_val "$(cat /sys/kernel/helio-dvfsrc/dvfsrc_opp_table | grep -o '\[[^]]*\]' | grep -oE '[+-]?[0-9]+' | sort -nr | head -n 1)" /sys/kernel/helio-dvfsrc/dvfsrc_force_vcore_dvfs_opp
	write_val "powersave" /sys/class/devfreq/mtk-dvfsrc-devfreq/governor
	write_val "powersave" /sys/devices/platform/soc/1c00f000.dvfsrc/mtk-dvfsrc-devfreq/devfreq/mtk-dvfsrc-devfreq/governor

	# Mediatek's APU freq
	if [[ $(cat ${data_dir}/apu_freq_lock) == 1 ]]; then
		write_val "$(cat /sys/module/mmdvfs_pmqos/parameters/dump_setting | grep -o '\[[^]]*\]' | grep -oE '[+-]?[0-9]+' | sort -n | tail -n 1)" /sys/module/mmdvfs_pmqos/parameters/force_step
	fi

	# GPU Frequency
	if [ ! $(uname -r | cut -d'.' -f1,2 | sed 's/\.//') -gt 500 ]; then
		gpu_freq="$(cat /proc/gpufreq/gpufreq_opp_dump | grep -o 'freq = [0-9]*' | sed 's/freq = //' | sort -n | head -n 1)"
		echo "$gpu_freq" >/proc/gpufreq/gpufreq_opp_freq
	else
		gpu_freq="$(cat /proc/gpufreqv2/gpu_working_opp_table | awk '{print $3}' | sed 's/,//g' | sort -n | head -n 1)"
		gpu_volt="$(cat /proc/gpufreqv2/gpu_working_opp_table | awk -v freq="$freq" '$0 ~ freq {gsub(/.*, volt: /, ""); gsub(/,.*/, ""); print}')"
		echo "${gpu_freq} ${gpu_volt}" >/proc/gpufreqv2/fix_custom_freq_volt
	fi
}

apply_mode() {
	if [[ "$1" == "1" ]] && [[ ! "$cur_mode" == "1" ]]; then
		export cur_mode="1"
		renice -n -20 -p $pid
		ionice -c 1 -n 0 -p $pid
		/system/bin/am start -a android.intent.action.MAIN -e toasttext "Boosting game $gamestart" -n bellavita.toast/.MainActivity
		performance_mode
	elif [[ "$1" == "2" ]] && [[ ! "$cur_mode" == "2" ]]; then
		export cur_mode="2"
		powersave_mode
	elif [[ "$1" == "0" ]] && [[ ! "$cur_mode" == "0" ]]; then
		export cur_mode="0"
		normal_mode
	fi
}

perf_common() {
	# CPU tweaks
	cpu=0
	while [ $cpu -lt $cpu_cores ]; do
		cpu_dir="/sys/devices/system/cpu/cpu${cpu}"
		if [ -d "$cpu_dir" ]; then
			echo 1 >${cpu_dir}/online
			chmod 0644 "${cpu_dir}/cpufreq/scaling_governor"
			chmod 000 "${cpu_dir}/cpufreq/cpuinfo_max_freq"
			chmod 000 "${cpu_dir}/cpu_capacity"
			chmod 000 "${cpu_dir}/topology/physical_package_id"
		fi
		cpu="$((cpu + 1))"
	done

	# Networking tweaks
	echo "cubic" >/proc/sys/net/ipv4/tcp_congestion_control
	echo "1" >/proc/sys/net/ipv4/tcp_low_latency
	echo "1" >/proc/sys/net/ipv4/tcp_ecn
	echo "3" >/proc/sys/net/ipv4/tcp_fastopen
	echo "1" >/proc/sys/net/ipv4/tcp_sack
	echo "0" >/proc/sys/net/ipv4/tcp_timestamps

	# Disable ccci debugging
	write_val 0 /sys/kernel/ccci/debug

	# Thermal governor
	chmod 0644 /sys/class/thermal/thermal_zone0/available_policies
	if [[ "$(cat /sys/class/thermal/thermal_zone0/available_policies)" == *step_wise* ]]; then
		for thermal in /sys/class/thermal/thermal_zone*; do
			chmod 0644 ${thermal}/policy
			echo "step_wise" >${thermal}/policy
		done
	fi

	# minimize printk logging
	lock_val "0 0 0 0" >/proc/sys/kernel/printk
	lock_val "0" >/sys/kernel/tracing/options/trace_printk

	# Push notification
	su -lp 2000 -c "/system/bin/cmd notification post -S bigtext -t \"MTKFEST\" "Tag$(date +%s)" \"Tweaks applied successfully\""
}

perfmon() {
	while true; do
		window="$(dumpsys window)"
		gamestart=$(echo "$window" | grep -E 'mCurrentFocus|mFocusedApp' | grep -Eo "$game_list_filter" | tail -n 1)
		screenoff=$(echo "$window" | grep mScreen | grep -Eo "false" | tail -n 1)
		if [[ ! -z "$gamestart" ]] && [[ ! "$screenoff" == "false" ]]; then
			pid="$(pidof $gamestart)"
			apply_mode "1" # Apply performance mode
		elif [[ "$(settings get global low_power_sticky)" == "1" ]]; then
			apply_mode "2" # Apply powersave mode
		else
			apply_mode "0" # Apply normal mode
		fi
		sleep 10
	done
}

menu_value_tune() {
	echo -e "\n${1}"
	echo -e "\nUse ( ↑ ↓ ) to enable or disable feature (1 = enable | 0 = disable)\nUse HOME or END to exit\n"

	number=$(cat ${2})

	print_number() {
		printf "\r%s%s\033[K" "value: " "$number   "
	}

	while true; do
		print_number
		read -r -sN3 t
		case "${t}" in
		*A*)
			if ((number <1)); then
				((number += 1))
			fi
			;;
		*B*)
			if ((number >0)); then
				((number -= 1))
			fi
			;;
		*) break ;;
		esac

		echo $number >${2} 2>/dev/null
	done
}

mtkfest_menu() {
	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m MTKFEST Tweak ${VERSION}$(yes " " | sed $((LINE - 21))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] Scheduler switch: $(cat ${data_dir}/scheduler_switch_enabled)"
		echo -e "   /        /\\     [ϟ] Idle Charging: $(cat ${data_dir}/idle_charging_enabled)"
		echo -e "  /        /  \\    [] Memory Cache drop: $(cat ${data_dir}/drop_cache_enabled)"
		echo -e " /        /    \\   [] APUs frequency lock: $(cat ${data_dir}/apu_freq_lock)"
		echo -e "/________/      \\  "
		echo -e "\\        \\      /  "
		echo -e " \\        \\    /   "
		echo -e "  \\        \\  /    "
		echo -e "   \\________\\/     "
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] MTKFEST Tweak Menu\033[0m\n"

		echo -e "1. Enable Scheduler switch\n2. Enable Idle Charging\n3. Enable Memory Cache drop\n4. APUs frequency lock\n5. Exit\n"
		echo -ne "Select the number: "
		read selected_prompt
		clear

		case $selected_prompt in
		1) menu_value_tune "Mediatek Scheduler switch\nAutomaticly switches scheduler to EAS/HMP/Hybrid according to mode, maybe not compatible with your kernel." "${data_dir}/scheduler_switch_enabled" ;;
		2) menu_value_tune "Enable Idle charging\nPassthrough power from charger to hardware without touching the battery while playing games." "${data_dir}/idle_charging_enabled" ;;
		3) menu_value_tune "Drop Memory cache\nCan help devices with low memory volume, can causes some trouble." "${data_dir}/drop_cache_enabled" ;;
		4) menu_value_tune "APUs frequency lock\nLock APUs to highest frequency while playing games, you maybe not need this." "${data_dir}/apu_freq_lock" ;;
		5) clear && plugins ;;
		esac

		clear
	done
}

case $1 in
"-s")
	perf_common
	perfmon # Start monitoring for games
	;;
*) mtkfest_menu ;;
esac
