#!/bin/bash
cat $1 | win2koi | tr '\015' '\012' | tr -d '\014' | awk '

    function summ(asd) {
        return asd;
    }
    
    BEGIN {
        STATYPE = "";
        CONT = "";
        REGDT = "";
        NAME = "";
        KZT = 0;
        DEVICE = "";
        print "001";# " (-1"; # 001 - HSBK, 005 - ABN AMRO
    }

    NR == 43 {
        STATYPE = $4;
    }

    NR == 49 {
        REGDT = $3;
        print REGDT;# " (0";
    }

    /Office/ {
        for (i = 1; i <= NF; i++) {
            if ($i == "Office:") {
                break;
            }
        }
        NAME = "";
        for (j = 1; j < i; j++) {
            NAME = NAME " " $j
        }
        NAME = substr(NAME, 2, length(NAME) - 1);
        getline;
        getline;
        getline;
        CONT = substr($NF,3,14);
#        print "NAME = " NAME;
#        print "CONT = " CONT;
    }

    /KZT|USD/ {
        CRC = $2;
        DEV = $4;
        while($1 != "TOTAL" ) {
            getline;
            if (NF == 7 && substr($1,1,1) != "-" ) {
                print CRC;
                print CONT;
                print $1;
                print $2;
                print $3;
                print NAME;
                print $5;
                print $6;
                print $7;
                print DEV;
            }
        }
        
    }
'

