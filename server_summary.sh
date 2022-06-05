#!/bin/bash

function main {

	server_stats
	which_stack
	database_services
	php_services
	redis_service
	memcache_service
	shorewall_service
	elasticsearch_service
	disk_stats
	applications_disk_stats
}

function which_stack {
	
	echo -e "\e[1;96m|######################|############|############|\e[0m"
	printf '\e[1;96m%-1s\e[m \e[3;94m%-20s\e[m \e[1;96m%-1s\e[m \e[3;94m%-10s\e[m \e[1;96m%-1s\e[m \e[3;94m%-9s\e[m \e[1;96m%-1s\e[m\n' "|" "    Services Name" "|" "  Version" "|" "  Status" " |"
	echo -e "\e[1;96m|######################|############|############|\e[0m"

	lemp=$(ls -al /etc/init.d/ | grep -Ei nginx | awk '{print $9}')

	if [[ ! -z "$lemp" ]]; then

		nginx_status=$(systemctl status "$lemp" | grep active | awk '{print $2}')
		nginx_version=$(nginx -v 2>&1 | awk -F "/" '{print $2}')
		[ -z $nginx_version ] && nginx_version="NULL"

		if [ "$nginx_status" == "active" ]; then

			[ "$nginx_version" != "NULL" ] && printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Nginx" " |" "  $nginx_version" "|" "UP" "|" 
			[ "$nginx_version" == "NULL" ] && printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Nginx" " |" "  $nginx_version" "|" "UP" "|" 
		
		else

			[ "$nginx_version" != "NULL" ] && printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Nginx" " |" "  $nginx_version" "|" "DOWN" "|"
			[ "$nginx_version" == "NULL" ] && printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Nginx" " |" "  $nginx_version" "|" "DOWN" "|"
		fi

	elif [[ -z "$LEMP" ]]; then

        	apache=$(ls -al /etc/init.d/ | grep -Ei apache2 | awk '{print $9}')
        	apache_status=$(systemctl status "$apache" | grep -Ei active | cut -d: -f2 | awk '{print $1}')
       		apache_version=$(apache2 -v 2> /dev/null | head -1 | awk -F "/" '{print $2}' | awk '{print $1}')
		[ -z $apache_version ] && apache_version=NULL

		if [ "$apache_status" == "active" ]; then

	 		[ "$apache_status" != "NULL" ] && printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "Apache" "|" "  $apache_version" "|" "UP" "|"
			[ "$apache_status" == "NULL" ] && printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "Apache" "|" "  $apache_version" "|" "UP" "|"
		
		else
		
			[ "$apache_status" != "NULL" ] && printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "Apache" "|" "  $apache_version" "|" "DOWN" "|"
			[ "$apache_status" == "NULL" ] && printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "Apache" "|" "  $apache_version" "|" "DOWN" "|"		
	
		fi

	else

		printf '\e[1;96m%-1s\e[m \e[1;90m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "WebServer" " |" "  NULL" "|" "NULL" "|"

	fi

}

function database_services {

	database_check=$(ls -al /etc/init.d/ | grep -Ei mysql | wc -l)
	[ $database_check -gt 0 ] && database_type=$(mysql --version | grep -i  mariadb | wc -l)
	[ $database_type -gt 0 ] && database_type="mariadb" || database_type="mysql"

	if [ "$database_type" == "mariadb" ]; then

        	mariadb_version=$(mysql --version | awk '{print $5}' | sed 's/-MariaDB,//')
        	mariadb_status=$(systemctl status mysql | grep -Ei active | cut -d: -f2 | awk '{print $1}')

		if [ "$mariadb_status" == "active" ]; then

	 		printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "MariaDB" "|" "  $mariadb_version" "|" "UP" "|"

		else

			printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "MariaDB" "|" "  $mariadb_version" "|" "DOWN" "|"

		fi
	elif [ "$database_type" == "mysql" ]; then

        	mysql_version=$(mysql --version | awk '{print $3}')
        	mysql_status=$(systemctl status mysql | grep -Ei active | cut -d: -f2 | awk '{print $1}')

		if [ "$mysql_status" == "active" ]; then

	 		printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "MySQL" "|" "  $mysql_version" "|" "UP" "|"

		else

			printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "MySQL" "|" "  $mysql_version" "|" "DOWN" "|"

		fi
	else

        	printf '\e[1;96m%-1s\e[m \e[1;90m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Database" " |" "NULL" "|" "NULL" "|"

	fi

}

