#!/usr/bin/bash

rightSign='\xE2\x9C\x94'
crossSign='\xE2\x9D\x8C'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
currecntDirectory=$(pwd) 
while true
do
    echo "=============================================================="
    echo "=== HN Table Menu ==="
    echo "=============================================================="
    tableMenu=("Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Update Table" "Delete From Table" "Exit") 
    select answer in "${tableMenu[@]}"
    do
        case $answer in
         "Create Table")
         		 echo -e " ${GREEN} ${rightSign}     You selected: $answer ${NC}"
         		createTable.sh
         		;;
            "List Tables") 
         		 echo -e  "${GREEN} ${rightSign}     You selected: $answer ${NC}"
            		listTables.sh
            		;;
            "Drop Table") 
         		 echo -e  "${GREEN} ${rightSign}     You selected: $answer ${NC}"
            		dropTable.sh
            		;;
            "Insert into Table") 
         		 echo -e "${GREEN} ${rightSign}     You selected: $answer ${NC}"
            		insertIntoTable.sh
            		;;
            "Select From Table")
         		 echo -e "${GREEN} ${rightSign}     You selected: $answer ${NC}"
            		 selectFromTable.sh
            		 ;;
            "Update Table") 
         		 echo -e "${GREEN} ${rightSign}     You selected: $answer ${NC}"
            		#updateTable.sh
            		ExternalUpdateTable.sh
            		;;
            "Delete From Table") 
         		 echo -e "${GREEN} ${rightSign}     You selected: $answer ${NC}"
            		deleteFromTable.sh
            		;;
            "Exit") 
            		echo "Exiting program!"
            		exit;;
            *) 
            echo "Invalid choice. Please enter a valid option.";;
        esac
        break
    done
done

