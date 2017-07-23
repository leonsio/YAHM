
[![Spenden](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9WRZHSCVYL6XL) Falls Sie dieses Projekt unterstützen möchten, würde ich mich über einen Pull-Request oder eine Spende: [![Spenden](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9WRZHSCVYL6XL) freuen.

# YAHM
**Yet Another Homematic Management** - Skripte zur Einrichtung der Homematic CCU2 Oberfläche in einem LXC Container unter Debian basierten Distribution auf ARM-Basis (x86 experimentell).


**Bitte lesen Sie diese Dokumentation bis zum Ende durch, bevor Sie die Anwendung installieren**

Zur Zeit wurde dieses Skript auf folgender Hardware erfolgreich getestet:
* Rapsberry Pi 2/3
* Odroid XU4
* Orange PI Plus 2
* Experimentell: x86 

Folgende Betrebssysteme werden aktuell unterstützt:
* Debian Jessie (ARM/x86)
* Raspbian Jessie
* Experimentell: Armbian
* Experimentell: Ubuntu 16.04

_(* Die Einrichtung des HM-MOD-RPI-PCB erfolgt automatisiert ausschließlich auf Rapsberry Pi)_

_(* Die Unterstützung von Homematic-IP setzt Raspberry Pi System voraus)_

**Weitere Informationen und Anleitungen können dem [Wiki](https://github.com/leonsio/YAHM/wiki) bzw. dem [Homematic-Forum](https://homematic-forum.de/forum/viewforum.php?f=67) entnommen werden.**

# Installation:

## Automatisiert: 
Es wird automatisch ein aktuelles CCU2 Image installiert und das Netzwerk konfiguriert. Diese Installation ist für wenig erfahrene Benutzer auf einem frischen minimalen Debian/Raspbian empfehlenswert.  Die frisch installierte CCU2 wird eine IP per DHCP abrufen, diese kann durch **sudo yahm-ctl info** nach dem Start des Containers angezeigt werden.

```
wget -nv -O- https://raw.githubusercontent.com/leonsio/YAHM/master/yahm-init | sudo -E  bash -s quickinstall -
```

**Hinweis:** Im Zuge der automatisierten Installation wird die Unterstützung für Homematic-IP automatisch deaktiviert. Sollte Bedarf an der Funktionalität bestehen, siehe nachfolgende [Schritte](#homematic-ip).


## UI Modus:
"Grafisches" Installationswerkzeug. Diese Möglichkeit ist für wenig bis erfahrene Benutzer geeignet.

```
wget -nv -O- https://raw.githubusercontent.com/leonsio/YAHM/master/yahm-init | sudo -E  bash -s ui -
```

## Angepasst:

Mit dieser Methode wird lediglich die aktuelle YAHM Version runtergeladen und unter **/opt/YAHM/bin** installiert, anschließend muss mit Hilfe von YAHM Tools ein [LXC Container](https://github.com/leonsio/YAHM/wiki/YAHM-LXC) angelegt und das [Netzwerk](https://github.com/leonsio/YAHM/wiki/YAHM-Netzwerk) konfiguriert werden. Sollten Sie bereits andere Anwendungen und Tools installiert haben, bzw. eine angepasste Netzerkkonfiguration besitzen/wünschen ist diese Möglichkeit genau das richtige für Sie.

```
wget -nv -O- https://raw.githubusercontent.com/leonsio/YAHM/master/yahm-init | sudo -E  bash -
```

Folgende Schritte sind **mindestens** notwendig um ein CCU2 Image innerhalb von YAHM zu installieren:

```
sudo yahm-lxc install
sudo yahm-network -w create_bridge
sudo yahm-network attach_bridge
```

Anschließend kann mit **sudo yahm-ctl start** das Container gestartet werden

# Updates
Mit **sudo yahm-ctl update** kann YAHM Installation (nicht CCU2 Firmware) jederzeit aktualisiert werden. Für die Aktualisierung der CCU2 Installation, siehe [LXC Container](https://github.com/leonsio/YAHM/wiki/YAHM-LXC)


# Rapsberry Pi Funkmodul
Nach der erfolgreichen Installation von YAHM kann das Funkmodul aktiviert werden, für weitere Informationen siehe [YAHM-Module](https://github.com/leonsio/YAHM/wiki/YAHM-Module)

```
yahm-module -m hm-mod-rpi-pcb enable
```

**Achtung:** Im Zuge der Installation wird ein Reboot benötigt

**Hinweis:** Die Konfiguration des Funkmoduls durch das hm-mod-rpi-pcb Modul, erfolgt ausschließlich auf einem Raspberry Pi. Für die Installation auf einer anderen Hardware sind die Installationsschritte im [Wiki](https://github.com/leonsio/YAHM/wiki/YAHM-Module:-HM-MOD-RPI-PCB) hinterlegt

# Homematic-IP 
Die aktuelle CCU2 Firmware (ab 2.15.x) beinhaltet standardmäßig die Unterstützung für Homematic-IP. Die Unterstützung in YAHM wird ab der YAHM Version 1.7 durch das [Homematic-IP Modul](https://github.com/leonsio/YAHM/wiki/YAHM-Module:-Homematic-IP) realisiert. <br/>
Die Aktivierung der Unterstützung kann je nach Bedarf erfolgen, wird die Unterstützung für Homematic-IP nicht benötigt **sollte** die CCU Homematic-IP Funktionalität deaktiviert werden.

**Hinweis:** Im Zuge der automatisierten Installation wird Homematic-IP automatisch deaktiviert, die Durchführung unten genannter Schritte ist nicht notwendig. Die Schritte sind lediglich bei der GUI bzw. manuellen Installation notwendig.


## Deaktivierung von Homematic-IP
Damit in der CCU2 Oberfläche keine Fehlermeldungen hinsichtlich **HMIP-RF** bzw. **VirtualDevices** auftauchen und kein Bedarf an der Homematic-IP Unterstützung bestehen, wird empfohlen die Unterstützung von Homematic-IP durch YAHM zu deaktivieren.

```
sudo yahm-module -f -m homematic-ip disable
```

## Aktivierung von Homematic-IP
Für die Unterstützung der Homematic-IP muss das Raspberry Pi Kernel neu kompiliert werden, sowie müssen einige Kernel Module eingebunden werden. Alle Schritte werden durch das Homematic-IP Modul automatisch durchgeführt. Eine Interaktion seitens des Benutzers ist nicht notwendig. 

**Achtung:** Die Installation kann zwischen 1 und 4 Stunden dauern

**Achtung:** Im Zuge der Installation wird ein Reboot benötigt

```
sudo yahm-module -m homematic-ip enable
```

# Hinweise

## Migration CCU2/LXCCU zu YAHM
Für die Migration von CCU2 bzw. LXCCU zu YAHM bitte folgenden [Wiki-Eintrag](https://github.com/leonsio/YAHM/wiki/Migration-von-CCU-zu-YAHM) beachten. Es müssen keine Geräte neu angelernt werden. Sollten LAN-Gateways im Betrieb sein, muss einmalig unter **EINSTELLUNGEN - SYSTEMSTEUERUNG - LAN GATEWAY** die Zuordnung überprüft/angepasst werden


## Kostenfaktor
Dieses Projekt wurde **nicht** dafür entworfen die Anschaffungskosten einer CCU2 zu reduzieren.
Eine Kalkulation mit einen Raspberry Pi (45€) zuzüglich des Funkmoduls (30€), sowie Gehäuse/Netzteil (15€) übersteigt oder gleicht sich den Anschaffungskosten einer CCU2 (ca. 90€). 

Für erfahrene Benutzer mit mehreren hundert Geräten/Programmen reicht die Leistung einer CCU2 nicht aus, für diese Zielgruppe wurde diese Anwendung primär entworfen. Für unerfahrene Benutzer wird weiterhin empfohlen die CCU2 zu erwerben.

## Credits
Die Arbeit/Idee basiert auf der Arbeit von [bullshit](https://github.com/bullshit/lxccu) bzw. des [LXCCU](http://www.lxccu.com) Projektes.

**Wesentliche Unterschiede zu LXCCU:**
+ Unterstützung von Debian/Raspbian Jessie
+ Unterstützung aktueller/älterer CCU2 Firmware (ältere Versionen lassen sich nicht länger von Homematic Seite runterladen, somit ist LXCCU aktuell leider unbenutzbar)
+ Die Installation kann manuell gesteuert werden und wird nicht durch DEB-Installer vorgenommen
+ Modulare Bauweise, es können beliebige Module eingebunden werden
+ Kann mit geringer Anpassung auf anderen Betriebssystemen portiert werden