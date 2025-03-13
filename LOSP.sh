#!/bin/bash
# crave run --no-patch -- "curl https://raw.githubusercontent.com/zeydann/Android-Scripts/refs/heads/main/LOSP.sh | bash"

# Remove Unnecessary Files
echo "===================================="
echo "     Removing Unnecessary Files"
echo "===================================="

dirs_to_remove=(
  "vendor/xiaomi"
  "kernel/xiaomi"
  "device/xiaomi"
  "device/xiaomi/sm6150-common"
  "vendor/xiaomi/sm6150-common"
  "hardware/xiaomi"
  "out/target/product/*/*zip"
  "out/target/product/*/*txt"
  "out/target/product/*/boot.img"
  "out/target/product/*/recovery.img"
  "out/target/product/*/super*img"
)

for dir in "${dirs_to_remove[@]}"; do
  [ -e "$dir" ] && rm -rf "$dir"
done

echo "===================================="
echo "  Removing Unnecessary Files Done"
echo "===================================="

# Initialize repo
echo "=============================================="
echo "         Cloning Manifest..........."
echo "=============================================="
if ! repo init -u https://github.com/Evolution-X/manifest -b vic-qpr1 --git-lfs; then
  echo "Repo initialization failed. Exiting."
  exit 1
fi
echo "=============================================="
echo "       Manifest Cloned successfully"
echo "=============================================="
# Sync
if ! /opt/crave/resync.sh || ! repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all); then
  echo "Repo sync failed. Exiting."
  exit 1
fi
echo "============="
echo " Sync success"
echo "============="

# Clone device trees and other dependencies
echo "=============================================="
echo "       Cloning Trees..........."
echo "=============================================="
git clone https://github.com/zeydann/android_device_xiaomi_mojito.git --depth 1 -b 15 device/xiaomi/mojito || { echo "Failed to clone device tree"; exit 1; }

git clone https://github.com/zeydann/android_device_xiaomi_sm6150-common.git --depth 1 -b 15 device/xiaomi/sm6150-common || { echo "Failed to clone common device tree"; exit 1; }

git clone https://github.com/zeydann/kernel_xiaomi_mojito.git --depth 1 -b 15 kernel/xiaomi/mojito || { echo "Failed to clone kernel"; exit 1; }

git clone https://gitlab.com/Sepidermn/android_vendor_xiaomi_mojito.git --depth 1 -b 15 vendor/xiaomi/mojito || { echo "Failed to clone vendor"; exit 1; }

git clone https://gitlab.com/Sepidermn/android_vendor_xiaomi_sm6150-common.git --depth 1 -b 15 vendor/xiaomi/sm6150-common || { echo "Failed to clone common vendor"; exit 1; }

git clone https://github.com/zeydann/android_hardware_xiaomi.git --depth 1 -b mojito hardware/xiaomi || { echo "Failed to clone hardware"; exit 1; }

 # remove frameworks/native
rm -rf frameworks/native

# add frameworks/native
git clone https://github.com/ViLelouch/frameworks_native.git -b 15 frameworks/native

# Export Environment Variables
echo "======= Exporting........ ======"
export SELINUX_IGNORE_NEVERALLOWS=true
echo "======= Export Done ======"

# Set up build environment
echo "====== Starting Envsetup ======="
. build/envsetup.sh || { echo "Envsetup failed"; exit 1; }
echo "====== Envsetup Done ======="


# Build ROM
echo "===================================="
echo "        Lunch Target, Start compiling"
echo "===================================="
lunch lineage_mojito-ap4a-userdebug || { echo "Build failed"; exit 1; }
m evolution