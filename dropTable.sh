#!/usr/bin/bash
rightSign='\xE2\x9C\x94'
crossSign='\xE2\x9D\x8C'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
yellow=$(tput setaf 3)  # Yellow text
nc=$(tput sgr0)         # No color
#_________________________________________________________________________________________________
#drop table with two ways whole or just data file and take confirmation from user
read -p "Please enter the table name you want to drop: " tableName
if [ ! -e "${tableName}.metadata" ]
   	then
        echo -e " ${crossSign} ${RED}Sorry... table with name '$tableName' not exists to drop ${NC}"
else
   	read -p "${yellow} Do you really want to drop the table '$tableName'? (yes/no): ${nc}" confirmation
	if [ "$confirmation" == "yes" ]
 	then
  	  list=("whole table" "data file only" "Exit") 
 	select answer in "${list[@]}"
   	 do
    	  	case $answer in
     	       "whole table")
                metadataTables=$( ls *.metadata )
                dataTables=$( ls *.data )
                rm "$tableName.data" "$tableName.metadata"
                echo -e "${rightSign} ${GREEN}Data file '$tableName.data' and '$tableName.metadata' removed successfully.${NC}"
                ;;
            "data file only")
                dataTables=$( ls *.data )
                rm "$tableName.data"
                 echo -e "${rightSign} ${GREEN}Data file '$tableName.data' removed successfully.${NC}"
                ;;
            "Exit")
                 echo -e "${rightSign} ${YELLOW}Exiting program!${NC}"
                exit;;
            *) 
                 echo -e "${crossSign} ${RED}Invalid choice. Please enter a valid option.${NC}";;
        esac
        break
    done
else
    echo -e "${crossSign} ${RED}Table '$tableName' not dropped.${NC}"
fi
fi
