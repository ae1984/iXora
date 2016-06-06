#!/bin/bash
#*************************************************************************

#*************************************************************************
echo "Creation database /data/$1/bank..."
cd /data/$1/
prostrct create bank -blocksize 8192


#echo "Copy empty database /data/$1/bank..."
#procopy /home/bankadm/empty/empty8  /data/9/$1/bank

dbrest /data/$1/bank /savedb/etalon_fil/bank0.Z $1
