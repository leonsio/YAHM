
Falls Sie dieses Projekt unterstützen möchten, würde ich mich über einen Pull-Request oder eine Spende: <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9WRZHSCVYL6XL"><img style="padding:0;" width=74 height=21  src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif" alt="Donate!" / border="0"></a> freuen.

# YAHM
Yet Another Homematic Management - Skripte zur Einrichtung der Homematic CCU2 Oberfläche in einem LXC Container unter Debian Jessie auf ARM-Basis.

Zur Zeit wurde dieses Skript auf folgender Hardware erfolgreich getestet:
* Rapsberry Pi 2/3
* Odroid XU4
* Orange PI Plus 2
(Die Einrichtung des HM-MOD-RPI-PCB erfolgt automatisiert ausschließlich auf Rapsberry Pi)

Weitere Informationen und Anleitungen können dem [Wiki](https://github.com/leonsio/YAHM/wiki) oder Homematic-Forum entnommen werden. 

## Installation:

### Automatisiert: 
Es wird automatisch ein aktuelles CCU2 Image installiert und das Netzwerk konfiguriert. Diese Installation ist für wenig erfahrene Benutzer auf einem frischen minimalen Debian/Raspbian empfehlenswert. Nach der Installation muss nur noch das LXC Container mit **sudo yahm-ctl start** start gestartet werden. Die frisch installierte CCU2 wird sich eine IP per DHCP abgerufen und kann durch **sudo yahm-ctl show** angezeigt werden.

```
sudo wget -nv -O- https://raw.githubusercontent.com/leonsio/YAHM/master/yahm-init | bash -s quickinstall -
```

### Angepasst:

Mit dieser Installation wird lediglich die aktuelle YAHM runtergeladen und unter /opt/YAHM/bin installiert, anschließend muss mit Hilfe von YAHM ein [LXC Container](https://github.com/leonsio/YAHM/wiki/YAHM-LXC) angelegt und as [Netzwerk](https://github.com/leonsio/YAHM/wiki/YAHM-Netzwerk) konfiguriert werden.

```
sudo wget -nv -O- https://raw.githubusercontent.com/leonsio/YAHM/master/yahm-init | bash -
```

Anbei die notwendigen minimalen Schritte:

```
sudo yahm-lxc install
sudo yahm-network create_bridge
sudo yahm-network attach_bridge
```

anschließend kann mit **sudo yahm-ctl start** das Container gestartet werden

### Hinweis:
Die Aktuelle CCU2 Firmware beinhaltet die Unterstützung für Homematic-IP. Diese wird zum aktuellen Zeitpunkt **NICHT** im vollen Umfang durch YAHM unterstützt. Damit in der CCU2 Oberfläche keine Fehlermeldungen hinsichtlich HMIP-RF auftauchen wird empfohlen die Unterstützung von Homematic-IP durch YAHM zu deaktivieren.

```
sudo yahm-module -f -m homematic-ip disable
```
