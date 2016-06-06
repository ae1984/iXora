#!/bin/sh
# gather -- get statistics out of PROMON without user interaction
# gather takes two arguments, the database name and the name of a
# file to place the output.
#
# This version gathers the interesting sar data during the same
# interval output is placed in the file named in the third argument
# If this option is not available or you want to use vmstat instead
# please comment out the sar line and substitute the appropriate line.
#
# syntax:     gather dbname mon.out sar.out
#
# where
#       dbname is the name of the database
#       mon.out is the name of the file to capture the PROMON output
#       sar.out is the name of the file to capture the sar outputt
#
# gather reads the file gather.answers for input to PROMON
# gather.answers has the following fields:
#
#m   /* this goes into the modify defaults screen */
#1   /* change screen size */
#50  /* the new screen size set large enough to handle all users */
#q   /* return to main menu */
#1   /* user control screen */
#1   /* display all */
#q   /* return to menu */
#R&D /* go to R&D section of PROMON */
#5   /* change screen size */
#1
#50
#p
#1   /* active transactions */
#4
#3
#p
#2   /* blocked clients */
#p
#p
#p
#2   /* other activity */
#1  /* activity summary */
#p
#5 /* BI log */
#p
#13 /* activity other */
#s
#p
#7  /* lock table */
#s
#p
#p
#3  /* i/o operations by process */
#2
#p
#4  /* checkpoints */
#p
#p
#3  /* i/o operations by process again */
#2
#p
#p
#debghb /* debug section */
#6
#8  /* resource queues */
#s
#p
#9  /* latch counts */
#s
#x
promon $1 >> $2 < /pragma/bin9/gather.answers;
# *** END of gather script ***

