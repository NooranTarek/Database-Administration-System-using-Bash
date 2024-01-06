#!/bin/bash
shopt -s extglob
export LC_COLLATE=C
#------------------------------------------------------------------------------------#
PS3="====> what you want to update?  "
updateActions=("Entire Column" "Specific Row" "Exit")
select action in "${updateActions[@]}";
	do    
	case $REPLY in
		1 | [Ee][Nn][Tt][Ii][Rr][EE][[:space:]][Cc][Oo][Ll][Uu][Mm][Nn])
			ans=1
			break
		;;
		
		2 | [Ss][Pp][Ee][Cc][Ii][Ff][Ii][CC][[:space:]][Rr][Oo][Ww])
			ans=2
			break
		;;
		
		3 | [Ee][Xx][Ii][Tt] )
		exit
		
		;;
		* ) 
		echo -e " ${crossSign} ${RED} Invalid Action ${crossSign} ${NC}"
		;;
	esac
					
	done 	
echo  "======================================================"

  
# -------------------------------------- Check if the table exists -------------------------------------#
read -p "=> Enter the Table Name you want to update it: " tableName
dataFile=$tableName.data

while ! [ -e $dataFile ];
do
	echo -e " ${crossSign} ${RED} This table name dosn't exist. Try again ${crossSign} ${NC}"
	read -p "=> Enter the Table Name you want to update it: " tableName
	dataFile=$tableName.data
done

metaDataFile=$tableName.metadata
header=`head -n 1 $metaDataFile`

# ------------------------------------- Check if the desiredColumnName exists -------------------------------------#
read -p "=> Enter the Column Name you want to update it: " desiredColumnName  

desiredColumnNumber=$(echo  "$header" | awk -F: -v desiredColumnName="$desiredColumnName" '{for(i=1; i<=NF; i++) if($i == desiredColumnName) print i}')


while [[ -z "$desiredColumnName" || -z $desiredColumnNumber ]]; 
do	
	echo -e " ${crossSign} ${RED} This column name dosn't exist. Try again ${crossSign} ${NC}"
	read -p "Enter the Column Name you want to update it: " desiredColumnName  
	desiredColumnNumber=$(echo  "$header" | awk -F: -v desiredColumnName="$desiredColumnName" '{for(i=1; i<=NF; i++) if($i == desiredColumnName) print i}')
done

read -p "=> Enter the New $desiredColumnName value: " newValue 

if [ "$ans" -eq 2 ];
then
	#------------------------------------- Check if the whereColumnName exists -------------------------------------#

	read -p "=> Enter the Condition Column: " whereColumnName  

	CondColumnNumber=$(echo "$header" | awk -F: -v whereColumnName="$whereColumnName" '{for(i=1; i<=NF; i++) if($i == whereColumnName) print i}')


	while [[ -z "$whereColumnName"  || -z $CondColumnNumber ]]; 
	do	
		echo -e " ${crossSign} ${RED} This column name dosn't exist. Try again ${crossSign} ${NC}"
		read -p "=> Enter the Condition Column: " whereColumnName   
		CondColumnNumber=$(echo -e "$header" | awk -F: -v whereColumnName="$whereColumnName" '{for(i=1; i<=NF; i++) if($i == whereColumnName) print i}')

	done


	read -p "=> Enter the Condition Value: " whereValue 
fi
#--------------------------------------------------------------------------------------------------------#

IFS=: read -a PKsArray < <(sed -n '3p' "$metaDataFile") 


if [ ${PKsArray[$(($desiredColumnNumber-1))]} ==  "yes" ]
then
	if [ $ans -eq 2 ];
	then

	       #--------------- check if the newValue is empty ---------------#
	       while [ -z "$newValue"  ];
	       do
	       		echo -e " ${crossSign} ${RED} This column is primary key, so values cannot be empty ${crossSign} ${NC}";
	       		read -p "=> Enter the New $desiredColumnName value: " newValue 
	       done	
	       #--------------- check if the newValue already exist ---------------#
		#exist=$(awk -F: -v input="$newValue" '$2 == input {print 1}' "$dataFile")
		exist=$(awk -F: -v input="$newValue" -v desiredColumnNumber=$desiredColumnNumber '$desiredColumnNumber == input {print 1}' "$dataFile")

		while  [ -n "$exist" ];
		do
		    echo -e "${crossSign} ${RED} This column is primary key. so the values cannot be repeated. ${crossSign} ${NC}"
		    read -p "=> Enter the New $desiredColumnName value: " newValue
		    #exist=$(awk -F: -v input="$newValue" '$2 == input {print 1}' "$dataFile")
		exist=$(awk -F: -v input="$newValue" -v desiredColumnNumber=$desiredColumnNumber '$desiredColumnNumber == input {print 1}' "$dataFile")
		done


	       #--------------------------------------------------------------------------#

	 
		temp_file=$(mktemp)
		if grep -q "$whereValue" "$dataFile"; then
		    awk  -v whereValue="$whereValue" \
			-v new_name="$newValue" \
			-v whereColumnName="$whereColumnName" \
			-v CondColumnNumber=$CondColumnNumber\
			-v desiredColumnNumber=$desiredColumnNumber\
			'BEGIN { FS = OFS =":" } $CondColumnNumber == whereValue { $desiredColumnNumber = new_name } 1' "$dataFile" > "$temp_file"

		    mv "$temp_file" "$dataFile"

		    echo -e " ${GREEN} ${rightSign}  Record with $whereColumnName=$whereValue updated successfully.${rightSign} ${NC}  "
		else
		    echo -e "${crossSign} ${RED} Record with $whereColumnName=$whereValue not found. ${crossSign} ${NC}"
		fi

		# Clean up temporary file
		rm -f "$temp_file"
	else
		echo -e " ${crossSign} ${RED} This column is Primary Key. You Can't set the entire column with the same value ${crossSign} ${NC}"
	fi
	###################################################      #HEREE  ###############################################
else 
	if [ "$ans" -eq 2 ];
	then
		temp_file=$(mktemp)
		if grep -q "$whereValue" "$dataFile"; then
		    awk  -v whereValue="$whereValue" \
			-v new_name="$newValue" \
			-v whereColumnName="$whereColumnName" \
			-v CondColumnNumber=$CondColumnNumber\
			-v desiredColumnNumber=$desiredColumnNumber\
			'BEGIN { FS = OFS =":" } $CondColumnNumber == whereValue { $desiredColumnNumber = new_name } 1' "$dataFile" > "$temp_file"

		    mv "$temp_file" "$dataFile"

		    echo -e " ${GREEN} ${rightSign}  Record with $whereColumnName=$whereValue updated successfully. ${crossSign} ${NC}"
		else
		    echo -e " ${crossSign} ${RED} Record with $whereColumnName=$whereValue not found. ${crossSign} ${NC}"
		fi

		# Clean up temporary file
		rm -f "$temp_file"
	else
		temp_file=$(mktemp)
		   awk  -v new_name="$newValue" \
			-v desiredColumnNumber=$desiredColumnNumber\
			'BEGIN { FS = OFS =":" }  {$desiredColumnNumber=new_name} 1' "$dataFile" > "$temp_file"	
			
		    mv "$temp_file" "$dataFile"
		    
		    echo -e " ${GREEN} ${crossSign} $desiredColumnName column updated successfully. ${crossSign} ${NC}"
		    rm -f "$temp_file"
	fi

fi

