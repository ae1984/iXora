#!/bin/sh
##############################################################################
#
# aiswitch.sh
#
# This shell performs switches the after image file, copies it to the after
# image directory and to the warm spare hold directory.
#
# Parameters:
#
# $1 Database directory - REQUIRED
# $2 Database name - REQUIRED  SHOULD NOT INCLUDE THE .db EXTENSION
#
###############################################################################

AIDBDIR=$1

AIDBNAME=$2

RUNDATE=`date "+%m/%d/%y %H:%M:%S"`

BKDATE=`date "+%m-%d-%y"`

AILOG=$DBDIR/log/ai.log

DLC=/usr/dlc

export AIDIR AIDBDIR AIDBNAME RUNDATE BKDATE AILOG DLC

###############################################################################
# Let's check out all the parameters and make sure we've got valid information
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
    echo "$RUNDATE Could not find the database " $AIDBNAME " in " $AIDBDIR ".  Aborting AI switch" >> $AILOG
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

###############################################################################
# Check the database status.  If it's not 16 it means that it's not online.
# This is not an error condition, hence exit with a 0 code.
###############################################################################
#
#$DLC/bin/proutil $AIDBDIR/$AIDBNAME -C holder > /dev/null
#if [ $? != 16 ] 
#then
#    echo $RUNDATE "Server is not running for" $AIDBDIR/$AIDBNAME >> $AILOG
#    exit 0
#fi


#############################
# Step One: Copy the full after-image file(s) to the database's after
#           image file directory and mark them empty
#############################
$EXECDIR/aiswitch2.sh
RETCODE=$?
if [ $RETCODE != 0 ]
then
    exit $RETCODE
fi

#############################
# Step Two: Switch current AI
#############################
$DLC/bin/rfutil $AIDBDIR/$AIDBNAME -C aimage new > /dev/null
if [ $? != 0 ]
then
    echo $RUNDATE "ERROR!  Could not switch to a new AI extent" >> $AILOG
    exit 1
fi


#############################
# Step Three: Copy newly created full after-image file to the database's after
#             image file directory and mark it empty
#############################
$EXECDIR/aiswitch2.sh
RETCODE=$?
if [ $RETCODE != 0 ]
then
    exit $RETCODE
fi

