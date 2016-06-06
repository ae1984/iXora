#!/bin/sh
##############################################################################
#
# aiswitchall.sh
#
# This shell script runs aiswitch.sh for all databases that needed.
#
# Syntax: aiswitch.sh database-directory database-name
#
##############################################################################

. /pragma/bin9/dbenv
. /pragma/bin9/aienv

$EXECDIR/aiswitch.sh $DBDIR $LDBNAME

