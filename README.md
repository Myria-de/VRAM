# VRAM
How to use VRAM as ramdisk

## Grafikkarte als Ramdisk nutzen
Vramfs: https://github.com/Overv/vramfs

Erforderlichen Pakete (Ubuntu 22.04 / Linux Mint 21):
```
sudo apt install build-essential clinfo libfuse3-dev opencl-dev opencl-clhpp-headers git
```
Quellcode herunterladen:
```
mkdir ~/src && cd ~/src
git clone https://github.com/Overv/vramfs.git
```

"~/src/vramfs/src/vramfs.cpp" bearbeiten:
```
fuse_opt_add_arg(&args, "-oallow_other");
```
Vramfs compilieren:
```
cd vramfs
make
sudo cp bin/vramfs /usr/local/bin
```

"/etc/fuse.conf" bearbeiten,  Kommentarzeichen vor „user_allow_other“ entfernen.

Textdatei "90-vramfs.conf" im Ordner "/etc/security" erstellen:
```
[User] hard memlock unlimited
[User] soft memlock unlimited
[User] hard rtprio unlimited
[User] soft rtprio unlimited
```
Den Platzhalter „[User]“ ersetzen Sie durch Ihren Benutzernamen. Starten Sie Linux anschließend neu.

Erstellen Sie beispielsweise den Ordner „VRAM“ in Ihrem Home-Verzeichnis. Eine VRAM-Ramdisk mit 2 GB lässt sich jetzt im Terminal mit 
```
vramfs ~/VRAM 2G -f
```
erstellen.

Die Ramdisk lässt sich in einem anderen Terminal mit
```
fusermount -u ~/VRAM
```
entladen, was auch Vramfs beendet.

Mit Kdiskmark (https://github.com/JonMagon/KDiskMark) lässt sich die Geschwindigkeit von Festplatten, SSDs und Ramdisks messen. 

## Vramfs als Systemd-Dienst starten
Vramfs im Hintergrund starten:
```
nohup vramfs ~/VRAM 2G -f &
```
