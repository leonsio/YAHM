#!/bin/bash
#
# Thomas Kluge <th.kluge@me.com>
#
# RFD Config Check
#


_check_result=0
_check_ok="Die rfd.conf sieht ok aus."
_check_fail="Es wurde das HM-MOD-RPI-PCB Modul installiert, aber eine Anpassung in der Konfigurationsdatei fehlt. Eventuell wurde diese ja durch ein eingespieltes Backup überschrieben. Bitte reinstalliere das YAHM Modul HM-MOD-RPI-PCB um dieses Problem zu lösen."


_check_proceed() {
 # Check RFD.conf
 if [ -e ${LXC_ROOT_MODULES}/hm-mod-rpi-pcb ] ; then 
  if [ $(cat ${LXC_ROOT_FS}/usr/local/etc/config/rfd.conf|grep "\Improved\ Coprocessor\ Initialization\ =\ true"|wc -l) -eq 1 ];then
   _check_result=1
  fi
 fi
 echo $_check_result
}


_check_fix_issue() {
 progress "Not yet implemented"
}