#!/usr/bin/env bash

#Written by Jonathan Silman
#This script is designed to obtain information about disk usage for databases present in MySQL.

#Clearing the terminal screen.
clear

#Setting the title and menu instruction variables.

TITLE="MySQL Database Disk Usage Calculator\n"
MENU="Choose one of the following options:\n"

#Performing a check to make sure MySQL is present on the system and storing the results into variables to be used in functions.

mybin=$(which mysql 2>/dev/null)
result=$?

#Print the Title and Menu messages to terminal.

echo -e "$TITLE"
echo -e "$MENU"

#The all_dbs function displays disk usage information for all databases and their indexes as well as the number of tables in each database.

all_dbs () {
	if [ "$REPLY" = 1 ] && [ "$result" = 0 ]; then
		$mybin -e 'SELECT table_schema as `Database`,ROUND(SUM(data_length) /1024/1024, 1) AS "Data MB", ROUND(SUM(index_length)/1024/1024, 1) AS "Index MB", ROUND(SUM(data_length + index_length)/1024/1024, 1) AS "Total MB", COUNT(*) "Num Tables" FROM INFORMATION_SCHEMA.TABLES GROUP BY table_schema;'

	else [ "$REPLY" = 1 ] && [ "$result" = 1 ]
		echo "MySQL is not present on this system. Goodbye!"
		exit
	fi
}

#The tables function displays the name of each table in a specified database and the size of each table therein. Verifies the specified database exists and if not, exits the script.

tables () {
	if [ "$REPLY" = 2 ] && [ "$result" = 0 ]; then
		read -p "You selected $REPLY which is $opt. Please enter database name: " answer
		mysqlshow "$answer" > /dev/null 2>&1
		db_exists=$?

		if [ "$REPLY" = 2 ] && [ "$result" = 0 ] && [ "$db_exists" = 0 ]; then
			echo $answer
			$mybin -e "SELECT table_name AS 'Table', round(((data_length + index_length) / 1024 / 1024), 2) as 'size (MB)' FROM information_schema.TABLES WHERE table_schema = '${answer}' ORDER BY data_length DESC;"
		else [ "$REPLY" = 2 ] && [ "$result" = 0 ] && [ "$db_exists" = 1 ]
			echo "That database does not exist. Goodbye!"
			exit
		fi
	else [ "$REPLY" = "2" ] && [ "$result" = 1 ]
		echo "MySQL is not present on this system. Goodbye!"
		exit
	fi
}

#The storage function provides disk usage information for the storage engines in MySQL. 

storage () {
	if [ "$REPLY" = 3 ] && [ "$result" = 0 ]; then
		$mybin -e 'SELECT ENGINE,ROUND(SUM(data_length) /1024/1024, 1) AS "Data MB", ROUND(SUM(index_length)/1024/1024, 1) AS "Index MB", ROUND(SUM(data_length + index_length)/1024/1024, 1) AS "Total MB", COUNT(*) "Num Tables" FROM  INFORMATION_SCHEMA.TABLES WHERE  table_schema not in ("information_schema", "performance_schema") GROUP BY ENGINE;'
	else [ "$REPLY" = "3" ] && [ "$result" = 1 ]
		echo "MySQL is not present on this system. Goodbye!"
		exit
	fi
}

#A while loop to create a menu that is presented to the user. The user can make their selection and also to enter a specified database if they choose the Specific Database option. Includes an option to quit the script and also verifies that the input matches an option that is available.

while true; do

	options=("All Databases" "Specific Database" "Storage Engines" "Quit")

	select opt in "${options[@]}"; do
		case $REPLY in
			1) all_dbs;;
			2) tables;;
			3) storage;;
			4) echo "Goodbye!"; exit;;
			*) echo "Invalid option $REPLY. Please enter one of the displayed options.";;
		esac
	done
done