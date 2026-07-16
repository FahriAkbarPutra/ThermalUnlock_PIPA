#!/system/bin/sh
# Modul Thermal Unlock - Xiaomi Pad 6 (pipa) LineageOS A16
# Berdasarkan analisis thermal_debug.txt

# 1. Hentikan service mi_thermald yang sedang berjalan
stop mi_thermald
killall -9 mi_thermald 2>/dev/null

# 2. Nonaktifkan binary mi_thermald (chmod 000) agar tidak bisa dijalankan ulang
#    File dummy di overlay akan menggantikan binary asli, tapi kita pastikan dengan chmod.
chmod 000 /system/vendor/bin/mi_thermald 2>/dev/null
chmod 000 /vendor/bin/mi_thermald 2>/dev/null

# 3. Lock GPU ke frekuensi tertinggi (683 MHz) dengan governor performance
GPU_DEVFREQ="/sys/class/kgsl/kgsl-3d0/devfreq"
if [ -d "$GPU_DEVFREQ" ]; then
    echo "performance" > $GPU_DEVFREQ/governor
    echo 683000000 > $GPU_DEVFREQ/max_freq
    echo 683000000 > $GPU_DEVFREQ/min_freq
    echo 683000000 > $GPU_DEVFREQ/target_freq 2>/dev/null
fi

# 4. Set CPU governor performance untuk semua cluster & set max freq
# Cluster 0 (little)
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1804800 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

# Cluster 4 (mid)
echo "performance" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 2419200 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq

# Cluster 7 (big)
echo "performance" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
echo 3187200 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq

# 5. Opsional: nonaktifkan throttle baterai (jika ada)
echo 0 > /sys/class/power_supply/battery/input_suspend 2>/dev/null
echo 0 > /sys/class/power_supply/battery/charge_control_limit_max 2>/dev/null

# 6. Log sukses
log -p i -t "ThermalUnlock" "Modul thermal unlock & GPU lock berhasil dijalankan."