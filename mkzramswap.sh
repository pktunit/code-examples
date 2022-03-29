#!/bin/sh
sudo modprobe zram num_devices=2
sudo cat /sys/block/zram0/max_comp_streams
sudo cat /sys/block/zram1/max_comp_streams

sudo mkswap --label zram0 /dev/zram0
echo lz4 | sudo tee /sys/block/zram0/comp_algorithm
echo 2G | sudo tee /sys/block/zram0/disksize
sudo swapon zram0
sudo mke2fs -t ext4 /dev/zram0
#sudo e2fsck -p -l /dev/zram0

sudo mkswap --label zram1 /dev/zram1
echo lz4 | sudo tee /sys/block/zram1/comp_algorithm
echo 2G | sudo tee /sys/block/zram1/disksize
sudo swapon zram1
sudo mke2fs -t ext4 /dev/zram1
sudo e2fsck -p -l /dev/zram1

#sudo echo 1 > /sys/block/zram0/reset
#sudo echo 1 > /sys/block/zram1/reset
#sudo modprobe -r zram
