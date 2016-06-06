#!/bin/bash
#*************************************************************************
echo "Creating directory for " $1 " database..."
if [ -d /data/$1/ ]
then
	echo "Directory for database "$1" already exists";
else
mkdir /data/$1/
mkdir /data/$1/ai/
mkdir /data/$1/ai_apply/
mkdir /data/$1/alga/
mkdir /data/$1/alga/ai/
mkdir /data/$1/alga/ai_apply/
mkdir /data/$1/alga/backup/
mkdir /data/$1/alga/log/
mkdir /data/$1/backup/
mkdir /data/$1/export/
mkdir /data/$1/export/offpl/
mkdir /data/$1/export/dpk/
mkdir /data/$1/export/dpk/aki-a/
mkdir /data/$1/export/dpk/aki-q/
mkdir /data/$1/export/dpk/aki-script/
mkdir /data/$1/export/dpk/photos/
mkdir /data/$1/export/dpk/photos/5/
mkdir /data/$1/export/dpk/photos/6/
mkdir /data/$1/export/dpk/photos/7/
mkdir /data/$1/export/dpk/docs/
mkdir /data/$1/import/
mkdir /data/$1/import/aes/
mkdir /data/$1/import/asu/
mkdir /data/$1/import/offpl/
mkdir /data/$1/import/offpl/log/
mkdir /data/$1/log/
mkdir /data/$1/log/banklgarc/
mkdir /data/$1/log/clientmon/
mkdir /data/$1/log/procmon/
mkdir /data/$1/log/ps/
mkdir /data/$1/ps/
mkdir /data/$1/ps/DOC/
mkdir /data/$1/ps/LOG/
mkdir /data/$1/ps/MSG/
mkdir /data/$1/ps/NB/
mkdir /data/$1/ps/NB/arx/
mkdir /data/$1/ps/NB/IN/
mkdir /data/$1/ps/NB/IN/ARC/
mkdir /data/$1/ps/NB/OUT/
mkdir /data/$1/ps/NB/OUT/ARC/
mkdir /data/$1/ps/NB/OUT/EKS/
mkdir /data/$1/ps/NB/OUTG/
mkdir /data/$1/ps/NB/OUTG/ARC/
mkdir /data/$1/ps/NB/PSJ/
mkdir /data/$1/ps/NB/PSJ/ARC/
mkdir /data/$1/ps/NB/PSJ/ARCPNJ/
mkdir /data/$1/ps/NB/PSJ/IN/
mkdir /data/$1/ps/PS_ERR/
mkdir /data/$1/ps/PSJFILE/
mkdir /data/$1/ps/TRX_LOG/
mkdir /data/$1/onlinebkp/
mkdir /data/log/$1/
mkdir /savedb/$1/
mkdir /savedb/$1/bank/
mkdir /savedb/$1/bank/full/
mkdir /savedb/$1/alga/
mkdir /savedb/$1/alga/full/
mkdir /data/reports/push/$1/
mkdir /data/$1/log/logdayclose/
mkdir /data/$1/ps/NB/CRD/
mkdir /data/$1/ps/NB/CRD/IN/
mkdir /data/log/$1/
mkdir /data/log/$1/arc_log/
mkdir /data/log/$1/clientmon/
mkdir /data/log/$1/procmon/
mkdir /data/log/$1/procmon_arc/
mkdir /data/log/$1/ps/
mkdir /data/log/$1/ps/arc_log_ps/
mkdir /data/log/$1/ps/TRX_LOG/

echo "Directorys creation is ended."