function disk_stats {

	rs_data=$(df -hT | grep 'ext4' | egrep "/$")
	rs_name=$(echo "$rs_data" | awk '{print $1}' | sed 's+/dev/++g')
	rs_total=$(echo "$rs_data" | awk '{print $3}')
	rs_used=$(echo "$rs_data" | awk '{print $4}')
	rs_avail=$(echo "$rs_data" | awk '{print $5}')
	rs_perc=$(echo "$rs_data" | awk '{print $6}')
	rs_perc_check=$(echo $rs_perc | awk -F "." '{print $1}' | sed "s+%++g")

	rs_idata=$(df -ihT | grep 'ext4' | egrep "/$")
	rs_iname=$(echo "$rs_idata" | awk '{print $1}' | sed 's+/dev/++g')
	rs_itotal=$(echo "$rs_idata" | awk '{print $3}')
	rs_iused=$(echo "$rs_idata" | awk '{print $4}')
	rs_iavail=$(echo "$rs_idata" | awk '{print $5}')
	rs_iperc=$(echo "$rs_idata" | awk '{print $6}')
	rs_iperc_check=$(echo "$rs_iperc" | awk -F "." '{print $1}' | sed "s+%++g")

	bs_data=$(df -hT | grep 'ext4' | egrep "/mnt/user_data")
	bs_name=$(echo "$bs_data" | awk '{print $1}' | sed 's+/dev/++g')
	bs_total=$(echo "$bs_data" | awk '{print $3}')
	bs_used=$(echo "$bs_data" | awk '{print $4}')
	bs_avail=$(echo "$bs_data" | awk '{print $5}')
	bs_perc=$(echo "$bs_data" | awk '{print $6}')
	bs_perc_check=$(echo $bs_perc | awk -F "." '{print $1}' | sed "s+%++g")

	bs_idata=$(df -ihT | grep 'ext4' | egrep "/mnt/user_data")
	bs_iname=$(echo "$bs_idata" | awk '{print $1}' | sed 's+/dev/++g')
	bs_itotal=$(echo "$bs_idata" | awk '{print $3}')
	bs_iused=$(echo "$bs_idata" | awk '{print $4}')
	bs_iavail=$(echo "$bs_idata" | awk '{print $5}')
	bs_iperc=$(echo "$bs_idata" | awk '{print $6}')
	bs_iperc_check=$(echo $bs_iperc | awk -F "." '{print $1}' | sed "s+%++g")

	echo -e "\e[1;96m|######################|############|############|##############|############|############|\e[0m"
	printf '\e[1;96m%-1s\e[m \e[3;94m%-20s\e[m \e[1;96m%-1s\e[m \e[3;94m%-10s\e[m \e[1;96m%-1s\e[m \e[3;94m%-9s\e[m \e[1;96m%-1s\e[m \e[3;94m%-10s\e[m \e[1;96m%-1s\e[m \e[3;94m%-10s\e[m \e[1;96m%-1s\e[m \e[3;94m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "    Storage Names" "|" "  Total" "|" "   Used" " |" "Availability" "|" "Percentage" "|" "  Status" "|"
	echo -e "\e[1;96m|######################|############|############|##############|############|############|\e[0m"

	if [[ $rs_perc_check -lt 90 ]]; then

		printf '\e[1;96m%-1s\e[m \e[1;93m%-20s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "$rs_name" "|" "$rs_total" "|" "$rs_used" "|" "$rs_avail" "|" "$rs_perc" "|" "GOOD" "|" 
	else
		printf '\e[1;96m%-1s\e[m \e[1;93m%-20s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "$rs_name" "|" "$rs_total" "|" "$rs_used" "|" "$rs_avail" "|" "$rs_perc" "|" "BAD" "|"
	fi

	if [[ $rs_iperc_check -lt 90 ]]; then

		printf '\e[1;96m%-1s\e[m \e[1;93m%-20s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "$rs_iname (Inode)" "|" "$rs_itotal" "|" "$rs_iused" "|" "$rs_iavail" "|" "$rs_iperc" "|" "GOOD" "|" 
	else
		printf '\e[1;96m%-1s\e[m \e[1;93m%-20s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "$rs_iname (Inode)" "|" "$rs_itotal" "|" "$rs_iused" "|" "$rs_iavail" "|" "$rs_iperc" "|" "BAD" "|"
	fi

	if [[ $bs_perc_check -lt 90 ]]; then

		printf '\e[1;96m%-1s\e[m \e[1;93m%-20s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "$bs_name" "|" "$bs_total" "|" "$bs_used" "|" "$bs_avail" "|" "$bs_perc" "|" "GOOD" "|" 
	else
		printf '\e[1;96m%-1s\e[m \e[1;93m%-20s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "$bs_name" "|" "$bs_total" "|" "$bs_used" "|" "$bs_avail" "|" "$bs_perc" "|" "BAD" "|"
	fi

	if [[ $bs_iperc_check -lt 90 ]]; then

		printf '\e[1;96m%-1s\e[m \e[1;93m%-20s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "$bs_iname (Inode)" "|" "$bs_itotal" "|" "$bs_iused" "|" "$bs_iavail" "|" "$bs_iperc" "|" "GOOD" "|" 
	else
		printf '\e[1;96m%-1s\e[m \e[1;93m%-20s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "$bs_iname (Inode)" "|" "$bs_itotal" "|" "$bs_iused" "|" "$bs_iavail" "|" "$bs_iperc" "|" "BAD" "|"
	fi

	echo -e "\e[1;96m###########################################################################################\e[0m"
	echo ""

}

