#!/bin/sh
##############################################################################
#
# aisyncall.sh
#
# Synchronize all AI files for the specified database
#
##############################################################################

. /pragma/bin9/dbenv
. /pragma/bin9/aienv

$EXECDIR/aisync.sh
