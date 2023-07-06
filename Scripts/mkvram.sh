#!/bin/bash
if [ ! -d /tmp/vram ]; then
mkdir /tmp/vram
fi
vramfs /tmp/vram 2G -f