function php_services {

        php_array=($(ls -l /etc/init.d/ | grep -E php | awk '{print $9}'))
        length_php_array="${#php_array[@]}"

        for (( i=0; i<$length_php_array; i++ )) do

		php_version=$(echo "${php_array[$i]}" | awk -F "-" '{print $1}' | sed 's/php//' )
		php_status=$(systemctl status "${php_array[$i]}" | grep -i active | head -1 | awk '{print $2}')

		if [ "$php_status" == "active" ]; then

			printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "PHP-FPM" "|" "  $php_version" "|" "UP" "|"
		else
			printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "PHP-FPM" "|" "  $php_version" "|" "DOWN" "|"
		fi
        done

}

function redis_service {

	redis_check=$(ls -al /etc/init.d/ | grep -Ei redis | awk '{print $9}')

        if [[ -n $redis_check ]]; then

	        redis_status=$(systemctl status "$redis_check" | grep -Ei active | awk -F " " '{print $2}')
                redis_version=$( redis-server -v | awk -F " " '{print $3}' | cut -d= -f2)

                if [[ $redis_status == active ]]; then

	                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Redis" " |" "  $redis_version" "|" "UP" "|"

		else

                        printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "Redis" "|" "  $redis_version" "|" "DOWN" "|"

                fi

        else

                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Redis" " |" "  NULL" "|" "NULL" "|"

        fi

}

function memcache_service {

	memcached_check=$(ls -al /etc/init.d/ | grep -Ei memcache | awk '{print $9}')

        if [[ -n $memcached_check ]]; then

                memcache_status=$(systemctl status "$memcached_check" | grep -Ei active | awk -F " " '{print $2}')
                memcache_version=$( memcached --version | awk '{print $2}')

                if [[ $memcache_status == active ]]; then

	                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Memcached" " |" "  $memcache_version" "|" "UP" "|"

		else

	                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "Memcached" "|" "  $memcache_version" "|" "DOWN" "|"

                fi

        else

                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Memcache" " |" "  NULL" "|" "NULL" "|"

        fi

}

function shorewall_service {

	shorewall_check=$(ls -al /etc/init.d/ | grep -Ei shorewall | awk '{print $9}')

        if [[ -n $shorewall_check ]]; then

                shorewall_status=$(systemctl status "$shorewall_check" | grep -Ei active | awk -F " " '{print $2}')
                shorewall_version="NULL"

                if [[ $shorewall_status == active ]]; then

	                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Shorewall" " |" "  $shorewall_version" "|" "UP" "|"

		else

	                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "Shorewall" "|" "  $shorewall_version" "|" "DOWN" "|"

                fi

        else

                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Memcache" " |" "  NULL" "|" "NULL" "|"

        fi

}

