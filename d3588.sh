#!/bin/bash

set -ex
JOB=`sed -n "N;/processor/p" /proc/cpuinfo|wc -l`

ARCH=`uname -m`
export KERNEL_TARGET=d3588

if [ X"${ARCH}" == X"aarch64" ] ; then
	GCC=""
	CROSS_COMPILE_ARM64=""
elif [ X"${ARCH}" == X"x86_64" ] ; then
	GCC=`realpath ../gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu`
	CROSS_COMPILE_ARM64=${GCC}/bin/aarch64-none-linux-gnu-
	echo "using gcc: [${CROSS_COMPILE_ARM64}]"
else
	echo "${ARCH} is not supported now!"
	exit 1
fi


# clean
# make ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE_ARM64 mrproper

# kernel
if [ -f .config ] ; then
	cp -a .config .config-bak
fi
make ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE_ARM64 ${KERNEL_TARGET}_defconfig
diff .config .config-bak
if [ $? -eq 0 ] ; then
	cp -a .config-bak .config
fi
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

