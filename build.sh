#!/bin/bash

set -xe

gcc -ggdb -c numconv.s
ld -o numconv numconv.o
rm numconv.o
