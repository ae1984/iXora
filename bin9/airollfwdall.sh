#!/bin/sh
##############################################################################
#
# airollfwdall.sh
#
# This shell script runs rolls forward procedure for all databases
#
# Syntax: airollfwd.sh database-directory database-name
#
# Example: airollfwdall.sh alm alm
# Example: airollfwdall.sh alm sklad
# Example: airollfwdall.sh alm cards 
#
##############################################################################

. /pragma/bin9/dbenv
. /pragma/bin9/aienv

$EXECDIR/airollfwd.sh $DBDIR $LDBNAME
