#!/bin/bash

./reproduce.sh &
./run.sh
devel ./decode_stacktrace.sh
rm report_raw.txt
exit 0
