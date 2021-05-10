#!/bin/bash

root_dir="${HOME}/syzrep"
host_port_ssh=10022

if [ "$( basename "${0}")" == "ssh.sh" ]; then
	ssh -p ${host_port_ssh} -i ${root_dir}/files/stretch.img.key root@localhost "${@}"
	exit 0
fi

# https://github.com/google/syzkaller/blob/master/docs/syzbot.md
run() {
	qemu-system-x86_64 -smp 2 -m 4G -enable-kvm -cpu host \
	    -net nic -net user,hostfwd=tcp::${host_port_ssh}-:22 \
	    -kernel ./linux/arch/x86/boot/bzImage \
	    -nographic \
	    -device virtio-scsi-pci,id=scsi \
	    -device scsi-hd,bus=scsi.0,drive=d0 \
	    -drive file="${root_dir}/files/stretch.img",format=raw,if=none,id=d0 \
	    -snapshot -display none -no-reboot \
	    -append "root=/dev/sda console=ttyS0 earlyprintk=serial \
	      oops=panic panic_on_warn=1 panic=-1 kvm-intel.nested=1 \
	      security=apparmor ima_policy=tcb workqueue.watchdog_thresh=140 \
	      nf-conntrack-ftp.ports=20000 nf-conntrack-tftp.ports=20000 \
	      nf-conntrack-sip.ports=20000 nf-conntrack-irc.ports=20000 \
	      nf-conntrack-sane.ports=20000 vivid.n_devs=16 \
	      vivid.multiplanar=1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2 \
	      spec_store_bypass_disable=prctl nopcid"	
}

upload() {
	scp -P ${host_port_ssh} -i ${root_dir}/files/stretch.img.key ${root_dir}/files/syz-execprog \
		${root_dir}/files/syz-executor ./reproducer.syz root@localhost:
}

reproduce() {
	sleep 25s
	upload
	ssh -p ${host_port_ssh} -i ${root_dir}/files/stretch.img.key \
		root@localhost ./syz-execprog -repeat=0 -procs=8 ./reproducer.syz > ./report_full2.txt
	ssh -p ${host_port_ssh} -i ${root_dir}/files/stretch.img.key \
		root@localhost systemctl poweroff
}

filter_report() {
	while read line; do
		[ "${line/============================================}" != "${line}" ] && start_report=
		[ "${line/'panic_on_warn set'}" != "${line}" ] && start_report=
		[ "${line/BUG}" != "${line}" ] && start_report="1"
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

reproduce &

run | ansi2txt >> ./report_full1.txt

cat ./report_full1.txt | filter_report | cut_timestamps > ./report1.txt
./decode_stacktrace.sh 1
cat ./report_decoded1.txt | ansi2txt > report1.txt
rm ./report_decoded1.txt
rm ./report_full1.txt

cat ./report_full2.txt | filter_report > ./report2.txt
./decode_stacktrace.sh 2
mv ./report_decoded2.txt report2.txt
rm ./report_full2.txt

[ ! "$(cat ./report1.txt)" ] && rm ./report1.txt
[ ! "$(cat ./report2.txt)" ] && rm ./report2.txt

exit 0
