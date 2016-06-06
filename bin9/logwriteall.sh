#!/bin/sh
##############################################################################
#
# logwriteall.sh
#
# 1) Writes given database log files to special folder
# 2) Sorts log files by system date
#
###############################################################################


/pragma/bin9/logwrite.sh alm alm
/pragma/bin9/logwrite.sh alm alga

/pragma/bin9/logwrite.sh rkc rkc
/pragma/bin9/logwrite.sh rkc alga
