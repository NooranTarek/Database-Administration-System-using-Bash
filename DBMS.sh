#!/bin/bash
shopt -s extglob
export LC_COLLATE=C

rightSign='\xE2\x9C\x94'
crossSign='\xE2\x9D\x8C'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

currentPath=`pwd` # to know the path where the will user run the program.

# check if DB dir exit or not.
if [ ! -d "$currentPath/DB" ];
then 
    mkdir "$currentPath/DB"
fi

cd $currentPath/DB

echo  -e " " 

#----------------------------------- create selcet menu ------------------------------------
PS3="====> choose an action to do: "

actions=("Create Database" "List Databases" "Connect to Database" "Drop Database" "Exit")


select action in "${actions[@]}"; # @ to get all elements.
	do    
	# export flag=1
	# export DB_Name=" "
	
	flag=1
	DB_Name=" "
		case $REPLY in
			################################# Create the databse ################################
		    1 | [Cc][Rr][Ee][Aa][Tt][Ee][[:space:]][Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee] )

			read -p "=> Enter database name: " DB_Name
			echo  -e " "

			
			source databaseNameChecker.sh

			if (( flag == 1 ))
			then 
				if [ -d "$currentPath/DB/$DB_Name" ]
				then
					echo  -e " ${crossSign} ${RED} Error: This Database already exists ${crossSign} ${NC} "
					echo  -e "---------------------------------------------"
				else
					mkdir "$currentPath/DB/$DB_Name"
					echo  -e  "${GREEN} ${rightSign} ${rightSign}  $DB_Name database is created ${rightSign}  ${rightSign} ${NC}"   
					echo  -e "---------------------------------------------"
					echo  -e " "
				fi
			fi
			
			;;	
			
			################################# List available databases ################################	
		    2 | [Ll][Ii][Ss][Tt][[:space:]][Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee] )
			echo  -e "=> The available databases are: "
			ls  "$currentPath/DB" 
			echo  -e " "
			;;
			
			################################# Connect to a databases ################################	
		    3 | [Cc][Oo][Nn][Nn][Ee][Cc][Tt][[:space:]][Tt][Oo][[:space:]][Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee] )
		    
		        read -p "=> Enter database name: " DB_Name
		        source databaseNameChecker.sh
		        if (( flag == 1 ))
		        then
				if [ -d "$currentPath/DB/$DB_Name" ]
				then
					 cd "./$DB_Name"
					 echo  -e " ${WHITE} Your path now is: `pwd`  ${NC} " 
		  			 source tableMenue.sh
				else
					echo  -e " ${crossSign} ${RED} Error: This Database doesn't exist ${crossSign} ${NC} "  
					echo  -e "---------------------------------------------"
					echo  -e ""
				fi
			fi	
			;;
			
			################################# Drop a databases ################################	
		    4 | [Dd][Rr][Oo][Pp][[:space:]][Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee] )
			read -p "Enter database name: " DB_Name
			
			source databaseNameChecker.sh
		        if (( flag == 1 ))
		        then
				if [ -d "$currentPath/DB/$DB_Name" ]
				then
					
					rm -r "$currentPath/DB/$DB_Name" 
					echo  -e "${rightSign} ${GREEN}  $DB_Name database is deleted successfully.${rightSign} ${NC}  "
					echo  -e "---------------------------------------------"
					echo  -e " "
				else
					echo  -e "${crossSign} ${RED} Error: This Database doesn't exist ${crossSign} ${NC} "  
					echo  -e "---------------------------------------------"
					echo  -e " "
				fi
		        fi 
			;;
			
		    5 | [Ee][Xx][Ii][Tt] )
			break
			;;
		    * ) 
			echo  -e  " ${crossSign} ${RED} Invalid Action ${crossSign} ${NC} "
			echo  -e "---------------------------------------------"
			echo  -e " "
			;;
		esac				
	done 	
: '
	
	
