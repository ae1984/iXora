#!/bin/sh
######################################################
#
# aiswitch2.sh
#
# This shell performs switches the after image file
# and copies it to the AI/RUNDATE/ directory
#
######################################################

while :
do
    # Get the oldest full AI file

    AIFILE=`$DLC/bin/rfutil $AIDBDIR/$AIDBNAME -C aimage extent full| grep $AIDBNAME`
    if [ $AIFILE ] 
    then 
    
        echo $RUNDATE "Replicating file $AIFILE" >> $AILOG
        
        # Copy the AI file to the replication directory
        TS=`date "+%y%m%d%H%M%S"`
        /usr/bin/gzip -c1 $AIFILE > $AIDIR/$BKDATE/${AIDBNAME}.${TS}.gz
#        if [ $LDBNAME = "bank" ]; then 
#            cp $AIDIR/$BKDATE/${AIDBNAME}.${TS}.gz $AIDBDIR/stat/data/ai
#        fi
        if [ $? != 0 ]
        then
            echo $RUNDATE $AIDBDIR $AIDBNAME "AIERROR.  Could not zip the full AI extent $AIFILE to $AIDIR/$BKDATE/${AIDBNAME}.${TS}.gz" >> $AILOG
            exit 2
        fi

        # Mark the full AI extent as empty
        $DLC/bin/rfutil $AIDBDIR/$AIDBNAME -C aimage extent empty >> $AILOG
        if [ $? != 0 ]
        then
            echo $RUNDATE $AIDBDIR $AIDBNAME "AIERROR.  Could not mark the AI extent as empty. Code = " $? >> $AILOG
 	    $DLC/bin/rfutil $AIDBDIR/$AIDBNAME -C aimage list >> $AILOG 	
            exit 1
        fi
        sleep 1
    else
        exit 0
    fi
done

