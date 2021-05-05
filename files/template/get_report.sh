#!/bin/bash

filter_report() {
	while read line; do
		[ "${line/============================================}" != "${line}" ] && start_report=
		[ "${line/'panic_on_warn set'}" != "${line}" ] && start_report=
		[ "${line/KASAN}" != "${line}" ] && start_report="1"
		[ "${line/UBSAN}" != "${line}" ] && start_report="1"
		[ "${line/WARNING}" != "${line}" ] && start_report="1"
		if [ "${start_report}" == "1" ]; then
			[ "${line/'Creating new'}" == "${line}" ] && \
			[ "${line/'filter on device'}" == "${line}" ] && \
			[ "${line/'entered blocking state'}" == "${line}" ] && \
			[ "${line/'entered forwarding state'}" == "${line}" ] && \
			[ "${line/'link becomes ready'}" == "${line}" ] && echo ${line}
		fi
	done
}

cut_timestamps() {
	while read line; do
		echo "${line:20}"
	done
}

./reproduce.sh &
./run.sh | ansi2txt > ./report_full.txt
cat ./report_full.txt | filter_report | cut_timestamps > ./report.txt
./decode_stacktrace.sh
cat ./report_decoded.txt | ansi2txt > report.txt
rm ./report_decoded.txt
rm ./report_full.txt

exit 0
