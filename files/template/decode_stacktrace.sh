#!/bin/bash

[ ! -e "./linux/scripts/decode_stacktrace.sh" ] && echo "./linux/scripts/decode_stacktrace.sh not found!" && exit 1

cat ./report.txt | ./linux/scripts/decode_stacktrace.sh \
	./linux/vmlinux . > ./report_decoded.txt

