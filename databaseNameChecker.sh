#!/bin/bash
shopt -s extglob


			#-------------------------- Check the name length--------------------------#
			if [ ${#DB_Name} -le 1 -o ${#DB_Name} -ge 64 ]
			then 
				echo -e " ${crossSign} ${RED} Error: Database name length should be from 1 to 64 characters.  ${crossSign} ${NC}"
				echo " "
				flag=0
			fi    	
							
			#-------------------------- Check for spaces --------------------------#
			if [[ $DB_Name =~ [[:space:]] ]]
			then 
				echo -e "${YELLOW} Warning: Database name cannot contain spaces, the spaces will be replaced with uderscore(_) ${NC}"
				echo -e "${YELLOW} The database name will be \"${DB_Name// /_}\" instead of \"$DB_Name\" ${NC}"
				echo ""
				DB_Name=${DB_Name// /_}
				flag=1								
			fi
			
			#-------------------------- Check for sepecial charachters OR if start with number OR if start with (_) --------------------------#
			if ! [[ $DB_Name =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]
			then 
				echo -e " ${crossSign} ${RED} Error: Database names may include letters, numbers, and underscores but must not start with a number or underscore. ${crossSign} ${NC} "
				flag=0 
			fi


