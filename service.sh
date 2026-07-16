#!/system/bin/sh
# Module: Thermal Unlock - LATE EXECUTION (Fix untuk init restart)
# Dijalankan saat late_start, setelah semua service init berjalan.

# 1. Bunuh mi_thermald yang sedang berjalan
stop mi_thermald 2>/dev/null
pkill -9 -f mi_thermald 2>/dev/null
killall -9 mi_thermald 2>/dev/null

# 2. Buat file dummy dan timpa binary asli dengan bind mount (pencegah restart)
DUMMY_PATH="/data/adb/modules/thermalunlock_pipa/dummy_bin"
touch $DUMMY_PATH
chmod 000 $DUMMY_PATH
mount -o bind $DUMMY_PATH /system/vendor/bin/mi_thermald 2>/dev/null
mount -o bind $DUMMY_PATH /vendor/bin/mi_thermald 2>/dev/null

# 3. Lock GPU ke 683MHz (langsung eksekusi, tanpa menunggu)
echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor
echo 683000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq
echo 683000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq
echo 683000000 > /sys/class/kgsl/kgsl-3d0/devfreq/target_freq 2>/dev/null

# 4. Lock CPU
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1804800 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo performance > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 2419200 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
echo performance > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
echo 3187200 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq

# 5. Nonaktifkan throttle baterai
echo 0 > /sys/class/power_supply/battery/input_suspend 2>/dev/null
echo 0 > /sys/class/power_supply/battery/charge_control_limit_max 2>/dev/null

log -p i -t "ThermalUnlock" "service.sh: mi_thermald killed & bind-mounted, GPU locked to 683MHz!"