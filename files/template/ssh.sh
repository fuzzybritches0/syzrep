#!/bin/bash
root_dir="${HOME}/syzrep"

ssh -p 10022 -i ${root_dir}/files/stretch.img.key root@localhost "${@}"
