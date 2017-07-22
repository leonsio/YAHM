#!/bin/bash
#
# Leonid Kogan <leon@leonsio.com>
# Yet Another Homematic Management 
#
# Globale Funktionen
#

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!" 1>&2
   exit 1
fi

#echo ${0##*/}
#exit;

# Default path
YAHM_DIR=/opt/YAHM
YAHM_TOOLS=/opt/YAHM/share/tools
YAHM_TMP=/tmp/YAHM
YAHM_LIB=/var/lib/yahm

# Default names/variables (Raspberry/YAHM)
LXCNAME="yahm"
CCU2Version="2.29.18"
BRIDGE="yahmbr0"
INTERFACE="eth0"

#######################################
## DO NOT CHANGE THE FOLLOWING LINES ##
#######################################

# Default options
YAHM_VERSION="1.7"
OPTIND=1
QUIET="--quiet"
VERBOSE=""
ARCH=""

# Default behavior YAHM
IS_FORCE=0
IS_DEBUG=0
IS_VERBOSE=0
DRY_RUN=0
RESTART=1

# Check if we can use colours in our output
use_colour=0
[ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null && use_colour=1

# Some useful functions
progress() 
{
    [ $use_colour -eq 1 ] && echo -ne "\033[01;32m"
    echo -e "$@" 2>&1
    [ $use_colour -eq 1 ] && echo -ne "\033[00m"
}

info() 
{
    [ $use_colour -eq 1 ] && echo -ne "\033[01;34m"
    echo -e "$@" 2>&1
    [ $use_colour -eq 1 ] && echo -ne "\033[00m"
}

error() 
{
    [ $use_colour -eq 1 ] && echo -ne "\033[01;31m"
    echo -e "$@" >&2
    [ $use_colour -eq 1 ] && echo -ne "\033[00m"
}

die () {
    [ $use_colour -eq 1 ] && echo -ne "\033[01;31m"
    echo -e "$@" >&2
    [ $use_colour -eq 1 ] && echo -ne "\033[00m"
    exit 1
}

# Load system information
if [ -f ${YAHM_LIB}/systeminfo ]
then
    source ${YAHM_LIB}/systeminfo
else
    mkdir -p ${YAHM_LIB}
    source ${YAHM_TOOLS}/arm-board-detect/armhwinfo.sh
    echo "BOARD_TYPE='$BOARD_TYPE'" >> ${YAHM_LIB}/systeminfo
    echo "ARCH='$ARCH'" >> ${YAHM_LIB}/systeminfo
    echo "BOARD_VERSION='$BOARD_VERSION'" >> ${YAHM_LIB}/systeminfo
fi

# check architecture 
#case `dpkg --print-architecture` in
case $ARCH in
    armhf|armv6l|armv7l|arm64|aarch64)
        ARCH="ARM"
        ;;
    i386|amd64|x86_64)
        ARCH="X86"
        ;;
    *)
        die "Unsupported CPU architecture, we support only ARM and x86"
        ;;
esac

while getopts "${PARAMETER}" OPTION
do
    case $OPTION in
        f)
            IS_FORCE=1
            set +e
            ;;
        b)
	        BUILD=$OPTARG
            BRIDGE=$OPTARG
            ;;
        i)
            INTERFACE=$OPTARG
            ;;
        w)
            WRITE=1
            ;;
        d)
            DRY_RUN=1
            DATA_FILE=$OPTARG
            ;;
        p)
            PATCH_FILE=$OPTARG
            if [ ! -f "${PATCH_FILE}" ]
            then
                die "Specified patch file can not be found"
            fi
            ;;
        m)
            MODULE=$OPTARG
            # Pruefen ob Modul existiert
            if [ ! -f "${YAHM_DIR}/share/modules/${MODULE}" ]
            then
                die "Specified module can not be found"
            fi
            ;;
        r)
            if [ $OPTARG == "false" ] || [ $OPTARG == "no" ] || [ $OPTARG == "0" ]
            then
                RESTART=0
            elif [ $OPTARG == "true" ] || [ $OPTARG == "yes" ] || [ $OPTARG == "1" ]
            then
                RESTART=1
            else
                die "Unsupported option"
            fi
            ;;
        v)
            IS_VERBOSE=1
            QUIET=""
            VERBOSE="-v"
            ;;
        n)
            LXCNAME=$OPTARG
            ;;
        h|\?)
            show_help
            ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

