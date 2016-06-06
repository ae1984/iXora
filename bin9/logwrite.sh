#!/bin/sh
##############################################################################
#
# logwrite.sh
#
# 1) Writes given database log files to special folder
# 2) Sorts log files by system date
#
###############################################################################


###############################################################################
# 1) Script parameters
###############################################################################

. /pragma/bin9/dbenv
. /pragma/bin9/aienv

RUNDATE=`/usr/bin/date "+%m/%d/%y %H:%M:%S"`
LOGDATE=`/usr/bin/date "+%m-%d-%y"`

ERRORFILE=/data/log/dblogger.log
TMPFILE=/data/temp/$DBID-$AIID-$LDBNAME-log-temp$$

export RUNDATE LOGDATE ERRORFILE TMPFILE

LOGHEAD=`echo $RUNDATE [$DBID] [$AIID]`
LOGFILE=$DBDIR/log/$LDBNAME-$LOGDATE.log

export LOGHEAD LOGFILE

###############################################################################
#  2) Lets check the given database and log directories
###############################################################################

if [ ! -d $DBDIR ]
then
    echo $LOGHEAD " The database directory [" $DBDIR "] does not exist.  Aborting logger" >> $ERRORFILE
    exit -1
fi

if [ ! -f $DBDIR/${LDBNAME}.db ]
then
    echo $LOGHEAD " Could not find the database " $LDBNAME " in " $DBDIR ".  Aborting logger." >> $ERRORFILE
    exit -2
fi

if [ ! -d $DBDIR/log ]
then
   mkdir $DBDIR/log
   chmod 750 $DBDIR/log
fi

if [ ! -f $DBDIR/${LDBNAME}.lg ]
then
    exit -3
fi

###############################################################################
#  3) Copy DB log file
###############################################################################


touch $TMPFILE
rm $TMPFILE 
RETCODE=$?
if [ $RETCODE != 0 ]
then
    echo $LOGHEAD " Failed to prepare temporary file [$TMPFILE]" >> $ERRORFILE
    exit -4
fi


mv $DBDIR/$LDBNAME.lg $TMPFILE
touch $DBDIR/$LDBNAME.lg
chmod 660 $DBDIR/$LDBNAME.lg
RETCODE=$?
if [ $RETCODE != 0 ]
then
    echo $LOGHEAD " Failed to move [$LDBNAME.lg] from [$DBDIR] to [$TMPFILE]" >> $ERRORFILE
    exit -5
fi

cat $TMPFILE >> $LOGFILE
RETCODE=$?
if [ $RETCODE != 0 ]
then
   echo $LOGHEAD " Failed to cat [$TMPFILE] to [$LOGFILE]"
   exit -6 
fi

cat $TMPFILE >> $DBDIR/log/$LDBNAME.log
RETCODE=$?
if [ $RETCODE != 0 ]
then
   echo $LOGHEAD " Failed to cat [$TMPFILE] to [$DBDIR/log/$LDBNAME.log]"
   exit -7
fi

rm $TMPFILE
RETCODE=$?
if [ $RETCODE != 0 ]
then
   echo $LOGHEAD " Failed to rm [$TMPFILE]"
   exit -8 
fi
   
