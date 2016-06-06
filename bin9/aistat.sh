#!/bin/sh
#
# aistat - ai note statistics

if [ $# -ne 2 ]; then 
  echo "Usage: $0 db-name ai-file" >&2
  exit 1
fi

Db=$1
Ai=$2

rfutil $Db -C aimage scan verbose -a $Ai | \
awk '
#code = <name> (1637)
  $NF=="\(1637\)" {
    NoteName=$3
    next
  }

#transaction index = <number> (1638)
  $NF=="\(1638\)" {
    TranID=$(NF-1)
    TranID=sprintf("%9d", TranID)
    NoteID=TranID " " sprintf("%-12s",NoteName)
    i=NoteCount[NoteID]
    NoteCount[NoteID]=i+1
    next
  }

#Trid: <num> <time>. (2598)
#Trid: 1651 Wed Nov  5 14:38:27 2003. (2598)
  $NF=="\(2598\)" {
    TranTime[TranID]=$(NF-2)
    next
  }

#User Id: <name>. (2599)
  $NF=="\(2599\)" {
    TranUser[TranID]=$(NF-1)
    next
  }

#dbkey = <dbkey>   update counter = <number> (1639)
  $NF=="\(1639\)" {next} # ignore it.

#area = <area>   dbkey = <dbkey>   update counter = <number> (9016)
  $NF=="\(9016\)" {next} # ignore it.

  END {
   for(TranID in TranTime) {
    Time=TranTime[TranID]
    User=TranUser[TranID]
    printf "%s  Time: %s, User: %s\n", TranID, Time, User
   }

   for(NoteID in NoteCount) {
    Count=NoteCount[NoteID]
    printf "%s %9d\n", NoteID, Count
   }
  } # END
'