LXC_ROOT=/var/lib/lxc/$LXCNAME
LXC_ROOT_FS=/var/lib/lxc/$LXCNAME/root
LXC_ROOT_MODULES=/var/lib/lxc/$LXCNAME/.modules

# Develop Branch warning
cd ${YAHM_DIR}
GIT_BRANCH=$(git branch | grep -e "^*" | cut -d' ' -f 2)
if [ "$GIT_BRANCH" == "develop" ]
then
    error "\n!!! You are using develop branch, this branch is unstable. Using at your own risk !!!!\n"
fi

get_ccu2_actual_version()
{
    # aktuelle Version bestimmen
    checkVersion="http://update.homematic.com/firmware/download?cmd=js_check_version&serial=0&product=HM-CCU2"
    curVersion=$(wget $QUIET -qO-  -T 3 -t 1  "$checkVersion" | cut -d"'" -f2)
    # Bei misserfolg letze bekannte Version ausgeben
    if [ "$curVersion" = "" ] || [ "$curVersion" = "n/a" ]
    then
        curVersion=$CCU2Version
    fi
    # Ausgabe
    echo $curVersion
}

download_ccu2_fw()
{
    BUILD=$1
    aBUILD=`get_ccu2_actual_version`

    if [ "${BUILD}" == "" ]
    then
        BUILD=$aBUILD
    fi

    progress "Downloading CCU Firmware"
    # Falls wir aktuelle FW runterladen
    if [ $(ver ${BUILD}) -eq $(ver ${aBUILD}) ]
    then
        curFWdl="http://update.homematic.com/firmware/download?cmd=download&product=HM-CCU2&serial=0"
        # Falls Download nicht funktioniert aus dem GIT runterladen (archiv)
        wget $QUIET -T 3 -t 1 --spider "$curFWdl" || {
            if [ `check_ccu2_archive $BUILD` -eq 0 ] && [ $IS_FORCE -ne 1 ]
            then
                die "ERROR: Can not find specified file in repository"
            fi
            error "EQ3 site, seems to be down. Trying to download from GIT"
            curFWdl="https://github.com/leonsio/CCU2-FW/raw/master/HM-CCU2-${BUILD}.tgz"
        }
    fi
    # Falls die FW unter aktuellen liegt, aus dem GIT runterladen (archiv)
    if [ $(ver ${BUILD}) -lt $(ver ${aBUILD}) ]
    then
        if [ `check_ccu2_archive $BUILD` -eq 0 ] && [ $IS_FORCE -ne 1 ]
        then
            die "ERROR: Can not find specified version in repository"
        fi
        curFWdl="https://github.com/leonsio/CCU2-FW/raw/master/HM-CCU2-${BUILD}.tgz"
    fi
    # Sollte nicht vorkommen
    if [ $(ver ${BUILD}) -gt $(ver ${aBUILD}) ]
    then
        die "ERROR: Specified version is greater than actual version"
    fi

    EQ3_FW="${YAHM_TMP}/HM-CCU2-${BUILD}.tar.gz"

    wget $QUIET --tries=3 --retry-connrefused  -O "$EQ3_FW" "$curFWdl" || info "Can not download file"
    if [ ! -f "$EQ3_FW" ] && [ $IS_FORCE -ne 1 ]
    then
        die "ERROR: Can not download firmware. Are you connected to the internet? Try to download the file manually and use -d flag"
    fi
}

check_ccu2_archive()
{
    CCU2_VERSION=$1
    if [ ! -f ${YAHM_LIB}/fw.list ]
    then
        wget $QUIET -O ${YAHM_LIB}/fw.list -N https://raw.githubusercontent.com/leonsio/CCU2-FW/master/fw.list
    fi
    ALL_FW=$(cat ${YAHM_LIB}/fw.list | grep -Po '(?<=CCU2-)\d.\d\d?.\d\d?')
    [[ $ALL_FW =~ $CCU2_VERSION ]] && echo 1 || echo 0
}

