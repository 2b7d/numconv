#!/bin/bash

set -xe

yasm -f elf64 -g dwarf2 numconv.asm

for f in ./include/*.asm
do
    yasm -f elf64 -g dwarf2 $f
done

ld -o numconv *.o

rm *.o
