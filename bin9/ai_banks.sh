#!/bin/sh
   
#############################
# Main
#############################

AILOG=/data/log/ai-to-banks.log
AIAPPLIED=0
#RUNDATE=`/usr/bin/date "+%m/%d/%y %H:%M:%S"`
AIDB=$1
AIPATH=$2


# Unzip files.
for AIFILE in `ls $AIPATH/*.*gz 2>/dev/null`
do

#    cp $AIFILE $STOREDIR/$BKDATE
#    if [ $? != 0 ]
#    then
#        echo $RUNDATE $AIFILE "ERROR. Could not copy $AIFILE to $STOREDIR/$BKDATE." >> $AILOG
#        echo $RUNDATE $AIFILE "ERROR. Could not copy $AIFILE to $STOREDIR/$BKDATE."
#        exit 2
#    fi

    /usr/bin/gzip -d $AIFILE
    if [ $? != 0 ]
    then
        echo $RUNDATE "ERROR. Could not unzip $AIFILE." >> $AILOG
        exit 2
    fi
done

# Apply AI.
for AIFILE in `ls $AIPATH/* 2>/dev/null`
do
    if [ $AIFILE = *.gz ]
    then
      continue;
    fi
    mv $AIFILE PROC_TMP
    echo "$RUNDATE Applying extent $AIFILE..." | tee -a $AILOG
    $DLC/bin/rfutil $AIDB -C roll forward -a PROC_TMP >/dev/null
    if [ $? != 0 ]
    then
        echo $RUNDATE "ERROR.  Could not roll forward extent $AIDBNAME $AIFILE " >> $AILOG
        exit 3
    fi
    rm PROC_TMP
    AIAPPLIED=`expr $AIAPPLIED + 1`
    $DLC/bin/_rfutil $DBDIR/$DBNAME -C aimage begin
done

if [ ! $AIAPPLIED = 0 ]
then
    RUNDATE=`/usr/bin/date "+%m/%d/%y %H:%M:%S"`
    echo $RUNDATE $AIAPPLIED "extents applied to" $AIDB >> $AILOG
fi