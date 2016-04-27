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
mknod -m 666 /dev/ttyS0 c 4 64
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
