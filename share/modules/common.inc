#!/bin/bash 

get_yahm_name()
{
        if [ `check_yahm_installed` -eq 1 ] 
        then
                local installed_name=`cat /var/lib/yahm/container_name`
		echo $installed_name
        else
                echo 0
        fi

}

check_yahm_name()
{
	if [ `check_yahm_installed` -eq 1 ] ; then
		local container_name=$1
		local installed_name=`cat /var/lib/yahm/container_name`

		if [ "$installed_name" = "$installed_name" ] ; then
			echo 1
			echo "hier"
			return 1
		fi
	fi
	echo 0
	return 0 
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
