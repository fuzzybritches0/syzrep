#!/bin/bash

./reproduce.sh &
./run.sh
./decode_stacktrace.sh
rm report_raw.txt
exit 0
