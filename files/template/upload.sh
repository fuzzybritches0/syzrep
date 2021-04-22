#!/bin/bash
root_dir="${HOME}/syzrep"

scp -P 10022 -i ${root_dir}/files/stretch.img.key ${root_dir}/files/syz-execprog \
	${root_dir}/files/syz-executor ./reproducer.syz root@localhost:
