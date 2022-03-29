#!/bin/sh

modprobe zram
size=1536
echo $((size*1024*1024)) > /sys/block/zram0/disksize
echo $((size*1024*1024)) > /sys/block/zram1/disksize
echo $((size*1024*1024)) > /sys/block/zram2/disksize
echo $((size*1024*1024)) > /sys/block/zram3/disksize

echo lz4 > sys/block/zram0/comp_algorithm
echo lz4 > sys/block/zram1/comp_algorithm
mk2fs.ext -O journal /dev/zram0
mk2fs.ext -O journal /dev/zram1

mount /dev/zram0 /tmp/ramdisk
mount /dev/zram1 /mnt/ramdisk
