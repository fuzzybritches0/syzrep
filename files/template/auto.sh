#!/bin/bash

root_dir="${HOME}/syzrep"
conf="syzrep.rc"

[ ! -f "./${conf}" ] && echo "./${conf} not found!" && exit 1
. "./${conf}"

[ ! "${REPRODUCER_HASH}" ] && echo "REPRODUCER_HASH not set!" && exit 1
[ ! "${KCONFIG_HASH}" ] && echo "KCONFIG_HASH not set!" && exit 1

if [ ! -d "${root_dir}/linux/${KCONFIG_HASH}" ]; then
	echo -n "copying linux_mainline..."
	cp -LR "${root_dir}/linux/linux" "${root_dir}/linux/${KCONFIG_HASH}"
	echo "done."
fi

[ -d "./linux" ] && rm ./linux
[ ! -d "./linux" ] && ln -s "${root_dir}/linux/${KCONFIG_HASH}" ./linux
[ ! -f "./linux/.config" ] && wget -O "./linux/.config" \
	"https://syzkaller.appspot.com/text?tag=KernelConfig&x=${KCONFIG_HASH}"
[ ! -f "./reproducer.syz" ] && wget -O reproducer.syz \
	"https://syzkaller.appspot.com/text?tag=ReproSyz&x=${REPRODUCER_HASH}"
if [ ! -f "./linux/arch/x86/boot/bzImage" ]; then
	cd ./linux
	make clean
	make -j4
	cd ..
fi
if [ -f "./linux/arch/x86_64/boot/bzImage" ] && [ ! -f "./report.txt" ]; then
	./get_report.sh
	cat ./report.txt
fi
