#!/bin/bash
#
#
#
#

#Default Settings
LXCNAME=yahm
YAHM_DIR=/opt/YAHM/
OPTIND=1

while getopts "fvn:" OPTION
do
    case $OPTION in
        f)
            IS_FORCE=1
            ;;
        v)
            IS_VERBOSE=1
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


# Check if we can use colours in our output
use_colour=0
[ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null && use_colour=1

# Some useful functions
progress() {
	[ $use_colour -eq 1 ] && echo -ne "\033[01;32m"
	echo "$@" >&2
	[ $use_colour -eq 1 ] && echo -ne "\033[00m"
}

info() {
	[ $use_colour -eq 1 ] && echo -ne "\033[01;34m"
	echo "$@" >&2
	[ $use_colour -eq 1 ] && echo -ne "\033[00m"
}

die () {
	[ $use_colour -eq 1 ] && echo -ne "\033[01;31m"
	echo "$@" >&2
	[ $use_colour -eq 1 ] && echo -ne "\033[00m"
	exit 1
}

get_yahm_name()
{
        if [ `check_yahm_installed` -eq 1 ] 
        then
                local installed_name=`cat /var/lib/yahm/container_name`
        else
                echo 0
        fi

}

check_yahm_name()
{
	if [ `check_yahm_installed` -eq 1 ] ; then
		local container_name=$1
		local installed_name=`cat /var/lib/yahm/container_name`

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
	file="/var/lib/yahm/is_installed"
	if [ -f "$file" ]
	then
		echo 1 
	else
		echo 0
	fi
}

get_yahm_version()
{
    return
}

yahm_compatibility()
{
    local ccufw_version=$1
    if [ ! -f "/opt/YAHM/share/tools/patches/${ccufw_version}.patch" ] ; then
        echo 1 
        return 1 
    fi

    if [ ! -f "/opt/YAHM/share/tools/scripts/${ccufw_version}.sh" ] ; then
        echo 1 
        return 1
    fi 

    echo 0
}

