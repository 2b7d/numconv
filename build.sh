#!/bin/bash

set -xe

gcc -g -c numconv.s
ld -o numconv numconv.o
rm numconv.o
