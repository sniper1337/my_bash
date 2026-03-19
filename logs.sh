#!/bin/bash

Lines=10
Order="up"
directory=""

args=("$@")
for ((i=0; i<${#args[@]}; i++)) 
do
    if [[ "${args[i]}" == "-l" ]] || [[ "${args[i]}" == "--lines" ]]
    then
        Lines="${args[i+1]}"
        ((i++))
    elif [[ "${args[i]}" == "-o" ]] || [[ "${args[i]}" == "--order" ]]
    then
        Order="${args[i+1]}"
        ((i++))
    else
        directory="${args[i]}"
    fi
done

temp=$(mktemp)
reg='^\[ (INFO|DEBUG|WARNING|ERROR) \][[:space:]]([0-9]{2}:[0-9]{2}:[0-9]{4})[[:space:]](0|[1-9][0-9]*)[[:space:]]([a-zA-Z_]*)$'

while IFS= read -r -d '' file
do
    while IFS= read -r line
    do
        if [[ "$line" =~ $reg ]]
        then
            id_str="${BASH_REMATCH[3]}"
            echo "$id_str:$line" >> "$temp"
        fi
    done < "$file"
done < <(find "$directory" -type f -name "*.log" -print0)

if [[ -s "$temp" ]]
then
    sort -t':' -k1,1nr "$temp" > "${temp}_sorted"
    cut -d':' -f2- "${temp}_sorted" > "${temp}_logs"
    
    if [[ "$Order" == "up" ]]
    then
        head -n "$Lines" "${temp}_logs"
    else
        tail -n "$Lines" "${temp}_logs"
    fi
fi

rm -f "$temp" "${temp}_logs" "${temp}_sorted"