function elasticsearch_service {

	elasticsearch_check=$(ls -al /etc/init.d/ | grep -Ei elasticsearch | awk '{print $9}')

        if [[ -n $elasticsearch_check ]]; then

                elasticsearch_status=$(systemctl status "$elasticsearch_check" | grep -Ei active | awk -F " " '{print $2}')
                elasticsearch_version="NULL"

                if [[ $elasticsearch_status == active ]]; then

	                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Elastic Search" " |" "  $elasticsearch_version" "|" "UP" "|"

		else

	                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "| " "Elastic Search" "|" "  $elasticsearch_version" "|" "DOWN" "|"

                fi

        else

                printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m \e[1;90m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" " Elastic Search" " |" "  NULL" "|" "NULL" "|"

        fi

	echo -e "\e[1;96m##################################################\e[0m"
	echo ""
}

function server_stats {

	cpu_threshold="90"
	cpu_usage=$(echo "scale=0;100-`top -b -n1 | grep "Cpu(s)" | awk -F "," '{print $4}' | sed -e 's/id//g' -e 's/ //g' | awk -F "." '{print $1}'`" | bc)
	
	echo ""	
	echo -e "\e[1;96m|################|############|############|\e[0m"
	printf '\e[1;96m%-1s\e[m \e[3;94m%-10s\e[m \e[1;96m%-1s\e[m \e[3;94m%-10s\e[m \e[1;96m%-1s\e[m \e[3;94m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "Resource Names" "|" "Percentage" "|" "  Status" "|"
	echo -e "\e[1;96m|################|############|############|\e[0m"

	if [ "$cpu_usage" -ge "$cpu_threshold" ]; then

		printf '\e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "CPU" "|" "${cpu_usage}%" "|" "BAD" "|" 

	else

		printf '\e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "CPU" "  |" "${cpu_usage}%" "|" "GOOD" "|"

	fi

	mem_threshold="90"
	mem_free_data=`free -m | grep Mem`
	mem_current=`echo $mem_free_data | cut -f3 -d' '`
	mem_total=`echo $mem_free_data | cut -f2 -d' '`
	mem_usage=$(echo "scale = 2; $mem_current/$mem_total*100" | bc | awk -F "." '{print $1}')

	if [ "$mem_usage" -ge "$mem_threshold" ]; then

		printf '\e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;91m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "RAM" "|" "${mem_usage}%" "|" "BAD" "|" 

	else

		printf '\e[1;96m%-1s\e[m \e[1;93m%-12s\e[m \e[1;96m%-1s\e[m \e[1;93m%-10s\e[m \e[1;96m%-1s\e[m \e[1;92m%-10s\e[m \e[1;96m%-1s\e[m\n' "|" "RAM" "  |" "${mem_usage}%" "|" "GOOD" "|"

	fi

	echo -e "\e[1;96m############################################\e[0m"
	echo ""
}

function applications_disk_stats {

	application_dir="/mnt/user_data/home/master/applications/"
	apps_array=($(ls ${application_dir}))
	length_apps_array=${#apps_array[@]}

	echo -e "\e[1;96m|######################|##################|####################|\e[0m"
	printf '\e[1;96m%-1s\e[m \e[3;94m%-20s\e[m \e[1;96m%-1s\e[m \e[3;94m%-16s\e[m \e[1;96m%-1s\e[m \e[3;94m%-18s\e[m \e[1;96m%-1s\e[m\n' "|" "  Application Names" "|" "Disk Consumption" "|" "Inode Consumption" "|"
	echo -e "\e[1;96m|######################|##################|####################|\e[0m"


	for (( j=0; j<$length_apps_array; j++ )); do

		app_inode=$(du -sh --inodes "${application_dir}${apps_array[$j]}" | awk '{print $1}')
		app_disk=$(du -sh "${application_dir}${apps_array[$j]}" | awk '{print $1}')
		printf '\e[1;96m%-1s\e[m \e[1;93m%-19s\e[m \e[1;96m%-1s\e[m \e[1;93m%-16s\e[m \e[1;96m%-1s\e[m \e[1;93m%-18s\e[m \e[1;96m%-1s\e[m\n' "| " "${apps_array[$j]}" "|" "${app_disk}" "|" "${app_inode}" "|"
	done

	echo -e "\e[1;96m################################################################\e[0m"
	echo ""

}

main
