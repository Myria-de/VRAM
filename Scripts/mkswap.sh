#!/bin/bash
sleep 5
dd if=/dev/zero of=/tmp/vram/swapfile bs=1M count=2000 # Substitute 2000 with your target swapspace size in MiB
chmod 0600 /tmp/vram/swapfile
cd /tmp/vram
LOOPDEV=$(losetup -f)
truncate -s 2G swapfile # replace 2G with target swapspace size, has to be smaller than the allocated vramfs
losetup $LOOPDEV swapfile
mkswap $LOOPDEV
swapon $LOOPDEV
