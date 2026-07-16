#!/system/bin/sh
# Module: Thermal Unlock & GPU Lock - FINAL RELEASE
# Designed for Xiaomi Pad 6 (pipa) - LineageOS A16 - KernelSU Next

# 1. Stop mi_thermald menggunakan init control (paling ampuh)
setprop ctl.stop mi_thermald 2>/dev/null
stop mi_thermald 2>/dev/null

# 2. Bunuh paksa semua proses yang tersisa (jaga-jaga)
pkill -9 -f mi_thermald 2>/dev/null
killall -9 mi_thermald 2>/dev/null

# 3. Beri jeda sebentar agar proses benar-benar mati
sleep 0.5

# 4. Lock GPU ke 683MHz (overclock maksimal)
GPU_PATH="/sys/class/kgsl/kgsl-3d0/devfreq"
if [ -d "$GPU_PATH" ]; then
    echo performance > $GPU_PATH/governor
    echo 683000000 > $GPU_PATH/min_freq
    echo 683000000 > $GPU_PATH/max_freq
    # target_freq terkadang read-only, abaikan error
    echo 683000000 > $GPU_PATH/target_freq 2>/dev/null
fi

# 5. Lock CPU ke performa maksimal
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1804800 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

echo performance > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 2419200 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq

echo performance > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
echo 3187200 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq

# 6. Nonaktifkan throttle baterai (opsional)
echo 0 > /sys/class/power_supply/battery/input_suspend 2>/dev/null
echo 0 > /sys/class/power_supply/battery/charge_control_limit_max 2>/dev/null

log -p i -t "ThermalUnlock" "GPU locked to 683MHz, mi_thermald successfully killed!"