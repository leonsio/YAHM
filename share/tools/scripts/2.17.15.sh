#!/usr/bin/env bash
ROOT=$(pwd)
DEV=${ROOT}/dev
#mv ${DEV} ${DEV}.old
#mkdir -p ${DEV}
mknod -m 666 ${DEV}/null c 1 3
mknod -m 666 ${DEV}/zero c 1 5
mknod -m 666 ${DEV}/random c 1 8
mknod -m 666 ${DEV}/urandom c 1 9
#mkdir -m 755 ${DEV}/pts
#mkdir -m 1777 ${DEV}/shm
mknod -m 666 ${DEV}/tty c 5 0
mknod -m 600 ${DEV}/console c 5 1
mknod -m 666 ${DEV}/tty0 c 4 0
mknod -m 666 ${DEV}/tty1 c 4 0
#mknod -m 666 ${DEV}/ttyAMA0 c 4 1
#mknod -m 666 ${DEV}/ttyGS0 c 4 2
mknod -m 666 ${DEV}/ttyS0 c 4 64
#mknod -m 666 ${DEV}/full c 1 7
#mknod -m 600 ${DEV}/initctl p
#mknod -m 666 ${DEV}/ptmx c 5 2


mkdir ${ROOT}/media/sd-mmcblk0
# fuer den fall der faelle
echo '#!/bin/sh' > ${ROOT}/bin/update_firmware_pre
echo '#!/bin/sh' > ${ROOT}/bin/update_firmware_run
# wir halten patches klein und reagieren auf zukuenftige anpassungen
sed -i "s/modprobe/echo/g" ${ROOT}/etc/init.d/S00eQ3SystemStart
touch ${ROOT}/usr/local/etc/config/no-coprocessor-update
mv ${ROOT}/etc/init.d/S40UsbNetwork  ${ROOT}/etc/init.d/_S40UsbNetwork
cat >> "${ROOT}/bin/update_firmware_run"  <<EOF
log() {
  logger -t homematic -p user.notice $1
}

echo "YAHM: Entering addon install mode"
log "YAHM: Entering addon install mode"
if [ ! -f /var/new_firmware.tar.gz ]; then
  log "YAHM: addon image archive does not exist. Nothing to do"
  echo "YAHM: addon image archive does not exist. Nothing to do"
  exit
fi

echo "YAHM: extract addon archive"
log "YAHM: extract addon archive"
cd /var
cat new_firmware.tar.gz | gunzip | tar x
rm new_firmware.tar.gz
if [ ! -x /var/update_script ]; then
  log "YAHM: Error unzipping addon image archive. Nothing to do"
  echo "YAHM: Error unzipping addon image archive. Nothing to do"
  exit
fi

log "YAHM: prepare mount points to simulate ccu"
echo "YAHM: prepare mount points to simulate ccu"
cat /var/update_script | sed -r 's/mount -t ubifs ubi0:root ([\/\w\-]*)/mount -o bind \/ \1/' > /var/update_script_prepare
cat /var/update_script_prepare | sed -r 's/mount -t ubifs ubi1:user ([\/\w\-]*)/mount -o bind \/usr\/local \1/' > /var/update_script

log "YAHM: start update_script as YAHM"
echo "YAHM: start update_script as YAHM"
chmod +x /var/update_script
cd /var/
/var/update_script CCU2

EOF
