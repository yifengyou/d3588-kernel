#!/bin/bash

set -ex
JOB=`sed -n "N;/processor/p" /proc/cpuinfo|wc -l`

# CROSS_COMPILE_ARM64=aarch64-none-linux-gnu-
GCC=`realpath ../gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu`
CROSS_COMPILE_ARM64=${GCC}/bin/aarch64-none-linux-gnu-
echo "using gcc: [${CROSS_COMPILE_ARM64}]"

export KERNEL_TARGET=d3588
#export RK_KERNEL_DTB=rk-kernel.dtb
RK_KERNEL_DEFCONFIG_FRAGMENT=

# kernel
# make ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE_ARM64 mrproper

make ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE_ARM64 ${KERNEL_TARGET}_defconfig
make ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE_ARM64 -j$JOB
# make ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE_ARM64 dtbs -j$JOB
# make ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE_ARM64 ${KERNEL_TARGET}.img

mkdir -p ../tools/
cp arch/arm64/boot/Image ../tools/

mkdir -p ../rockdev/modules
find . -name "*.ko" |xargs -i /bin/cp -a {} ../rockdev/modules/

ls -alh ../rockdev/modules/
md5sum ../rockdev/modules/*.ko

echo "All done! [$?]"

