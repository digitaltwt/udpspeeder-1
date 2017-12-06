#!/bin/bash

ss-server -s 0.0.0.0 -p 8989 -m aes-256-gcm -k 131415 -u &

speederv2 -s -l0.0.0.0:8855 -r127.0.0.1:8989  --mode 0 -f20:10 -k "131415" 


