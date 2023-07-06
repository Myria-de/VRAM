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
Erstellen Sie dafür die Textdatei „/etc/systemd/system/vramuser.service“ (siehe Ordner "Scripts").Tragen Sie hinter „User=“ und „Group=“ jeweils Ihren Benutzernamen ein. Zum Dienst gehört das Bash-Script „vramuser.sh“ in Ihrem Home-Verzeichnis

Aktivieren und starten Sie den Dienst mit
```
sudo systemctl enable vramuser.service
sudo systemctl start vramuser.service
```
## Die Ramdisk sinnvoll einsetzen
Bei Firefox rufen Sie die Konfiguration mit „about:config“ auf und tragen in die Eingabezeile
```
browser.cache.disk.parent_directory
```
ein. Wählen Sie die Option „String“, klicken Sie auf die „+“-Schaltfläche und geben Sie den gewünschten Pfad ein, beispielsweise „/home/[User]/VRAM“.

Bei Google Chrome erstellen Sie einen Symlink vom Cache-Verzeichnis auf die Ramdisk. Schließen Sie den Browser und führen Sie im Terminal diese zwei Befehlszeilen aus:
```
mv ~/.cache/google-chrome ~/.cache/google-chrome.bak
ln -s ~/VRAM .~/cache/google-chrome
```
## VRAM als Swapspeicher verwenden
Erstellen Sie die Textdatei „/etc/systemd/system/vramswap.service“ (siehe Ordner "Scripts") und kopieren Sie die Bash-Scripts „mkswap.sh“ und "mkvram.sh" in den Ordner "/root". Passen Sie in allen Scripten die Werte für die Größe der Ramdisk und des Swapspeichers an.
Aktivieren und starten Sie den Dienst mit
```
sudo systemctl enable vramswap.service
sudo systemctl start vramswap.service
```
## Komprimierter Swapspeicher in der Ramdisk

Zur Installation verwenden Sie im Terminal diese Befehlszeile:
```
sudo apt install zram-config
```
Danach starten Sie Linux neu oder Sie aktivieren den Dienst mit
```
sudo systemctl start zram-config
```
Mit dem Befehl
```
swapon
```
lässt sich kontrollieren, dass eine neue Swap-Partition erstellt wurde. Mit dem Tool zramctl kann man die Konfiguration ebenfalls prüfen und bei Bedarf ändern (siehe man zramctl).

## Universelle Ramdisk (Hauptspeicher) als Datenspeicher
Eine Ramdisk ist im Handumdrehen erstellt. Idealerweise liegt dieser Speicher zentral, etwa im Home-Verzeichnis oder gleich auf dem Desktop. Erstellen Sie mit
```
mkdir ~/Schreibtisch/Ramdisk
```
den Zielordner und die Ramdisk mit
```
sudo mount -t tmpfs -o size=2000M ramdisk ~/Schreibtisch/Ramdisk
```
Der Befehl erzeugt im Order „Ramdisk“ Platz für maximal zwei GB Daten. Die angegebene Kapazität wird dynamisch abgezweigt - je nach Bedarf bis zum angegebenen Maximum. Mit 
```
sudo umount ~/Schreibtisch/Ramdisk
```
lässt sich die Ramdisk wieder entfernen. Darin gespeicherte Daten gehen verloren.
Dauerhaft lässt ich eine Ramdisk über die Datei „fstab“ einrichten:
```
sudo nano /etc/fstab
```
Hier fügen Sie die Zeile (Beispiel)
```
tmpfs /home/[User]/Schreibtisch/Ramdisk tmpfs defaults,size=40%,mode=1777 0 0
```
hinzu, den Platzhalte „[User]“ ersetzen Sie durch Ihren Benutzernamen. „40%“ legt die Größe der Ramdisk auf 40 Prozent des verfügbaren RAM fest. Mit
```
sudo mount -a
```
prüfen Sie, ob Linux den neuen Eintrag korrekt auswertet. Beim nächsten Systemstart wird die Ramdisk automatisch erstellt.

## Logdateien im RAM speichern
Log2Ram: https://github.com/azlux/log2ram

Backup der Log-Ordners:
```
sudo tar cvjf /Backup/log.tar.bz2 /var/log
```
Danach löschen Sie nur die großen Dateien und .gz-Archive oder einfach den kompletten Inhalt des Ordners. Vor allem der Inhalt von "/var/log/journal" kann auf mehrere GB anwachsen. Um das zu verhindern, bearbeiten Sie die Datei "/etc/systemd/journald.conf". Unterhalb von "[Journal]" entfernen Sie das Kommentarzeichen vor "SystemMaxUse=" und tragen dahinter beispielsweise "50M" ein. Danach starten Sie
```
sudo journalctl --vacuum-size=32M
```
was die Größe sofort reduziert. Mit
```
sudo du -h /var/log
```
ermitteln Sie die Größe des Ordners, der jetzt nicht deutlich weniger als 120 MB enthalten sollte.

**Log2Ram installieren:** Zur Installation richten Sie die Voraussetzungen ein:
```
sudo apt install rsync git
```
Danach wechseln Sie in ein Arbeitsverzeichnis, beispielsweise „~/src“ und starten darin
```
git clone https://github.com/azlux/log2ram.git
```
Rufen Sie das Installationsscript mit
```
cd log2ram
sudo ./install.sh
```
auf. Danach ist ein Reboot nötig, um Log2Ram zu aktivieren. Nach dem Boot überprüft die Eingabe von
```
sudo systemctl status log2ram
```
den korrekten Start von Log2Ram und
```
df -h
```
zeigt die Größe sowie der Auslastung der angelegten Ramdisk namens "log2ram" an (standardmäßig 128 MB). Eine Änderung der Konfiguration ist nur nötig, wenn der Dienst nicht startet weil die Ramdisk zu klein bemessen ist. Erscheint beim Status "RAM disk for /var/hdd.log/ too small", dann passt der Inhalt von „/var/log“ nicht in die Ramdisk. Löschen Sie weitere Dateien oder tragen Sie in der Datei "/etc/log2ram.conf" einen größeren Wert hinter "SIZE=" ein und starten Linux neu.


