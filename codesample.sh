#!/usr/bin/env bash

TITLE="MySQL Database Size Calculator\n"
MENU="Choose one of the following options:\n"
mybin=$(which mysql 2>/dev/null)
result=$?


echo -e "$TITLE"
echo -e "$MENU"

all_dbs () {
	if [ "$REPLY" = 1 ] && [ "$result" = 0 ]; then
		$mybin -e 'SELECT table_schema "DB Name",
		sum( data_length + index_length ) / 1024 /
		1024 "DB Size in MB",
		sum( data_free )/ 1024 / 1024 "Free Space in MB"
		FROM information_schema.TABLES
		GROUP BY table_schema ;'

	else [ "$REPLY" = 1 ] && [ "$result" = 1 ]
		echo "MySQL is not present on this system. Goodbye!"
		exit
	fi
}

tables () {
	if [ "$REPLY" = 2 ] && [ "$result" = 0 ]; then
		read -p "You selected $REPLY which is $opt. Please enter database name: " answer
		echo $answer
		$mybin -e 'SELECT table_name AS "Table", round(((data_length + index_length) / 1024 / 1024), 2) as "size (MB)" FROM information_schema.TABLES WHERE table_schema = "$answer"  ORDER BY data_length DESC;'

	else [ "$REPLY" = "2" ] && [ "$result" = 1 ]
		echo "MySQL is not present on this system. Goodbye!"
		exit
	fi
}

while true; do

#select opt in 'All Databases' 'Tables in a Database' Quit; do
	options=("All Databases" "Tables in a Database" "Quit")

	select opt in "${options[@]}"; do
		case $REPLY in
			1) all_dbs;;

			2) tables;;
	#			echo "You selected $opt"
			3) echo "Goodbye!"; exit;;
			*) echo "Invalid option $REPLY";;
		esac
	done

#if [ "$REPLY" = "1" ] && [ "$result" = 0 ]; then
#	$mybin -e 'SELECT table_schema "DB Name",
#sum( data_length + index_length ) / 1024 /
#1024 "DB Size in MB",
#sum( data_free )/ 1024 / 1024 "Free Space in MB"
#FROM information_schema.TABLES
#GROUP BY table_schema ;'

#elif [ "$REPLY" = "1" ] && [ "$result" = 1 ]; then
#	echo "MySQL is not present on this system. Goodbye!"
#	break

#elif [ "$REPLY" = 2 ] && [ "$result" = 0 ]; then
#	read -p "You selected $REPLY which is $opt. Please enter database name: " answer
#	echo $answer
#	$mybin -e 'SELECT table_name AS "Table", round(((data_length + index_length) / 1024 / 1024), 2) as "size (MB)" FROM information_schema.TABLES WHERE table_schema = "$answer"  ORDER BY data_length DESC;'

#elif [ "$REPLY" = "2" ] && [ "$result" = 1 ]; then
#	echo "MySQL is not present on this system. Goodbye!"
#	break

#elif [ "$REPLY" = "3" ]; then
#	echo "Goodbye!"
#	break
#fi
done

