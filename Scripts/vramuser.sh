#!/bin/bash
if [ ! -d ~/VRAM ]; then
mkdir ~/VRAM
fi
vramfs ~/VRAM 2G -f
