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

echo -e "${YELLOW}=========================================================${NC}"
echo  -e "${YELLOW}Hello And Welcome To H&N Database Administration System.\nLet's Start To Create Table${NC}"
echo -e "${YELLOW}=========================================================${NC}"

#___________________________________________________________________________________________________________________________
#as I want to loop all over until I find the correct choice, I used a flag instead of using break 
#here we validate the name of the table if it's wrong at all
flag=false
while [ "$flag" != true ]
do
    read -p "Please enter a table name to create: " tableName
    if [ -e "${tableName}.metadata" ]
    then
        echo -e " ${RED} ${crossSign}   Sorry... table with name '$tableName' already exists. Try another name ${NC}"
    elif [[ ! "$tableName" =~ ^[a-zA-Z][a-zA-Z0-9_] || ${#tableName} -gt 64 ]]
    then
        echo -e "${RED}  ${crossSign}   Sorry... invalid name. Try another name starting with a letter, or underscore, and BE CAREFUL to be less than 64 characters ${NC}"
    else
        flag=true
    fi
done

#_________________________________________________________________________________________________________________________________
#here we validate the name if it has spaces replace it with underscore using sed
if echo "$tableName" | grep -q ' ' 
then
    tableNameReplacedSpace=$(echo "$tableName" | sed 's/ /_/g')
    touch "${tableNameReplacedSpace}.metadata"
    touch "${tableNameReplacedSpace}.data"
    echo -e " ${GREEN} ${rightSign}   Table with name '$tableNameReplacedSpace' created successfully ${NC} "
    validFieldNumber=false
    while [ "$validFieldNumber" != true ]
    do
        read -p "Please enter the number of fields you want to enter: " fieldNumber
        if [[ "$fieldNumber" =~ ^[0-9]+$ ]]
        then
            validFieldNumber=true
        else
            echo -e "  ${crossSign} ${RED}   Invalid input. Please enter a valid number for the field number ${NC} "
        fi
    done

    fieldNames=""
    dataTypes=""
    primaryKeys=""
    for ((i=1; i<=fieldNumber; i++))
    do
        flag=false
        while [ "$flag" != true ]
        do
            read -p "Please enter field name for field $i: " fieldName
            if [[ ! "$fieldName" =~ ^[a-zA-Z][a-zA-Z0-9_] || ${#fieldName} -gt 64 ]]
            then
                echo -e "  ${crossSign} ${RED}   Sorry... invalid field name. Try another name starting with a letter, or underscore, and BE CAREFUL to be less than 64 characters ${NC} "
            elif grep -q -w "$fieldName" "${tableNameReplacedSpace}.metadata"
            then
                echo -e "  ${crossSign} ${RED}   Sorry... field name '$fieldName' already exists. Try another name ${NC}"
            else
                fieldNames+="$fieldName:"
                while [ "$flag" != true ]
                do
                    read -p "Please enter field data type for $fieldName you have to write ( 'string' or 'number') : " fieldDataType
                    case "$fieldDataType" in
                        "string" | "number")
                            dataTypes+="$fieldDataType:"
                            flag=true
                            ;;
                        *)
                            echo -e "  ${crossSign} ${RED}   Invalid data type. Please enter ( 'string' or 'number') ${NC}"
                            ;;
                    esac
                done

                flag=false
                while [ "$flag" != true ]
                do
                    read -p "Is $fieldName a primary key? (yes/no): " isPrimary
                    case "$isPrimary" in
                        "yes" | "no")
                            primaryKeys+="$isPrimary:"
                            flag=true
                            ;;
                        *)
                            echo -e "  ${crossSign} ${RED}   Invalid input. Please enter 'yes' or 'no' ${NC} "
                            ;;
                    esac
                done
            fi
        done
    done

    echo -n "$fieldNames" >> "${tableNameReplacedSpace}.metadata"
    echo >> "${tableNameReplacedSpace}.metadata"
    echo -n "$dataTypes" >> "${tableNameReplacedSpace}.metadata"
    echo >> "${tableNameReplacedSpace}.metadata"
    echo "$primaryKeys" >> "${tableNameReplacedSpace}.metadata"

#___________________________________________________________________________________________________________________________________
#if the user enters a table name without any problems
else
    touch "${tableName}.metadata"
    touch "${tableName}.data"
    echo -e "${GREEN}${rightSign}   Table with name '$tableName' created successfully${NC}"
    validFieldNumber=false
    while [ "$validFieldNumber" != true ]
    do
        read -p "Please enter the number of fields you want to enter: " fieldNumber
        # Check if fieldNumber is a valid number
        if [[ "$fieldNumber" =~ ^[0-9]+$ ]]
        then
            validFieldNumber=true
        else
            echo -e " ${crossSign} ${RED}   Invalid input. Please enter a valid number for the field number.${NC}"
        fi
    done

    fieldNames=""
    dataTypes=""
    primaryKeys=""
    declaredFieldNames=()
    for ((i=1; i<=fieldNumber; i++))
    do
        counter=0
        flag=false
        pkFlag=false
        while [ "$flag" != "true" ]
        do
            read -p "Please enter field name for field $i: " fieldName
            if [[ ! "$fieldName" =~ ^[a-zA-Z][a-zA-Z0-9_]  || ${#fieldName} -gt 64 ]]
            then
                echo -e "${RED}${crossSign}   Sorry... invalid field name. Try another name starting with a letter, or underscore, and BE CAREFUL to be less than 64 characters ${NC}"
            elif grep -q -w "$fieldName" "${tableName}.metadata"
            then
                echo -e " ${crossSign} ${RED}   Sorry... field name '$fieldName' already exists. Try another name.${NC}"
            elif [[ " ${declaredFieldNames[@]} " =~ " ${fieldName} " ]]
            then
                echo -e " ${crossSign} ${RED}   Sorry... field name '$fieldName' already used. Try another name.${NC}"
            else
                declaredFieldNames+=("$fieldName")
                fieldNames+="$fieldName:"
                while [ "$flag" != "true" ]
                do
                    read -p "Please enter field data type for $fieldName you have to write ( 'string' or 'number') : " fieldDataType
                    case "$fieldDataType" in
                        "string" | "number")
                            dataTypes+="$fieldDataType:"
                            flag=true
                            ;;
                        *)
                            echo -e " ${crossSign} ${RED}   Invalid data type. Please enter ('string' or 'number').${NC}"
                            ;;
                    esac
                done
		
                while [ "$pkFlag" != "true" ]
                do
                    read -p "Is $fieldName a primary key? (yes/no): " isPrimary
                    case "$isPrimary" in
                        "yes" )
                            if [[ $counter -eq 0 && ! $(grep -o -w "yes" <<< "$primaryKeys") ]]
                            then
                                primaryKeys+="$isPrimary:"
                                counter=$((counter + 1))
                                pkFlag=true
                            else
                                echo -e " ${crossSign} ${RED}   Sorry... can't add more than one unique PK in the same table ${NC}"
                                pkFlag=false
                            fi
                            ;;
                        "no")
                            primaryKeys+="$isPrimary:"
                            pkFlag=true
                            ;;
                        *)
                            echo -e " ${crossSign} ${RED}   Invalid input. Please enter 'yes' or 'no'. ${NC}"
                            ;;
                    esac
                done
            fi
        done
    done

    echo -n "$fieldNames" >> "${tableName}.metadata"
    echo >> "${tableName}.metadata"
    echo -n "$dataTypes" >> "${tableName}.metadata"
    echo >> "${tableName}.metadata"
    echo "$primaryKeys" >> "${tableName}.metadata"
fi

