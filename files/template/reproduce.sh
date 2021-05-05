#!/bin/bash
root_dir="${HOME}/syzrep"

filter_report() {
	while read line; do
		[ "${line/BUG}" != "${line}" ] && start_report="1"
		[ "${line/KASAN}" != "${line}" ] && start_report="1"
		[ "${line/UBSAN}" != "${line}" ] && start_report="1"
		[ "${line/WARNING}" != "${line}" ] && start_report="1"
		if [ "${start_report}" == "1" ]; then
			#[ "${line/'Creating new'}" == "${line}" ] && \
			#[ "${line/'filter on device'}" == "${line}" ] && \
			#[ "${line/'entered blocking state'}" == "${line}" ] && \
			#[ "${line/'entered forwarding state'}" == "${line}" ] && \
			#[ "${line/'link becomes ready'}" == "${line}" ] && echo ${line}
			echo ${line}
		fi
	done
}


sleep 25s
./upload.sh
ssh -p 10022 -i ${root_dir}/files/stretch.img.key \
	root@localhost ./syz-execprog -output -repeat=0 -procs=8 ./reproducer.syz |\
		filter_report > report_raw.txt