chmod 0777 /data/$1/
chmod 0777 /data/$1/ai/
chmod 0777 /data/$1/ai_apply/
chmod 0777 /data/$1/alga/
chmod 0777 /data/$1/alga/ai/
chmod 0777 /data/$1/alga/ai_apply/
chmod 0777 /data/$1/alga/backup/
chmod 0777 /data/$1/alga/log/
chmod 0777 /data/$1/backup/
chmod 0777 /data/$1/export/
chmod 0777 /data/$1/export/offpl/
chmod 0777 /data/$1/export/dpk/
chmod 0777 /data/$1/export/dpk/aki-a/
chmod 0777 /data/$1/export/dpk/aki-q/
chmod 0777 /data/$1/export/dpk/aki-script/
chmod 0777 /data/$1/export/dpk/photos/
chmod 0777 /data/$1/export/dpk/photos/5/
chmod 0777 /data/$1/export/dpk/photos/6/
chmod 0777 /data/$1/export/dpk/photos/7/
chmod 0777 /data/$1/export/dpk/docs/
chmod 0777 /data/$1/import/
chmod 0777 /data/$1/import/aes/
chmod 0777 /data/$1/import/asu/
chmod 0777 /data/$1/import/offpl/
chmod 0777 /data/$1/import/offpl/log/
chmod 0777 /data/$1/log/
chmod 0777 /data/$1/log/banklgarc/
chmod 0777 /data/$1/log/clientmon/
chmod 0777 /data/$1/log/procmon/
chmod 0777 /data/$1/log/ps/
chmod 0777 /data/$1/ps/
chmod 0777 /data/$1/ps/DOC/
chmod 0777 /data/$1/ps/LOG/
chmod 0777 /data/$1/ps/MSG/
chmod 0777 /data/$1/ps/NB/
chmod 0777 /data/$1/ps/NB/arx/
chmod 0777 /data/$1/ps/NB/IN/
chmod 0777 /data/$1/ps/NB/IN/ARC/
chmod 0777 /data/$1/ps/NB/OUT/
chmod 0777 /data/$1/ps/NB/OUT/ARC/
chmod 0777 /data/$1/ps/NB/OUT/EKS/
chmod 0777 /data/$1/ps/NB/OUTG/
chmod 0777 /data/$1/ps/NB/OUTG/ARC/
chmod 0777 /data/$1/ps/NB/PSJ/
chmod 0777 /data/$1/ps/NB/PSJ/ARC/
chmod 0777 /data/$1/ps/NB/PSJ/ARCPNJ/
chmod 0777 /data/$1/ps/NB/PSJ/IN/
chmod 0777 /data/$1/ps/PS_ERR/
chmod 0777 /data/$1/ps/PSJFILE/
chmod 0777 /data/$1/ps/TRX_LOG/
chmod 0777 /data/$1/onlinebkp/
chmod 0777 /data/log/$1/
chmod 0777 /savedb/$1/
chmod 0777 /savedb/$1/bank/
chmod 0777 /savedb/$1/bank/full/
chmod 0777 /savedb/$1/alga/
chmod 0777 /savedb/$1/alga/full/
chmod 0777 /data/reports/push/$1/
chmod 0777 /data/$1/log/logdayclose/
chmod 0777 /data/$1/ps/NB/CRD/IN/
chmod 0777 /data/$1/ps/NB/CRD/
chmod 0777 /data/log/$1/
chmod 0777 /data/log/$1/arc_log/
chmod 0777 /data/log/$1/clientmon/
chmod 0777 /data/log/$1/procmon/
chmod 0777 /data/log/$1/procmon_arc/
chmod 0777 /data/log/$1/ps/
chmod 0777 /data/log/$1/ps/arc_log_ps/
chmod 0777 /data/log/$1/ps/TRX_LOG/
fi
#*************************************************************************

echo "Copying of the structured file /data/"$2"/bank.st to /data/"$1"/bank.st"; 
if [ -f /data/$2/bank.st ]
then
	cp /data/$2/bank.st /data/$1/bank.st
	chmod 0777 /data/$1/bank.st
	echo "Structured file is successfully copied to /data/"$1"/bank.st"
else
	echo "File /data/"$2"/bank.st not exists"
fi
#*************************************************************************
#echo "Creation database /data/$1/bank..."
#cd /data/$1/
#prostrct create /data/$1/bank /data/$1/bank.st -blocksize 8192
#procopy /home/bankadm/empty/empty8  /data/$1/bank

