#!/bin/bash

input="$1"
l="$2"
u="$3"
Precision="$4"

declare -a Ans
declare -a L
declare -a U
n=0

while IFS=',' read -r -a row || [ -n "${row[*]}" ]
do
    procesed_array=()
    for i in "${row[@]}"
    do
        cur="${i%$'\r'}"
        procesed_array+=("$cur")
    done
    Ans+=("${procesed_array[@]}")
    ((n++))
done < "$input"

for ((i=0; i<n; i++))
do
    for ((j=0; j<n; j++))
    do
        L[$((i*n + j))]="0"
        U[$((i*n + j))]="0"
    done
done

for ((i=0; i<n; i++))
do
    L[$((i*n + i))]="1"
    for ((j=i; j<n; j++))
    do
        su="0"
        for ((k=0; k<i; k++))
        do
            su=$(echo "$su + ${L[$((i*n + k))]} * ${U[$((k*n + j))]}" | bc -l)
        done
        U[$((i*n + j))]=$(echo "${Ans[$((i*n + j))]} - $su" | bc -l)
    done
    for ((j=i+1; j<n; j++))
    do
        sl="0"
        for ((k=0; k<i; k++))
        do
            sl=$(echo "$sl + ${L[$((j*n + k))]} * ${U[$((k*n + i))]}" | bc -l)
        done
        L[$((j*n + i))]=$(echo "(${Ans[$((j*n + i))]} - $sl) / ${U[$((i*n + i))]}" | bc -l)
    done
done

: > "$l"
: > "$u"

for ((i=0; i<n; ++i))
do
    line=""
    for ((j=0; j<n; ++j))
    do
        value=$(printf "%.*f" "$Precision" "${L[((i*n+j))]}")
        if [ "$j" -eq 0 ]
        then
            line="$value"
        else
            line="$line,$value"
        fi
    done
    echo "$line" >> "$l"
done

for ((i=0; i<n; ++i))
    do
    line=""
    for ((j=0; j<n; ++j))
    do
        val=$(printf "%.*f" "$Precision" "${U[((i*n+j))]}")
        if [ "$j" -eq 0 ]
        then
            line="$val"
        else
            line="$line,$val"
        fi
    done
    echo "$line" >> "$u"
done
