#!/bin/sh

modprobe zram
SIZE=1536
echo $(($SIZE*1024*1024)) > /sys/block/zram0/disksize
echo $(($SIZE*1024*1024)) > /sys/block/zram1/disksize
echo $(($SIZE*1024*1024)) > /sys/block/zram2/disksize
echo $(($SIZE*1024*1024)) > /sys/block/zram3/disksize

echo lz4 > sys/block/zram0/comp_algorithm
echo lz4 > sys/block/zram1/comp_algorithm
mk2fs.ext -O journal /dev/zram0
mk2fs.ext -O journal /dev/zram1

moiunt /dev/zram0 /tmp/ramdisk
moiunt /dev/zram1 /mnt/ramdisk
