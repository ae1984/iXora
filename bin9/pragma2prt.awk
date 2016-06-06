#!/bin/bash
cat $1 | awk '

    function todig(amt) {
        dCnt = split (amt, decim, ".");
        pCnt = split (decim[1], parts, ",");
        char Sum;
        Sum = "";
        for (i = 1; i <= pCnt; i++)
            Sum = Sum "" parts[i];
        Sum = Sum "." decim[2];
        return Sum;
    }
    
    BEGIN {
        print " ";
        print "                                    Merchant Statement By Period";
        RDT = "";
        TYPESTR = "-------------------------------------------------------------------------------------";
        CCURR = "";
        CCONT = ""

        HFORMAT = "%-10s %-16s %-18s %-15s %-10s %-15s %s\n"
        
        
        FORMAT =  "%10s %16s %-18s %15.2f %10.2f %15.2f %s\n";
        TFORMAT =            "%46s %15.2f %10.2f %15.2f %s\n"

        TAMNT = 0;
        TDISC = 0;
        TTOTL = 0;
    }

    NR == 2 {
        RDT = $1;
    }

    NR > 2 {
        CURR = $0;
        getline;
        CONT = $0;
        getline;
        TRDT = $0;
        getline;
        CARD = $0;
        getline;
        AUTH = $0;
        getline;
        NAME = $0;
        getline;
        AMNT = todig($0);
        getline;
        DISC = todig($0);
        getline;
        TOTL = todig($0);
        getline;
        DEVS = $0;

        if ((CCURR != CURR) || (CCONT != CONT) || (CCURR == "") || (CCONT == "")) {
            if (CCONT != "") {
                print "--------------------------------------------------------------------------------------------------------------";
                printf(TFORMAT, "Всего:", TAMNT, TDISC, TTOTL, "");
                TAMNT = 0;
                TDISC = 0;
                TTOTL = 0;
            }

            CCURR = CURR;
            CCONT = CONT;
            

            print "";
            print "";
            print "                                      " RDT " - " RDT;
#            print "                                             !!!!!!!!!!";
            print "";
            print "--------------------------------------------------------------------------------------------------------------";
            print "   Валюта : " CURR "                Контракт : " CONT;
            print "--------------------------------------------------------------------------------------------------------------";
            printf(HFORMAT, "Дата", "Номер карты", "Описание", "Сумма", "Комиссия", "К зачислению", "Устройство");
            print "";
        }
        printf(FORMAT, TRDT, CARD, substr(NAME, 1, 18), AMNT, DISC, TOTL, DEVS);
        TAMNT = TAMNT + todig(AMNT);
        TDISC = TDISC + todig(DISC);
        TTOTL = TTOTL + todig(TOTL);

    
    }
    
    END {
        if (NR > 3) {
            print "--------------------------------------------------------------------------------------------------------------";
            printf(TFORMAT, "Всего:", TAMNT, TDISC, TTOTL, "");
        }
        print ""; print ""; print ""; 
        print "                                     End Of Merchant Statement";
    }

'
