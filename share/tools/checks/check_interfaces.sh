#!/bin/bash
#
# Thomas Kluge <th.kluge@me.com>
#
# InterfacesList.xml Config Check
#


_check_result=0
_check_fail="Es wurde eine fehlerhafte InterfacesList.xml Datei in /usr/local/etc/config gefunden."
_check_ok="Die InterfacesList.xml sieht ok aus."

_check_proceed() {
 # Check Interfaces.xml
  if [ $(cat ${LXC_ROOT_FS}/usr/local/etc/config/InterfacesList.xml|grep "BidCos-RF"|wc -l) -eq 1 ];then
   _check_result=1
  fi
 echo $_check_result
}


_check_fix_issue() {
 progress "Not yet implemented"
}