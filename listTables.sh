#!/usr/bin/bash
rightSign='\xE2\x9C\x94'
crossSign='\xE2\x9D\x8C'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
metadataTables=$(ls *.metadata 2>/dev/null)
dataTables=$(ls *.data 2>/dev/null)
currentPath=`pwd`
#__________________________________________________________________________________________________________________
#listing tables using ls
while true
do
    echo -e "${YELLOW}=== HN List Menu ===${NC}"
    echo -e "${YELLOW}==============================================================${NC}"
    listMenu=("List all tables" "List metadata tables" "List data table" "Exit") 
    select answer in "${listMenu[@]}"
    do
        case $answer in
            "List all tables")
                echo -e "${GREEN}${rightSign}    You selected: $answer${NC}"
                if [[ ! "$dataTables" && ! "$metadataTables" ]]
                then
                    echo -e "${crossSign} ${RED}   There are no tables. Try to create tables to list them.${NC}"
                else
                    echo -e "${GREEN}${rightSign}    Tables in this database are:${NC}"
                    echo -e "$dataTables""\n""$metadataTables"
                fi
                ;;
            "List metadata tables")
                echo -e "${GREEN}${rightSign}    You selected: $answer${NC}"
                if [ ! "$metadataTables" ]
                then
                    echo -e "${YELLOW}There is no metadata tables so no tables created yet${NC}"
                else
                    echo -e "${GREEN}${rightSign}    Metadata tables in this database are:${NC}"
                    echo "$metadataTables"
                fi
                ;;
            "List data table")
                echo -e "${GREEN}${rightSign}   You selected: $answer${NC}"
                if [ ! "$dataTables" ]
                then
                    echo -e "${YELLOW}There is no data tables so no tables filled yet${NC}"
                else
                    echo -e "${GREEN}${rightSign}    Data tables in this database are:${NC}"
                    echo "$dataTables"
                fi
                ;;
            "Exit")
                echo -e "${GREEN}${rightSign}    Exiting program! ${NC}"
                exit;;
            *) 
            echo -e "${crossSign} ${RED}   Invalid choice. Please enter a valid option. ${NC}";;
        esac
        break
    done
done



