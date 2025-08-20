#!/bin/sh
#
while true; do
	sleep 10;
	bat_status=$(cat /sys/class/power_supply/BAT0/status)
	while [ $bat_status != 'Full' ]; do
		while [ $bat_status == 'Charging' ]; do
			bat_status=$(cat /sys/class/power_supply/BAT0/status)
			time=$(date +"%e %b %H:%M:%S");
			charge=$(cat /sys/class/power_supply/BAT0/energy_now);
			bat_percent=$(cat /sys/class/power_supply/BAT0/capacity);
			echo "$time $bat_status $bat_percent $charge" >> $HOME/battery_charge_log;
			sleep 10;
		done;
		
		while [ $bat_status == 'Discharging' ]; do
			bat_status=$(cat /sys/class/power_supply/BAT0/status)
			time=$(date +"%e %b %H:%M:%S");
			charge=$(cat /sys/class/power_supply/BAT0/energy_now);
			bat_percent=$(cat /sys/class/power_supply/BAT0/capacity);
			echo "$time $bat_status $bat_percent $charge" >> $HOME/battery_discharge_log;
			sleep 10;
		done;
	done;
done;
