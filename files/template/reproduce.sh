#!/bin/bash
root_dir="${HOME}/syzrep"

sleep 25s
./upload.sh
ssh -p 10022 -i ${root_dir}/files/stretch.img.key \
	root@localhost ./syz-execprog -repeat=0 -procs=8 ./reproducer.syz
