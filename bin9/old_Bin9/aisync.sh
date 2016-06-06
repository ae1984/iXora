#!/bin/sh

RUNDATE=`/usr/bin/date "+%m/%d/%y %H:%M:%S"`

AILOG=$DBDIR/log/ai.log

export AIDIR RUNDATE AILOG

##################################################################

echo $RUNDATE "Synchronizing files between servers..." >> $AILOG

/usr/local/rsync/bin/rsync -rtqR --exclude ".stop" --exclude ".backup" --include "*" $AIREPLFROM::$AIRSYNC /data/ 2>> $AILOG >> $AILOG

RETCODE=$?
if [ $RETCODE != 0 ]
then
    echo $RUNDATE "RSYNC FAILED" >> $AILOG
    exit 1
fi

##################################################################

echo $RUNDATE "Copying new files from $AIDIR to $AIAPPLY" >> $AILOG

touch $DBDIR/$LDBNAME.ai_list

find $AIDIR/ -type f > $DBDIR/$LDBNAME.ainew

F_LIST=`diff $DBDIR/$LDBNAME.ai_list $DBDIR/$LDBNAME.ainew | awk '/>/ {print $2}'`

for FNAME in $F_LIST
do
    cp $FNAME $AIAPPLY
    RETCODE=$?
    if [ $RETCODE != 0 ]
    then
        echo $RUNDATE "COPY TO APPLY DIR FAILED" >> $AILOG
        exit 2
    fi
done

rm -f $DBDIR/$LDBNAME.ai_list
mv $DBDIR/$LDBNAME.ainew $DBDIR/$LDBNAME.ai_list

exit 0

