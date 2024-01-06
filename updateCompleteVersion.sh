#!/bin/bash
# -------------------------------------- Check if the table exists -------------------------------------#
read -p "Enter the Table Name you want to update it: " tableName
dataFile=$tableName.data

while ! [ -e $dataFile ];
do
	echo ">> This table name dosn't exist. Try again"
	read -p "Enter the Table Name you want to update it: " tableName
	dataFile=$tableName.data
done

metaDataFile=$tableName.metadata
header=`head -n 1 $metaDataFile`

# ------------------------------------- Check if the desiredColumnName exists -------------------------------------#
read -p "Enter the Column Name you want to update it: " desiredColumnName  

desiredColumnNumber=$(echo "$header" | awk -F: -v desiredColumnName="$desiredColumnName" '{for(i=1; i<=NF; i++) if($i == desiredColumnName) print i}')

while [ -z "$desiredColumnNumber" ]; 
do	
	echo ">> This column name dosn't exist. Try again"
	read -p "Enter the Column Name you want to update it: " desiredColumnName  
	desiredColumnNumber=$(echo "$header" | awk -F: -v desiredColumnName="$desiredColumnName" '{for(i=1; i<=NF; i++) if($i == desiredColumnName) print i}')
done

read -p "Enter the New $desiredColumnName value: " newValue 
#------------------------------------- Check if the whereColumnName exists -------------------------------------#

read -p "Enter the Condition Column: " whereColumnName  

CondColumnNumber=$(echo "$header" | awk -F: -v whereColumnName="$whereColumnName" '{for(i=1; i<=NF; i++) if($i == whereColumnName) print i}')


while [ -z "$CondColumnNumber" ]; 
do	
	echo ">> This column name dosn't exist. Try again"
	read -p "Enter the Condition Column: " whereColumnName   
	CondColumnNumber=$(echo "$header" | awk -F: -v whereColumnName="$whereColumnName" '{for(i=1; i<=NF; i++) if($i == whereColumnName) print i}')

done


read -p "Enter the Condition Value: " whereValue 
#--------------------------------------------------------------------------------------------------------#

IFS=: read -a PKsArray < <(sed -n '3p' "$metaDataFile") 


if [ ${PKsArray[$(($desiredColumnNumber-1))]} ==  "yes" ]
then
isRepeated=1

       #--------------- check if the newValue is empty ---------------#
       while [ -z "$newValue"  ];
       do
       		echo ">> This column is primary key, so values cannot be empty";
       		read -p "Enter the New $desiredColumnName value: " newValue 
       done	
       #--------------- check if the newValue already exist ---------------#
	#exist=$(awk -F: -v input="$newValue" '$2 == input {print 1}' "$dataFile")
	exist=$(awk -F: -v input="$newValue" -v desiredColumnNumber=$desiredColumnNumber '$desiredColumnNumber == input {print 1}' "$dataFile")

	while  [ -n "$exist" ];
	do
	    echo ">> This column is primary key. so the values cannot be repeated."
	    read -p "Enter the New $desiredColumnName value: " newValue
	    #exist=$(awk -F: -v input="$newValue" '$2 == input {print 1}' "$dataFile")
	exist=$(awk -F: -v input="$newValue" -v desiredColumnNumber=$desiredColumnNumber '$desiredColumnNumber == input {print 1}' "$dataFile")
	done

	echo "You entered a unique value: $newValue"
       #--------------------------------------------------------------------------#
	: '
       while IFS= read line; 
       do 	   
       	    #--------------- check if the newValue already exists ---------------#
	   if [ "$newValue" == "$line" ];
	   then
	   	echo "This column is primary key, so values cannot be repeated";
	   	isRepeated=1
	   fi	   
	   	   	read -p "Enter the New $desiredColumnName value: " newValue 
	done < <(cut -d: -f$desiredColumnNumber "$dataFile")
	'
	temp_file=$(mktemp)
	if grep -q "$whereValue" "$dataFile"; then
	    awk  -v whereValue="$whereValue" \
		-v new_name="$newValue" \
		-v whereColumnName="$whereColumnName" \
		-v CondColumnNumber=$CondColumnNumber\
		-v desiredColumnNumber=$desiredColumnNumber\
		'BEGIN { FS = OFS =":" } $CondColumnNumber == whereValue { $desiredColumnNumber = new_name } 1' "$dataFile" > "$temp_file"

	    mv "$temp_file" "$dataFile"

	    echo "Record with $whereColumnName=$whereValue updated successfully."
	else
	    echo "Record with $whereColumnName=$whereValue not found."
	fi

	# Clean up temporary file
	rm -f "$temp_file"
else 
	temp_file=$(mktemp)
	if grep -q "$whereValue" "$dataFile"; then
	    awk  -v whereValue="$whereValue" \
		-v new_name="$newValue" \
		-v whereColumnName="$whereColumnName" \
		-v CondColumnNumber=$CondColumnNumber\
		-v desiredColumnNumber=$desiredColumnNumber\
		'BEGIN { FS = OFS =":" } $CondColumnNumber == whereValue { $desiredColumnNumber = new_name } 1' "$dataFile" > "$temp_file"

	    mv "$temp_file" "$dataFile"

	    echo "Record with $whereColumnName=$whereValue updated successfully."
	else
	    echo "Record with $whereColumnName=$whereValue not found."
	fi

	# Clean up temporary file
	rm -f "$temp_file"

fi