# Gibt installierte Bridge zurück
get_ccu2_bridge()
{
    CCU2_BRIDGE=$(cat ${LXC_ROOT}/config.network  | grep "lxc.network.link" | cut -d" " -f3)
    echo $CCU2_BRIDGE
}

# Achtung gibt nur das Erste Interface zurück, mehrere Interfaces werden nicht unterstützt
get_bridge_interface()
{
    BRIDGE_NAME=$1
    BRIDGE_INTERFACE=$(brctl show ${BRIDGE_NAME} | awk 'NF>1 && NR>1 {print $4}')
    echo $BRIDGE_INTERFACE
}

get_yahm_name()
{
    if [ `check_yahm_installed` -eq 1 ] 
    then
            local installed_name=`cat ${YAHM_LIB}/container_name`
    else
            echo 0
    fi

}

check_yahm_name()
{
    if [ `check_yahm_installed` -eq 1 ] ; then
        local container_name=$1
        local installed_name=`cat ${YAHM_LIB}/container_name`

        if [ "$container_name" = "$installed_name" ] ; then
                echo 1
                return 1
        fi
    fi
    echo 0
    return 1 
}

check_yahm_installed()
{
    file="${YAHM_LIB}/is_installed"
    if [ -f "$file" ]
    then
        echo 1 
    else
        echo 0
    fi
}

check_container_installed()
{
    file="${LXC_ROOT}/config"
    if [ -f "$file" ]
    then
        echo 1 
    else
        echo 0
    fi
}


get_yahm_version()
{
    local container_name=$1
    local yahm_version=`cat /var/lib/lxc/${container_name}/root/boot/VERSION  | cut -d'=' -f2` 
    echo $yahm_version
}

yahm_compatibility()
{
    local ccufw_version=$1
    if [ ! -f "${YAHM_DIR}/share/patches/${ccufw_version}.patch" ] ; then
        echo 1 
        return 1 
    fi

    if [ ! -f "${YAHM_DIR}/share/scripts/${ccufw_version}.sh" ] ; then
        echo 1 
        return 1
    fi 

    echo 0
}

ver() 
{ 
   printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ') 
}

countdown()
{
    secs=$((5))
    while [ $secs -gt 0 ]; do
        echo -ne "$secs\033[0K\r"
        sleep 1
        : $((secs--))
    done
}

check_install_deb()
{
    progress "Installing dependencies"
    packages=$1
    for P in $packages
    do
        dpkg -s "$P" >/dev/null 2>&1 && {
        info $P is installed
        } || {
            install_package "$P"
        }
    done
}

install_package() {
    package=$1
    info "install ${package}"
    apt-get -qq -y install $package 2>&1 > /dev/null
    return $?
}

### Shared Network functionality

show_bridges()
{
    info "Available Bridges"
    brctl show
}

check_bridge_name()
{
    local brname=$1
    local bridges=$(brctl show | awk 'NF>1 && NR>1 {print $1}')
    for bridge in $bridges
    do
        if [ "$brname" = "$bridge" ]
        then
            echo 1
            return 1
        fi
    done
    echo 0
}


check_interface_name()
{
    # interface name
    local int_name=$1

    if  [[ ! `ip -d link show ${int_name} 2>/dev/null ` ]]; then
        die "ERROR: Interface ${int_name} does not exists"
    elif [[ `ip -d link show ${int_name} | tail -n +2 | grep loopback` ]] ; then
        echo "local"
    elif [[ `ip -d link show ${int_name} | tail -n +2 | grep vlan` ]] ; then
        echo "vlan"
    elif [[ `ip -d link show ${int_name} | tail -n +2 | grep bridge` ]] ; then
        echo "bridge"
    else
        echo "physical"
    fi
}

check_git_update()
{
    cd ${YAHM_DIR}
    git remote update >/dev/null
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse @{u})
	BASE=$(git merge-base @ @{u})

	if [ $LOCAL = $REMOTE ]; then
    	echo 0
	elif [ $LOCAL = $BASE ]; then
    	echo 1
	fi
}
