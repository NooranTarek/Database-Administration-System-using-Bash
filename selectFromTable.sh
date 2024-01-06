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
currentPath=$(pwd)
#____________________________________________________________________________________________________________________
#menu for choosing select type
while true
do
    echo  -e "${YELLOW}=== HN Select Menu ===${NC}"
    echo -e "${YELLOW}==============================================================${NC}"
   selectMenu=("Select whole table" "Select whole field"  "Select whole row" "Exit")
    select answer in "${selectMenu[@]}"
     do
        case $answer in
#____________________________________________________________________________________________________________________
#cat on the two files to combine them ans show whole table
            "Select whole table")
                echo -e "${GREEN}${rightSign}You selected: $answer ${NC}"
                read -p "${yellow}Please enter the name of the table you want to select:${nc} " tableName  
                 if [[  -z "$tableName" ]]
       			then
       			 echo "Please enter a value for the table you want"
                elif [[ -f "$currentPath/$tableName.data" && -f "$currentPath/$tableName.metadata" ]]
                then
                    cat "$tableName.metadata" "$tableName.data"
                elif [[ -f "$currentPath/$tableName.metadata" && ! -f "$currentPath/$tableName.data" ]]
                then
                    echo -e "${YELLOW}This table is empty ${NC}"
                    cat "$tableName.metadata"
                else
                    echo  -e " ${RED}${crossSign}   Table '$tableName' not found ${NC}"
                fi
                ;;
#____________________________________________________________________________________________________________________
#awk on .metadata to get field number then getting the values its contains
          "Select whole field")
           echo -e "${GREEN}${rightSign}  You selected: $answer ${NC}"
  	  read -p "${yellow} Please enter the name of the table you want to select a field from: ${nc}" tableName  
 	   if [[ -f "$currentPath/$tableName.data" && -f "$currentPath/$tableName.metadata" ]]
 	   then
   	     read -p "${yellow}Please enter the name of the field you want to select from $tableName: ${nc}" fieldName  
   	     fieldNumber=$(echo "$currentPath/$tableName.metadata" | awk -F: -v col="$fieldName" '{for (i=1; i<=NF; i++) if ($i == col) print i}' "$tableName.metadata")
   	   		 if [[  -z "$fieldName" ]]
       			then
       			 echo "Please enter a value for the field you want"
  		      elif [[ ${#fieldNumber} -gt 0 ]]
   		     then
       			    awk -F: -v fieldNum="$fieldNumber" '{if (NF >= fieldNum) print $fieldNum}' "$currentPath/$tableName.data"	
     		   else
           		 echo -e "${RED}${crossSign}    Field '$fieldName' not found in the metadata of '$tableName'. ${NC}"
        		fi
    	else
      	  echo "${RED}${crossSign}    Table '$tableName' not found ${NC}"
   	 fi
   	 ;;
#____________________________________________________________________________________________________________________
#awk on .metadata to get field number then reading specific value to get whole row
	"Select whole row")
         echo -e "${GREEN}${rightSign}   You selected: $answer ${NC}"
  	read -p "${yellow}Please enter the name of the table you want to select a row from:${nc} " tableName  
 	if [[ -f "$currentPath/$tableName.data" && -f "$currentPath/$tableName.metadata" ]]
 	 then
 		 read -p "${yellow}Please enter the name of the field:  ${nc} " fieldName
       		 fieldPosition=$(awk -F: -v field="$fieldName" 'NR==1 {for (i=1; i<=NF; i++) if ($i == field) print i}' "$currentPath/$tableName.metadata")
     		   if [[ $fieldPosition -gt 0 ]]
     		   then
     		 read -p "${yellow}Please enter the value in row: ${nc}" rowValue  
          		  result=$(awk -F: -v pos="$fieldPosition" -v value="$rowValue" '$(pos) == value {found=1; exit} END {print found}' "$currentPath/$tableName.data")
      			  if [[ $result -eq 0 ]]
      			  then
               			echo -e "${RED} ${crossSign}    Row  '$rowValue' not found in '$fieldName'. ${NC}"
         		   else
             			   awk -F: -v pos="$fieldPosition" -v value="$rowValue" '$(pos) == value' "$currentPath/$tableName.data"
         	  	 fi
     		  else
     		          echo -e "${RED} ${crossSign}    Field  '$fieldName' not found in '$fieldName'. ${NC}"
      		  fi
  	  else
    		    echo -e "${RED}${crossSign}    Table '$tableName' not found ${NC}"
   	 fi
 	   ;;
            "Exit")
                echo -e "${YELLOW}Exiting program! ${NC}"
                exit;;
            *) 
                echo -e"${RED}${crossSign}    Invalid choice. Please enter a valid option.${NC}";;
        esac
        break
    done
done
