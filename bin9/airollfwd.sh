#!/bin/sh
##############################################################################
#
# airollfwd.sh
#
# This shell rolls forward the after-image files that are located in AI/DATE
# by copying them to AI_APPLY dir, rolling forward and erasing AI_APPLY
#
# Parameters:
#
# $1 Warm spare database directory - REQUIRED
# $2 Warm spare database name - REQUIRED  SHOULD NOT INCLUDE THE .db EXTENSION
#
###############################################################################


AIDBDIR=$1

AIDBNAME=$2

RUNDATE=`/usr/bin/date "+%m/%d/%y %H:%M:%S"`

BKDATE=`/usr/bin/date "+%m-%d-%y`

AILOG=$DBDIR/log/ai.log

APPLYDIR=$AIAPPLY

export RUNDATE BKDATE AILOG AIDBDIR AIDBNAME APPLYDIR

###############################################################################

if [ $# -lt 2 ]
then
    echo "Insufficient number of parameters.  The syntax for this command is :"
    echo "$0 <directory> <db name> "
    exit -1
fi

if [ ! -d $AIDBDIR ]
then
    echo "The database directory does not exist.  Aborting AI Switch" >> $AILOG
    exit -1
fi

if [ ! -f $AIDBDIR/${AIDBNAME}.db ]
then
    echo $RUNDATE "Could not find the warmspare database " $AIDBNAME " in " $AIDBDIR ".  Aborting roll forward." >> $AILOG
    exit -1
fi

if [ ! -d $AIDIR ]
then
    echo "$RUNDATE The after image directory $AIDIR does not exist. Aborting." >> $AILOG
    exit -1
fi

if [ -f $AIDIR/.stop ]
then
    echo "$RUNDATE Cannot replicate AI files... Remove .stop from /ai directory!" >> $AILOG
    exit -1
fi
            
if [ ! -d $AIDIR/$BKDATE ]
then
   echo "$RUNDATE Creating directory $BKDATE" >> $AILOG
   mkdir $AIDIR/$BKDATE
fi

if [ ! -d $APPLYDIR ]
then
    echo $RUNDATE "The warm spare hold directory does not exist.  Aborting roll forward." >> $AILOG
    exit -1
fi

if [ -f $APPLYDIR/.stop ]
then
    echo $RUNDATE "airollfwd.sh [$2]: Cannot roll forward! Remove .stop file from apply directory!" >> $AILOG
    echo "airollfwd.sh [$2]: Cannot roll forward! Remove .stop file from apply directory!"
    exit 4
fi

if [ -f $APPLYDIR/.backup ]
then
    FILECONT=`cat $APPLYDIR/.backup`
    echo $RUNDATE "airollfwd.sh [$2]: Cannot roll forward! Need to restore backup." >> $AILOG
    echo $RUNDATE "You can run $FILECONT script and then remove .backup file from $APPLYDIR directory." >> $AILOG
    echo "airollfwd.sh [$2]: Cannot roll forward! Need to restore backup."
    echo "    Please, run script airestore.sh in order to continue!"
    echo "Or, you can run $FILECONT script and then remove .backup file"
    echo "    from $APPLYDIR directory."
    exit 5
fi
   
###############################################################

# Synchronize new file between servers and move new files to AI_APPLY_DIR
#
# - synchronizes AI_TO_DR directories
# - deletes copied files from remote AI_TO_DR dir
# - moves copied files to local AI_APPLY dir
#

# Check that previous roll forward process finished.
cd $APPLYDIR
if [ -f PROC_${AIDBNAME}* ]
then
  exit 1
fi

# Copy new AI files from primary server
$EXECDIR/aisync.sh

RETCODE=$?
if [ $RETCODE != 0 ]
then
    echo $RUNDATE "airollfwd.sh [$2]: Cannot roll forward! Synchronizing failed (Error = $RETCODE)" >> $AILOG
    exit $RETCODE
fi

   
#############################
# Main
#############################

AIAPPLIED=0

# Unzip files.
for AIFILE in `ls $AIDBNAME.*gz 2>/dev/null`
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
for AIFILE in `ls $AIDBNAME.* 2>/dev/null`
do
    if [ $AIFILE = *.gz ]
    then
      continue;
    fi
    mv $AIFILE PROC_$AIFILE
    echo "$RUNDATE Applying extent $AIFILE..." >> $AILOG
    $DLC/bin/rfutil $AIDBDIR/$AIDBNAME -C roll forward -a PROC_$AIFILE >> $AILOG
    if [ $? != 0 ]
    then
        echo $RUNDATE "ERROR.  Could not roll forward extent $AIDBNAME $AIFILE " >> $AILOG
        exit 3
    fi
    rm PROC_$AIFILE
    AIAPPLIED=`expr $AIAPPLIED + 1`
done

if [ ! $AIAPPLIED = 0 ]
then
    RUNDATE=`/usr/bin/date "+%m/%d/%y %H:%M:%S"`
    echo $RUNDATE $AIAPPLIED $AIDBNAME "extents applied to" $AIDBDIR/$AIDBNAME >> $AILOG
fi

