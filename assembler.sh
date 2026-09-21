#!/usr/bin/env bash
if [ $# -eq 0 ]; then
    echo "usage: no argument is provided"
    exit 1
fi

if [ $# -gt 1 ]; then
    echo "usage: more than one arguments are provided"
    exit 1
fi

if [ -d "$1" ]; then
    echo "usage: input is not a file or it does not exist"
    exit 1
fi

if [[ "$1" != *.vsc ]]; then
    echo "usage: input does not have the extension .vsc"
    exit 1
fi


if [ ! -f "$1" ]; then
    echo "usage: input is not a file or it does not exist"
    exit 1
fi

if [ ! -s "$1" ]; then
    echo "usage: the file is empty - no .bin file is produced"
    exit 1
fi

#Spltting .vsc file into 3 parts
n_values=$(head -n 1 "$1")
statics=$(tail -n +2 "$1" | head -n "$n_values")
instructions=$(tail -n +$((n_values + 2)) "$1")

#turning the bytes into a list
bytes=()

#getting the first n values
if [ "$n_values" -gt 0 ]; then
    while read -r value; do
        bytes+=("$value")
    done <<< "$statics"
fi

kind="QUIT"

#getting the instruction and analyzing their opcode
while IFS=, read -r name reg addr; do
    if [ -z "$name" ]; then
        continue
    fi

    if [ "$name" = "LOAD" ]; then
        opcode=1
    elif [ "$name" = "STORE" ]; then
        opcode=2
    elif [ "$name" = "ADD" ]; then
        opcode=3
    elif [ "$name" = "SUB" ]; then
        opcode=4
    elif [ "$name" = "QUIT" ]; then
        opcode=8
    elif [ "$name" = "PRINT" ]; then
        opcode=9
    fi

    if [ "$name" = "ADD" ] || [ "$name" = "SUB" ]; then
        kind="ADD/SUB"
    fi

    bytes+=( $(( (opcode << 2) + reg )) )
    bytes+=( "$addr" )
done <<< "$instructions"
