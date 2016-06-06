#!/bin/sh
#проверка статуса выполнения аудита за определенную дату id00477 (c)

echo "Введите дату для проверки в формате yyyymmdd"
echo "например: `date +%Y%m%d`"
read TIME
clear
date +%Y-%m-%d
for i in `echo "bmkb balm bakt bkos btrz burl bkar bsem bkok bast bpet batr bpav bust bzes bchm baku comm"`
do
	BAOMM="bank"
	if [ "$i" = "comm" ]; then
		BAOMM="comm"
	fi	
	
	echo -n "$i "
	tail -1 /savedb/$i/auditing/$TIME/auditbck.log

done