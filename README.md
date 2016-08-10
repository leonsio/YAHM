
Falls Sie dieses Projekt unterstützen möchten, würde ich mich über einen Pull-Request oder eine Spende: <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9WRZHSCVYL6XL"><img style="padding:0;" width=74 height=21  src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif" alt="Donate!" / border="0"></a> freuen.

# YAHM
**Yet Another Homematic Management** - Skripte zur Einrichtung der Homematic CCU2 Oberfläche in einem LXC Kontainer unter Debian basierten Distribution auf ARM-Basis (x86 experimentell).

Die Arbeit/Idee basiert auf der Arbeit von [bullshit](https://github.com/bullshit/lxccu) bzw. des [LXCCU](http://www.lxccu.com) Projektes.


**Bitte lesen Sie diese Dokumentation bis zum Ende durch, bevor Sie die Anwendung installieren**


**Wesentliche Unterschiede zu LXCCU:**
+ Unterstützung von Debian/Raspbian Jessie
+ Unterstützung aktueller CCU2 Firmware (ältere Versionen lassen sich nicht länger von Homematic Seite runterladen, somit ist LXCCU aktuell leider unbenutzbar)
+ Die Installation kann manuell gesteuert werden und wird nicht durch DEB-Installer vorgenommen
+ Modulare Bauweise, es können beliebige Module eingebunden werden
+ Kann mit geringer Anpassung auf anderen Betriebssystemen portiert werden

Zur Zeit wurde dieses Skript auf folgender Hardware erfolgreich getestet:
* Rapsberry Pi 2/3
* Odroid XU4
* Orange PI Plus 2
* Experimentell: x86 

Folgende Betrebssysteme werden aktuel unterstützt:
* Debian Jessie (ARM/x86)
* Raspbian Jessie
* Experimentell: Armbian
* Experimentell: Ubuntu 16.04

_(Die Einrichtung des HM-MOD-RPI-PCB erfolgt automatisiert ausschließlich auf Rapsberry Pi)_

**Weitere Informationen und Anleitungen können dem [Wiki](https://github.com/leonsio/YAHM/wiki) bzw. dem [Homematic-Forum](http://homematic-forum.de/forum/viewtopic.php?f=18&t=31033) entnommen werden.**

## Installation:

### Automatisiert: 
Es wird automatisch ein aktuelles CCU2 Image installiert und das Netzwerk konfiguriert. Diese Installation ist für wenig erfahrene Benutzer auf einem frischen minimalen Debian/Raspbian empfehlenswert.  Die frisch installierte CCU2 wird eine IP per DHCP abrufen, diese kann durch **sudo yahm-ctl info** nach dem Start des Kontainers angezeigt werden.

```
wget -nv -O- https://raw.githubusercontent.com/leonsio/YAHM/release_1.5/yahm-init | sudo -E  bash -s quickinstall -
```

### UI Modus:

```
wget -nv -O- https://raw.githubusercontent.com/leonsio/YAHM/release_1.5/yahm-init | sudo -E  bash -s ui -
```

### Angepasst:

Mit dieser Methode wird lediglich die aktuelle YAHM Version runtergeladen und unter **/opt/YAHM/bin** installiert, anschließend muss mit Hilfe von YAHM ein [LXC Kontainer](https://github.com/leonsio/YAHM/wiki/YAHM-LXC) angelegt und das [Netzwerk](https://github.com/leonsio/YAHM/wiki/YAHM-Netzwerk) konfiguriert werden.

```
wget -nv -O- https://raw.githubusercontent.com/leonsio/YAHM/release_1.5/yahm-init | sudo -E  bash -
```

Folgende Schritte sind mindestens notwendig um ein CCU2 Image innerhalb von YAHM zu installieren:

```
sudo yahm-lxc install
sudo yahm-network -w create_bridge
sudo yahm-network attach_bridge
```

Anschließend kann mit **sudo yahm-ctl start** das Kontainer gestartet werden

### Aktivierung Rapsberry Pi Funkmodul
Nach der erfolgreichen Installation von YAHM kann das Funkmodul aktiviert werden, für weitere Informationen siehe [YAHM-Module](https://github.com/leonsio/YAHM/wiki/YAHM-Module)

```
yahm-module -m hm-mod-rpi-pcb enable
```

**Achtung:** Im Zuge der Installation wird ein Reboot benötigt

**Hinweis:** Die Konfiguration des Funkmoduls durch das hm-mod-rpi-pcb Modul, erfolgt ausschließlich auf einem Raspberry Pi. Für die Installation auf einer anderen Hardware sind die Installationsschritte im [Wiki](https://github.com/leonsio/YAHM/wiki/YAHM-Module:-HM-MOD-RPI-PCB) hinterlegt

### Migration CCU2/LXCCU zu YAHM
Für die Migration von CCU2 bzw. LXCCU zu YAHM bitte folgenden [Wiki-Eintrag](https://github.com/leonsio/YAHM/wiki/Migration-von-CCU-zu-YAHM) beachten. Es müssen keine Geräte neu angelernt werden. Sollten LAN-Gateways im Betrieb sein, muss einmalig unter **EINSTELLUNGEN - SYSTEMSTEUERUNG - LAN GATEWAY** die Zuordnung überprüft/angepasst werden

## Hinweise
### Homematic-IP
Die aktuelle CCU2 Firmware (ab 2.15.x) beinhaltet die Unterstützung für Homematic-IP. Diese wird zum aktuellen Zeitpunkt (04/2016) **NICHT** durch YAHM unterstützt und wird durch das [Homematic-IP Modul](https://github.com/leonsio/YAHM/wiki/YAHM-Module:-Homematic-IP) nachgereicht. Damit in der CCU2 Oberfläche keine Fehlermeldungen hinsichtlich **HMIP-RF** bzw. **VirtualDevices** auftauchen wird empfohlen die Unterstützung von Homematic-IP durch YAHM zu deaktivieren.

```
sudo yahm-module -f -m homematic-ip disable
```

**Hinweis:** Im Zuge der automatisierten Installation wird Homematic-IP automatisch deaktiviert, die Durchführung oben genannter Schritte ist nicht notwendig.

### Updates
Mit **sudo yahm-ctl update** kann YAHM Installation (nicht CCU2 Firmware) jederzeit aktualisiert werden. Für die Aktualisierung der CCU2 Installation, siehe [LXC Kontainer](https://github.com/leonsio/YAHM/wiki/YAHM-LXC)

### Kostenfaktor
Dieses Projekt wurde **nicht** dafür entworfen die Anschaffungskosten einer CCU2 zu reduzieren.
Eine Kalkulation mit einen Raspberry Pi (45€) zuzüglich des Funkmoduls (30€), sowie Gehäuse/Netzteil (15€) übersteigt oder gleicht sich den Anschaffungskosten einer CCU2 (ca. 90€). 

Für erfahrene Benutzer mit mehreren hundert Geräten/Programmen reicht die Leistung einer CCU2 nicht aus, für diese Zielgruppe wurde diese Anwendung primär entworfen. Für unerfahrene Benutzer wird weiterhin empfohlen die CCU2 zu erwerben.

